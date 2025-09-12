defmodule SigneaseWeb.Admin.Users.Learners.LearnersLive do
  use SigneaseWeb, :live_view
  import Ecto.Query

  alias Signease.Repo
  alias Signease.Accounts
  alias Signease.Accounts.User
  alias Signease.Notifications
  import SigneaseWeb.Components.LoaderComponent

  @url "/admin/learners"

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
        title: "Learner Management",
        description: "Manage learners and their learning progress."
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    if connected?(socket), do: send(self(), {:fetch_learners, params})

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
    |> assign(:page_title, "Learner Management")
    |> assign(:learner, nil)
    |> assign(:show_modal, false)
  end

  defp apply_action(socket, nil, _params) do
    socket
    |> assign(:page_title, "Learner Management")
    |> assign(:learner, nil)
    |> assign(:show_modal, false)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Learner")
    |> assign(:learner, %User{})
    |> assign(:show_modal, true)
    |> assign(:action, :new)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Learner")
    |> assign(:learner, Accounts.get_user!(id))
    |> assign(:show_modal, true)
    |> assign(:action, :edit)
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Learner Details")
    |> assign(:learner, Accounts.get_user!(id))
    |> assign(:show_modal, false)
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
      "block" -> handle_show_block_confirmation(params, socket)
      "delete" -> handle_show_delete_confirmation(params, socket)
      "reset_password" -> handle_reset_password_event(params, socket)
      "reload" -> handle_reload(socket)
      "export_pdf" -> handle_export_pdf(socket, params)
      "export_csv" -> handle_export_csv(socket, params)
      "export_excel" -> handle_export_excel(socket, params)
      "change_page" -> handle_change_page(params, socket)
      "change_per_page" -> handle_change_per_page(params, socket)
      "sort" -> handle_sort_event(params, socket)
      "show_create_modal" -> handle_show_create_modal(socket)
      "close_modal" -> handle_close_modal(socket)
      _ -> {:noreply, socket}
    end
  end

  defp handle_info_switch(socket, data) do
    case data do
      {:fetch_learners, params} -> fetch_learners(socket, params)
      {SigneaseWeb.Admin.Users.Components.LearnerFormComponent, {:saved, _learner}} ->
        # Refresh the learners list after saving
        send(self(), {:fetch_learners, socket.assigns.params})
        {:noreply,
         socket
         |> assign(:show_modal, false)
         |> put_flash(:info, "Learner saved successfully.")}
      {SigneaseWeb.Admin.Users.Components.LearnerFormComponent, :close_modal} ->
        {:noreply,
         socket
         |> assign(:show_modal, false)
         |> assign(:learner, nil)}
      {:close_confirmation_modal, _modal_id} ->
        {:noreply, assign(socket, :show_confirmation_modal, false)}
      {:confirm_action, action, params} ->
        handle_confirmed_action(action, params, socket)
      _ -> {:noreply, socket}
    end
  end

  # =============================================================================
  # MODAL HANDLERS
  # =============================================================================

    defp handle_show_create_modal(socket) do
    {:noreply,
     socket
     |> assign(:show_modal, true)
     |> assign(:learner, %User{})
     |> assign(:action, :new)}
  end

  defp handle_close_modal(socket) do
    {:noreply,
     socket
     |> assign(:show_modal, false)
     |> assign(:learner, nil)}
  end

  # =============================================================================
  # ACTION HANDLERS
  # =============================================================================

  defp handle_approve_event(%{"id" => id}, socket) do
    learner = Accounts.get_user!(id)

    case Accounts.approve_user(learner, socket.assigns.current_user.id) do
      {:ok, _learner} ->
        # Refresh the learners list
        send(self(), {:fetch_learners, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "Learner approved successfully.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve learner: #{reason}")}
    end
  end

  defp handle_reject_event(%{"id" => id, "reason" => reason}, socket) do
    learner = Accounts.get_user!(id)

    case Accounts.reject_user(learner, socket.assigns.current_user.id, reason) do
      {:ok, _learner} ->
        # Refresh the learners list
        send(self(), {:fetch_learners, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "Learner rejected successfully.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reject learner: #{reason}")}
    end
  end

  defp handle_disable_event(%{"id" => id, "reason" => reason}, socket) do
    learner = Accounts.get_user!(id)

    case Accounts.disable_user(learner, socket.assigns.current_user.id, reason) do
      {:ok, _learner} ->
        # Refresh the learners list
        send(self(), {:fetch_learners, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "Learner disabled successfully.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to disable learner: #{reason}")}
    end
  end

  defp handle_enable_event(%{"id" => id}, socket) do
    learner = Accounts.get_user!(id)

    case Accounts.enable_user(learner, socket.assigns.current_user.id) do
      {:ok, _learner} ->
        # Refresh the learners list
        send(self(), {:fetch_learners, socket.assigns.params})
        {:noreply,
         socket
         |> put_flash(:info, "Learner enabled successfully.")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to enable learner: #{reason}")}
    end
  end

  defp handle_block_event(%{"id" => id}, socket) do
    learner = Accounts.get_user!(id)

    # Prevent blocking the default admin user (ID 1) or seed users
    if learner.id == 1 or Accounts.is_seed_user?(learner) do
      {:noreply,
       socket
       |> put_flash(:error, "Cannot block system users (default admin or seed users).")}
    else
      case Accounts.block_user(learner, socket.assigns.current_user.id) do
        {:ok, _learner} ->
          # Refresh the learners list
          send(self(), {:fetch_learners, socket.assigns.params})
          {:noreply,
           socket
           |> put_flash(:info, "Learner blocked successfully.")}

        {:error, reason} ->
          {:noreply,
           socket
           |> put_flash(:error, "Failed to block learner: #{reason}")}
      end
    end
  end

  defp handle_delete_event(%{"id" => id}, socket) do
    learner = Accounts.get_user!(id)

    # Prevent deleting the default admin user (ID 1) or seed users
    if learner.id == 1 or Accounts.is_seed_user?(learner) do
      {:noreply,
       socket
       |> put_flash(:error, "Cannot delete system users (default admin or seed users).")}
    else
      case Accounts.soft_delete_user(learner, socket.assigns.current_user.id) do
        {:ok, _learner} ->
          # Refresh the learners list
          send(self(), {:fetch_learners, socket.assigns.params})
          {:noreply,
           socket
           |> put_flash(:info, "Learner deleted successfully.")}

        {:error, reason} ->
          {:noreply,
           socket
           |> put_flash(:error, "Failed to delete learner: #{reason}")}
      end
    end
  end

  defp handle_reset_password_event(%{"id" => id}, socket) do
    case Accounts.reset_user_password(id) do
      {:ok, _learner, _new_password} ->
        # Refresh the learners list
        send(self(), {:fetch_learners, socket.assigns.params})
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
  # CONFIRMATION HANDLERS
  # =============================================================================

  defp handle_show_delete_confirmation(%{"id" => id}, socket) do
    learner = Accounts.get_user!(id)

    {:noreply,
     socket
     |> assign(:show_confirmation_modal, true)
     |> assign(:confirmation_action, "delete")
     |> assign(:confirmation_params, %{"id" => id, "user_name" => "#{learner.first_name} #{learner.last_name}"})}
  end

  defp handle_show_block_confirmation(%{"id" => id}, socket) do
    learner = Accounts.get_user!(id)

    {:noreply,
     socket
     |> assign(:show_confirmation_modal, true)
     |> assign(:confirmation_action, "block")
     |> assign(:confirmation_params, %{"id" => id, "user_name" => "#{learner.first_name} #{learner.last_name}"})}
  end

  defp handle_confirmed_action("delete", params, socket) do
    case handle_delete_event(params, socket) do
      {:noreply, updated_socket} ->
        {:noreply, assign(updated_socket, :show_confirmation_modal, false)}
      other ->
        other
    end
  end

  defp handle_confirmed_action("block", params, socket) do
    case handle_block_event(params, socket) do
      {:noreply, updated_socket} ->
        {:noreply, assign(updated_socket, :show_confirmation_modal, false)}
      other ->
        other
    end
  end

  # =============================================================================
  # PAGINATION HANDLERS
  # =============================================================================

  defp handle_change_page(%{"page" => page}, socket) do
    current_params = socket.assigns.params
    new_params = Map.put(current_params, "page", page)

    {:noreply,
     socket
     |> assign(:params, new_params)
     |> then(fn socket -> send(self(), {:fetch_learners, new_params}); socket end)}
  end

  defp handle_change_per_page(%{"per_page" => per_page}, socket) do
    current_params = socket.assigns.params
    new_params = Map.merge(current_params, %{"per_page" => per_page, "page" => "1"})

    {:noreply,
     socket
     |> assign(:params, new_params)
     |> then(fn socket -> send(self(), {:fetch_learners, new_params}); socket end)}
  end

  defp handle_sort_event(%{"sort_field" => field, "sort_direction" => direction}, socket) do
    current_params = socket.assigns.params
    new_params = Map.merge(current_params, %{"sort_field" => field, "sort_direction" => direction})

    {:noreply,
     socket
     |> assign(:params, new_params)
     |> then(fn socket -> send(self(), {:fetch_learners, new_params}); socket end)}
  end

  # =============================================================================
  # DATA FETCHING
  # =============================================================================

  defp fetch_learners(socket, params) do
    {learners, pagination} = get_learners_with_pagination_and_filters(params)
    stats = get_learner_stats()

    {:noreply,
     assign(socket, :learners, learners)
     |> assign(:pagination, pagination)
     |> assign(:stats, stats)
     |> assign(:data_loader, false)}
  end

  defp get_learners_with_pagination_and_filters(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "20")
    sort_field = params["sort_field"] || "inserted_at"
    sort_direction = params["sort_direction"] || "desc"

    # Get learners (users with user_type = "LEARNER")
    learners = get_learners_with_pagination(page, per_page, sort_field, sort_direction)
    total_count = get_learners_count()

    pagination = %{
      current_page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: ceil(total_count / per_page),
      has_prev: page > 1,
      has_next: page < ceil(total_count / per_page)
    }

    {learners, pagination}
  end

  defp get_learners_with_pagination(page, per_page, sort_field, sort_direction) do
    User
    |> where([u], u.user_type == "LEARNER" and is_nil(u.deleted_at))
    |> apply_learners_sorting(sort_field, sort_direction)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
  end

  defp get_learners_count() do
    User
    |> where([u], u.user_type == "LEARNER" and is_nil(u.deleted_at))
    |> Repo.aggregate(:count, :id)
  end

  defp apply_learners_sorting(query, sort_field, sort_direction) do
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

  defp handle_reload(socket) do
    {:noreply,
     socket
     |> assign(:params, %{})
     |> then(fn socket -> send(self(), {:fetch_learners, %{}}); socket end)}
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
    |> assign(:learners, [])
    |> assign(:pagination, %{})
    |> assign(:data_loader, true)
    |> assign(:error_modal, false)
    |> assign(:success_modal, false)
    |> assign(:error_message, "")
    |> assign(:success_message, "")
    |> assign(:show_modal, false)
    |> assign(:learner, nil)
    |> assign(:action, nil)
    |> assign(:show_confirmation_modal, false)
    |> assign(:confirmation_action, nil)
    |> assign(:confirmation_params, nil)
    |> assign(:stats, get_learner_stats())
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

  defp get_learner_stats do
    total_learners = Repo.aggregate(from(u in User, where: u.user_type == "LEARNER" and is_nil(u.deleted_at)), :count, :id)
    active_learners = Repo.aggregate(from(u in User, where: u.user_type == "LEARNER" and u.status == "ACTIVE" and is_nil(u.deleted_at)), :count, :id)
    pending_learners = Repo.aggregate(from(u in User, where: u.user_type == "LEARNER" and u.status == "PENDING_APPROVAL" and is_nil(u.deleted_at)), :count, :id)
    hearing_learners = Repo.aggregate(from(u in User, where: u.user_type == "LEARNER" and u.hearing_status == "HEARING" and is_nil(u.deleted_at)), :count, :id)
    deaf_learners = Repo.aggregate(from(u in User, where: u.user_type == "LEARNER" and u.hearing_status == "DEAF" and is_nil(u.deleted_at)), :count, :id)

    %{
      total_users: total_learners,
      active_users: active_learners,
      pending_approvals: pending_learners,
      disabled_users: 0,
      total_roles: 0,
      active_sessions: 0,
      stats_cards: [
      %{
        title: "Total Learners",
        value: total_learners,
        icon: "academic-cap",
        color: "blue"
      },
      %{
        title: "Active Learners",
        value: active_learners,
        icon: "check-circle",
        color: "green"
      },
      %{
        title: "Pending Approval",
        value: pending_learners,
        icon: "clock",
        color: "yellow"
      },
      %{
          title: "Hearing Status",
          value: "#{hearing_learners} Hearing / #{deaf_learners} Deaf",
          icon: "ear",
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


end
