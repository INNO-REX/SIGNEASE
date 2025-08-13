defmodule SigneaseWeb.Lecturer.Courses.CoursesLive do
  use SigneaseWeb, :live_view

  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Signease.PubSub, "course_updates")
    end

    {:ok, assign(socket,
      courses: [],
      current_user: get_current_user(),
      page_title: "Course Management",
      current_path: "/lecturer/courses",
      current_page: "courses",
      stats: get_course_stats(),
      filters: %{},
      selected_course: nil,
      show_course_modal: false
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    courses = try do
      get_courses_for_lecturer(socket.assigns.current_user.id)
    rescue
      _ -> []
    end

    {:noreply, assign(socket, courses: courses)}
  end

  @impl true
  def handle_event("view_course", %{"id" => id}, socket) do
    course = Enum.find(socket.assigns.courses, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_course: course, show_course_modal: true)}
  end

  @impl true
  def handle_event("close_course_modal", _params, socket) do
    {:noreply, assign(socket, show_course_modal: false, selected_course: nil)}
  end

  @impl true
  def handle_event("filter_courses", %{"filters" => filters}, socket) do
    filtered_courses = apply_filters(socket.assigns.courses, filters)
    {:noreply, assign(socket, courses: filtered_courses, filters: filters)}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    courses = try do
      get_courses_for_lecturer(socket.assigns.current_user.id)
    rescue
      _ -> []
    end
    {:noreply, assign(socket, courses: courses, filters: %{})}
  end

  # =============================================================================
  # HELPER FUNCTIONS
  # =============================================================================

  defp get_current_user do
    # For now, return a default user for development
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

  defp get_courses_for_lecturer(_lecturer_id) do
    [
      %{
        id: 1,
        title: "Introduction to Elixir",
        description: "Learn the basics of Elixir programming and functional concepts.",
        status: "ACTIVE",
        student_count: 25,
        lesson_count: 10
      },
      %{
        id: 2,
        title: "Advanced Phoenix",
        description: "Deep dive into Phoenix LiveView and real-time web apps.",
        status: "DRAFT",
        student_count: 12,
        lesson_count: 8
      },
      %{
        id: 3,
        title: "Accessible Web Design",
        description: "Designing web applications for accessibility and inclusivity.",
        status: "COMPLETED",
        student_count: 30,
        lesson_count: 15
      }
    ]
  end

  defp get_course_stats do
    %{
      total_courses: 0,
      active_courses: 0,
      completed_courses: 0,
      total_students: 0,
      # Add these keys for compatibility with the admin stats component and side nav:
      total_users: 0,
      pending_approvals: 0,
      total_roles: 0,
      active_sessions: 0,
      average_student_rating: 0.0,
      stats_cards: [
        %{
          title: "Total Courses",
          value: 0,
          icon: "academic-cap",
          color: "blue"
        },
        %{
          title: "Active Courses",
          value: 0,
          icon: "play-circle",
          color: "green"
        },
        %{
          title: "Total Students",
          value: 0,
          icon: "users",
          color: "purple"
        },
        %{
          title: "Completed Courses",
          value: 0,
          icon: "check-circle",
          color: "yellow"
        }
      ]
    }
  end

  defp apply_filters(courses, filters) do
    # Placeholder filtering logic
    courses
  end

  defp format_course_status(status) do
    case status do
      "ACTIVE" -> "Active"
      "INACTIVE" -> "Inactive"
      "DRAFT" -> "Draft"
      "COMPLETED" -> "Completed"
      _ -> "Unknown"
    end
  end

  defp get_status_class(status) do
    case status do
      "ACTIVE" -> "bg-green-100 text-green-800"
      "INACTIVE" -> "bg-gray-100 text-gray-800"
      "DRAFT" -> "bg-yellow-100 text-yellow-800"
      "COMPLETED" -> "bg-blue-100 text-blue-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end
end