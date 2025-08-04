defmodule SigneaseWeb.Admin.Users.AllUsers.UsersLive do
  use SigneaseWeb, :live_view
  import Ecto.Query

  alias Signease.Repo
  alias Signease.Accounts
  alias Signease.Accounts.User
  import SigneaseWeb.Components.LoaderComponent

  @url "/admin/users"

  # =============================================================================
  # LIVEVIEW CALLBACKS
  # =============================================================================

  @impl true
  def mount(_params, session, socket) do
    # Get current user from session
    current_user = get_current_user(session)

    socket =
      socket
      |> assign_initial_state()
      |> assign(
        current_user: current_user,
        title: "User Management",
        description: "A comprehensive list of all users in the system."
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    # If we have existing params with filters and the new params are empty, preserve the filters
    current_params = Map.get(socket.assigns, :params, %{})
    new_params = if map_size(params) == 0 and map_size(current_params) > 0 do
      current_params
    else
      params
    end

    if connected?(socket), do: send(self(), {:fetch_users, new_params})

    {:noreply,
     socket
     |> assign(:params, new_params)
     |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event(event, params, socket), do: handle_event_switch(event, params, socket)

  @impl true
  def handle_info(data, socket), do: handle_info_switch(socket, data)

  # =============================================================================
  # ROUTE ACTIONS
  # =============================================================================

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "User Management")
    |> assign(:user, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "User Details")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :filter, _params) do
    socket
    |> assign(:page_title, "Filter Users")
    |> assign(:filter_modal, true)
  end

  # Default clause for when live_action is nil
  defp apply_action(socket, nil, _params) do
    socket
    |> assign(:page_title, "User Management")
    |> assign(:user, nil)
  end

  # =============================================================================
  # EVENT HANDLERS
  # =============================================================================

  defp handle_event_switch(event, params, socket) do
    case event do
      "approve" -> handle_approve_event(params, socket)
      "reject" -> handle_reject_event(params, socket)
      "disable" -> handle_disable_event(params, socket)
      "enable" -> handle_enable_event(params, socket)
      "delete" -> handle_delete_event(params, socket)
      "reset_password" -> handle_reset_password_event(params, socket)
      "reload" -> handle_reload(socket)
      "export_pdf" -> handle_export_pdf(socket, params)
      "export_csv" -> handle_export_csv(socket, params)
      "export_excel" -> handle_export_excel(socket, params)
      "filter" -> handle_filter_event(params, socket)
      "clear_filters" -> handle_clear_filters(socket)
      "change_page" -> handle_change_page(params, socket)
      "change_per_page" -> handle_change_per_page(params, socket)
      "sort" -> handle_sort_event(params, socket)
      "show_create_modal" -> handle_show_create_modal(socket)
      "close_modal" -> handle_close_modal(socket)
      "open_filter" -> open_filter_modal(socket)
      "iSearch" -> fetch_users(socket, params)
      _ -> {:noreply, socket}
    end
  end

  defp handle_info_switch(socket, data) do
    case data do
      :fetch_users ->
        fetch_users(socket, %{"sort_direction" => "desc", "sort_field" => "id"})

      {:fetch_users, params} ->
        fetch_users(socket, params)

      {:fetch_data, params} ->
        fetch_users(socket, params)

      {:filter, filter_data} ->
        handle_filter_event(filter_data, socket)

      {SigneaseWeb.Admin.Users.Components.UserFormComponent, {:saved, _user}} ->
        # Refresh the users list after saving
        send(self(), {:fetch_users, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "User saved successfully.")}

      {SigneaseWeb.Admin.Users.Components.UserFormComponent, :close_modal} ->
        {:noreply, socket}

      :close_modal ->
        {:noreply, push_patch(socket, to: ~p"/admin/users")}

      _ -> {:noreply, socket}
    end
  end

  # =============================================================================
  # MODAL HANDLERS
  # =============================================================================

  defp handle_show_create_modal(socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/users/new")}
  end

  defp handle_close_modal(socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/users")}
  end

  defp open_filter_modal(socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/users/filter")}
  end

  # =============================================================================
  # ACTION HANDLERS
  # =============================================================================

  defp handle_approve_event(%{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.approve_user(user, socket.assigns.current_user.id) do
      {:ok, _user} ->
        # Refresh the users list
        send(self(), {:fetch_users, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "User approved successfully.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve user: #{reason}")}
    end
  end

  defp handle_reject_event(%{"id" => id, "reason" => reason}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.reject_user(user, socket.assigns.current_user.id, reason) do
      {:ok, _user} ->
        # Refresh the users list
        send(self(), {:fetch_users, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "User rejected successfully.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reject user: #{reason}")}
    end
  end

  defp handle_disable_event(%{"id" => id, "reason" => reason}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.disable_user(user, socket.assigns.current_user.id, reason) do
      {:ok, _user} ->
        # Refresh the users list
        send(self(), {:fetch_users, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "User disabled successfully.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to disable user: #{reason}")}
    end
  end

  defp handle_enable_event(%{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.enable_user(user, socket.assigns.current_user.id) do
      {:ok, _user} ->
        # Refresh the users list
        send(self(), {:fetch_users, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "User enabled successfully.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to enable user: #{reason}")}
    end
  end

  defp handle_delete_event(%{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.delete_user(user, socket.assigns.current_user.id) do
      {:ok, _user} ->
        # Refresh the users list
        send(self(), {:fetch_users, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "User deleted successfully.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete user: #{reason}")}
    end
  end

  defp handle_reset_password_event(%{"id" => id}, socket) do
    case Accounts.reset_user_password(id) do
      {:ok, _user, _new_password} ->
        # Refresh the users list
        send(self(), {:fetch_users, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully! Notification sent to user via SMS and email.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reset password: #{reason}")}
    end
  end

  # =============================================================================
  # FILTER & PAGINATION HANDLERS
  # =============================================================================

  defp handle_filter_event(%{"filter" => filter_params}, socket) do
    current_params = socket.assigns.params
    new_params = Map.merge(current_params, filter_params)

    {:noreply,
     socket
     |> assign(:params, new_params)
     |> then(fn socket -> send(self(), {:fetch_users, new_params}); socket end)}
  end

  defp handle_filter_event(params, socket) do
    current_params = socket.assigns.params
    new_params = Map.merge(current_params, params)

    {:noreply,
     socket
     |> assign(:params, new_params)
     |> then(fn socket -> send(self(), {:fetch_users, new_params}); socket end)}
  end

  defp handle_clear_filters(socket) do
    {:noreply,
     socket
     |> assign(:params, %{})
     |> then(fn socket -> send(self(), {:fetch_users, %{}}); socket end)}
  end

  defp handle_change_page(%{"page" => page}, socket) do
    current_params = socket.assigns.params
    new_params = Map.put(current_params, "page", page)

    {:noreply,
     socket
     |> assign(:params, new_params)
     |> then(fn socket -> send(self(), {:fetch_users, new_params}); socket end)}
  end

  defp handle_change_per_page(%{"per_page" => per_page}, socket) do
    current_params = socket.assigns.params
    new_params = Map.merge(current_params, %{"per_page" => per_page, "page" => "1"})

    {:noreply,
     socket
     |> assign(:params, new_params)
     |> then(fn socket -> send(self(), {:fetch_users, new_params}); socket end)}
  end

  defp handle_sort_event(%{"sort_field" => field, "sort_direction" => direction}, socket) do
    current_params = socket.assigns.params
    new_params = Map.merge(current_params, %{"sort_field" => field, "sort_direction" => direction})

    {:noreply,
     socket
     |> assign(:params, new_params)
     |> then(fn socket -> send(self(), {:fetch_users, new_params}); socket end)}
  end

  # =============================================================================
  # DATA FETCHING
  # =============================================================================

  defp fetch_users(socket, params) do
    {users, pagination} = get_users_with_pagination_and_filters(params)
    stats = get_user_stats()

    # Hide loader and update data
    socket = push_event(socket, "hide-loader", %{id: "users-loader"})

    {:noreply,
     assign(socket, :users, users)
     |> assign(:pagination, pagination)
     |> assign(:filters, extract_filters(params))
     |> assign(:filter_params, extract_filters(params))
     |> assign(:stats, stats)
     |> assign(:data_loader, false)
     |> assign(:filter_modal, false)}
  end

  defp get_users_with_pagination_and_filters(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")
    sort_field = params["sort_field"] || "inserted_at"
    sort_direction = params["sort_direction"] || "desc"

    # Get all users
    users = get_users_with_pagination(page, per_page, sort_field, sort_direction, extract_filters_for_context(params))
    total_count = get_users_count(extract_filters_for_context(params))

    pagination = %{
      current_page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: ceil(total_count / per_page),
      has_prev: page > 1,
      has_next: page < ceil(total_count / per_page)
    }

    {users, pagination}
  end

  defp get_users_with_pagination(page, per_page, sort_field, sort_direction, filters) do
    User
    |> apply_users_filters(filters)
    |> apply_users_sorting(sort_field, sort_direction)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
  end

  defp get_users_count(filters) do
    User
    |> apply_users_filters(filters)
    |> Repo.aggregate(:count, :id)
  end

  defp apply_users_filters(query, filters) do
    # If no filters, return the query as is
    if map_size(filters) == 0 do
      query
    else
      Enum.reduce(filters, query, fn {key, value}, acc ->
        case {key, value} do
          {:search, search} when is_binary(search) and byte_size(search) > 0 ->
            search_term = "%#{search}%"
            from(u in acc,
              where: ilike(u.first_name, ^search_term) or
                     ilike(u.last_name, ^search_term) or
                     ilike(u.email, ^search_term) or
                     ilike(u.username, ^search_term))
          {:user_type, user_type} when is_binary(user_type) and byte_size(user_type) > 0 ->
            from(u in acc, where: u.user_type == ^user_type)
          {:status, status} when is_binary(status) and byte_size(status) > 0 ->
            from(u in acc, where: u.status == ^status)
          {:hearing_status, hearing_status} when is_binary(hearing_status) and byte_size(hearing_status) > 0 ->
            from(u in acc, where: u.hearing_status == ^hearing_status)
          _ -> acc
        end
      end)
    end
  end

  defp apply_users_sorting(query, sort_field, sort_direction) do
    case {sort_field, sort_direction} do
      {"first_name", "asc"} -> from(u in query, order_by: [asc: u.first_name])
      {"first_name", "desc"} -> from(u in query, order_by: [desc: u.first_name])
      {"last_name", "asc"} -> from(u in query, order_by: [asc: u.last_name])
      {"last_name", "desc"} -> from(u in query, order_by: [desc: u.last_name])
      {"email", "asc"} -> from(u in query, order_by: [asc: u.email])
      {"email", "desc"} -> from(u in query, order_by: [desc: u.email])
      {"username", "asc"} -> from(u in query, order_by: [asc: u.username])
      {"username", "desc"} -> from(u in query, order_by: [desc: u.username])
      {"inserted_at", "asc"} -> from(u in query, order_by: [asc: u.inserted_at])
      {"inserted_at", "desc"} -> from(u in query, order_by: [desc: u.inserted_at])
      _ -> from(u in query, order_by: [desc: u.inserted_at])
    end
  end

  defp extract_filters_for_context(params) do
    filters = %{}

    filters = if params["search"] && String.trim(params["search"]) != "", do: Map.put(filters, :search, String.trim(params["search"])), else: filters
    filters = if params["user_type"] && String.trim(params["user_type"]) != "", do: Map.put(filters, :user_type, String.trim(params["user_type"])), else: filters
    filters = if params["status"] && String.trim(params["status"]) != "", do: Map.put(filters, :status, String.trim(params["status"])), else: filters
    filters = if params["hearing_status"] && String.trim(params["hearing_status"]) != "", do: Map.put(filters, :hearing_status, String.trim(params["hearing_status"])), else: filters

    filters
  end

  defp extract_filters(params) do
    filters = %{}

    filters = if params["search"] && String.trim(params["search"]) != "", do: Map.put(filters, :search, String.trim(params["search"])), else: filters
    filters = if params["user_type"] && String.trim(params["user_type"]) != "", do: Map.put(filters, :user_type, String.trim(params["user_type"])), else: filters
    filters = if params["status"] && String.trim(params["status"]) != "", do: Map.put(filters, :status, String.trim(params["status"])), else: filters
    filters = if params["hearing_status"] && String.trim(params["hearing_status"]) != "", do: Map.put(filters, :hearing_status, String.trim(params["hearing_status"])), else: filters

    filters
  end

        defp handle_reload(socket) do
    # Show loader using your existing system
    socket = push_event(socket, "show-loader", %{
      id: "users-loader",
      message: "Refreshing Data",
      subtext: "Please wait while we fetch the latest user information..."
    })

    # Clear all filters and reset to initial state
    cleared_params = %{}

    # Add a small delay to make the loader visible and provide better UX
    Process.send_after(self(), {:fetch_users, cleared_params}, 300)

    {:noreply,
     socket
     |> assign(:params, cleared_params)
     |> assign(:filter_params, %{})
     |> assign(:filters, %{})}
  end



  # =============================================================================
  # EXPORT HANDLERS
  # =============================================================================

  defp handle_export_pdf(socket, _params) do
    {:noreply, socket |> put_flash(:info, "PDF export functionality coming soon")}
  end

  defp handle_export_excel(socket, _params) do
    {:noreply, socket |> put_flash(:info, "Excel export functionality coming soon")}
  end

  defp handle_export_csv(socket, _params) do
    {:noreply, socket |> put_flash(:info, "CSV export functionality coming soon")}
  end

  # =============================================================================
  # HELPER FUNCTIONS
  # =============================================================================

  defp assign_initial_state(socket) do
    socket
    |> assign(:current_path, @url)
    |> assign(:users, [])
    |> assign(:pagination, %{})
    |> assign(:filters, %{})
    |> assign(:filter_params, %{})
    |> assign(:data_loader, true)
    |> assign(:filter_modal, false)
    |> assign(:error_modal, false)
    |> assign(:success_modal, false)
    |> assign(:error_message, "")
    |> assign(:success_message, "")
    |> assign(:user, nil)
    |> assign(:action, nil)
    |> assign(:page, nil)
    |> assign(:stats, get_user_stats())
  end

  defp get_current_user(session) do
    user_id = session["user_id"]

    case user_id do
      nil ->
        # Default admin for development when no session
        %{
          id: 1,
          first_name: "System",
          last_name: "Admin",
          email: "admin@signease.com",
          user_type: "ADMIN",
          user_role: "ADMIN"
        }
      user_id ->
        case Signease.Accounts.get_user(user_id) do
          nil ->
            %{
              id: 1,
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

  defp get_user_stats do
    total_users = Repo.aggregate(User, :count, :id)
    active_users = Repo.aggregate(from(u in User, where: u.status == "ACTIVE"), :count, :id)
    pending_users = Repo.aggregate(from(u in User, where: u.status == "PENDING_APPROVAL"), :count, :id)
    disabled_users = Repo.aggregate(from(u in User, where: u.status == "DISABLED"), :count, :id)
    learners = Repo.aggregate(from(u in User, where: u.user_type == "LEARNER"), :count, :id)
    instructors = Repo.aggregate(from(u in User, where: u.user_type == "INSTRUCTOR"), :count, :id)
    admins = Repo.aggregate(from(u in User, where: u.user_type == "ADMIN"), :count, :id)

    %{
      total_users: total_users,
      active_users: active_users,
      pending_approvals: pending_users,
      disabled_users: disabled_users,
      total_roles: 0,
      active_sessions: 0,
      stats_cards: [
        %{
          title: "Total Users",
          value: total_users,
          icon: "users",
          color: "blue"
        },
        %{
          title: "Active Users",
          value: active_users,
          icon: "check-circle",
          color: "green"
        },
        %{
          title: "Pending Approval",
          value: pending_users,
          icon: "clock",
          color: "yellow"
        },
        %{
          title: "User Types",
          value: "#{learners} Learners / #{instructors} Instructors / #{admins} Admins",
          icon: "user-group",
          color: "purple"
        }
      ]
    }
  end

  # =============================================================================
  # TEMPLATE HELPER FUNCTIONS
  # =============================================================================

  defp get_status_class(status) do
    case status do
      "ACTIVE" -> "bg-green-100 text-green-800"
      "PENDING_APPROVAL" -> "bg-yellow-100 text-yellow-800"
      "DISABLED" -> "bg-red-100 text-red-800"
      "SUSPENDED" -> "bg-orange-100 text-orange-800"
      "COMPLETED" -> "bg-purple-100 text-purple-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  defp format_user_status(status) do
    case status do
      "ACTIVE" -> "Active"
      "PENDING_APPROVAL" -> "Pending Approval"
      "DISABLED" -> "Disabled"
      "SUSPENDED" -> "Suspended"
      "COMPLETED" -> "Completed"
      _ -> "Unknown"
    end
  end

  defp get_hearing_status_class(hearing_status) do
    case hearing_status do
      "HEARING" -> "bg-blue-100 text-blue-800"
      "DEAF" -> "bg-red-100 text-red-800"
      "HARD_OF_HEARING" -> "bg-yellow-100 text-yellow-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  defp format_hearing_status(hearing_status) do
    case hearing_status do
      "HEARING" -> "Hearing"
      "DEAF" -> "Deaf"
      "HARD_OF_HEARING" -> "Hard of Hearing"
      _ -> "Unknown"
    end
  end

  defp format_user_type(type) do
    case type do
      "LEARNER" -> "Learner"
      "INSTRUCTOR" -> "Instructor"
      "ADMIN" -> "Admin"
      "SUPPORT" -> "Support"
      _ -> type || "N/A"
    end
  end
end
