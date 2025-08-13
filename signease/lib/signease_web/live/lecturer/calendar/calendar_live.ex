defmodule SigneaseWeb.Lecturer.Calendar.CalendarLive do
  use SigneaseWeb, :live_view

  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      current_user: get_current_user(),
      page_title: "Calendar",
      current_path: "/lecturer/calendar",
      current_page: "calendar",
      events: get_calendar_events(),
      current_month: Date.utc_today(),
      stats: get_calendar_stats(),
      selected_date: nil,
      show_event_modal: false
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("select_date", %{"date" => date}, socket) do
    selected_date = Date.from_iso8601!(date)
    {:noreply, assign(socket, selected_date: selected_date)}
  end

  @impl true
  def handle_event("add_event", _params, socket) do
    {:noreply, assign(socket, show_event_modal: true)}
  end

  @impl true
  def handle_event("close_event_modal", _params, socket) do
    {:noreply, assign(socket, show_event_modal: false)}
  end

  @impl true
  def handle_event("previous_month", _params, socket) do
    new_month = Date.add(socket.assigns.current_month, -1)
    {:noreply, assign(socket, current_month: new_month)}
  end

  @impl true
  def handle_event("next_month", _params, socket) do
    new_month = Date.add(socket.assigns.current_month, 1)
    {:noreply, assign(socket, current_month: new_month)}
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

  defp get_calendar_events do
    [
      %{
        id: 1,
        title: "Sign Language Class",
        description: "Introduction to basic signs",
        date: ~D[2024-01-15],
        start_time: ~T[09:00:00],
        end_time: ~T[10:30:00],
        type: "class",
        location: "Room 101",
        attendees: 15
      },
      %{
        id: 2,
        title: "Accessibility Workshop",
        description: "Web accessibility best practices",
        date: ~D[2024-01-17],
        start_time: ~T[14:00:00],
        end_time: ~T[16:00:00],
        type: "workshop",
        location: "Computer Lab",
        attendees: 8
      },
      %{
        id: 3,
        title: "Student Consultation",
        description: "One-on-one session with Sarah",
        date: ~D[2024-01-20],
        start_time: ~T[11:00:00],
        end_time: ~T[11:30:00],
        type: "consultation",
        location: "Office",
        attendees: 1
      }
    ]
  end

  defp get_events_for_date(events, date) do
    Enum.filter(events, &(&1.date == date))
  end

  defp get_calendar_days(year, month) do
    first_day = Date.new!(year, month, 1)
    last_day = Date.end_of_month(first_day)
    
    # Get the first day of the week for the first day of the month
    first_weekday = Date.day_of_week(first_day)
    
    # Calculate the start date (previous month's days to fill the first week)
    start_date = Date.add(first_day, -(first_weekday - 1))
    
    # Calculate the end date (next month's days to fill the last week)
    last_weekday = Date.day_of_week(last_day)
    end_date = Date.add(last_day, 7 - last_weekday)
    
    Date.range(start_date, end_date)
  end

  defp get_calendar_stats do
    %{
      total_assessments: 3,
      published_assessments: 1,
      draft_assessments: 1,
      closed_assessments: 1,
      average_score: 81.75,
      average_student_rating: 0.0,
      total_users: 0,
      total_students: 45,
      pending_approvals: 0,
      total_roles: 0,
      active_sessions: 0,
      stats_cards: [
        %{
          title: "Total Events",
          value: 3,
          icon: "calendar-days",
          color: "blue"
        },
        %{
          title: "Classes",
          value: 1,
          icon: "academic-cap",
          color: "green"
        },
        %{
          title: "Workshops",
          value: 1,
          icon: "light-bulb",
          color: "yellow"
        },
        %{
          title: "Consultations",
          value: 1,
          icon: "user-group",
          color: "purple"
        }
      ]
    }
  end
end