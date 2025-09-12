defmodule SigneaseWeb.Admin.Moderation.UserApprovalsLive do
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
    {:noreply, fetch_pending_approvals(socket, params)}
  end

  @impl true
  def handle_info({:fetch_approvals, params}, socket) do
    {:noreply, fetch_pending_approvals(socket, params)}
  end

  @impl true
  def handle_event("approve", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, %{status: "ACTIVE", approved: true}) do
      {:ok, _updated_user} ->
        # Send approval notification
        Signease.Notifications.send_approval_notification(user)

        {:noreply,
         socket
         |> put_flash(:info, "User approved successfully")
         |> fetch_pending_approvals(socket.assigns.params)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve user")
         |> fetch_pending_approvals(socket.assigns.params)}
    end
  end

  @impl true
  def handle_event("reject", %{"id" => id, "reason" => reason}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, %{status: "REJECTED", approved: false}) do
      {:ok, _updated_user} ->
        # Send rejection notification
        Signease.Notifications.send_rejection_notification(user, reason)

        {:noreply,
         socket
         |> put_flash(:info, "User rejected successfully")
         |> fetch_pending_approvals(socket.assigns.params)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reject user")
         |> fetch_pending_approvals(socket.assigns.params)}
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
    all_user_ids = Enum.map(socket.assigns.pending_approvals, & &1.id)
    {:noreply, assign(socket, :selected_users, MapSet.new(all_user_ids))}
  end

  @impl true
  def handle_event("deselect_all", _params, socket) do
    {:noreply, assign(socket, :selected_users, MapSet.new())}
  end

  @impl true
  def handle_event("bulk_approve", _params, socket) do
    selected_user_ids = MapSet.to_list(socket.assigns.selected_users)

    if length(selected_user_ids) == 0 do
      {:noreply, put_flash(socket, :error, "Please select users to approve")}
    else
      {approved_count, _} =
        User
        |> where([u], u.id in ^selected_user_ids)
        |> Repo.update_all(set: [status: "ACTIVE", approved: true])

      if approved_count > 0 do
        # Send bulk approval notifications
        users = Accounts.list_users_by_ids(selected_user_ids)
        Enum.each(users, &Signease.Notifications.send_approval_notification/1)
      end

      {:noreply,
       socket
       |> put_flash(:info, "#{approved_count} users approved successfully")
       |> assign(:selected_users, MapSet.new())
       |> fetch_pending_approvals(socket.assigns.params)}
    end
  end

  @impl true
  def handle_event("reload", _params, socket) do
    # Show loader using your existing system
    socket = push_event(socket, "show-loader", %{
      id: "approvals-loader",
      message: "Refreshing Data",
      subtext: "Please wait while we fetch the latest approval requests..."
    })

    # Add a small delay to make the loader visible and provide better UX
    Process.send_after(self(), {:fetch_approvals, socket.assigns.params}, 300)

    {:noreply, socket}
  end

  @impl true
  def handle_event("open_filter", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/user-approvals/filter")}
  end

  @impl true
  def handle_event("add_user", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/users/new")}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "User Details")
    |> assign(:live_action, :show)
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :filter, _params) do
    socket
    |> assign(:page_title, "Filter Approvals")
    |> assign(:filter_modal, true)
  end

  defp assign_initial_state(socket) do
    socket
    |> assign(:page_title, "User Approvals")
    |> assign(:title, "User Approvals")
    |> assign(:description, "Review and approve pending user registrations")
    |> assign(:pending_approvals, [])
    |> assign(:pagination, %{})
    |> assign(:params, %{})
    |> assign(:filter_params, %{})
    |> assign(:stats, get_approval_stats())
    |> assign(:data_loader, true)
    |> assign(:selected_users, MapSet.new())
    |> fetch_initial_data(%{})
  end

  defp fetch_initial_data(socket, params) do
    {pending_approvals, pagination} = get_pending_approvals_with_pagination(params)
    stats = get_approval_stats()

    socket
    |> assign(:pending_approvals, pending_approvals)
    |> assign(:pagination, pagination)
    |> assign(:params, params)
    |> assign(:stats, stats)
    |> assign(:data_loader, false)
  end

  defp fetch_pending_approvals(socket, params) do
    {pending_approvals, pagination} = get_pending_approvals_with_pagination(params)
    stats = get_approval_stats()

    # Hide loader and update data
    socket = push_event(socket, "hide-loader", %{id: "approvals-loader"})

    {:noreply,
     socket
     |> assign(:pending_approvals, pending_approvals)
     |> assign(:pagination, pagination)
     |> assign(:params, params)
     |> assign(:stats, stats)
     |> assign(:data_loader, false)}
  end

  defp get_pending_approvals_with_pagination(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "20")
    sort_field = params["sort_field"] || "inserted_at"
    sort_direction = params["sort_direction"] || "desc"

    pending_approvals = get_pending_approvals(page, per_page, sort_field, sort_direction, extract_filters(params))
    total_count = get_total_pending_count(extract_filters(params))

    pagination = %{
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: :math.ceil(total_count / per_page),
      sort_field: sort_field,
      sort_direction: sort_direction
    }

    {pending_approvals, pagination}
  end

  defp get_pending_approvals(page, per_page, sort_field, sort_direction, filters) do
    offset = (page - 1) * per_page

    User
    |> where([u], u.status == "PENDING_APPROVAL" or (u.approved == false and u.status != "REJECTED"))
    |> apply_filters(filters)
    |> apply_sorting(sort_field, sort_direction)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()
  end

  defp get_total_pending_count(filters) do
    User
    |> where([u], u.status == "PENDING_APPROVAL" or (u.approved == false and u.status != "REJECTED"))
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
    filters
  end

  defp get_approval_stats do
    total_pending = Repo.aggregate(from(u in User, where: u.status == "PENDING_APPROVAL" or (u.approved == false and u.status != "REJECTED")), :count, :id)
    pending_learners = Repo.aggregate(from(u in User, where: (u.status == "PENDING_APPROVAL" or (u.approved == false and u.status != "REJECTED")) and u.user_type == "LEARNER"), :count, :id)
    pending_instructors = Repo.aggregate(from(u in User, where: (u.status == "PENDING_APPROVAL" or (u.approved == false and u.status != "REJECTED")) and u.user_type == "INSTRUCTOR"), :count, :id)
    today_requests = Repo.aggregate(from(u in User, where: (u.status == "PENDING_APPROVAL" or (u.approved == false and u.status != "REJECTED")) and fragment("DATE(?)", u.inserted_at) == fragment("CURRENT_DATE")), :count, :id)

    # Get total users for the stats component
    total_users = Repo.aggregate(from(u in User), :count, :id)

    # Get total roles for the stats component
    total_roles = Repo.aggregate(from(r in Signease.Roles.UserRole), :count, :id)

    # Active sessions (placeholder for now)
    active_sessions = 0

    %{
      total_pending: total_pending,
      pending_learners: pending_learners,
      pending_instructors: pending_instructors,
      today_requests: today_requests,
      # Required by StatsCardsComponent
      total_users: total_users,
      pending_approvals: total_pending,
      total_roles: total_roles,
      active_sessions: active_sessions,
      stats_cards: [
        %{color: "blue", icon: "clock", title: "Total Pending", value: total_pending},
        %{color: "green", icon: "academic-cap", title: "Pending Learners", value: pending_learners},
        %{color: "yellow", icon: "user-group", title: "Pending Instructors", value: pending_instructors},
        %{color: "purple", icon: "calendar", title: "Today's Requests", value: today_requests}
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
      _ -> "Unknown"
    end
  end

  defp get_status_class(status) do
    case status do
      "ACTIVE" -> "bg-green-100 text-green-800"
      "PENDING_APPROVAL" -> "bg-yellow-100 text-yellow-800"
      "REJECTED" -> "bg-red-100 text-red-800"
      "DISABLED" -> "bg-gray-100 text-gray-800"
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
              user_type: user.user_type,
              user_role: admin_type
            }
        end
    end
  end
end
