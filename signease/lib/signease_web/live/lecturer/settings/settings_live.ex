defmodule SigneaseWeb.Lecturer.Settings.SettingsLive do
  use SigneaseWeb, :live_view

  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      current_user: get_current_user(),
      page_title: "Settings",
      current_path: "/lecturer/settings",
      current_page: "settings",
      settings: get_user_settings(),
      stats: get_settings_stats(),
      show_password_modal: false,
      show_profile_modal: false
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_notification", %{"type" => type}, socket) do
    settings = update_in(socket.assigns.settings.notifications, [type], &(!&1))
    {:noreply, assign(socket, settings: %{socket.assigns.settings | notifications: settings})}
  end

  @impl true
  def handle_event("update_preference", %{"key" => key, "value" => value}, socket) do
    settings = put_in(socket.assigns.settings.preferences, [key], value)
    {:noreply, assign(socket, settings: %{socket.assigns.settings | preferences: settings})}
  end

  @impl true
  def handle_event("show_password_modal", _params, socket) do
    {:noreply, assign(socket, show_password_modal: true)}
  end

  @impl true
  def handle_event("close_password_modal", _params, socket) do
    {:noreply, assign(socket, show_password_modal: false)}
  end

  @impl true
  def handle_event("show_profile_modal", _params, socket) do
    {:noreply, assign(socket, show_profile_modal: true)}
  end

  @impl true
  def handle_event("close_profile_modal", _params, socket) do
    {:noreply, assign(socket, show_profile_modal: false)}
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

  defp get_user_settings do
    %{
      notifications: %{
        email_notifications: true,
        push_notifications: true,
        sms_notifications: false,
        session_reminders: true,
        assessment_deadlines: true,
        student_messages: true
      },
      preferences: %{
        theme: "light",
        language: "en",
        timezone: "UTC",
        accessibility_mode: false,
        auto_save: true,
        default_session_duration: 60
      },
      privacy: %{
        profile_visibility: "public",
        show_contact_info: true,
        allow_student_messages: true,
        share_analytics: false
      }
          }
    end

  defp get_settings_stats do
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
          title: "Account Status",
          value: "Active",
          icon: "check-circle",
          color: "green"
        },
        %{
          title: "Last Login",
          value: "Today",
          icon: "clock",
          color: "blue"
        },
        %{
          title: "Notifications",
          value: "3 Active",
          icon: "bell",
          color: "yellow"
        },
        %{
          title: "Security",
          value: "Protected",
          icon: "shield-check",
          color: "purple"
        }
      ]
    }
  end
end