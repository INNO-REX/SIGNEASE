defmodule SigneaseWeb.Admin.RoleAssignmentsLive do
  use SigneaseWeb, :live_view

  alias Signease.Roles
  alias Signease.Accounts
  alias Signease.Accounts.User

  @impl true
  def mount(params, session, socket) do
    # Get current user from session or URL params
    current_user = get_current_user(session, params)

    # Check if user has permission to manage role assignments
    unless has_role_permission?(current_user, "user_mgt", "edit") do
      {:ok, push_navigate(socket, to: "/admin/dashboard")}
    else
      socket = assign(socket,
        current_user: current_user,
        current_page: "role_assignments",
        page_title: "Role Assignments - SignEase",
        users: Accounts.list_users(),
        roles: Roles.get_active_roles(),
        selected_user: nil,
        show_assign_modal: false,
        changeset: User.changeset(%User{}, %{}),
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
  def handle_event("show-assign-modal", %{"id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    changeset = User.changeset(user, %{})
    {:noreply, assign(socket, show_assign_modal: true, selected_user: user, changeset: changeset)}
  end

  @impl true
  def handle_event("hide-assign-modal", _params, socket) do
    {:noreply, assign(socket, show_assign_modal: false, selected_user: nil)}
  end

  @impl true
  def handle_event("update-role-assignment", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "updated_by", socket.assigns.current_user.id)

    case Accounts.update_user(socket.assigns.selected_user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> assign(show_assign_modal: false, selected_user: nil, users: Accounts.list_users())
         |> put_flash(:info, "Role assignment updated successfully.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("bulk-assign-role", %{"role_id" => role_id, "user_ids" => user_ids}, socket) do
    _role = Roles.get_user_role!(role_id)

    results = Enum.map(user_ids, fn user_id ->
      user = Accounts.get_user!(user_id)
      Accounts.update_user(user, %{role_id: role_id, updated_by: socket.assigns.current_user.id})
    end)

    success_count = Enum.count(results, fn {status, _} -> status == :ok end)
    error_count = length(results) - success_count

    flash_message = case {success_count, error_count} do
      {0, _} -> "Failed to assign role to any users."
      {_, 0} -> "Successfully assigned role to #{success_count} users."
      _ -> "Assigned role to #{success_count} users. #{error_count} assignments failed."
    end

    flash_type = if error_count == 0, do: :info, else: :warning

    {:noreply,
     socket
     |> assign(users: Accounts.list_users())
     |> put_flash(flash_type, flash_message)}
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
    # For now, allow super admin and admin to manage role assignments
    # In a real implementation, you'd check the actual permissions
    user.user_role in ["SUPER_ADMIN", "ADMIN"]
  end

  defp get_user_role_name(user) do
    case user.role_id do
      nil -> "No Role Assigned"
      role_id ->
        case Roles.get_user_role(role_id) do
          nil -> "Unknown Role"
          role -> role.name
        end
    end
  end

  defp get_user_status_badge(user) do
    case user.status do
      "ACTIVE" -> {"bg-green-100 text-green-800", "Active"}
      "PENDING_APPROVAL" -> {"bg-yellow-100 text-yellow-800", "Pending"}
      "INACTIVE" -> {"bg-red-100 text-red-800", "Inactive"}
      _ -> {"bg-gray-100 text-gray-800", user.status}
    end
  end
end
