defmodule WhisperElixir do
  @moduledoc """
  A  Whisper implementation using Bumblebee for speech-to-text transcription
  with integrated Ollama grammar checking.
  """



  @doc """
  Transcribe an audio file to text with optional grammar checking.

  ## Parameters
  - `audio_path`: Path to the audio file (supports WAV, MP3, etc.)
  - `options`: Optional parameters
    - `:language`: Language code (e.g., "en", "es", "fr") - auto-detect if not specified
    - `:task`: :transcribe (default) or :translate (translate to English)
    - `:timestamps`: true/false - include word-level timestamps
    - `:grammar_check`: true/false - enable Ollama grammar checking (default: true)

  ## Examples
      iex> WhisperElixir.transcribe("path/to/audio.wav")
      {:ok, %{text: "Hello world", corrected: "Hello world", chunks: [...]}}

      iex> WhisperElixir.transcribe("path/to/audio.wav", language: "es", grammar_check: false)
      {:ok, %{text: "Hola mundo", chunks: [%{text: "Hola", start_timestamp_seconds: 0.0, end_timestamp_seconds: 0.5}, ...]}}
  """
  def transcribe(audio_path, options \\ []) do
    try do
      # Load and preprocess audio
      audio_tensor = load_audio(audio_path)

      # Ensure audio tensor is in the correct shape for Whisper
      audio_tensor = Nx.reshape(audio_tensor, {:auto})

      # Load model directly
      model_repo = "whisper-small"
      {:ok, model_info} = Bumblebee.load_model({:hf, model_repo})
      {:ok, featurizer} = Bumblebee.load_featurizer({:hf, model_repo})
      {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, model_repo})
      {:ok, generation_config} = Bumblebee.load_generation_config({:hf, model_repo})

      # Configure generation settings for faster processing
      generation_config = Bumblebee.configure(generation_config,
        max_new_tokens: 50  # Reduced for faster processing
      )

      # Create serving function
      serving = Bumblebee.Audio.speech_to_text_whisper(
        model_info,
        featurizer,
        tokenizer,
        generation_config,
        compile: [batch_size: 1],
        defn_options: [compiler: EXLA]
      )

      # Run transcription with timeout
      result = Task.await(
        Task.async(fn -> Nx.Serving.run(serving, audio_tensor) end),
        30_000  # 30 second timeout
      )

      # Format result
      formatted_result = format_result(result, options)

      # Apply grammar checking if enabled
      final_result = if Keyword.get(options, :grammar_check, true) do
        apply_grammar_check(formatted_result, options)
      else
        apply_grammar_check(formatted_result, options)

      end

      {:ok, final_result}
    rescue
      error ->
        IO.inspect(error, label: "Transcription error")
        {:error, "Transcription failed: #{inspect(error)}"}
    end
  end

  @doc """
  Transcribe audio from a binary (useful for web uploads or streaming).

  ## Parameters
  - `audio_binary`: Raw audio data as binary
  - `sample_rate`: Sample rate of the audio (default: 16000)
  - `options`: Same as transcribe/2
  """
  def transcribe_binary(audio_binary, sample_rate \\ 16000, options \\ []) do
    try do
      # Convert binary to tensor
      audio_tensor = binary_to_tensor(audio_binary, sample_rate)

      # Ensure audio tensor is in the correct shape for Whisper
      audio_tensor = Nx.reshape(audio_tensor, {:auto})

      # Load model directly
      model_repo = "openai/whisper-tiny"
      {:ok, model_info} = Bumblebee.load_model({:hf, model_repo})
      {:ok, featurizer} = Bumblebee.load_featurizer({:hf, model_repo})
      {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, model_repo})
      {:ok, generation_config} = Bumblebee.load_generation_config({:hf, model_repo})

      # Configure generation settings for faster processing
      generation_config = Bumblebee.configure(generation_config,
        max_new_tokens: 50  # Reduced for faster processing
      )

      # Create serving function
      serving = Bumblebee.Audio.speech_to_text_whisper(
        model_info,
        featurizer,
        tokenizer,
        generation_config,
        compile: [batch_size: 1],
        defn_options: [compiler: EXLA]
      )

      # Run transcription with timeout
      result = Task.await(
        Task.async(fn -> Nx.Serving.run(serving, audio_tensor) end),
        30_000  # 30 second timeout
      )

      # Format result
      formatted_result = format_result(result, options)

      # Apply grammar checking if enabled
      final_result = if Keyword.get(options, :grammar_check, true) do
        apply_grammar_check(formatted_result, options)
      else
        formatted_result
      end

      {:ok, final_result}
    rescue
      error ->
        IO.inspect(error, label: "Transcription error")
        {:error, "Transcription failed: #{inspect(error)}"}
    end
  end

  @doc """
  Transcribe audio from base64 encoded data (from web audio recording).
  This is a placeholder - real transcription should be handled by browser speech recognition.
  """
  def transcribe_base64(_base64_data, _options \\ []) do
    # Return error to indicate this method is not implemented
    # The browser speech recognition should handle transcription instead
    {:error, "Audio transcription not implemented - use browser speech recognition"}
  end


  # TODO: Implement real Whisper transcription
  # This requires converting WebM audio to WAV format that Whisper can process
  # For now, we're using a smart simulation that responds to audio characteristics
  defp real_whisper_transcription(audio_binary, options) do
    # This is where we would implement real Whisper processing
    # The challenge is converting WebM audio to a format Whisper understands

    # For now, return an error to fall back to simulation
    {:error, "Real Whisper processing not yet implemented"}
  end

  @doc """
  Get available Whisper models and their characteristics.
  """
  def available_models do
    [
      %{
        name: "whisper-tiny",
        repo: "openai/whisper-tiny",
        size: "39 MB",
        speed: "Very Fast",
        accuracy: "Lower"
      },
      %{
        name: "whisper-base",
        repo: "openai/whisper-base",
        size: "74 MB",
        speed: "Fast",
        accuracy: "Good"
      },
      %{
        name: "whisper-small",
        repo: "openai/whisper-small",
        size: "244 MB",
        speed: "Medium",
        accuracy: "Better"
      },
      %{
        name: "whisper-medium",
        repo: "openai/whisper-medium",
        size: "769 MB",
        speed: "Slow",
        accuracy: "Very Good"
      },
      %{
        name: "whisper-large-v2",
        repo: "openai/whisper-large-v2",
        size: "1550 MB",
        speed: "Very Slow",
        accuracy: "Best"
      }
    ]
  end

  # Private functions

  defp load_audio(audio_path) do
    # This is a simplified version. In practice, you might want to use
    # FFmpeg or another library to handle different audio formats
    case File.read(audio_path) do
      {:ok, binary} ->
        # Assume WAV format for simplicity
        # You might want to add proper audio decoding here
        binary_to_tensor(binary, 16000)

      {:error, reason} ->
        raise "Failed to read audio file: #{reason}"
    end
  end

  defp binary_to_tensor(audio_binary, sample_rate) do
    # Convert binary audio data to Nx tensor
    # This is a simplified implementation
    # In practice, you'd want proper audio decoding

    # Skip WAV header if present (first 44 bytes)
    audio_data = if byte_size(audio_binary) > 44 do
      <<_header::binary-size(44), data::binary>> = audio_binary
      data
    else
      audio_binary
    end

    # Convert to 16-bit signed integers and then to float32
    audio_data
    |> :binary.bin_to_list()
    |> Enum.chunk_every(2)
    |> Enum.map(fn [low, high] ->
      <<sample::signed-little-16>> = <<low, high>>
      sample / 32768.0  # Normalize to [-1, 1]
    end)
    |> Nx.tensor(type: :f32)
    |> Nx.reshape({:auto})
  end

  defp webm_binary_to_tensor(webm_binary) do
    # For WebM audio, we need a more sophisticated approach
    # This is a placeholder implementation
    # In production, you'd want to use FFmpeg or a proper audio library

    IO.puts("🔊 Attempting to extract audio from WebM...")

    # Try to find audio data in WebM (this is simplified)
    case extract_audio_from_webm(webm_binary) do
      {:ok, audio_data} ->
        IO.puts("🔊 Successfully extracted audio data: #{byte_size(audio_data)} bytes")
        # Convert to tensor
        audio_data
        |> :binary.bin_to_list()
        |> Enum.chunk_every(2)
        |> Enum.map(fn [low, high] ->
          <<sample::signed-little-16>> = <<low, high>>
          sample / 32768.0  # Normalize to [-1, 1]
        end)
        |> Nx.tensor(type: :f32)
        |> Nx.reshape({:auto})

      {:error, reason} ->
        IO.puts("🔊 Failed to extract audio: #{reason}")
        IO.puts("🔊 Falling back to raw audio processing...")
        # Fallback: try to process as raw audio
        # This might work for some simple cases
        webm_binary
        |> :binary.bin_to_list()
        |> Enum.take_every(2)  # Take every other byte to reduce noise
        |> Enum.map(fn byte ->
          (byte - 128) / 128.0  # Convert to [-1, 1] range
        end)
        |> Nx.tensor(type: :f32)
        |> Nx.reshape({:auto})
    end
  end

  defp extract_audio_from_webm(webm_binary) do
    # This is a very basic WebM audio extraction
    # In production, you'd want to use a proper WebM parser

    IO.puts("🔊 Looking for audio data in WebM...")

    # Look for audio data in WebM (simplified)
    case :binary.matches(webm_binary, "OpusHead") do
      [{pos, _len}] ->
        IO.puts("🔊 Found Opus header at position #{pos}")
        # Found Opus header, try to extract audio data
        audio_start = pos + 19  # Skip Opus header
        audio_data = binary_part(webm_binary, audio_start, byte_size(webm_binary) - audio_start)
        {:ok, audio_data}

      [] ->
        IO.puts("🔊 No Opus header found, trying alternative methods...")
        # Try to find other audio markers
        case :binary.matches(webm_binary, "audio") do
          [{pos, _len}] ->
            IO.puts("🔊 Found 'audio' marker at position #{pos}")
            audio_start = pos + 5
            audio_data = binary_part(webm_binary, audio_start, byte_size(webm_binary) - audio_start)
            {:ok, audio_data}

          [] ->
            IO.puts("🔊 No audio markers found, using raw data")
            # No audio markers found, use raw data
            {:ok, webm_binary}
        end
    end
  end



  defp format_result(result, _options) do
    # Extract text from chunks if available, otherwise use result.text
    text = case result do
      %{chunks: chunks} when is_list(chunks) and length(chunks) > 0 ->
        chunks
        |> Enum.map(& &1.text)
        |> Enum.join(" ")
        |> String.trim()

      %{text: text} when is_binary(text) ->
        text

      _ ->
        "No transcription available"
    end

    %{
      text: text,
      language: Map.get(result, :language, "unknown"),
      chunks: Map.get(result, :chunks, [])
    }
  end

  defp apply_grammar_check(formatted_result, options) do
    case Signease.GrammarChecker.check_grammar(formatted_result.text, options) do
      {:ok, grammar_result} ->
        Map.merge(formatted_result, %{
          corrected: grammar_result.corrected,
          grammar_confidence: grammar_result.confidence,
          grammar_changes: grammar_result.changes
        })

      {:error, reason} ->
        IO.puts("⚠️ Grammar check failed: #{reason}")
        # Return original result if grammar check fails
        Map.put(formatted_result, :corrected, formatted_result.text)
    end
  end
end
