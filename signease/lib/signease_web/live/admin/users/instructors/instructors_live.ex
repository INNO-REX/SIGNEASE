defmodule SigneaseWeb.Admin.Users.Instructors.InstructorsLive do
  use SigneaseWeb, :live_view
  import Ecto.Query

  alias Signease.Repo
  alias Signease.Accounts
  alias Signease.Accounts.User
  alias SigneaseWeb.Helpers.Utils, as: Util
  import SigneaseWeb.Components.LoaderComponent

  @url "/admin/instructors"

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
        title: "Instructor Management",
        description: "Manage instructors and their teaching capabilities."
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    if connected?(socket), do: send(self(), {:fetch_instructors, params})

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
    |> assign(:page_title, "Instructor Management")
    |> assign(:user, nil)
  end

  defp apply_action(socket, nil, _params) do
    socket
    |> assign(:page_title, "Instructor Management")
    |> assign(:user, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Instructor")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Instructor")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Instructor Details")
    |> assign(:user, Accounts.get_user!(id))
  end

  defp apply_action(socket, :filter, _params) do
    socket
    |> assign(:page_title, "Filter Instructors")
    |> assign(:filter_params, %{})
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
      "reset_password" -> handle_reset_password_event(params, socket)
      "reload" -> handle_reload(socket)
      "open_filter" -> open_filter_modal(socket)
      "filter" -> fetch_instructors(socket, params)
      "iSearch" -> fetch_instructors(socket, params)
      "export_pdf" -> handle_export_pdf(socket, params)
      "export_csv" -> handle_export_csv(socket, params)
      "export_excel" -> handle_export_excel(socket, params)
      _ -> {:noreply, socket}
    end
  end

  defp handle_info_switch(socket, data) do
    case data do
      :fetch_instructors ->
        fetch_instructors(socket, %{"sort_direction" => "desc", "sort_field" => "id"})

      {:fetch_instructors, params} ->
        fetch_instructors(socket, params)

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
         |> put_flash(:info, "Instructor approved successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve instructor: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_reject_event(%{"id" => id}, socket) do
    case Accounts.reject_user(id, socket.assigns.current_user.id, "Rejected by admin") do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Instructor rejected successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reject instructor: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_disable_event(%{"id" => id}, socket) do
    case Accounts.disable_user(id, socket.assigns.current_user.id, "Disabled by admin") do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Instructor disabled successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to disable instructor: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_enable_event(%{"id" => id}, socket) do
    case Accounts.enable_user(id, socket.assigns.current_user.id) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Instructor enabled successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to enable instructor: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_delete_event(%{"id" => id}, socket) do
    case Accounts.delete_user(id, socket.assigns.current_user.id) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Instructor deleted successfully.")
         |> push_navigate(to: @url, replace: true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete instructor: #{reason}")
         |> push_navigate(to: @url, replace: true)}
    end
  end

  defp handle_reset_password_event(%{"id" => id}, socket) do
    case Accounts.reset_user_password(id) do
      {:ok, _user} ->
        send(self(), {:fetch_instructors, %{"sort_direction" => "desc", "sort_field" => "id"}})
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully. New password sent via SMS and email.")}

      {:error, reason} ->
        send(self(), {:fetch_instructors, %{"sort_direction" => "desc", "sort_field" => "id"}})
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reset password: #{reason}")}
    end
  end

  defp open_filter_modal(socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/instructors/filter")}
  end

  # =============================================================================
  # DATA FETCHING & PAGINATION
  # =============================================================================

  defp fetch_instructors(socket, params) do
    data = get_instructors_with_filters(params)
    pagination = Util.generate_pagination_details(data)
    stats = get_instructor_stats()

    {:noreply,
     assign(socket, :data, data)
     |> assign(:pagination, pagination)
     |> assign(:stats, stats)
     |> assign(:data_loader, false)
     |> assign(:filter_modal, false)
     |> assign(:params, params)}
  end

  defp get_instructors_with_filters(params) do
    search = Map.get(params, "search", "")
    status = Map.get(params, "status", "")
    hearing_status = Map.get(params, "hearing_status", "")
    gender = Map.get(params, "gender", "")

    User
    |> preload([:role])
    |> where([u], u.user_type == "INSTRUCTOR")
    |> filter_by_search(search)
    |> filter_by_status(status)
    |> filter_by_hearing_status(hearing_status)
    |> filter_by_gender(gender)
    |> order_by([u], [desc: u.inserted_at])
    |> Repo.all()
  end

  defp filter_by_search(query, ""), do: query
  defp filter_by_search(query, search) do
    search_term = "%#{search}%"
    from(u in query,
      where: ilike(u.first_name, ^search_term) or
             ilike(u.last_name, ^search_term) or
             ilike(u.email, ^search_term) or
             ilike(u.username, ^search_term)
    )
  end

  defp filter_by_status(query, ""), do: query
  defp filter_by_status(query, status) do
    from(u in query, where: u.status == ^status)
  end

  defp filter_by_hearing_status(query, ""), do: query
  defp filter_by_hearing_status(query, hearing_status) do
    from(u in query, where: u.hearing_status == ^hearing_status)
  end

  defp filter_by_gender(query, ""), do: query
  defp filter_by_gender(query, gender) do
    from(u in query, where: u.gender == ^gender)
  end

  defp handle_reload(socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/instructors")}
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
    |> assign(:data, [])
    |> assign(:data_loader, true)
    |> assign(:filter_modal, false)
    |> assign(:filter_params, %{})
    |> assign(:pagination, nil)
    |> assign(:stats, get_instructor_stats())
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

  defp get_instructor_stats do
    total_instructors = Repo.aggregate(from(u in User, where: u.user_type == "INSTRUCTOR"), :count, :id)
    active_instructors = Repo.aggregate(from(u in User, where: u.user_type == "INSTRUCTOR" and u.user_status == "ACTIVE"), :count, :id)
    pending_instructors = Repo.aggregate(from(u in User, where: u.user_type == "INSTRUCTOR" and u.status == "PENDING_APPROVAL"), :count, :id)
    disabled_instructors = Repo.aggregate(from(u in User, where: u.user_type == "INSTRUCTOR" and u.disabled == true), :count, :id)

    %{
      total_users: total_instructors,
      active_users: active_instructors,
      pending_approvals: pending_instructors,
      disabled_users: disabled_instructors,
      total_roles: 0,
      active_sessions: 0,
      stats_cards: [
        %{
          title: "Total Instructors",
          value: total_instructors,
          icon: "academic-cap",
          color: "purple"
        },
        %{
          title: "Active Instructors",
          value: active_instructors,
          icon: "check-circle",
          color: "green"
        },
        %{
          title: "Pending Approval",
          value: pending_instructors,
          icon: "clock",
          color: "yellow"
        },
        %{
          title: "Disabled Instructors",
          value: disabled_instructors,
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

  def format_hearing_status(status) do
    case status do
      "HEARING" -> "Hearing"
      "DEAF" -> "Deaf"
      "HARD_OF_HEARING" -> "Hard of Hearing"
      _ -> status || "N/A"
    end
  end

  def format_sign_language_skills(skills) do
    case skills do
      "BEGINNER" -> "Beginner"
      "INTERMEDIATE" -> "Intermediate"
      "ADVANCED" -> "Advanced"
      "FLUENT" -> "Fluent"
      _ -> skills || "N/A"
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

  def get_hearing_status_class(status) do
    case status do
      "HEARING" -> "bg-green-100 text-green-800"
      "DEAF" -> "bg-blue-100 text-blue-800"
      "HARD_OF_HEARING" -> "bg-yellow-100 text-yellow-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  def get_skills_class(skills) do
    case skills do
      "BEGINNER" -> "bg-blue-100 text-blue-800"
      "INTERMEDIATE" -> "bg-yellow-100 text-yellow-800"
      "ADVANCED" -> "bg-orange-100 text-orange-800"
      "FLUENT" -> "bg-green-100 text-green-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end
end
