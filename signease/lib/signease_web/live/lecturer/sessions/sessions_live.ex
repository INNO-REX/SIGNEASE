defmodule SigneaseWeb.Lecturer.Sessions.SessionsLive do
  use SigneaseWeb, :live_view

  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      sessions: get_sessions_for_lecturer(1),
      current_user: get_current_user(),
      page_title: "Session Management",
      current_path: "/lecturer/sessions",
      current_page: "sessions",
      stats: get_session_stats(),
      filters: %{},
      selected_session: nil,
      show_session_modal: false,
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    sessions = get_sessions_for_lecturer(socket.assigns.current_user.id)
    {:noreply, assign(socket, sessions: sessions)}
  end

  @impl true
  def handle_event("view_session", %{"id" => id}, socket) do
    session = Enum.find(socket.assigns.sessions, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_session: session, show_session_modal: true)}
  end

  @impl true
  def handle_event("close_session_modal", _params, socket) do
    {:noreply, assign(socket, show_session_modal: false, selected_session: nil)}
  end

  @impl true
  def handle_event("filter_sessions", %{"filters" => filters}, socket) do
    filtered_sessions = apply_filters(socket.assigns.sessions, filters)
    {:noreply, assign(socket, sessions: filtered_sessions, filters: filters)}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    sessions = get_sessions_for_lecturer(socket.assigns.current_user.id)
    {:noreply, assign(socket, sessions: sessions, filters: %{})}
  end


  # =============================================================================
  # HELPER FUNCTIONS
  # =============================================================================

  defp get_current_user do
    # Use the same mock user as in courses
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

  defp get_sessions_for_lecturer(_lecturer_id) do
    [
      %{
        id: 1,
        title: "Elixir Live Coding",
        description: "A real-time coding session on Elixir basics.",
        status: "SCHEDULED",
        student_count: 20,
        scheduled_at: ~N[2024-08-10 14:00:00],
        duration_minutes: 60
      },
      %{
        id: 2,
        title: "Phoenix Q&A",
        description: "Ask your questions about Phoenix LiveView.",
        status: "COMPLETED",
        student_count: 15,
        scheduled_at: ~N[2024-07-20 16:00:00],
        duration_minutes: 45
      },
      %{
        id: 3,
        title: "Accessibility Workshop",
        description: "Best practices for accessible web sessions.",
        status: "ONGOING",
        student_count: 30,
        scheduled_at: ~N[2024-08-01 10:00:00],
        duration_minutes: 90
      }
    ]
  end

  defp get_session_stats do
    %{
      total_sessions: 0,
      scheduled_sessions: 0,
      completed_sessions: 0,
      ongoing_sessions: 0,
      total_students: 0,
      average_student_rating: 0.0,
      total_users: 0,
      pending_approvals: 0,
      total_roles: 0,
      active_sessions: 0,
      stats_cards: [
        %{
          title: "Total Sessions",
          value: 0,
          icon: "calendar-days",
          color: "blue"
        },
        %{
          title: "Ongoing Sessions",
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
          title: "Completed Sessions",
          value: 0,
          icon: "check-circle",
          color: "yellow"
        }
      ]
    }
  end

  defp apply_filters(sessions, _filters) do
    sessions
  end
end