defmodule SigneaseWeb.Learner.LiveSessions.LiveSessionsLive do
  use SigneaseWeb, :live_view
  alias SigneaseWeb.RouteHelpers

  @impl true
  def mount(_params, _session, socket) do
    # Get current user from session or assign a mock user for development
    current_user = get_current_user()

    socket = assign(socket,
      current_user: current_user,
      current_page: "learner_live_sessions",
      is_recording: false,
      transcription_text: "",
      transcribed_lines: [],
      session_active: false,
      class_questions: [],
      animation_enabled: false,
      accessibility_settings: %{
        high_contrast: false,
        large_text: false,
        screen_reader: false
      },
      session_stats: %{
        words_transcribed: 0,
        accuracy: 98.5,
        session_duration: 0,
        questions_asked: 0
      }
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle-recording", _params, socket) do
    is_recording = !socket.assigns.is_recording

    socket = if is_recording do
      # Start recording
      socket
      |> assign(is_recording: true, session_active: true)
      |> push_event("start-recording", %{})
      |> start_session_timer()
    else
      # Stop recording
      socket
      |> assign(is_recording: false)
      |> push_event("stop-recording", %{})
      |> stop_session_timer()
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("ask-class-question", _params, socket) do
    # Simulate asking a class question
    question = "Can you please repeat that last part?"
    questions = [%{
      id: System.unique_integer([:positive]),
      text: question,
      timestamp: DateTime.utc_now(),
      status: "sent"
    } | socket.assigns.class_questions]

    socket = assign(socket,
      class_questions: questions,
      session_stats: Map.update!(socket.assigns.session_stats, :questions_asked, &(&1 + 1))
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle-animation", _params, socket) do
    animation_enabled = !socket.assigns.animation_enabled

    socket = assign(socket, animation_enabled: animation_enabled)

    if animation_enabled do
      # Start sign language animation
      socket = push_event(socket, "start-animation", %{
        text: socket.assigns.transcription_text
      })
    else
      # Stop animation
      socket = push_event(socket, "stop-animation", %{})
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("update-transcription", %{"text" => text}, socket) do
    # Update transcription text and add to lines
    lines = if text != socket.assigns.transcription_text do
      [%{
        id: System.unique_integer([:positive]),
        text: text,
        timestamp: DateTime.utc_now(),
        speaker: "Instructor"
      } | socket.assigns.transcribed_lines]
    else
      socket.assigns.transcribed_lines
    end

    words_count = String.split(text, " ") |> length()

    socket = assign(socket,
      transcription_text: text,
      transcribed_lines: lines,
      session_stats: Map.put(socket.assigns.session_stats, :words_transcribed, words_count)
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle-accessibility", %{"setting" => setting}, socket) do
    current_value = socket.assigns.accessibility_settings[String.to_atom(setting)]
    new_value = !current_value

    socket = assign(socket,
      accessibility_settings: Map.put(socket.assigns.accessibility_settings, String.to_atom(setting), new_value)
    )

    # Apply accessibility setting
    socket = push_event(socket, "apply-accessibility", %{
      setting: setting,
      enabled: new_value
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear-transcription", _params, socket) do
    socket = assign(socket,
      transcription_text: "",
      transcribed_lines: []
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info(:update_session_timer, socket) do
    if socket.assigns.session_active do
      duration = socket.assigns.session_stats.session_duration + 1

      socket = assign(socket,
        session_stats: Map.put(socket.assigns.session_stats, :session_duration, duration)
      )

      # Schedule next timer update
      Process.send_after(self(), :update_session_timer, 1000)
    end

    {:noreply, socket}
  end

  # ============================================================================
  # PRIVATE FUNCTIONS
  # ============================================================================

  defp get_current_user do
    # Mock user for development - replace with actual user from session
    %{
      id: 1,
      first_name: "Alex",
      last_name: "Johnson",
      email: "alex@example.com",
      user_type: "LEARNER",
      sign_language_skills: "INTERMEDIATE",
      hearing_status: "DEAF"
    }
  end

  defp start_session_timer(socket) do
    Process.send_after(self(), :update_session_timer, 1000)
    socket
  end

  defp stop_session_timer(socket) do
    socket
  end

  defp format_duration(seconds) do
    minutes = div(seconds, 60)
    remaining_seconds = rem(seconds, 60)
    "#{String.pad_leading("#{minutes}", 2, "0")}:#{String.pad_leading("#{remaining_seconds}", 2, "0")}"
  end
end
