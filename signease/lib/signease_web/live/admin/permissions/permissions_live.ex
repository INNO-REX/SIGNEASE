defmodule SigneaseWeb.Admin.Permissions.PermissionsLive do
  use SigneaseWeb, :live_view

  alias Signease.Accounts
  alias Signease.Roles

  @impl true
  def mount(params, session, socket) do
    # Get current user from session or URL params
    current_user = get_current_user(session, params)

    # Check if user has permission to view permissions
    if has_permission?(current_user, "permissions", "view") do
      # Get all roles with their permissions
      roles = Roles.list_user_roles_with_permissions()

      # Get the first role as default selected role
      selected_role = List.first(roles)

      socket = assign(socket,
        current_user: current_user,
        roles: roles,
        selected_role: selected_role,
        current_page: "permissions",
        page_title: "Permissions Management - SignEase",
        stats: get_permissions_stats()
      )

      {:ok, socket}
    else
      {:ok,
       socket
       |> put_flash(:error, "You don't have permission to access this page.")
       |> push_navigate(to: "/admin/dashboard")}
    end
  end

  @impl true
  def handle_event("refresh-permissions", _params, socket) do
    roles = Roles.list_user_roles_with_permissions()
    {:noreply, assign(socket, roles: roles)}
  end

      @impl true
  def handle_event("toggle-permission", %{"module" => module, "action" => action, "type" => type}, socket) do
    # Use the selected role instead of role-id parameter
    role = socket.assigns.selected_role
        # Get current permissions
        current_rights = role.rights || %{}

        # Determine the permission path based on type and module
        {type_key, _permission_path} = case type do
          "Backend Services" -> {"backend", [module, action]}
          "Frontend Interface" -> {"frontend", [module, action]}
          _ -> {type, [module, action]}
        end

        # Ensure the nested structure exists
        current_rights = Map.put_new(current_rights, type_key, %{})
        type_rights = Map.put_new(current_rights[type_key], module, %{})

        # Get current permission value
        current_value = Map.get(type_rights[module], action, false)

        # Toggle the permission
        new_value = !current_value

        # Update the permissions map
        updated_module_rights = Map.put(type_rights[module], action, new_value)
        updated_type_rights = Map.put(type_rights, module, updated_module_rights)
        updated_rights = Map.put(current_rights, type_key, updated_type_rights)

        # Save to database
        case Roles.update_role_permissions(role, updated_rights) do
          {:ok, _updated_role} ->
            # Refresh the roles data
            updated_roles = Roles.list_user_roles_with_permissions()
            # Update both roles list and selected role
            updated_selected_role = Enum.find(updated_roles, fn r -> r.id == role.id end)

            {:noreply,
             socket
             |> assign(roles: updated_roles, selected_role: updated_selected_role)
             |> put_flash(:info, "Permission #{if new_value, do: "enabled", else: "disabled"} successfully")}

          {:error, _changeset} ->
            {:noreply, put_flash(socket, :error, "Failed to update permission")}
        end
  end

  @impl true
  def handle_event("bulk-update-permissions", %{"role-id" => _role_id, "permissions" => _permissions}, socket) do
    # TODO: Implement bulk permission update logic
    {:noreply, put_flash(socket, :info, "Bulk permission update functionality coming soon!")}
  end

  @impl true
  def handle_event("switch-role", %{"role-id" => role_id}, socket) do
    role_id = String.to_integer(role_id)

    case Enum.find(socket.assigns.roles, fn role -> role.id == role_id end) do
      nil ->
        {:noreply, put_flash(socket, :error, "Role not found")}

      selected_role ->
        {:noreply, assign(socket, selected_role: selected_role)}
    end
  end

  @impl true
  def handle_event("select-all-backend", _params, socket) do
    # Use the selected role instead of first role
    role = socket.assigns.selected_role
    current_rights = role.rights || %{}

    # Add all backend permissions
    updated_rights = Map.put(current_rights, "backend", %{
      "dashboard" => %{"view" => true, "edit" => true, "delete" => true},
      "user_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "approve" => true, "reject" => true},
      "role_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true},
      "course_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "publish" => true},
      "speech_to_text" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
      "sign_language" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
      "accessibility" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
      "qa_system" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "moderate" => true},
      "analytics" => %{"view" => true, "export" => true, "configure" => true},
      "settings" => %{"view" => true, "edit" => true, "configure" => true},
      "system_mgt" => %{"view" => true, "edit" => true, "configure" => true, "backup" => true, "restore" => true}
    })

    case Roles.update_role_permissions(role, updated_rights) do
      {:ok, _updated_role} ->
        updated_roles = Roles.list_user_roles_with_permissions()
        # Update both roles list and selected role
        updated_selected_role = Enum.find(updated_roles, fn r -> r.id == role.id end)

        {:noreply,
         socket
         |> assign(roles: updated_roles, selected_role: updated_selected_role)
         |> put_flash(:info, "All backend permissions enabled for #{role.name}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update permissions")}
    end
  end

  @impl true
  def handle_event("select-all-frontend", _params, socket) do
    # Use the selected role instead of first role
    role = socket.assigns.selected_role
    current_rights = role.rights || %{}

    # Add all frontend permissions
    updated_rights = Map.put(current_rights, "frontend", %{
      "dashboard" => %{"view" => true, "edit" => true, "delete" => true},
      "user_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "approve" => true, "reject" => true},
      "role_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true},
      "course_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "publish" => true},
      "speech_to_text" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
      "sign_language" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
      "accessibility" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
      "qa_system" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "moderate" => true},
      "analytics" => %{"view" => true, "export" => true, "configure" => true},
      "settings" => %{"view" => true, "edit" => true, "configure" => true},
      "system_mgt" => %{"view" => true, "edit" => true, "configure" => true, "backup" => true, "restore" => true}
    })

    case Roles.update_role_permissions(role, updated_rights) do
      {:ok, _updated_role} ->
        updated_roles = Roles.list_user_roles_with_permissions()
        # Update both roles list and selected role
        updated_selected_role = Enum.find(updated_roles, fn r -> r.id == role.id end)

        {:noreply,
         socket
         |> assign(roles: updated_roles, selected_role: updated_selected_role)
         |> put_flash(:info, "All frontend permissions enabled for #{role.name}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update permissions")}
    end
  end

  @impl true
  def handle_event("select-all-module", %{"module" => module, "type" => type}, socket) do
    # Use the selected role instead of first role
    role = socket.assigns.selected_role
    current_rights = role.rights || %{}

    # Determine the type key
    type_key = case type do
      "Backend Services" -> "backend"
      "Frontend Interface" -> "frontend"
      _ -> type
    end

    # Get all permissions for this module
    module_permissions = get_module_permissions(module)

    # Update the permissions for this specific module
    type_rights = Map.get(current_rights, type_key, %{})
    updated_type_rights = Map.put(type_rights, module, module_permissions)
    updated_rights = Map.put(current_rights, type_key, updated_type_rights)

    case Roles.update_role_permissions(role, updated_rights) do
      {:ok, _updated_role} ->
        updated_roles = Roles.list_user_roles_with_permissions()
        # Update both roles list and selected role
        updated_selected_role = Enum.find(updated_roles, fn r -> r.id == role.id end)

        {:noreply,
         socket
         |> assign(roles: updated_roles, selected_role: updated_selected_role)
         |> put_flash(:info, "All #{module} permissions enabled for #{role.name}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update permissions")}
    end
  end

  @impl true
  def handle_event("select-all-permissions", _params, socket) do
    # Use the selected role instead of first role
    role = socket.assigns.selected_role

    # Set all permissions to true
    all_permissions = %{
      "backend" => %{
        "dashboard" => %{"view" => true, "edit" => true, "delete" => true},
        "user_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "approve" => true, "reject" => true},
        "role_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true},
        "course_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "publish" => true},
        "speech_to_text" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
        "sign_language" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
        "accessibility" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
        "qa_system" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "moderate" => true},
        "analytics" => %{"view" => true, "export" => true, "configure" => true},
        "settings" => %{"view" => true, "edit" => true, "configure" => true},
        "system_mgt" => %{"view" => true, "edit" => true, "configure" => true, "backup" => true, "restore" => true}
      },
      "frontend" => %{
        "dashboard" => %{"view" => true, "edit" => true, "delete" => true},
        "user_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "approve" => true, "reject" => true},
        "role_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true},
        "course_mgt" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "publish" => true},
        "speech_to_text" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
        "sign_language" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
        "accessibility" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true},
        "qa_system" => %{"view" => true, "create" => true, "edit" => true, "delete" => true, "moderate" => true},
        "analytics" => %{"view" => true, "export" => true, "configure" => true},
        "settings" => %{"view" => true, "edit" => true, "configure" => true},
        "system_mgt" => %{"view" => true, "edit" => true, "configure" => true, "backup" => true, "restore" => true}
      }
    }

    case Roles.update_role_permissions(role, all_permissions) do
      {:ok, _updated_role} ->
        updated_roles = Roles.list_user_roles_with_permissions()
        # Update both roles list and selected role
        updated_selected_role = Enum.find(updated_roles, fn r -> r.id == role.id end)

        {:noreply,
         socket
         |> assign(roles: updated_roles, selected_role: updated_selected_role)
         |> put_flash(:info, "All permissions enabled for #{role.name}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update permissions")}
    end
  end

  @impl true
  def handle_event("clear-all-permissions", _params, socket) do
    # Use the selected role instead of first role
    role = socket.assigns.selected_role

    # Set all permissions to false
    all_permissions = %{
      "backend" => %{
        "dashboard" => %{"view" => false, "edit" => false, "delete" => false},
        "user_mgt" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "approve" => false, "reject" => false},
        "role_mgt" => %{"view" => false, "create" => false, "edit" => false, "delete" => false},
        "course_mgt" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "publish" => false},
        "speech_to_text" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "configure" => false},
        "sign_language" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "configure" => false},
        "accessibility" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "configure" => false},
        "qa_system" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "moderate" => false},
        "analytics" => %{"view" => false, "export" => false, "configure" => false},
        "settings" => %{"view" => false, "edit" => false, "configure" => false},
        "system_mgt" => %{"view" => false, "edit" => false, "configure" => false, "backup" => false, "restore" => false}
      },
      "frontend" => %{
        "dashboard" => %{"view" => false, "edit" => false, "delete" => false},
        "user_mgt" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "approve" => false, "reject" => false},
        "role_mgt" => %{"view" => false, "create" => false, "edit" => false, "delete" => false},
        "course_mgt" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "publish" => false},
        "speech_to_text" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "configure" => false},
        "sign_language" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "configure" => false},
        "accessibility" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "configure" => false},
        "qa_system" => %{"view" => false, "create" => false, "edit" => false, "delete" => false, "moderate" => false},
        "analytics" => %{"view" => false, "export" => false, "configure" => false},
        "settings" => %{"view" => false, "edit" => false, "configure" => false},
        "system_mgt" => %{"view" => false, "edit" => false, "configure" => false, "backup" => false, "restore" => false}
      }
    }

    case Roles.update_role_permissions(role, all_permissions) do
      {:ok, _updated_role} ->
        updated_roles = Roles.list_user_roles_with_permissions()
        # Update both roles list and selected role
        updated_selected_role = Enum.find(updated_roles, fn r -> r.id == role.id end)

        {:noreply,
         socket
         |> assign(roles: updated_roles, selected_role: updated_selected_role)
         |> put_flash(:info, "All permissions cleared for #{role.name}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update permissions")}
    end
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
    end
  end

  defp has_permission?(user, _module, _action) do
    # For now, allow super admin and admin to view permissions
    # In a real implementation, you'd check the actual permissions
    user.user_role in ["SUPER_ADMIN", "ADMIN"]
  end

  defp get_permissions_stats do
    %{
      total_roles: Roles.get_total_roles_count(),
      total_permissions: 120, # TODO: Calculate actual permissions count
      active_permissions: 85, # TODO: Calculate active permissions
      permission_groups: 12   # TODO: Calculate permission groups
    }
  end

  defp get_module_display_name(module) do
    case module do
      "dashboard" -> "Dashboard"
      "user_mgt" -> "User Management"
      "role_mgt" -> "Role Management"
      "course_mgt" -> "Course Management"
      "speech_to_text" -> "Speech to Text"
      "sign_language" -> "Sign Language"
      "accessibility" -> "Accessibility"
      "qa_system" -> "Q&A System"
      "analytics" -> "Analytics"
      "settings" -> "Settings"
      "system_mgt" -> "System Management"
      _ -> String.upcase(module)
    end
  end

  defp get_action_display_name(action) do
    case action do
      "view" -> "View"
      "create" -> "Create"
      "edit" -> "Edit"
      "delete" -> "Delete"
      "approve" -> "Approve"
      "reject" -> "Reject"
      "publish" -> "Publish"
      "configure" -> "Configure"
      "moderate" -> "Moderate"
      "export" -> "Export"
      "backup" -> "Backup"
      "restore" -> "Restore"
      _ -> String.upcase(action)
    end
  end

  defp get_permission_icon(module) do
    case module do
      "dashboard" -> "chart-bar"
      "user_mgt" -> "users"
      "role_mgt" -> "shield-check"
      "course_mgt" -> "academic-cap"
      "speech_to_text" -> "microphone"
      "sign_language" -> "hand-raised"
      "accessibility" -> "heart"
      "qa_system" -> "chat-bubble-left-right"
      "analytics" -> "chart-pie"
      "settings" -> "cog-6-tooth"
      "system_mgt" -> "server"
      _ -> "cog"
    end
  end

  defp get_permission_color(module) do
    case module do
      "dashboard" -> "blue"
      "user_mgt" -> "green"
      "role_mgt" -> "purple"
      "course_mgt" -> "indigo"
      "speech_to_text" -> "pink"
      "sign_language" -> "yellow"
      "accessibility" -> "red"
      "qa_system" -> "teal"
      "analytics" -> "cyan"
      "settings" -> "gray"
      "system_mgt" -> "orange"
      _ -> "gray"
    end
  end

  defp get_module_permissions(module) do
    case module do
      "dashboard" -> %{"view" => true, "edit" => true, "delete" => true}
      "user_mgt" -> %{"view" => true, "create" => true, "edit" => true, "delete" => true, "approve" => true, "reject" => true}
      "role_mgt" -> %{"view" => true, "create" => true, "edit" => true, "delete" => true}
      "course_mgt" -> %{"view" => true, "create" => true, "edit" => true, "delete" => true, "publish" => true}
      "speech_to_text" -> %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true}
      "sign_language" -> %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true}
      "accessibility" -> %{"view" => true, "create" => true, "edit" => true, "delete" => true, "configure" => true}
      "qa_system" -> %{"view" => true, "create" => true, "edit" => true, "delete" => true, "moderate" => true}
      "analytics" -> %{"view" => true, "export" => true, "configure" => true}
      "settings" -> %{"view" => true, "edit" => true, "configure" => true}
      "system_mgt" -> %{"view" => true, "edit" => true, "configure" => true, "backup" => true, "restore" => true}
      _ -> %{"view" => true}
    end
  end

  defp get_role_permission(role, type, module, action) do
    case role.rights do
      nil -> false
      rights ->
        # Determine the permission path based on type
        permission_path = case type do
          "Backend Services" -> ["backend", module, action]
          "Frontend Interface" -> ["frontend", module, action]
          _ -> [type, module, action]
        end

        # Get the permission value using the path
        get_in(rights, permission_path) || false
    end
  end

  defp get_icon_path(icon) do
    case icon do
      "chart-bar" -> "M3 13a3 3 0 015.356-1.857M3 13a3 3 0 015.356 1.857M3 13h6m0-6a3 3 0 015.356-1.857M9 7a3 3 0 015.356 1.857M9 7h6m6 6a3 3 0 015.356-1.857M15 13a3 3 0 015.356 1.857M15 13h6"
      "users" -> "M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"
      "shield-check" -> "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
      "academic-cap" -> "M12 14l9-5-9-5-9 5 9 5z M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z"
      "microphone" -> "M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"
      "hand-raised" -> "M7 11.5V14m0-2.5v-6a1.5 1.5 0 113 0m-3 6a1.5 1.5 0 00-3 0v2a7.5 7.5 0 0015 0v-5a1.5 1.5 0 00-3 0m-6-3V11m0-5.5v-1a1.5 1.5 0 013 0v1m0 0V11m0-5.5a1.5 1.5 0 013 0v3m0 0V11"
      "heart" -> "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
      "chat-bubble-left-right" -> "M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
      "chart-pie" -> "M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z"
      "cog-6-tooth" -> "M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z"
      "server" -> "M21.75 17.25v-.228a4.5 4.5 0 00-.12-1.03l-2.268-9.64a3.375 3.375 0 00-3.285-2.602H7.923a3.375 3.375 0 00-3.285 2.602L2.37 16.22a4.5 4.5 0 00-.12 1.03v.228m19.5 0a3 3 0 01-3 3H5.25a3 3 0 01-3-3m19.5 0a3 3 0 00-3-3H5.25a3 3 0 00-3 3m16.5 0h.008v.008h-.008v-.008zm-3 0h.008v.008h-.008v-.008z"
      _ -> "M6 18L18 6M6 6l12 12"
    end
  end
end
