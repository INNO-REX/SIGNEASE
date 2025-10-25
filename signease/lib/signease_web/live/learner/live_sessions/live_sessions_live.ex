defmodule SigneaseWeb.Learner.LiveSessions.LiveSessionsLive do
  use SigneaseWeb, :live_view

  alias SigneaseWeb.RouteHelpers
  alias Signease.Accounts
  alias WhisperElixir

  @impl true
  def mount(params, session, socket) do
    # Get current user from session
    user = get_current_user()

    # Check if user exists and has learner permissions

          socket = assign(socket,
            current_user: user,
            current_page: "learner_live_sessions",
            is_recording: false,
            transcription_text: "",
            transcribed_lines: [],
            session_active: false,
            current_speaker: " ",
            session_committed: false,
            current_session_text: "", # Track accumulated text during recording session
            class_questions: [],
            animation_enabled: false,
            accessibility_settings: %{
              high_contrast: false,
              large_text: false,
              screen_reader: false
            },
            session_stats: %{
              words_transcribed: 0,
              accuracy: 9.5,
              session_duration: 0,
              questions_asked: 0
            },
            # New assigns for audio handling
            audio_chunks: [],
            session_timer_ref: nil,
            transcription_processing: false
          )

          {:ok, socket}

    end
  

  @impl true
  def handle_event("toggle-recording", _params, socket) do
    is_recording = !socket.assigns.is_recording
    user = socket.assigns.current_user

    current_speaker =
      if user.user_type == "LEARNER" and is_recording do
        "#{user.first_name} #{user.last_name}"
      else
        "Instructor"
      end

    socket = if is_recording do
      # Start recording
      IO.puts("🎤 Starting recording for user: #{current_speaker}")
      socket
      |> assign(%{
        is_recording: true,
        session_active: true,
        current_speaker: current_speaker,
        audio_chunks: [],
        transcription_processing: false,
        session_committed: false,
        current_session_text: "" # Reset session text
      })
      |> push_event("start-recording", %{})
      |> start_session_timer()
    else
      # Stop recording and create history item
      IO.puts("🛑 Stopping recording")

      # Create history item from accumulated session text
      session_text = socket.assigns.current_session_text || ""
      IO.puts("🛑 Session text when stopping: '#{session_text}'")

      socket = if session_text != "" do
        # Create new transcribed line from accumulated session text
        new_line = %{
          id: System.unique_integer([:positive]),
          text: session_text,
          timestamp: DateTime.utc_now(),
          speaker: socket.assigns.current_speaker,
          language: "en", # Default language
          confidence: 0.95 # Default confidence
        }

        lines = [new_line | socket.assigns.transcribed_lines]
        words_count = socket.assigns.session_stats.words_transcribed + (String.split(session_text, " ") |> length())

        socket
        |> assign(%{
          is_recording: false,
          transcribed_lines: lines,
          current_session_text: "", # Clear session text
          session_stats: Map.put(socket.assigns.session_stats, :words_transcribed, words_count)
        })
        |> push_event("transcription-update", %{transcription: new_line})
        |> push_event("stop-recording", %{})
        |> stop_session_timer()
      else
        socket
        |> assign(%{
          is_recording: false,
          current_session_text: "" # Clear session text
        })
        |> push_event("stop-recording", %{})
        |> stop_session_timer()
      end
    end

    {:noreply, socket}
  end

  # Handle audio data chunks from frontend
  @impl true
  def handle_event("audio-chunk", %{"audio_data" => audio_base64}, socket) do
    # Store audio chunks for later processing
    audio_chunks = [audio_base64 | socket.assigns.audio_chunks]

    socket = assign(socket, audio_chunks: audio_chunks)

    {:noreply, socket}
  end

  # Handle final audio data for transcription
  @impl true
  def handle_event("audio-recorded", %{"audio" => audio_base64}, socket) do
    IO.puts("🎵 Received audio data from frontend")
    IO.puts("🎵 Audio data size: #{String.length(audio_base64)} characters")

    socket =
      socket
      |> assign(audio_chunks: [audio_base64 | socket.assigns.audio_chunks])
      |> process_recorded_audio()

    {:noreply, socket}
  end

  # Handle recording errors
  @impl true
  def handle_event("recording-error", %{"error" => error_message}, socket) do
    IO.puts("❌ Recording error: #{error_message}")

    socket = socket
    |> assign(%{
      is_recording: false,
      session_active: false,
      transcription_processing: false
    })
    |> put_flash(:error, "Recording failed: #{error_message}")

    {:noreply, socket}
  end

  # Handle interim transcription results (real-time)
  @impl true
  def handle_event("interim-transcription", %{"text" => text}, socket) do
    IO.puts("📝 Interim transcription: #{text}")

    # Update the current transcription text for real-time display
    socket = socket
    |> assign(transcription_text: text)
    |> push_event("update-current-transcription", %{text: text})

    {:noreply, socket}
  end

  # Handle final transcription results from browser speech recognition
  @impl true
  def handle_event("final-transcription", %{"text" => text, "confidence" => confidence, "language" => language}, socket) do
    IO.puts("🎉 Final transcription from browser: #{text}")

    # Accumulate text in current session instead of creating new lines
    current_session_text = socket.assigns.current_session_text || ""
    new_session_text = if current_session_text == "" do
      text
    else
      current_session_text <> " " <> text
    end

    IO.puts("📝 Accumulating text: '#{text}' -> Total: '#{new_session_text}'")

    # If recording already stopped, immediately persist one history item
    socket =
      if socket.assigns.is_recording do
        # Still recording: keep accumulating only
        socket
        |> assign(%{
          transcription_text: "",
          current_session_text: new_session_text,
          transcription_processing: false
        })
        |> push_event("clear-current-transcription", %{})
      else
        # Recording stopped: only persist once per session
        if socket.assigns.session_committed do
          socket
          |> assign(%{
            transcription_text: "",
            current_session_text: new_session_text,
            transcription_processing: false
          })
          |> push_event("clear-current-transcription", %{})
        else
          # First final after stop: write the accumulated text now
        session_text = String.trim(new_session_text)

        if session_text == "" do
          socket
          |> assign(%{
            transcription_text: "",
            current_session_text: "",
            transcription_processing: false
          })
          |> push_event("clear-current-transcription", %{})
        else
          new_line = %{
            id: System.unique_integer([:positive]),
            text: session_text,
            timestamp: DateTime.utc_now(),
            speaker: socket.assigns.current_speaker,
            language: language,
            confidence: confidence
          }

          lines = [new_line | socket.assigns.transcribed_lines]
          words_count = socket.assigns.session_stats.words_transcribed + (String.split(session_text, " ") |> length())

          socket
          |> assign(%{
            transcription_text: "",
            current_session_text: "",
            transcribed_lines: lines,
              session_committed: true,
            transcription_processing: false,
            session_stats: Map.put(socket.assigns.session_stats, :words_transcribed, words_count)
          })
          |> push_event("transcription-update", %{transcription: new_line})
          |> push_event("clear-current-transcription", %{})
        end
        end
      end

    # Update animation if enabled
    if socket.assigns.animation_enabled do
      socket = push_event(socket, "update-animation", %{text: text})
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
        speaker: socket.assigns.current_speaker
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

    # If animation is enabled, update it with new text
    if socket.assigns.animation_enabled do
      socket = push_event(socket, "update-animation", %{text: text})
    end

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

    # Handle real-time transcription results from Whisper
  @impl true
  def handle_info({:transcription_result, result}, socket) do
    IO.puts("📨 Received transcription result in handle_info")
    IO.puts("📨 Result text: \"#{result.text}\"")
    IO.inspect(result, label: "Transcription result received")

    # Create new transcribed line
    new_line = %{
      id: System.unique_integer([:positive]),
      text: result.text,
      timestamp: DateTime.utc_now(),
      speaker: socket.assigns.current_speaker,
      language: result.language,
      confidence: Map.get(result, :confidence, 0.0)
    }

    lines = [new_line | socket.assigns.transcribed_lines]
    words_count = socket.assigns.session_stats.words_transcribed + (String.split(result.text, " ") |> length())

    IO.puts("📝 Adding transcription to UI: \"#{result.text}\"")

    socket =
      socket
      |> assign(%{
        transcription_text: result.text,
        transcribed_lines: lines,
        transcription_processing: false,
        session_stats: Map.put(socket.assigns.session_stats, :words_transcribed, words_count)
      })
      |> push_event("transcription-update", %{transcription: new_line})

    # Update animation if enabled
    if socket.assigns.animation_enabled do
      socket = push_event(socket, "update-animation", %{text: result.text})
    end

    IO.puts("✅ Transcription result processed and sent to UI")
    {:noreply, socket}
  end

  # Handle transcription errors
  @impl true
  def handle_info({:transcription_error, error}, socket) do
    IO.inspect(error, label: "Transcription error in handle_info")

    socket =
      socket
      |> assign(transcription_processing: false)
      |> put_flash(:error, "Transcription failed: #{error}")

    {:noreply, socket}
  end

  # Handle session timeout
  @impl true
  def handle_info(:session_timeout, socket) do
    socket =
      socket
      |> assign(%{
        is_recording: false,
        session_active: false,
        transcription_processing: false
      })
      |> push_event("stop-recording", %{})
      |> put_flash(:info, "Recording session ended due to timeout")

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

  defp get_current_user do
    # Mock user for development - replace with actual user from session
    %{
      id: 1,
      first_name: "Jonas",
      last_name: "Jr",
      email: "alex@example.com",
      user_type: "LEARNER",
      sign_language_skills: "INTERMEDIATE",
      hearing_status: "DEAF"
    }
  end
  # ============================================================================

  defp start_session_timer(socket) do
    # Start session duration timer
    Process.send_after(self(), :update_session_timer, 1000)

    # Auto-stop recording after 10 minutes to prevent excessive usage
    timer_ref = Process.send_after(self(), :session_timeout, 10 * 60 * 1000)

    assign(socket, session_timer_ref: timer_ref)
  end

  defp stop_session_timer(socket) do
    if socket.assigns.session_timer_ref do
      Process.cancel_timer(socket.assigns.session_timer_ref)
    end
    assign(socket, session_timer_ref: nil)
  end

  defp process_recorded_audio(socket) do
    audio_chunks = socket.assigns.audio_chunks |> Enum.reverse()
    IO.puts("🎵 Processing #{length(audio_chunks)} audio chunks...")

    if length(audio_chunks) > 0 do
      IO.puts("🚀 Starting transcription process...")

      # Set processing state
      socket = assign(socket, transcription_processing: true)

      # Use the most recent audio chunk (the complete recording)
      latest_audio = List.first(audio_chunks)
      IO.puts("📊 Processing latest audio chunk: #{String.length(latest_audio)} characters")

      # Process transcription asynchronously to avoid blocking UI
      liveview_pid = self()
      Task.start(fn ->
        IO.puts("🔄 Task started - attempting transcription...")

        # Check if Google Speech API key is available
        api_key = System.get_env("GOOGLE_SPEECH_API_KEY")

        if is_nil(api_key) do
          IO.puts("⚠️ No Google Speech API key found, audio transcription not available")
          IO.puts("💡 Please use browser speech recognition for real-time transcription")
          # Don't process audio - let browser speech recognition handle it
          send(liveview_pid, {:transcription_error, "Audio transcription not available - use browser speech recognition"})
        else
          IO.puts("🔑 Google Speech API key found, attempting real transcription")
          # Try Google Speech API first, fallback to Whisper if needed
          case GoogleSpeech.transcribe_base64(latest_audio, [
            language_code: "en-US"  # You can make this configurable
          ]) do
            {:ok, result} ->
              IO.puts("🎉 Google Speech transcription successful!")
              IO.inspect(result, label: "Transcription result")
              IO.puts("📤 Sending transcription_result message to LiveView...")
              send(liveview_pid, {:transcription_result, result})
              IO.puts("📤 Message sent!")
            {:error, error} ->
              IO.puts("❌ Google Speech failed, trying Whisper...")
              IO.inspect(error, label: "Google Speech error")

              # Fallback to Whisper
              case WhisperElixir.transcribe_base64(latest_audio, []) do
                {:ok, result} ->
                  IO.puts("🎉 Whisper transcription successful!")
                  IO.inspect(result, label: "Whisper result")
                  send(liveview_pid, {:transcription_result, result})
                {:error, whisper_error} ->
                  IO.puts("❌ Both transcription services failed!")
                  IO.inspect(whisper_error, label: "Whisper error")
                  send(liveview_pid, {:transcription_error, "All transcription services failed"})
              end
          end
        end
      end)

      socket
    else
      IO.puts("⚠️ No audio chunks to process")
      socket
    end
    |> assign(audio_chunks: [])
  end

  def format_duration(seconds) do
    minutes = div(seconds, 60)
    remaining_seconds = rem(seconds, 60)
    "#{String.pad_leading("#{minutes}", 2, "0")}:#{String.pad_leading("#{remaining_seconds}", 2, "0")}"
  end
end
