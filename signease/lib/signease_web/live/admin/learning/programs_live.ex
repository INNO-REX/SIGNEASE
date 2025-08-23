defmodule SigneaseWeb.Admin.Learning.ProgramsLive do
  use SigneaseWeb, :live_view

  alias Signease.Learning
  alias Signease.Learning.Program
  alias Signease.Accounts

  @impl true
  def mount(_params, session, socket) do
    # Get current user from session
    current_user = get_current_user(session)

    socket =
      socket
      |> assign_initial_state()
      |> assign(
        current_user: current_user,
        title: "Program Management",
        description: "Create and manage learning programs, assign instructors, and enroll learners"
      )

    {:ok, socket}
  end

  defp assign_initial_state(socket) do
    socket
    |> assign(:current_path, "/admin/programs")
    |> assign(:live_action, :index)
    |> assign(:programs, [])
    |> assign(:pagination, %{})
    |> assign(:data_loader, true)
    |> assign(:error_modal, false)
    |> assign(:success_modal, false)
    |> assign(:error_message, "")
    |> assign(:success_message, "")
    |> assign(:show_form, false)
    |> assign(:program, %Program{})
    |> assign(:editing_program, nil)
    |> assign(:instructors, Accounts.list_users_by_type("INSTRUCTOR"))
    |> assign(:learners, Accounts.list_users_by_type("LEARNER"))
    |> assign(:stats, get_program_stats())
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

  defp get_program_stats do
    total_programs = Learning.count_programs()
    active_programs = Learning.count_active_programs()
    total_courses = Learning.count_courses()
    total_enrollments = Learning.count_enrollments()

    %{
      total_users: total_programs,
      active_users: active_programs,
      pending_approvals: total_courses,
      disabled_users: total_enrollments,
      total_roles: 0,
      active_sessions: 0,
      stats_cards: [
        %{
          title: "Total Programs",
          value: total_programs,
          icon: "academic-cap",
          color: "blue"
        },
        %{
          title: "Active Programs",
          value: active_programs,
          icon: "check-circle",
          color: "green"
        },
        %{
          title: "Total Courses",
          value: total_courses,
          icon: "book-open",
          color: "yellow"
        },
        %{
          title: "Total Enrollments",
          value: total_enrollments,
          icon: "users",
          color: "purple"
        }
      ]
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    if connected?(socket), do: send(self(), {:fetch_programs, params})

    {:noreply,
     socket
     |> assign(:params, params)
     |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({:fetch_programs, _params}, socket) do
    programs = Learning.list_programs()
    pagination = %{
      total_count: length(programs),
      page_size: 10,
      current_page: 1,
      total_pages: 1
    }

    {:noreply,
     socket
     |> assign(:programs, programs)
     |> assign(:pagination, pagination)
     |> assign(:data_loader, false)}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  # =============================================================================
  # ROUTE ACTIONS
  # =============================================================================

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Program Management")
    |> assign(:program, %Program{})
    |> assign(:show_form, false)
  end

  defp apply_action(socket, nil, _params) do
    socket
    |> assign(:page_title, "Program Management")
    |> assign(:program, %Program{})
    |> assign(:show_form, false)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Program")
    |> assign(:program, %Program{})
    |> assign(:show_form, true)
    |> assign(:editing_program, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Program")
    |> assign(:program, Learning.get_program!(id))
    |> assign(:show_form, true)
    |> assign(:editing_program, id)
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Program Details")
    |> assign(:program, Learning.get_program!(id))
    |> assign(:show_form, false)
  end

  @impl true
  def handle_event("new", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:editing_program, nil)
     |> assign(:program, %Program{})}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    program = Learning.get_program!(id)
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:editing_program, program)
     |> assign(:program, program)}
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, false)
     |> assign(:editing_program, nil)
     |> assign(:program, %Program{})}
  end

  @impl true
  def handle_event("save", %{"program" => program_params}, socket) do
    save_program(socket, socket.assigns.editing_program, program_params)
  end

  @impl true
  def handle_event("reload", _params, socket) do
    {:noreply,
     socket
     |> assign(:programs, Learning.list_programs())
     |> put_flash(:info, "Programs list refreshed")}
  end

  @impl true
  def handle_event("export_pdf", _params, socket) do
    {:noreply, put_flash(socket, :info, "PDF export - Coming Soon!")}
  end

  @impl true
  def handle_event("export_excel", _params, socket) do
    {:noreply, put_flash(socket, :info, "Excel export - Coming Soon!")}
  end

  @impl true
  def handle_event("export_csv", _params, socket) do
    {:noreply, put_flash(socket, :info, "CSV export - Coming Soon!")}
  end

  @impl true
  def handle_event("view", %{"id" => _id}, socket) do
    {:noreply, put_flash(socket, :info, "Program details view - Coming Soon!")}
  end

  @impl true
  def handle_event("manage_courses", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: "/admin/courses?program_id=#{id}")}
  end

  @impl true
  def handle_event("assign_instructors", %{"id" => _id}, socket) do
    # TODO: Implement instructor assignment to program
    {:noreply, put_flash(socket, :info, "Instructor assignment - Coming Soon!")}
  end

  @impl true
  def handle_event("enroll_learners", %{"id" => _id}, socket) do
    # TODO: Implement learner enrollment in program
    {:noreply, put_flash(socket, :info, "Learner enrollment - Coming Soon!")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    program = Learning.get_program!(id)
    {:ok, _} = Learning.delete_program(program, socket.assigns.current_user.id)

    {:noreply,
     socket
     |> put_flash(:info, "Program deleted successfully")
     |> assign(:programs, Learning.list_programs())}
  end

  @impl true
  def handle_event("assign-instructor", %{"course-id" => course_id, "instructor-id" => instructor_id}, socket) do
    case Learning.assign_instructor_to_course(course_id, instructor_id, socket.assigns.current_user.id) do
      {:ok, _course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Instructor assigned successfully")
         |> assign(:programs, Learning.list_programs())}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to assign instructor")}
    end
  end

  @impl true
  def handle_event("enroll-learner", %{"program-id" => program_id, "learner-id" => learner_id}, socket) do
    case Learning.enroll_learner_in_program(program_id, learner_id, socket.assigns.current_user.id) do
      {:ok, _enrollment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Learner enrolled successfully")
         |> assign(:programs, Learning.list_programs())}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to enroll learner")}
    end
  end

  defp save_program(socket, %Program{} = program, program_params) do
    case Learning.update_program(program, program_params) do
      {:ok, _program} ->
        {:noreply,
         socket
         |> put_flash(:info, "Program updated successfully")
         |> assign(:show_form, false)
         |> assign(:editing_program, nil)
         |> assign(:program, %Program{})
         |> assign(:programs, Learning.list_programs())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :program, changeset)}
    end
  end

  defp save_program(socket, nil, program_params) do
    case Learning.create_program(program_params) do
      {:ok, _program} ->
        {:noreply,
         socket
         |> put_flash(:info, "Program created successfully")
         |> assign(:show_form, false)
         |> assign(:program, %Program{})
         |> assign(:programs, Learning.list_programs())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :program, changeset)}
    end
  end
end
