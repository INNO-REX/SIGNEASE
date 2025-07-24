defmodule SigneaseWeb.Learner.Dashboard.LearnerDashboardLive do
  use SigneaseWeb, :live_view

  alias Signease.Accounts
  alias Signease.Roles

  @impl true
  def mount(params, session, socket) do
    # Get current user from session or URL params
    current_user = get_current_user(session, params)

    # Check if user exists and has learner permissions
    case current_user do
      nil ->
        {:ok, push_navigate(socket, to: "/")}
      user ->
        unless has_learner_permission?(user) do
          {:ok, push_navigate(socket, to: "/")}
        else
          socket = assign(socket,
            current_user: user,
            current_page: "learner_dashboard",
            page_title: "Learner Dashboard - SignEase",
            stats: get_learner_stats(user),
            recent_activities: get_learner_activities(user),
            learning_progress: get_learning_progress(user),
            upcoming_lessons: get_upcoming_lessons(user),
            completed_lessons: get_completed_lessons(user),
            recommended_content: get_recommended_content(user)
          )

          {:ok, socket}
        end
    end
  end

  @impl true
  def handle_event("refresh-stats", _params, socket) do
    {:noreply, assign(socket, stats: get_learner_stats(socket.assigns.current_user))}
  end

  @impl true
  def handle_event("navigate-to-lesson", %{"lesson_id" => lesson_id}, socket) do
    {:noreply, push_navigate(socket, to: "/learner/lessons/#{lesson_id}")}
  end

  @impl true
  def handle_event("navigate-to-progress", _params, socket) do
    {:noreply, push_navigate(socket, to: "/learner/progress")}
  end

  @impl true
  def handle_event("navigate-to-schedule", _params, socket) do
    {:noreply, push_navigate(socket, to: "/learner/schedule")}
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

  defp has_learner_permission?(user) do
    # Check if user has learner permissions
    user.user_type == "LEARNER" || user.user_role == "STUDENT"
  end

  defp get_learner_stats(user) do
    # Get real user data and provide realistic mock statistics based on user profile
    base_stats = case user.sign_language_skills do
      "BEGINNER" ->
        %{
          total_lessons_completed: 5,
          total_lessons_in_progress: 2,
          total_hours_learned: 8,
          current_streak: 3,
          average_score: 78,
          certificates_earned: 0,
          upcoming_lessons: 3,
          total_lessons_available: 25,
          speech_transcriptions: 12,
          chat_messages_sent: 45,
          sign_language_videos_watched: 8,
          accessibility_features_used: 15
        }
      "INTERMEDIATE" ->
        %{
          total_lessons_completed: 15,
          total_lessons_in_progress: 4,
          total_hours_learned: 32,
          current_streak: 12,
          average_score: 85,
          certificates_earned: 1,
          upcoming_lessons: 6,
          total_lessons_available: 40,
          speech_transcriptions: 28,
          chat_messages_sent: 120,
          sign_language_videos_watched: 25,
          accessibility_features_used: 42
        }
      "ADVANCED" ->
        %{
          total_lessons_completed: 28,
          total_lessons_in_progress: 2,
          total_hours_learned: 56,
          current_streak: 21,
          average_score: 92,
          certificates_earned: 3,
          upcoming_lessons: 4,
          total_lessons_available: 35,
          speech_transcriptions: 67,
          chat_messages_sent: 234,
          sign_language_videos_watched: 45,
          accessibility_features_used: 89
        }
      "FLUENT" ->
        %{
          total_lessons_completed: 45,
          total_lessons_in_progress: 1,
          total_hours_learned: 90,
          current_streak: 30,
          average_score: 96,
          certificates_earned: 5,
          upcoming_lessons: 2,
          total_lessons_available: 20,
          speech_transcriptions: 156,
          chat_messages_sent: 567,
          sign_language_videos_watched: 89,
          accessibility_features_used: 234
        }
      _ ->
        %{
          total_lessons_completed: 8,
          total_lessons_in_progress: 3,
          total_hours_learned: 16,
          current_streak: 5,
          average_score: 82,
          certificates_earned: 1,
          upcoming_lessons: 4,
          total_lessons_available: 30,
          speech_transcriptions: 18,
          chat_messages_sent: 67,
          sign_language_videos_watched: 12,
          accessibility_features_used: 28
        }
    end

    # Adjust based on user's hearing status
    case user.hearing_status do
      "DEAF" ->
        Map.merge(base_stats, %{
          total_hours_learned: base_stats.total_hours_learned + 5,
          average_score: base_stats.average_score + 3,
          speech_transcriptions: base_stats.speech_transcriptions + 10,
          sign_language_videos_watched: base_stats.sign_language_videos_watched + 5
        })
      "HARD_OF_HEARING" ->
        Map.merge(base_stats, %{
          total_hours_learned: base_stats.total_hours_learned + 2,
          average_score: base_stats.average_score + 1,
          speech_transcriptions: base_stats.speech_transcriptions + 5,
          sign_language_videos_watched: base_stats.sign_language_videos_watched + 2
        })
      _ ->
        base_stats
    end
  end

  defp get_learner_activities(_user) do
    # Mock data for recent activities focused on accessibility and communication
    [
      %{
        id: 1,
        type: "speech_transcribed",
        title: "Live Session Transcription",
        description: "Real-time speech-to-text during group discussion",
        timestamp: DateTime.utc_now() |> DateTime.add(-1800, :second),
        accuracy: 98,
        words_transcribed: 245
      },
      %{
        id: 2,
        type: "chat_message",
        title: "Group Chat Participation",
        description: "Active participation in class discussion via text chat",
        timestamp: DateTime.utc_now() |> DateTime.add(-3600, :second),
        messages_sent: 8,
        responses_received: 12
      },
      %{
        id: 3,
        type: "sign_video_watched",
        title: "Sign Language Video",
        description: "Watched animated sign language translation",
        timestamp: DateTime.utc_now() |> DateTime.add(-5400, :second),
        video_duration: 3.5,
        signs_learned: 15
      },
      %{
        id: 4,
        type: "accessibility_used",
        title: "Accessibility Feature",
        description: "Used high contrast mode and large text",
        timestamp: DateTime.utc_now() |> DateTime.add(-7200, :second),
        features_used: ["high_contrast", "large_text"],
        session_duration: 45
      },
      %{
        id: 5,
        type: "lesson_completed",
        title: "Communication Skills - Lesson 2",
        description: "Completed lesson on effective text-based communication",
        timestamp: DateTime.utc_now() |> DateTime.add(-9000, :second),
        score: 94
      }
    ]
  end

  defp get_learning_progress(_user) do
    # Mock data for learning progress
    %{
      beginner_course: 85,
      intermediate_course: 45,
      advanced_course: 0,
      conversation_practice: 60
    }
  end

  defp get_upcoming_lessons(_user) do
    # Mock data for upcoming lessons with accessibility features
    [
      %{
        id: 1,
        title: "Inclusive Communication Workshop",
        instructor: "Sarah Johnson",
        scheduled_time: DateTime.utc_now() |> DateTime.add(3600, :second),
        duration: 60,
        type: "live_session",
        features: ["speech_to_text", "live_captioning", "sign_language_avatar", "text_chat"],
        participants: 12,
        accessibility_level: "full"
      },
      %{
        id: 2,
        title: "Text-Based Discussion Group",
        instructor: "Mike Chen",
        scheduled_time: DateTime.utc_now() |> DateTime.add(7200, :second),
        duration: 45,
        type: "text_chat_session",
        features: ["text_only", "emoji_support", "voice_to_text", "read_aloud"],
        participants: 8,
        accessibility_level: "text_focused"
      },
      %{
        id: 3,
        title: "Sign Language Animation Practice",
        instructor: "Lisa Wang",
        scheduled_time: DateTime.utc_now() |> DateTime.add(10800, :second),
        duration: 90,
        type: "interactive_practice",
        features: ["3d_avatar", "gesture_recognition", "text_overlay", "speed_control"],
        participants: 15,
        accessibility_level: "visual_focused"
      },
      %{
        id: 4,
        title: "Accessibility Tools Training",
        instructor: "David Kim",
        scheduled_time: DateTime.utc_now() |> DateTime.add(14400, :second),
        duration: 30,
        type: "tutorial",
        features: ["screen_reader", "keyboard_navigation", "high_contrast", "large_text"],
        participants: 6,
        accessibility_level: "assistive_tech"
      }
    ]
  end

  defp get_completed_lessons(_user) do
    # Mock data for completed lessons
    [
      %{
        id: 1,
        title: "Basic Greetings",
        completed_at: DateTime.utc_now() |> DateTime.add(-3600, :second),
        score: 92,
        time_spent: 25
      },
      %{
        id: 2,
        title: "Numbers 1-10",
        completed_at: DateTime.utc_now() |> DateTime.add(-7200, :second),
        score: 88,
        time_spent: 30
      },
      %{
        id: 3,
        title: "Colors",
        completed_at: DateTime.utc_now() |> DateTime.add(-10800, :second),
        score: 95,
        time_spent: 20
      }
    ]
  end

  defp get_recommended_content(_user) do
    # Mock data for recommended content focused on accessibility and communication
    [
      %{
        id: 1,
        title: "Speech-to-Text Mastery",
        type: "interactive_tutorial",
        difficulty: "beginner",
        estimated_time: 20,
        description: "Learn to effectively use real-time speech transcription",
        features: ["live_transcription", "accuracy_training", "customization"],
        accessibility_rating: 5
      },
      %{
        id: 2,
        title: "Text-Based Communication Skills",
        type: "workshop",
        difficulty: "intermediate",
        estimated_time: 45,
        description: "Master effective written communication in group settings",
        features: ["chat_etiquette", "response_timing", "clarity_techniques"],
        accessibility_rating: 5
      },
      %{
        id: 3,
        title: "Sign Language Avatar Guide",
        type: "video_tutorial",
        difficulty: "all_levels",
        estimated_time: 30,
        description: "Learn to use animated sign language translations",
        features: ["3d_animation", "speed_control", "text_overlay", "gesture_breakdown"],
        accessibility_rating: 4
      },
      %{
        id: 4,
        title: "Accessibility Tools Deep Dive",
        type: "hands_on_practice",
        difficulty: "beginner",
        estimated_time: 25,
        description: "Explore all available accessibility features",
        features: ["screen_reader", "keyboard_shortcuts", "visual_aids", "audio_cues"],
        accessibility_rating: 5
      },
      %{
        id: 5,
        title: "Inclusive Group Participation",
        type: "simulation",
        difficulty: "intermediate",
        estimated_time: 40,
        description: "Practice participating in mixed-ability group discussions",
        features: ["role_play", "feedback_system", "best_practices"],
        accessibility_rating: 5
      }
    ]
  end
end
