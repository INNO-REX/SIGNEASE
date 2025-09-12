defmodule SigneaseWeb.Lecturer.Analytics.AnalyticsLive do
  use SigneaseWeb, :live_view

  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      analytics: get_analytics_for_lecturer(1),
      current_user: get_current_user(),
      page_title: "Analytics Dashboard",
      current_path: "/lecturer/analytics",
      current_page: "analytics",
      stats: get_analytics_stats(),
      filters: %{}
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    analytics = get_analytics_for_lecturer(socket.assigns.current_user.id)
    {:noreply, assign(socket, analytics: analytics)}
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

  defp get_analytics_for_lecturer(_lecturer_id) do
    [
      %{label: "Active Students", value: 22},
      %{label: "Completed Courses", value: 5},
      %{label: "Average Progress", value: 76.2},
      %{label: "Session Attendance Rate", value: 89.5},
      %{label: "Assessment Pass Rate", value: 92.0}
    ]
  end

  defp get_analytics_stats do
    %{
      total_students: 22,
      completed_courses: 5,
      average_progress: 76.2,
      session_attendance_rate: 89.5,
      assessment_pass_rate: 92.0,
      average_student_rating: 0.0,
      total_users: 0,
      pending_approvals: 0,
      total_roles: 0,
      active_sessions: 0,
      stats_cards: [
        %{
          title: "Active Students",
          value: 22,
          icon: "users",
          color: "blue"
        },
        %{
          title: "Completed Courses",
          value: 5,
          icon: "academic-cap",
          color: "green"
        },
        %{
          title: "Avg. Progress",
          value: 76.2,
          icon: "chart-bar",
          color: "yellow"
        },
        %{
          title: "Attendance Rate",
          value: 89.5,
          icon: "calendar-days",
          color: "purple"
        }
      ]
    }
  end
end