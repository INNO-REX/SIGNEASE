defmodule SigneaseWeb.Lecturer.Dashboard.LecturerDashboardLive do
  use SigneaseWeb, :live_view

  alias Signease.Accounts
  alias Signease.Roles

  @impl true
  def mount(params, session, socket) do
    # Get current user from session or URL params
    current_user = get_current_user(session, params)

    # Check if user exists and has lecturer permissions
    case current_user do
      nil ->
        {:ok, push_navigate(socket, to: "/")}
      user ->
        unless has_lecturer_permission?(user) do
          {:ok, push_navigate(socket, to: "/")}
        else
          socket = assign(socket,
            current_user: user,
            current_page: "lecturer_dashboard",
            page_title: "Lecturer Dashboard - SignEase",
            stats: get_lecturer_stats(user),
            upcoming_sessions: get_upcoming_sessions(user),
            recent_activities: get_lecturer_activities(user),
            student_progress: get_student_progress(user),
            course_analytics: get_course_analytics(user),
            pending_requests: get_pending_requests(user)
          )

          {:ok, socket}
        end
    end
  end

  @impl true
  def handle_event("refresh-stats", _params, socket) do
    {:noreply, assign(socket, stats: get_lecturer_stats(socket.assigns.current_user))}
  end

  @impl true
  def handle_event("navigate-to-session", %{"session_id" => session_id}, socket) do
    {:noreply, push_navigate(socket, to: "/lecturer/sessions/#{session_id}")}
  end

  @impl true
  def handle_event("navigate-to-students", _params, socket) do
    {:noreply, push_navigate(socket, to: "/lecturer/students")}
  end

  @impl true
  def handle_event("navigate-to-courses", _params, socket) do
    {:noreply, push_navigate(socket, to: "/lecturer/courses")}
  end

  # Private functions

  defp get_current_user(session, params) do
    # Try to get user_id from URL params first, then from session
    user_id = params["user_id"] || session["user_id"]

    case user_id do
      nil ->
        # Redirect to home if no user_id provided
        nil
      user_id ->
        case Accounts.get_user(user_id) do
          nil ->
            # Redirect to home if user not found
            nil
          user ->
            # Return the actual user from database
            user
        end
    end
  end

  defp has_lecturer_permission?(user) do
    # Check if user has lecturer permissions
    user.user_type == "INSTRUCTOR" || user.user_role == "TEACHER"
  end

  defp get_lecturer_stats(user) do
    # Get real user data and provide realistic mock statistics based on user profile
    base_stats = case user.sign_language_skills do
      "BEGINNER" ->
        %{
          total_students: 12,
          active_courses: 2,
          total_sessions_conducted: 45,
          average_student_rating: 4.2,
          upcoming_sessions: 3,
          total_hours_taught: 67,
          student_completion_rate: 75,
          pending_assessments: 5
        }
      "INTERMEDIATE" ->
        %{
          total_students: 28,
          active_courses: 4,
          total_sessions_conducted: 89,
          average_student_rating: 4.5,
          upcoming_sessions: 6,
          total_hours_taught: 134,
          student_completion_rate: 82,
          pending_assessments: 8
        }
      "ADVANCED" ->
        %{
          total_students: 45,
          active_courses: 6,
          total_sessions_conducted: 156,
          average_student_rating: 4.8,
          upcoming_sessions: 8,
          total_hours_taught: 234,
          student_completion_rate: 89,
          pending_assessments: 12
        }
      "FLUENT" ->
        %{
          total_students: 67,
          active_courses: 8,
          total_sessions_conducted: 234,
          average_student_rating: 4.9,
          upcoming_sessions: 12,
          total_hours_taught: 351,
          student_completion_rate: 94,
          pending_assessments: 18
        }
      _ ->
        %{
          total_students: 20,
          active_courses: 3,
          total_sessions_conducted: 67,
          average_student_rating: 4.3,
          upcoming_sessions: 5,
          total_hours_taught: 100,
          student_completion_rate: 78,
          pending_assessments: 7
        }
    end

    # Adjust based on user's experience (using sign_language_skills as proxy)
    case user.sign_language_skills do
      "FLUENT" ->
        Map.merge(base_stats, %{
          total_hours_taught: base_stats.total_hours_taught + 50,
          average_student_rating: base_stats.average_student_rating + 0.1
        })
      "ADVANCED" ->
        Map.merge(base_stats, %{
          total_hours_taught: base_stats.total_hours_taught + 25,
          average_student_rating: base_stats.average_student_rating + 0.05
        })
      _ ->
        base_stats
    end
  end

  defp get_upcoming_sessions(_user) do
    # Mock data for upcoming sessions
    [
      %{
        id: 1,
        title: "Advanced Sign Language - Session 5",
        course: "Advanced Course",
        scheduled_time: DateTime.utc_now() |> DateTime.add(3600, :second),
        duration: 60,
        enrolled_students: 15,
        max_students: 20,
        type: "live_session"
      },
      %{
        id: 2,
        title: "Beginner Practice Session",
        course: "Beginner Course",
        scheduled_time: DateTime.utc_now() |> DateTime.add(7200, :second),
        duration: 45,
        enrolled_students: 12,
        max_students: 15,
        type: "practice_session"
      },
      %{
        id: 3,
        title: "Intermediate Grammar Review",
        course: "Intermediate Course",
        scheduled_time: DateTime.utc_now() |> DateTime.add(10800, :second),
        duration: 90,
        enrolled_students: 18,
        max_students: 25,
        type: "review_session"
      }
    ]
  end

  defp get_lecturer_activities(_user) do
    # Mock data for recent activities
    [
      %{
        id: 1,
        type: "session_completed",
        title: "Basic Signs - Session 3",
        description: "Completed session with 15 students",
        timestamp: DateTime.utc_now() |> DateTime.add(-3600, :second),
        students_attended: 15,
        average_rating: 4.9
      },
      %{
        id: 2,
        type: "assessment_graded",
        title: "Mid-term Assessment",
        description: "Graded 20 student assessments",
        timestamp: DateTime.utc_now() |> DateTime.add(-7200, :second),
        students_graded: 20,
        average_score: 85
      },
      %{
        id: 3,
        type: "course_created",
        title: "Advanced Conversation Course",
        description: "Created new advanced course",
        timestamp: DateTime.utc_now() |> DateTime.add(-10800, :second),
        students_enrolled: 0,
        average_rating: nil
      }
    ]
  end

  defp get_student_progress(_user) do
    # Mock data for student progress
    %{
      beginner_students: 25,
      intermediate_students: 15,
      advanced_students: 5,
      students_needing_attention: 3,
      top_performers: 8,
      struggling_students: 2
    }
  end

  defp get_course_analytics(_user) do
    # Mock data for course analytics
    [
      %{
        course_name: "Beginner Course",
        enrollment: 25,
        completion_rate: 92,
        average_rating: 4.7,
        active_students: 22
      },
      %{
        course_name: "Intermediate Course",
        enrollment: 18,
        completion_rate: 85,
        average_rating: 4.8,
        active_students: 15
      },
      %{
        course_name: "Advanced Course",
        enrollment: 12,
        completion_rate: 78,
        average_rating: 4.9,
        active_students: 8
      }
    ]
  end

  defp get_pending_requests(_user) do
    # Mock data for pending requests
    [
      %{
        id: 1,
        type: "assessment_review",
        student_name: "John Doe",
        course: "Intermediate Course",
        request: "Request for assessment review",
        timestamp: DateTime.utc_now() |> DateTime.add(-1800, :second)
      },
      %{
        id: 2,
        type: "schedule_change",
        student_name: "Jane Smith",
        course: "Beginner Course",
        request: "Request to reschedule session",
        timestamp: DateTime.utc_now() |> DateTime.add(-3600, :second)
      },
      %{
        id: 3,
        type: "additional_help",
        student_name: "Mike Johnson",
        course: "Advanced Course",
        request: "Request for additional practice session",
        timestamp: DateTime.utc_now() |> DateTime.add(-5400, :second)
      }
    ]
  end
end