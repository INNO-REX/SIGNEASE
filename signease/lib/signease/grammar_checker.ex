defmodule Signease.GrammarChecker do
  @moduledoc """
  Grammar checking service using Ollama for speech-to-text transcription corrections.
  """

  @default_model "llama3.2:3b"
  @ollama_base_url "http://localhost:11434"

  @doc """
  Check and correct grammar in transcribed text using Ollama.

  ## Parameters
  - `text`: The transcribed text to check
  - `options`: Optional parameters
    - `:model`: Ollama model to use (default: "llama3.2:3b")
    - `:language`: Language for grammar checking (default: "English")

  ## Examples
      iex> Signease.GrammarChecker.check_grammar("i am go to store")
      {:ok, %{original: "i am go to store", corrected: "I am going to the store", confidence: 0.95}}

      iex> Signease.GrammarChecker.check_grammar("Hello world", language: "English")
      {:ok, %{original: "Hello world", corrected: "Hello world", confidence: 1.0}}
  """
  def check_grammar(text, options \\ []) do
    try do
      model = Keyword.get(options, :model, @default_model)
      language = Keyword.get(options, :language, "English")

      # Create grammar checking prompt
      prompt = build_grammar_prompt(text, language)

      # Call Ollama API
      case call_ollama_api(model, prompt) do
        {:ok, response} ->
          corrected_text = extract_corrected_text(response)
          confidence = calculate_confidence(text, corrected_text)

          {:ok, %{
            original: text,
            corrected: corrected_text,
            confidence: confidence,
            changes: detect_changes(text, corrected_text)
          }}

        {:error, reason} ->
          {:error, "Grammar check failed: #{reason}"}
      end
    rescue
      error ->
        {:error, "Grammar check error: #{inspect(error)}"}
    end
  end

  @doc """
  Check if Ollama is running and available.
  """
  def health_check do
    try do
      case Req.get("#{@ollama_base_url}/api/tags") do
        {:ok, %{status: 200}} ->
          {:ok, "Ollama is running"}

        {:ok, %{status: status}} ->
          {:error, "Ollama returned status #{status}"}

        {:error, %{reason: reason}} ->
          {:error, "Cannot connect to Ollama: #{inspect(reason)}"}
      end
    rescue
      error ->
        {:error, "Health check failed: #{inspect(error)}"}
    end
  end

  @doc """
  Get available Ollama models.
  """
  def list_models do
    try do
      case Req.get("#{@ollama_base_url}/api/tags") do
        {:ok, %{status: 200, body: %{"models" => models}}} ->
          model_names = Enum.map(models, & &1["name"])
          {:ok, model_names}

        {:ok, %{status: status}} ->
          {:error, "Failed to get models, status: #{status}"}

        {:error, reason} ->
          {:error, "Cannot connect to Ollama: #{inspect(reason)}"}
      end
    rescue
      error ->
        {:error, "Failed to list models: #{inspect(error)}"}
    end
  end

  # Private functions

  defp build_grammar_prompt(text, language) do
    """
    You are a grammar checker. Please correct the following #{language} text for grammar, spelling, and clarity.
    Only return the corrected text, nothing else. Do not add explanations or markdown formatting.

    Original text: "#{text}"

    Corrected text:
    """
  end

  defp call_ollama_api(model, prompt) do
    payload = %{
      model: model,
      prompt: prompt,
      stream: false,
      options: %{
        temperature: 0.1,  # Low temperature for consistent grammar checking
        top_p: 0.9,
        max_tokens: 200
      }
    }

    case Req.post("#{@ollama_base_url}/api/generate", json: payload) do
      {:ok, %{status: 200, body: %{"response" => response}}} ->
        {:ok, response}

      {:ok, %{status: status, body: body}} ->
        {:error, "Ollama API error: status #{status}, body: #{inspect(body)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp extract_corrected_text(response) do
    response
    |> String.trim()
    |> String.replace(~r/^corrected text:\s*/i, "")
    |> String.trim()
  end

  defp calculate_confidence(original, corrected) do
    if String.downcase(original) == String.downcase(corrected) do
      1.0
    else
      # Simple confidence based on similarity
      similarity = calculate_similarity(original, corrected)
      max(0.5, similarity)
    end
  end

  defp calculate_similarity(text1, text2) do
    words1 = String.split(String.downcase(text1), ~r/\s+/)
    words2 = String.split(String.downcase(text2), ~r/\s+/)

    common_words = Enum.count(words1, &(&1 in words2))
    total_words = max(length(words1), length(words2))

    if total_words == 0, do: 1.0, else: common_words / total_words
  end

  defp detect_changes(original, corrected) do
    if original == corrected do
      []
    else
      # Simple change detection - in a real implementation, you might want
      # to use a more sophisticated diff algorithm
      [
        %{
          type: :grammar_correction,
          original: original,
          corrected: corrected,
          description: "Grammar and spelling corrections applied"
        }
      ]
    end
  end
end
