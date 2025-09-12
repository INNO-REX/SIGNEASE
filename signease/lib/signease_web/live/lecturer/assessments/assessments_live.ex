defmodule SigneaseWeb.Lecturer.Assessments.AssessmentsLive do
  use SigneaseWeb, :live_view

  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      assessments: get_assessments_for_lecturer(1),
      current_user: get_current_user(),
      page_title: "Assessment Management",
      current_path: "/lecturer/assessments",
      current_page: "assessments",
      stats: get_assessment_stats(),
      filters: %{},
      selected_assessment: nil,
      show_assessment_modal: false
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    assessments = get_assessments_for_lecturer(socket.assigns.current_user.id)
    {:noreply, assign(socket, assessments: assessments)}
  end

  @impl true
  def handle_event("view_assessment", %{"id" => id}, socket) do
    assessment = Enum.find(socket.assigns.assessments, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_assessment: assessment, show_assessment_modal: true)}
  end

  @impl true
  def handle_event("close_assessment_modal", _params, socket) do
    {:noreply, assign(socket, show_assessment_modal: false, selected_assessment: nil)}
  end

  @impl true
  def handle_event("filter_assessments", %{"filters" => filters}, socket) do
    filtered_assessments = apply_filters(socket.assigns.assessments, filters)
    {:noreply, assign(socket, assessments: filtered_assessments, filters: filters)}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    assessments = get_assessments_for_lecturer(socket.assigns.current_user.id)
    {:noreply, assign(socket, assessments: assessments, filters: %{})}
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

  defp get_assessments_for_lecturer(_lecturer_id) do
    [
      %{
        id: 1,
        title: "Elixir Basics Quiz",
        description: "A quiz on Elixir fundamentals.",
        status: "PUBLISHED",
        question_count: 10,
        attempts: 25,
        average_score: 78.5
      },
      %{
        id: 2,
        title: "Phoenix Project",
        description: "A project-based assessment for Phoenix skills.",
        status: "DRAFT",
        question_count: 1,
        attempts: 0,
        average_score: nil
      },
      %{
        id: 3,
        title: "Accessibility Case Study",
        description: "Analyze a web accessibility scenario.",
        status: "CLOSED",
        question_count: 5,
        attempts: 18,
        average_score: 85.0
      }
    ]
  end

  defp get_assessment_stats do
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
          title: "Total Assessments",
          value: 3,
          icon: "clipboard-document-list",
          color: "blue"
        },
        %{
          title: "Published",
          value: 1,
          icon: "check-circle",
          color: "green"
        },
        %{
          title: "Drafts",
          value: 1,
          icon: "pencil-square",
          color: "yellow"
        },
        %{
          title: "Closed",
          value: 1,
          icon: "archive-box-x-mark",
          color: "gray"
        }
      ]
    }
  end

  defp apply_filters(assessments, _filters) do
    assessments
  end
end