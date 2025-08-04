defmodule SigneaseWeb.Admin.Users.Admins.AdminsLive do
  use SigneaseWeb, :live_view
  import Ecto.Query

  alias Signease.Repo
  alias Signease.Accounts
  alias Signease.Accounts.User
  alias Signease.Roles
  import SigneaseWeb.Components.LoaderComponent

  @url "/admin/admins"

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
        title: "Administrator Management",
        description: "Manage system administrators and their permissions."
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    if connected?(socket), do: send(self(), {:fetch_admins, params})

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
    |> assign(:page_title, "Administrator Management")
    |> assign(:user, nil)
  end

  defp apply_action(socket, nil, _params) do
    socket
    |> assign(:page_title, "Administrator Management")
    |> assign(:user, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Administrator")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Administrator")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Administrator Details")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :filter, _params) do
    socket
    |> assign(:page_title, "Filter Administrators")
    |> assign(:filter_modal, true)
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
      "show_create_modal" -> handle_show_create_modal(socket)
      "open_filter" -> handle_open_filter(socket)
      "export_pdf" -> handle_export_pdf(socket, params)
      "export_csv" -> handle_export_csv(socket, params)
      "export_excel" -> handle_export_excel(socket, params)
      _ -> {:noreply, socket}
    end
  end

  defp handle_info_switch(socket, data) do
    case data do
      :fetch_admins ->
        fetch_admins(socket, %{"sort_direction" => "desc", "sort_field" => "id"})

      {:fetch_admins, params} ->
        fetch_admins(socket, params)

      {SigneaseWeb.Admin.Users.Components.UserFormComponent, {:saved, _user}} ->
        # Refresh the admins list after saving
        send(self(), {:fetch_admins, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "Administrator saved successfully.")}

      {SigneaseWeb.Admin.Users.Components.UserFormComponent, :close_modal} ->
        {:noreply, socket}

      :close_modal ->
        {:noreply, push_patch(socket, to: ~p"/admin/admins")}

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
         |> put_flash(:info, "Administrator approved successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve administrator: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_reject_event(%{"id" => id}, socket) do
    case Accounts.reject_user(id, socket.assigns.current_user.id, "Rejected by admin") do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Administrator rejected successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reject administrator: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_disable_event(%{"id" => id}, socket) do
    case Accounts.disable_user(id, socket.assigns.current_user.id, "Disabled by admin") do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Administrator disabled successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to disable administrator: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_enable_event(%{"id" => id}, socket) do
    case Accounts.enable_user(id, socket.assigns.current_user.id) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Administrator enabled successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to enable administrator: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_delete_event(%{"id" => id}, socket) do
    case Accounts.delete_user(id, socket.assigns.current_user.id) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Administrator deleted successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete administrator: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  # =============================================================================
  # DATA FETCHING
  # =============================================================================

  defp fetch_admins(socket, params) do
    {admins, pagination} = get_admins_with_pagination_and_filters(params)
    stats = get_admin_stats()

    {:noreply,
     assign(socket, :admins, admins)
     |> assign(:pagination, pagination)
     |> assign(:stats, stats)
     |> assign(:data_loader, false)}
  end

  defp get_admins_with_pagination_and_filters(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "20")
    sort_field = params["sort_field"] || "inserted_at"
    sort_direction = params["sort_direction"] || "desc"

    admins = get_admins_with_pagination(page, per_page, sort_field, sort_direction, extract_filters_for_context(params))

    # Get total count for pagination
    total_count = get_total_admins_count(extract_filters_for_context(params))

    pagination = %{
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: :math.ceil(total_count / per_page),
      sort_field: sort_field,
      sort_direction: sort_direction
    }

    {admins, pagination}
  end

  defp get_admins_with_pagination(page, per_page, sort_field, sort_direction, filters) do
    offset = (page - 1) * per_page

    User
    |> preload([:role])
    |> where([u], u.user_type == "ADMIN" or u.role_id in [1, 2])
    |> apply_filters(filters)
    |> apply_sorting(sort_field, sort_direction)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()
  end

  defp apply_sorting(query, sort_field, sort_direction) do
    sort_direction_atom = String.to_existing_atom(sort_direction)

    case sort_field do
      "first_name" -> order_by(query, [u], [{^sort_direction_atom, u.first_name}])
      "last_name" -> order_by(query, [u], [{^sort_direction_atom, u.last_name}])
      "email" -> order_by(query, [u], [{^sort_direction_atom, u.email}])
      "status" -> order_by(query, [u], [{^sort_direction_atom, u.status}])
      "inserted_at" -> order_by(query, [u], [{^sort_direction_atom, u.inserted_at}])
      _ -> order_by(query, [u], [desc: u.inserted_at])
    end
  end

  defp get_total_admins_count(filters) do
    User
    |> where([u], u.user_type == "ADMIN" or u.role_id in [1, 2])
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
        _ -> acc
      end
    end)
  end

  defp extract_filters_for_context(params) do
    filters = %{}
    filters = if params["search"] && String.trim(params["search"]) != "", do: Map.put(filters, :search, String.trim(params["search"])), else: filters
    filters
  end

      defp handle_reload(socket) do
    Process.send_after(self(), {:fetch_admins, socket.assigns.params}, 100)

    {:noreply,
     socket
     |> push_event("show-loader", %{id: "admins-loader"})}
  end

  defp handle_show_create_modal(socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/admins/new")}
  end

  defp handle_open_filter(socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/admins/filter")}
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
    |> assign(:admins, [])
    |> assign(:pagination, %{})
    |> assign(:data_loader, true)
    |> assign(:filter_modal, false)
    |> assign(:filter_params, %{})
    |> assign(:error_modal, false)
    |> assign(:success_modal, false)
    |> assign(:error_message, "")
    |> assign(:success_message, "")
    |> assign(:stats, get_admin_stats())
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

  defp get_admin_stats do
    total_admins = Repo.aggregate(from(u in User, where: u.user_type == "ADMIN" or u.role_id in [1, 2]), :count, :id)
    active_admins = Repo.aggregate(from(u in User, where: (u.user_type == "ADMIN" or u.role_id in [1, 2]) and u.user_status == "ACTIVE"), :count, :id)
    pending_admins = Repo.aggregate(from(u in User, where: (u.user_type == "ADMIN" or u.role_id in [1, 2]) and u.status == "PENDING_APPROVAL"), :count, :id)
    disabled_admins = Repo.aggregate(from(u in User, where: (u.user_type == "ADMIN" or u.role_id in [1, 2]) and u.disabled == true), :count, :id)

    %{
      total_users: total_admins,
      active_users: active_admins,
      pending_approvals: pending_admins,
      disabled_users: disabled_admins,
      total_roles: 0,
      active_sessions: 0,
      stats_cards: [
        %{
          title: "Total Administrators",
          value: total_admins,
          icon: "shield-check",
          color: "red"
        },
        %{
          title: "Active Administrators",
          value: active_admins,
          icon: "check-circle",
          color: "green"
        },
        %{
          title: "Pending Approval",
          value: pending_admins,
          icon: "clock",
          color: "yellow"
        },
        %{
          title: "Disabled Administrators",
          value: disabled_admins,
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

  def format_admin_role(role_id) do
    case role_id do
      1 -> "Super Admin"
      2 -> "Admin"
      _ -> "Admin"
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

  def get_admin_role_class(role_id) do
    case role_id do
      1 -> "bg-purple-100 text-purple-800"
      2 -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  def get_hearing_status_class(hearing_status) do
    case hearing_status do
      "HEARING" -> "bg-green-100 text-green-800"
      "DEAF" -> "bg-red-100 text-red-800"
      "HARD_OF_HEARING" -> "bg-yellow-100 text-yellow-800"
      "UNKNOWN" -> "bg-gray-100 text-gray-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  def format_hearing_status(hearing_status) do
    case hearing_status do
      "HEARING" -> "Hearing"
      "DEAF" -> "Deaf"
      "HARD_OF_HEARING" -> "Hard of Hearing"
      "UNKNOWN" -> "Unknown"
      _ -> "Unknown"
    end
  end
end
