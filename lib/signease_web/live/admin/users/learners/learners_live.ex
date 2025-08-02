defmodule SigneaseWeb.Admin.Users.Learners.LearnersLive do
  use SigneaseWeb, :live_view

  alias Signease.Learners
  alias Signease.Learners.Learner
  alias SigneaseWeb.Admin.Users.Components.FilterComponent
  alias SigneaseWeb.Admin.Users.Components.PaginationComponent

  @url ~p"/admin/learners"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_initial_state(socket)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, %{"id" => id})}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, nil)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "View Learner")
    |> assign(:learner, Learners.get_learner!(id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Learner")
    |> assign(:learner, Learners.get_learner!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Learner")
    |> assign(:learner, %Learner{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Learners")
    |> assign(:learner, nil)
  end

  defp apply_action(socket, nil, _params) do
    socket
    |> assign(:page_title, "Learners")
    |> assign(:learner, nil)
  end

  @impl true
  def handle_event("show_create_modal", _params, socket) do
    {:noreply, handle_show_create_modal(socket)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, handle_close_modal(socket)}
  end

  @impl true
  def handle_event("filter", %{"filters" => filters}, socket) do
    {:noreply, fetch_learners(socket, %{filters: filters, page: 1})}
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    {:noreply, fetch_learners(socket, %{page: page})}
  end

  @impl true
  def handle_event("change_per_page", %{"per_page" => per_page}, socket) do
    per_page = String.to_integer(per_page)
    {:noreply, fetch_learners(socket, %{per_page: per_page, page: 1})}
  end

  @impl true
  def handle_info({:fetch_learners, params}, socket) do
    {:noreply, fetch_learners(socket, params)}
  end

  @impl true
  def handle_info({SigneaseWeb.Admin.Users.Components.LearnerFormComponent, {:saved, _learner}}, socket) do
    {:noreply,
     socket
     |> assign(:show_modal, false)}
  end

  @impl true
  def handle_info({SigneaseWeb.Admin.Users.Components.LearnerFormComponent, :close_modal}, socket) do
    {:noreply,
     socket
     |> assign(:show_modal, false)
     |> assign(:learner, nil)}
  end

  defp fetch_learners(socket, params \\ %{}) do
    filters = Map.get(params, :filters, socket.assigns.filters)
    page = Map.get(params, :page, socket.assigns.pagination.current_page)
    per_page = Map.get(params, :per_page, socket.assigns.pagination.per_page)

    result = Learners.list_learners_with_pagination(
      page: page,
      per_page: per_page,
      filters: filters
    )

    socket
    |> assign(:learners, result.learners)
    |> assign(:pagination, result.pagination)
    |> assign(:filters, filters)
    |> assign(:data_loader, false)
  end

  defp assign_initial_state(socket) do
    current_user = get_current_user()
    stats = get_learner_stats()

    socket
    |> assign(:current_user, current_user)
    |> assign(:current_path, @url)
    |> assign(:title, "Learner Management")
    |> assign(:description, "Manage learners and their learning progress.")
    |> assign(:learners, [])
    |> assign(:pagination, %{current_page: 1, per_page: 20, total_count: 0, total_pages: 1, has_prev: false, has_next: false})
    |> assign(:filters, %{search: "", hearing_status: "", gender: "", access_type: ""})
    |> assign(:data_loader, true)
    |> assign(:show_modal, false)
    |> assign(:learner, nil)
    |> assign(:action, nil)
    |> assign(:stats, stats)
    |> fetch_learners()
  end

  defp get_current_user do
    # This should be replaced with actual user session logic
    %{id: 1, email: "admin@signease.com", first_name: "System", last_name: "Admin", user_role: "ADMIN", user_type: "ADMIN"}
  end

  defp get_learner_stats do
    stats = Learners.get_learner_stats()
    %{
      active_sessions: 0,
      active_users: stats.total_learners,
      disabled_users: 0,
      pending_approvals: 0,
      stats_cards: [
        %{color: "blue", icon: "academic-cap", title: "Total Learners", value: stats.total_learners},
        %{color: "green", icon: "check-circle", title: "Hearing Learners", value: stats.hearing_learners},
        %{color: "yellow", icon: "clock", title: "Deaf Learners", value: stats.deaf_learners},
        %{color: "purple", icon: "trophy", title: "Students", value: stats.students}
      ],
      total_roles: 0,
      total_users: stats.total_learners
    }
  end

  defp handle_show_create_modal(socket) do
    {:noreply,
     socket
     |> assign(:show_modal, true)
     |> assign(:learner, %Learner{})
     |> assign(:action, :new)}
  end

  defp handle_close_modal(socket) do
    {:noreply,
     socket
     |> assign(:show_modal, false)
     |> assign(:learner, nil)}
  end

  # Helper functions for rendering
  defp get_hearing_status_class("deaf"), do: "bg-red-100 text-red-800"
  defp get_hearing_status_class("hearing"), do: "bg-green-100 text-green-800"
  defp get_hearing_status_class(_), do: "bg-gray-100 text-gray-800"

  defp format_hearing_status("deaf"), do: "Deaf"
  defp format_hearing_status("hearing"), do: "Hearing"
  defp format_hearing_status(_), do: "Unknown"

  defp get_access_type_class("student"), do: "bg-blue-100 text-blue-800"
  defp get_access_type_class("teacher"), do: "bg-purple-100 text-purple-800"
  defp get_access_type_class("admin"), do: "bg-red-100 text-red-800"
  defp get_access_type_class(_), do: "bg-gray-100 text-gray-800"

  defp format_access_type("student"), do: "Student"
  defp format_access_type("teacher"), do: "Teacher"
  defp format_access_type("admin"), do: "Admin"
  defp format_access_type(_), do: "Unknown"
end
