defmodule SigneaseWeb.Admin.RolesLive do
  use SigneaseWeb, :live_view

  alias Signease.Roles
  alias Signease.Roles.UserRole
  alias Signease.Accounts

  @impl true
  def mount(params, session, socket) do
    # Get current user from session or URL params
    current_user = get_current_user(session, params)

    # Check if user has permission to manage roles
    unless has_role_permission?(current_user, "role_mgt", "view") do
      {:ok, push_navigate(socket, to: "/admin/dashboard")}
    else
      socket = assign(socket,
        current_user: current_user,
        current_page: "roles",
        page_title: "Role Management - SignEase",
        roles: Roles.list_user_roles(),
        selected_role: nil,
        show_edit_modal: false,
        show_delete_modal: false,
        show_permissions_modal: false,
        changeset: UserRole.changeset(%UserRole{}, %{}),
        permissions: get_default_permissions(),
        stats: %{
          total_users: Accounts.get_total_users_count(),
          total_roles: Roles.get_total_roles_count(),
          pending_approvals: Accounts.get_pending_approval_users_count()
        }
      )

      {:ok, socket}
    end
  end



  @impl true
  def handle_event("show-edit-modal", %{"id" => id}, socket) do
    role = Roles.get_user_role!(id)
    changeset = UserRole.changeset(role, %{})
    {:noreply, assign(socket, show_edit_modal: true, selected_role: role, changeset: changeset)}
  end

  @impl true
  def handle_event("hide-edit-modal", _params, socket) do
    {:noreply, assign(socket, show_edit_modal: false, selected_role: nil)}
  end

  @impl true
  def handle_event("show-delete-modal", %{"id" => id}, socket) do
    role = Roles.get_user_role!(id)
    {:noreply, assign(socket, show_delete_modal: true, selected_role: role)}
  end

  @impl true
  def handle_event("hide-delete-modal", _params, socket) do
    {:noreply, assign(socket, show_delete_modal: false, selected_role: nil)}
  end

  @impl true
  def handle_event("show-permissions-modal", %{"id" => id}, socket) do
    role = Roles.get_user_role!(id)
    permissions = Roles.get_role_permissions(role)
    permissions = atomize_keys(permissions)
    {:noreply, assign(socket, show_permissions_modal: true, selected_role: role, permissions: permissions)}
  end

  @impl true
  def handle_event("hide-permissions-modal", _params, socket) do
    {:noreply, assign(socket, show_permissions_modal: false, selected_role: nil)}
  end



  @impl true
  def handle_event("update-role", %{"user_role" => role_params}, socket) do
    role_params = Map.put(role_params, "updated_by", socket.assigns.current_user.id)

    case Roles.update_user_role(socket.assigns.selected_role, role_params) do
      {:ok, _role} ->
        {:noreply,
         socket
         |> assign(show_edit_modal: false, selected_role: nil, roles: Roles.list_user_roles())
         |> put_flash(:info, "Role updated successfully.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("delete-role", _params, socket) do
    case Roles.delete_user_role(socket.assigns.selected_role) do
      {:ok, _role} ->
        {:noreply,
         socket
         |> assign(show_delete_modal: false, selected_role: nil, roles: Roles.list_user_roles())
         |> put_flash(:info, "Role deleted successfully.")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> assign(show_delete_modal: false, selected_role: nil)
         |> put_flash(:error, "Cannot delete role. It may be assigned to users.")}
    end
  end

  @impl true
  def handle_event("update-permissions", %{"permissions" => permissions}, socket) do
    # Convert string keys to atoms for the permissions map
    permissions = convert_permissions_to_atoms(permissions)

    case Roles.update_role_permissions(socket.assigns.selected_role, permissions) do
      {:ok, _role} ->
        {:noreply,
         socket
         |> assign(show_permissions_modal: false, selected_role: nil, roles: Roles.list_user_roles())
         |> put_flash(:info, "Permissions updated successfully.")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> assign(show_permissions_modal: false, selected_role: nil)
         |> put_flash(:error, "Failed to update permissions.")}
    end
  end

  @impl true
  def handle_event("toggle-permission", %{"module" => module, "action" => action, "type" => type}, socket) do
    permissions = socket.assigns.permissions
    current_value = get_in(permissions, [String.to_atom(type), String.to_atom(module), String.to_atom(action)]) || false
    new_value = !current_value

    updated_permissions = put_in(permissions, [String.to_atom(type), String.to_atom(module), String.to_atom(action)], new_value)

    {:noreply, assign(socket, permissions: updated_permissions)}
  end

  @impl true
  def handle_event("toggle-all-permissions", %{"module" => module, "type" => type, "value" => value}, socket) do
    permissions = socket.assigns.permissions
    module_atom = String.to_atom(module)
    type_atom = String.to_atom(type)
    value_bool = value == "true"

    # Get all actions for this module
    module_permissions = get_in(permissions, [type_atom, module_atom]) || %{}

    # Update all actions for this module
    updated_module_permissions = Map.new(module_permissions, fn {action, _} -> {action, value_bool} end)
    updated_permissions = put_in(permissions, [type_atom, module_atom], updated_module_permissions)

    {:noreply, assign(socket, permissions: updated_permissions)}
  end

  # Private functions

  defp get_current_user(session, params) do
    # Try to get user_id from URL params first, then from session
    user_id = params["user_id"] || session["user_id"]

    case user_id do
      nil ->
        # Default admin for development when no session or params
        %{
          id: 2,
          first_name: "System",
          last_name: "Admin",
          email: "admin@signease.com",
          user_type: "ADMIN",
          user_role: "ADMIN"
        }
      user_id ->
        case Accounts.get_user(user_id) do
          nil ->
            %{
              id: 2,
              first_name: "System",
              last_name: "Admin",
              email: "admin@signease.com",
              user_type: "ADMIN",
              user_role: "ADMIN"
            }
          user ->
            admin_type = case user.role_id do
              1 -> "SUPER_ADMIN"
              2 -> "ADMIN"
              _ -> "ADMIN"
            end

            %{
              id: user.id,
              first_name: user.first_name,
              last_name: user.last_name,
              email: user.email,
              user_type: user.user_type,
              user_role: admin_type
            }
        end
      _ ->
        %{
          id: 2,
          first_name: "System",
          last_name: "Admin",
          email: "admin@signease.com",
          user_type: "ADMIN",
          user_role: "ADMIN"
        }
    end
  end

  defp has_role_permission?(user, _module, _action) do
    # For now, allow super admin and admin to manage roles
    # In a real implementation, you'd check the actual permissions
    user.user_role in ["SUPER_ADMIN", "ADMIN"]
  end

  defp get_default_permissions do
    %{
      backend: %{
        dashboard: %{view: false, edit: false, delete: false},
        user_mgt: %{view: false, create: false, edit: false, delete: false, approve: false, reject: false},
        role_mgt: %{view: false, create: false, edit: false, delete: false},
        course_mgt: %{view: false, create: false, edit: false, delete: false, publish: false},
        speech_to_text: %{view: false, create: false, edit: false, delete: false, configure: false},
        sign_language: %{view: false, create: false, edit: false, delete: false, configure: false},
        accessibility: %{view: false, create: false, edit: false, delete: false, configure: false},
        qa_system: %{view: false, create: false, edit: false, delete: false, moderate: false},
        analytics: %{view: false, export: false, configure: false},
        settings: %{view: false, edit: false, configure: false},
        system_mgt: %{view: false, edit: false, configure: false, backup: false, restore: false}
      },
      frontend: %{
        dashboard: %{view: false, edit: false, delete: false},
        user_mgt: %{view: false, create: false, edit: false, delete: false, approve: false, reject: false},
        role_mgt: %{view: false, create: false, edit: false, delete: false},
        course_mgt: %{view: false, create: false, edit: false, delete: false, publish: false},
        speech_to_text: %{view: false, create: false, edit: false, delete: false, configure: false},
        sign_language: %{view: false, create: false, edit: false, delete: false, configure: false},
        accessibility: %{view: false, create: false, edit: false, delete: false, configure: false},
        qa_system: %{view: false, create: false, edit: false, delete: false, moderate: false},
        analytics: %{view: false, export: false, configure: false},
        settings: %{view: false, edit: false, configure: false},
        system_mgt: %{view: false, edit: false, configure: false, backup: false, restore: false}
      }
    }
  end

  defp convert_permissions_to_atoms(permissions) do
    # Convert the permissions map from string keys to atom keys
    permissions
    |> Enum.map(fn {type, modules} ->
      {String.to_atom(type),
       Enum.map(modules, fn {module, actions} ->
         {String.to_atom(module),
          Enum.map(actions, fn {action, value} ->
            {String.to_atom(action), value == "true"}
          end) |> Map.new()}
       end) |> Map.new()}
    end) |> Map.new()
  end

  defp atomize_keys(map) when is_map(map) do
    for {k, v} <- map, into: %{} do
      key = if is_binary(k), do: String.to_atom(k), else: k
      value = if is_map(v), do: atomize_keys(v), else: v
      {key, value}
    end
  end

  @impl true
  def handle_info({:role_created, :ok}, socket) do
    {:noreply, assign(socket, roles: Roles.list_user_roles())}
  end
end
