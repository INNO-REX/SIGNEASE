defmodule SigneaseWeb.Lecturer.Students.StudentsLive do
  use SigneaseWeb, :live_view

  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      students: get_students_for_lecturer(1),
      current_user: get_current_user(),
      page_title: "Student Management",
      current_path: "/lecturer/students",
      current_page: "students",
      stats: get_student_stats(),
      filters: %{},
      selected_student: nil,
      show_student_modal: false,
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    students = get_students_for_lecturer(socket.assigns.current_user.id)
    {:noreply, assign(socket, students: students)}
  end

  @impl true
  def handle_event("view_student", %{"id" => id}, socket) do
    student = Enum.find(socket.assigns.students, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_student: student, show_student_modal: true)}
  end

  @impl true
  def handle_event("close_student_modal", _params, socket) do
    {:noreply, assign(socket, show_student_modal: false, selected_student: nil)}
  end

  @impl true
  def handle_event("filter_students", %{"filters" => filters}, socket) do
    filtered_students = apply_filters(socket.assigns.students, filters)
    {:noreply, assign(socket, students: filtered_students, filters: filters)}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    students = get_students_for_lecturer(socket.assigns.current_user.id)
    {:noreply, assign(socket, students: students, filters: %{})}
  end


  # =============================================================================
  # HELPER FUNCTIONS
  # =============================================================================

  defp get_current_user do
    %{
      id: 1,
      first_name: "John",
      last_name: "Instructor",
      email: "instructor@signease.com",
      user_type: "INSTRUCTOR",
      user_role: "TEACHER",
      sign_language_skills: "beginner",
      profile_picture: nil,
      gender: "male",
      phone: "123-456-7890",
      status: "ACTIVE",
      hearing_status: "HEARING",
      preferred_language: "en",
      education_level: "masters",
      years_experience: 5,
      subjects_expertise: "Computer Science, Accessibility",
      program: nil,
      enrolled_year: nil,
      semester: nil
    }
  end

  defp get_students_for_lecturer(_lecturer_id) do
    [
      %{
        id: 1,
        first_name: "Alice",
        last_name: "Smith",
        email: "alice@example.com",
        status: "ACTIVE",
        enrolled_at: ~N[2024-01-15 09:00:00],
        progress: 80
      },
      %{
        id: 2,
        first_name: "Bob",
        last_name: "Johnson",
        email: "bob@example.com",
        status: "INACTIVE",
        enrolled_at: ~N[2024-02-10 10:00:00],
        progress: 45
      },
      %{
        id: 3,
        first_name: "Carol",
        last_name: "Williams",
        email: "carol@example.com",
        status: "ACTIVE",
        enrolled_at: ~N[2024-03-05 11:00:00],
        progress: 95
      }
    ]
  end

  defp get_student_stats do
    %{
      total_students: 3,
      active_students: 2,
      inactive_students: 1,
      average_progress: 73.3,
      average_student_rating: 0.0,
      total_users: 0,
      pending_approvals: 0,
      total_roles: 0,
      active_sessions: 0,
      stats_cards: [
        %{
          title: "Total Students",
          value: 3,
          icon: "users",
          color: "blue"
        },
        %{
          title: "Active Students",
          value: 2,
          icon: "user-group",
          color: "green"
        },
        %{
          title: "Inactive Students",
          value: 1,
          icon: "user-minus",
          color: "gray"
        },
        %{
          title: "Avg. Progress",
          value: 73.3,
          icon: "chart-bar",
          color: "yellow"
        }
      ]
    }
  end

  defp apply_filters(students, _filters) do
    students
  end
end