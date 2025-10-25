defmodule GoogleSpeech do
  @moduledoc """
  Google Speech-to-Text implementation using HTTP requests.
  """

  @doc """
  Transcribe audio using Google Speech-to-Text API.

  ## Parameters
  - `audio_binary`: Raw audio data as binary
  - `options`: Optional parameters
    - `:language_code`: Language code (e.g., "en-US", "es-ES")
    - `:sample_rate`: Sample rate of the audio (default: 16000)

  ## Examples
      iex> GoogleSpeech.transcribe(audio_binary, language_code: "en-US")
      {:ok, %{text: "Hello world", confidence: 0.95}}
  """
  def transcribe(audio_binary, options \\ []) do
    try do
      language_code = options[:language_code] || "en-US"
      sample_rate = options[:sample_rate] || 16000

      # Convert audio to base64
      audio_base64 = Base.encode64(audio_binary)

      # Prepare the request body
      request_body = %{
        config: %{
          encoding: "WEBM_OPUS",
          sampleRateHertz: sample_rate,
          languageCode: language_code,
          enableAutomaticPunctuation: true,
          enableWordTimeOffsets: false,
          enableWordConfidence: true
        },
        audio: %{
          content: audio_base64
        }
      }

      # Get API key from environment
      api_key = System.get_env("GOOGLE_SPEECH_API_KEY")

      if is_nil(api_key) do
        {:error, "Google Speech API key not found. Set GOOGLE_SPEECH_API_KEY environment variable."}
      else
        # Make HTTP request to Google Speech-to-Text API
        url = "https://speech.googleapis.com/v1/speech:recognize?key=#{api_key}"

        headers = [
          {"Content-Type", "application/json"},
          {"Accept", "application/json"}
        ]

        case Finch.build(:post, url, headers, Jason.encode!(request_body))
             |> Finch.request(Signease.Finch) do
          {:ok, %Finch.Response{status: 200, body: body}} ->
            case Jason.decode(body) do
              {:ok, response} ->
                case response do
                  %{"results" => [%{"alternatives" => [%{"transcript" => transcript, "confidence" => confidence} | _]} | _]} ->
                    {:ok, %{text: transcript, confidence: confidence}}
                  %{"results" => []} ->
                    {:ok, %{text: "", confidence: 0.0}}
                  _ ->
                    {:error, "Unexpected response format from Google Speech API"}
                end
              {:error, _} ->
                {:error, "Failed to parse Google Speech API response"}
            end
          {:ok, %Finch.Response{status: status_code, body: body}} ->
            {:error, "Google Speech API error: #{status_code} - #{body}"}
          {:error, reason} ->
            {:error, "HTTP request failed: #{reason}"}
        end
      end
    rescue
      error ->
        {:error, "Transcription failed: #{inspect(error)}"}
    end
  end

  @doc """
  Transcribe audio from base64 encoded data (from web audio recording).
  """
  def transcribe_base64(base64_data, options \\ []) do
    try do
      # Remove data URL prefix if present
      audio_data = case String.split(base64_data, ",") do
        [_prefix, data] -> data
        [data] -> data
      end

      # Decode base64
      audio_binary = Base.decode64!(audio_data)

      # Call the main transcribe function
      transcribe(audio_binary, options)
    rescue
      error ->
        {:error, "Base64 transcription failed: #{inspect(error)}"}
    end
  end

  @doc """
  Mock transcription for testing purposes when API key is not available.
  """
  def mock_transcribe_base64(_base64_data, _options \\ []) do
    # Simulate processing delay
    Process.sleep(1000)

    # Return mock transcription
    mock_transcriptions = [
      "Hello, welcome to today's sign language lesson.",
      "We will be learning basic greetings today.",
      "Let's start with the sign for hello.",
      "Make sure to follow along with the hand movements.",
      "This is an important foundation for your learning journey.",
      "Practice makes perfect, so don't be afraid to make mistakes.",
      "Remember to maintain eye contact during conversations.",
      "The facial expressions are just as important as the hand signs.",
      "Let's practice the sign for thank you.",
      "Great job everyone! You're making excellent progress."
    ]

    random_text = Enum.random(mock_transcriptions)

    {:ok, %{
      text: random_text,
      confidence: 0.85 + (:rand.uniform() * 0.15), # Random confidence between 0.85-1.0
      language: "en-US"
    }}
  end
end
