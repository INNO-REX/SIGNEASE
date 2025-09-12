defmodule SigneaseWeb.Admin.Moderation.BlockedUsersLive do
  use SigneaseWeb, :live_view

  import SigneaseWeb.Components.LoaderComponent

  alias Signease.Accounts
  alias Signease.Accounts.User
  alias Signease.Repo
  alias Signease.Roles.UserRole
  alias SigneaseWeb.Admin.Users.Components.UserShowComponent
  alias SigneaseWeb.Admin.Users.Components.FilterComponent
  alias SigneaseWeb.Admin.Users.Components.PaginationComponent
  alias SigneaseWeb.Admin.Users.Components.ISearchComponent
  import Ecto.Query

  @impl true
  def mount(_params, session, socket) do
    # Get current user from session
    current_user = get_current_user(session)

    {:ok, assign_initial_state(socket) |> assign(:current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    user = Accounts.get_user!(id)
    {:noreply, assign(socket, :user, user)}
  end

  def handle_params(%{"action" => action} = params, _url, socket) do
    socket = apply_action(socket, action, params)
    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:fetch_data, params}, socket) do
    {:noreply, fetch_blocked_users(socket, params)}
  end

  @impl true
  def handle_info({:fetch_blocked_users, params}, socket) do
    {:noreply, fetch_blocked_users(socket, params)}
  end

  @impl true
  def handle_event("unblock", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, %{status: "ACTIVE", blocked: false}) do
      {:ok, _updated_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User unblocked successfully")
         |> fetch_blocked_users(socket.assigns.params)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to unblock user")
         |> fetch_blocked_users(socket.assigns.params)}
    end
  end



  @impl true
  def handle_event("toggle_selection", %{"id" => user_id}, socket) do
    user_id = String.to_integer(user_id)
    selected_users = socket.assigns.selected_users

    new_selected_users = if MapSet.member?(selected_users, user_id) do
      MapSet.delete(selected_users, user_id)
    else
      MapSet.put(selected_users, user_id)
    end

    {:noreply, assign(socket, :selected_users, new_selected_users)}
  end

  @impl true
  def handle_event("select_all", _params, socket) do
    all_user_ids = Enum.map(socket.assigns.blocked_users, & &1.id)
    {:noreply, assign(socket, :selected_users, MapSet.new(all_user_ids))}
  end

  @impl true
  def handle_event("deselect_all", _params, socket) do
    {:noreply, assign(socket, :selected_users, MapSet.new())}
  end

  @impl true
  def handle_event("bulk_unblock", _params, socket) do
    selected_user_ids = MapSet.to_list(socket.assigns.selected_users)

    if length(selected_user_ids) == 0 do
      {:noreply, put_flash(socket, :error, "Please select users to unblock")}
    else
      {unblocked_count, _} =
        User
        |> where([u], u.id in ^selected_user_ids)
        |> Repo.update_all(set: [status: "ACTIVE", blocked: false])

      {:noreply,
       socket
       |> put_flash(:info, "#{unblocked_count} users unblocked successfully")
       |> assign(:selected_users, MapSet.new())
       |> fetch_blocked_users(socket.assigns.params)}
    end
  end



  @impl true
  def handle_event("open_filter", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/blocked-users/filter")}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "User Details")
    |> assign(:live_action, :show)
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :filter, _params) do
    socket
    |> assign(:page_title, "Filter Blocked Users")
    |> assign(:filter_modal, true)
  end

  defp assign_initial_state(socket) do
    socket
    |> assign(:page_title, "Blocked Users")
    |> assign(:title, "Blocked Users")
    |> assign(:description, "Manage blocked and rejected users")
    |> assign(:blocked_users, [])
    |> assign(:pagination, %{})
    |> assign(:params, %{})
    |> assign(:filter_params, %{})
    |> assign(:stats, get_blocked_users_stats())
    |> assign(:data_loader, true)
    |> assign(:selected_users, MapSet.new())
    |> fetch_initial_data(%{})
  end

  defp fetch_initial_data(socket, params) do
    {blocked_users, pagination} = get_blocked_users_with_pagination(params)
    stats = get_blocked_users_stats()

    socket
    |> assign(:blocked_users, blocked_users)
    |> assign(:pagination, pagination)
    |> assign(:params, params)
    |> assign(:stats, stats)
    |> assign(:data_loader, false)
  end

  defp fetch_blocked_users(socket, params) do
    {blocked_users, pagination} = get_blocked_users_with_pagination(params)
    stats = get_blocked_users_stats()

    # Hide loader and update data
    socket = push_event(socket, "hide-loader", %{id: "blocked-users-loader"})

    {:noreply,
     socket
     |> assign(:blocked_users, blocked_users)
     |> assign(:pagination, pagination)
     |> assign(:params, params)
     |> assign(:stats, stats)
     |> assign(:data_loader, false)}
  end

  defp get_blocked_users_with_pagination(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "20")
    sort_field = params["sort_field"] || "inserted_at"
    sort_direction = params["sort_direction"] || "desc"

    blocked_users = get_blocked_users(page, per_page, sort_field, sort_direction, extract_filters(params))
    total_count = get_total_blocked_count(extract_filters(params))

    pagination = %{
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: :math.ceil(total_count / per_page),
      sort_field: sort_field,
      sort_direction: sort_direction
    }

    {blocked_users, pagination}
  end

  defp get_blocked_users(page, per_page, sort_field, sort_direction, filters) do
    offset = (page - 1) * per_page

    User
    |> where([u], u.status == "REJECTED" or u.blocked == true)
    |> apply_filters(filters)
    |> apply_sorting(sort_field, sort_direction)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()
  end

  defp get_total_blocked_count(filters) do
    User
    |> where([u], u.status == "REJECTED" or u.blocked == true)
    |> apply_filters(filters)
    |> Repo.aggregate(:count, :id)
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      case {key, value} do
        {:search, search} when is_binary(search) and byte_size(search) > 0 ->
          search_term = "%#{search}%"
          where(acc, [u],
            ilike(u.first_name, ^search_term) or
            ilike(u.last_name, ^search_term) or
            ilike(u.email, ^search_term) or
            ilike(u.username, ^search_term))
        {:user_type, user_type} when is_binary(user_type) and byte_size(user_type) > 0 ->
          where(acc, [u], u.user_type == ^user_type)
        {:hearing_status, hearing_status} when is_binary(hearing_status) and byte_size(hearing_status) > 0 ->
          where(acc, [u], u.hearing_status == ^hearing_status)
        {:status, status} when is_binary(status) and byte_size(status) > 0 ->
          where(acc, [u], u.status == ^status)
        _ -> acc
      end
    end)
  end

  defp apply_sorting(query, sort_field, sort_direction) do
    sort_direction_atom = String.to_existing_atom(sort_direction)

    case sort_field do
      "first_name" -> order_by(query, [u], [{^sort_direction_atom, u.first_name}])
      "last_name" -> order_by(query, [u], [{^sort_direction_atom, u.last_name}])
      "email" -> order_by(query, [u], [{^sort_direction_atom, u.email}])
      "user_type" -> order_by(query, [u], [{^sort_direction_atom, u.user_type}])
      "inserted_at" -> order_by(query, [u], [{^sort_direction_atom, u.inserted_at}])
      _ -> order_by(query, [u], [desc: u.inserted_at])
    end
  end

  defp extract_filters(params) do
    filters = %{}
    filters = if params["search"] && String.trim(params["search"]) != "", do: Map.put(filters, :search, String.trim(params["search"])), else: filters
    filters = if params["user_type"] && String.trim(params["user_type"]) != "", do: Map.put(filters, :user_type, String.trim(params["user_type"])), else: filters
    filters = if params["hearing_status"] && String.trim(params["hearing_status"]) != "", do: Map.put(filters, :hearing_status, String.trim(params["hearing_status"])), else: filters
    filters = if params["status"] && String.trim(params["status"]) != "", do: Map.put(filters, :status, String.trim(params["status"])), else: filters
    filters
  end

  defp get_blocked_users_stats do
    total_blocked = Repo.aggregate(from(u in User, where: u.status == "REJECTED" or u.blocked == true), :count, :id)
    blocked_learners = Repo.aggregate(from(u in User, where: (u.status == "REJECTED" or u.blocked == true) and u.user_type == "LEARNER"), :count, :id)
    blocked_instructors = Repo.aggregate(from(u in User, where: (u.status == "REJECTED" or u.blocked == true) and u.user_type == "INSTRUCTOR"), :count, :id)
    rejected_users = Repo.aggregate(from(u in User, where: u.status == "REJECTED"), :count, :id)

    # Get total users for the stats component
    total_users = Repo.aggregate(from(u in User), :count, :id)

    # Get total roles for the stats component
    total_roles = Repo.aggregate(from(r in UserRole), :count, :id)

    # Get pending approvals for the stats component
    pending_approvals = Repo.aggregate(from(u in User, where: u.status == "PENDING_APPROVAL" or (u.approved == false and u.status != "REJECTED")), :count, :id)

    # Active sessions (placeholder for now)
    active_sessions = 0

    %{
      total_blocked: total_blocked,
      blocked_learners: blocked_learners,
      blocked_instructors: blocked_instructors,
      rejected_users: rejected_users,
      # Required by StatsCardsComponent
      total_users: total_users,
      blocked_users: total_blocked,
      total_roles: total_roles,
      active_sessions: active_sessions,
      pending_approvals: pending_approvals,
      stats_cards: [
        %{color: "red", icon: "ban", title: "Total Blocked", value: total_blocked},
        %{color: "orange", icon: "academic-cap", title: "Blocked Learners", value: blocked_learners},
        %{color: "yellow", icon: "user-group", title: "Blocked Instructors", value: blocked_instructors},
        %{color: "purple", icon: "x-circle", title: "Rejected Users", value: rejected_users}
      ]
    }
  end

  # Helper functions for template
  defp format_user_status(status) do
    case status do
      "ACTIVE" -> "Active"
      "PENDING_APPROVAL" -> "Pending Approval"
      "REJECTED" -> "Rejected"
      "DISABLED" -> "Disabled"
      "BLOCKED" -> "Blocked"
      _ -> "Unknown"
    end
  end

  defp get_status_class(status) do
    case status do
      "ACTIVE" -> "bg-green-100 text-green-800"
      "PENDING_APPROVAL" -> "bg-yellow-100 text-yellow-800"
      "REJECTED" -> "bg-red-100 text-red-800"
      "DISABLED" -> "bg-gray-100 text-gray-800"
      "BLOCKED" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  defp format_hearing_status(hearing_status) do
    case hearing_status do
      "HEARING" -> "Hearing"
      "DEAF" -> "Deaf"
      "HARD_OF_HEARING" -> "Hard of Hearing"
      "UNKNOWN" -> "Unknown"
      _ -> "Unknown"
    end
  end

  defp get_hearing_status_class(hearing_status) do
    case hearing_status do
      "HEARING" -> "bg-green-100 text-green-800"
      "DEAF" -> "bg-red-100 text-red-800"
      "HARD_OF_HEARING" -> "bg-yellow-100 text-yellow-800"
      "UNKNOWN" -> "bg-gray-100 text-gray-800"
      _ -> "bg-gray-100 text-gray-800"
    end
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
              user_type: admin_type,
              user_role: "ADMIN"
            }
        end
    end
  end
end
