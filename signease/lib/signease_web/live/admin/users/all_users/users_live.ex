defmodule SigneaseWeb.Admin.Users.AllUsers.UsersLive do
  use SigneaseWeb, :live_view
  import Ecto.Query

  alias Signease.Repo
  alias Signease.Accounts
  alias Signease.Accounts.User
  alias Signease.Roles
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
    if connected?(socket), do: send(self(), {:fetch_users, params})

    {:noreply,
     socket
     |> assign(:params, params)
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

  defp apply_action(socket, nil, _params) do
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
      "reload" -> handle_reload(socket)
      "export_pdf" -> handle_export_pdf(socket, params)
      "export_csv" -> handle_export_csv(socket, params)
      "export_excel" -> handle_export_excel(socket, params)
      "filter" -> handle_filter_event(params, socket)
      "clear_filters" -> handle_clear_filters(socket)
      "change_page" -> handle_change_page(params, socket)
      "change_per_page" -> handle_change_per_page(params, socket)
      "sort" -> handle_sort_event(params, socket)
      _ -> {:noreply, socket}
    end
  end

  defp handle_info_switch(socket, data) do
    case data do
      :fetch_users ->
        fetch_users(socket, %{"sort_direction" => "desc", "sort_field" => "id"})

      {:fetch_users, params} ->
        fetch_users(socket, params)

      {:filter, params} ->
        current_params = socket.assigns.params
        new_params = Map.merge(current_params, params)
        fetch_users(socket, new_params)

      {:change_page, %{"page" => page}} ->
        current_params = socket.assigns.params
        new_params = Map.put(current_params, "page", page)
        fetch_users(socket, new_params)

      {:change_per_page, %{"per_page" => per_page}} ->
        current_params = socket.assigns.params
        new_params = Map.merge(current_params, %{"per_page" => per_page, "page" => "1"})
        fetch_users(socket, new_params)

      _ ->
        {:noreply, socket}
    end
  end

  # =============================================================================
  # MODAL HANDLERS
  # =============================================================================

  defp handle_approve_event(%{"id" => id}, socket) do
    case Accounts.approve_user(id, socket.assigns.current_user.id) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User approved successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve user: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_reject_event(%{"id" => id}, socket) do
    case Accounts.reject_user(id, socket.assigns.current_user.id, "Rejected by admin") do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User rejected successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reject user: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_disable_event(%{"id" => id}, socket) do
    case Accounts.disable_user(id, socket.assigns.current_user.id, "Disabled by admin") do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User disabled successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to disable user: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_enable_event(%{"id" => id}, socket) do
    case Accounts.enable_user(id, socket.assigns.current_user.id) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User enabled successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to enable user: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_delete_event(%{"id" => id}, socket) do
    case Accounts.delete_user(id, socket.assigns.current_user.id) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User deleted successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete user: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  # =============================================================================
  # FILTER & PAGINATION HANDLERS
  # =============================================================================

  defp handle_filter_event(params, socket) do
    current_params = socket.assigns.params
    new_params = Map.merge(current_params, params)

    {:noreply, push_patch(socket, to: ~p"/admin/users?#{new_params}")}
  end

  defp handle_clear_filters(socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/users")}
  end

  defp handle_change_page(%{"page" => page}, socket) do
    current_params = socket.assigns.params
    new_params = Map.put(current_params, "page", page)

    {:noreply, push_patch(socket, to: ~p"/admin/users?#{new_params}")}
  end

  defp handle_change_per_page(%{"per_page" => per_page}, socket) do
    current_params = socket.assigns.params
    new_params = Map.merge(current_params, %{"per_page" => per_page, "page" => "1"})

    {:noreply, push_patch(socket, to: ~p"/admin/users?#{new_params}")}
  end

  defp handle_sort_event(%{"sort_field" => field, "sort_direction" => direction}, socket) do
    current_params = socket.assigns.params
    new_params = Map.merge(current_params, %{"sort_field" => field, "sort_direction" => direction})

    {:noreply, push_patch(socket, to: ~p"/admin/users?#{new_params}")}
  end

  # =============================================================================
  # DATA FETCHING
  # =============================================================================

  defp fetch_users(socket, params) do
    {users, pagination} = get_users_with_pagination_and_filters(params)
    stats = get_user_stats()

    {:noreply,
     assign(socket, :users, users)
     |> assign(:pagination, pagination)
     |> assign(:filters, extract_filters(params))
     |> assign(:stats, stats)
     |> assign(:data_loader, false)}
  end

  defp get_users_with_pagination_and_filters(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "20")
    sort_field = params["sort_field"] || "inserted_at"
    sort_direction = params["sort_direction"] || "desc"
    offset = (page - 1) * per_page

    # Build the base query with filters
    base_query = User
    |> preload([:role])
    |> apply_filters(params)

    # Get total count for pagination
    total_count = Repo.aggregate(base_query, :count, :id)

    # Apply sorting and pagination
    users = base_query
    |> apply_sorting(sort_field, sort_direction)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()

    # Calculate pagination info
    total_pages = ceil(total_count / per_page)

    pagination = %{
      current_page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      has_prev: page > 1,
      has_next: page < total_pages
    }

    {users, pagination}
  end

  defp apply_filters(query, params) do
    query
    |> filter_by_search(params["search"])
    |> filter_by_status(params["status"])
    |> filter_by_user_type(params["user_type"])
    |> filter_by_role(params["role"])
    |> filter_by_date_range(params["date_from"], params["date_to"])
  end

  defp filter_by_search(query, nil), do: query
  defp filter_by_search(query, search) when search == "", do: query
  defp filter_by_search(query, search) do
    search_term = "%#{search}%"
    from u in query,
      where: ilike(u.first_name, ^search_term) or
             ilike(u.last_name, ^search_term) or
             ilike(u.email, ^search_term)
  end

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, status) when status == "", do: query
  defp filter_by_status(query, status) do
    from u in query, where: u.user_status == ^status
  end

  defp filter_by_user_type(query, nil), do: query
  defp filter_by_user_type(query, user_type) when user_type == "", do: query
  defp filter_by_user_type(query, user_type) do
    from u in query, where: u.user_type == ^user_type
  end

  defp filter_by_role(query, nil), do: query
  defp filter_by_role(query, role) when role == "", do: query
  defp filter_by_role(query, role) do
    from u in query, where: u.role_id == ^String.to_integer(role)
  end

  defp filter_by_date_range(query, nil, nil), do: query
  defp filter_by_date_range(query, date_from, nil) when date_from != "" do
    from u in query, where: u.inserted_at >= ^parse_date(date_from)
  end
  defp filter_by_date_range(query, nil, date_to) when date_to != "" do
    from u in query, where: u.inserted_at <= ^parse_date(date_to)
  end
  defp filter_by_date_range(query, date_from, date_to) when date_from != "" and date_to != "" do
    from u in query,
      where: u.inserted_at >= ^parse_date(date_from) and u.inserted_at <= ^parse_date(date_to)
  end
  defp filter_by_date_range(query, _, _), do: query

  defp apply_sorting(query, field, direction) do
    order_clause = case direction do
      "asc" -> :asc
      "desc" -> :desc
      _ -> :desc
    end

    case field do
      "first_name" -> from u in query, order_by: [{^order_clause, u.first_name}]
      "last_name" -> from u in query, order_by: [{^order_clause, u.last_name}]
      "email" -> from u in query, order_by: [{^order_clause, u.email}]
      "user_type" -> from u in query, order_by: [{^order_clause, u.user_type}]
      "user_status" -> from u in query, order_by: [{^order_clause, u.user_status}]
      "inserted_at" -> from u in query, order_by: [{^order_clause, u.inserted_at}]
      _ -> from u in query, order_by: [{^order_clause, u.inserted_at}]
    end
  end

  defp extract_filters(params) do
    %{
      search: params["search"] || "",
      status: params["status"] || "",
      user_type: params["user_type"] || "",
      role: params["role"] || "",
      date_from: params["date_from"] || "",
      date_to: params["date_to"] || ""
    }
  end

  defp parse_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  defp sortable_header(label, field, params) do
    current_field = params["sort_field"] || "inserted_at"
    current_direction = params["sort_direction"] || "desc"

    new_direction = if current_field == field and current_direction == "asc", do: "desc", else: "asc"

    assigns = %{
      label: label,
      field: field,
      current_field: current_field,
      current_direction: current_direction,
      new_direction: new_direction
    }

    ~H"""
    <button
      phx-click="sort"
      phx-value-sort_field={@field}
      phx-value-sort_direction={@new_direction}
      class="group inline-flex items-center text-xs font-medium text-gray-500 uppercase tracking-wider hover:text-gray-700"
    >
      <%= @label %>
      <span class="ml-2 flex-none rounded">
        <%= if @current_field == @field do %>
          <%= if @current_direction == "asc" do %>
            <svg class="w-4 h-4 text-gray-400 group-hover:text-gray-500" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M14.707 12.707a1 1 0 01-1.414 0L10 9.414l-3.293 3.293a1 1 0 01-1.414-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 010 1.414z" clip-rule="evenodd"></path>
            </svg>
          <% else %>
            <svg class="w-4 h-4 text-gray-400 group-hover:text-gray-500" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd"></path>
            </svg>
          <% end %>
        <% else %>
          <svg class="w-4 h-4 text-gray-400 group-hover:text-gray-500" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 3a1 1 0 01.707.293l3 3a1 1 0 01-1.414 1.414L10 5.414 7.707 7.707a1 1 0 01-1.414-1.414l3-3A1 1 0 0110 3zm-3.707 9.293a1 1 0 011.414 0L10 14.586l2.293-2.293a1 1 0 011.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd"></path>
          </svg>
        <% end %>
      </span>
    </button>
    """
  end

  defp handle_reload(socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/users")}
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
  # UTILITY FUNCTIONS
  # =============================================================================

  defp assign_initial_state(socket) do
    socket
    |> assign(:current_path, @url)
    |> assign(:users, [])
    |> assign(:pagination, %{})
    |> assign(:filters, %{})
    |> assign(:data_loader, true)
    |> assign(:filter_modal, false)
    |> assign(:error_modal, false)
    |> assign(:success_modal, false)
    |> assign(:error_message, "")
    |> assign(:success_message, "")
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
        case Accounts.get_user(user_id) do
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
    active_users = Repo.aggregate(from(u in User, where: u.user_status == "ACTIVE"), :count, :id)
    pending_users = Repo.aggregate(from(u in User, where: u.status == "PENDING_APPROVAL"), :count, :id)
    disabled_users = Repo.aggregate(from(u in User, where: u.disabled == true), :count, :id)

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
          title: "Disabled Users",
          value: disabled_users,
          icon: "x-circle",
          color: "red"
        }
      ]
    }
  end

  # =============================================================================
  # STATUS FORMATTERS
  # =============================================================================

  def format_user_status(status) do
    case status do
      "ACTIVE" -> "Active"
      "INACTIVE" -> "Inactive"
      "PENDING_APPROVAL" -> "Pending Approval"
      "APPROVED" -> "Approved"
      "REJECTED" -> "Rejected"
      "DISABLED" -> "Disabled"
      _ -> "Unknown"
    end
  end

  def format_user_type(type) do
    case type do
      "LEARNER" -> "Learner"
      "INSTRUCTOR" -> "Instructor"
      "ADMIN" -> "Admin"
      "SUPPORT" -> "Support"
      _ -> type || "N/A"
    end
  end

  def format_hearing_status(status) do
    case status do
      "HEARING" -> "Hearing"
      "DEAF" -> "Deaf"
      "HARD_OF_HEARING" -> "Hard of Hearing"
      _ -> status || "N/A"
    end
  end

  def get_status_class(status) do
    case status do
      "ACTIVE" -> "bg-green-100 text-green-800"
      "INACTIVE" -> "bg-gray-100 text-gray-800"
      "PENDING_APPROVAL" -> "bg-yellow-100 text-yellow-800"
      "APPROVED" -> "bg-blue-100 text-blue-800"
      "REJECTED" -> "bg-red-100 text-red-800"
      "DISABLED" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  def get_user_type_class(type) do
    case type do
      "LEARNER" -> "bg-blue-100 text-blue-800"
      "INSTRUCTOR" -> "bg-purple-100 text-purple-800"
      "ADMIN" -> "bg-red-100 text-red-800"
      "SUPPORT" -> "bg-orange-100 text-orange-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end
end
