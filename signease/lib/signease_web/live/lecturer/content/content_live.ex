defmodule SigneaseWeb.Lecturer.Content.ContentLive do
  use SigneaseWeb, :live_view

  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      current_user: get_current_user(),
      page_title: "Content Library",
      current_path: "/lecturer/content",
      current_page: "content",
      content_items: get_content_items(),
      categories: get_categories(),
      stats: get_content_stats(),
      filters: %{},
      selected_content: nil,
      show_content_modal: false
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("view_content", %{"id" => id}, socket) do
    content = Enum.find(socket.assigns.content_items, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_content: content, show_content_modal: true)}
  end

  @impl true
  def handle_event("close_content_modal", _params, socket) do
    {:noreply, assign(socket, show_content_modal: false, selected_content: nil)}
  end

  @impl true
  def handle_event("filter_content", %{"filters" => filters}, socket) do
    filtered_content = apply_filters(socket.assigns.content_items, filters)
    {:noreply, assign(socket, content_items: filtered_content, filters: filters)}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    content_items = get_content_items()
    {:noreply, assign(socket, content_items: content_items, filters: %{})}
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

  defp get_content_items do
    [
      %{
        id: 1,
        title: "Introduction to Sign Language",
        description: "Basic sign language fundamentals for beginners",
        type: "video",
        category: "Sign Language",
        duration: "45 minutes",
        views: 1250,
        rating: 4.8,
        created_at: "2024-01-15"
      },
      %{
        id: 2,
        title: "Accessibility Guidelines",
        description: "Web accessibility standards and best practices",
        type: "document",
        category: "Accessibility",
        duration: "30 minutes",
        views: 890,
        rating: 4.6,
        created_at: "2024-01-10"
      },
      %{
        id: 3,
        title: "Speech Recognition Tutorial",
        description: "Implementing speech-to-text functionality",
        type: "interactive",
        category: "Technology",
        duration: "60 minutes",
        views: 567,
        rating: 4.9,
        created_at: "2024-01-05"
      }
    ]
  end

  defp get_categories do
    ["All", "Sign Language", "Accessibility", "Technology", "Communication", "Practice"]
  end

  defp get_content_stats do
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
          title: "Total Content",
          value: 3,
          icon: "document-text",
          color: "blue"
        },
        %{
          title: "Videos",
          value: 1,
          icon: "video-camera",
          color: "green"
        },
        %{
          title: "Documents",
          value: 1,
          icon: "document",
          color: "yellow"
        },
        %{
          title: "Interactive",
          value: 1,
          icon: "light-bulb",
          color: "purple"
        }
      ]
    }
  end

  defp apply_filters(content_items, filters) do
    content_items
  end
end