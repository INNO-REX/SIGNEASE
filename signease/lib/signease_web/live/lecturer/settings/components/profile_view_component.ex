defmodule SigneaseWeb.Lecturer.Settings.Components.ProfileViewComponent do
  use SigneaseWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{id: _id, current_user: current_user} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user, current_user)}
  end

  @impl true
  def handle_event("close", _params, socket) do
    send(self(), :close_profile_view)
    {:noreply, socket}
  end

  defp format_date(nil), do: "Not specified"
  defp format_date(date), do: Calendar.strftime(date, "%B %d, %Y")

  defp format_field(nil), do: "Not specified"
  defp format_field(""), do: "Not specified"
  defp format_field(value), do: value

  defp format_education_level(level) do
    case level do
      "high_school" -> "High School"
      "associate_degree" -> "Associate Degree"
      "bachelors" -> "Bachelor's Degree"
      "masters" -> "Master's Degree"
      "doctorate" -> "Doctorate"
      "other" -> "Other"
      _ -> format_field(level)
    end
  end

  defp format_hearing_status(status) do
    case status do
      "HEARING" -> "Hearing"
      "DEAF" -> "Deaf"
      "HARD_OF_HEARING" -> "Hard of Hearing"
      _ -> format_field(status)
    end
  end

  defp format_sign_language_skills(skills) do
    case skills do
      "BEGINNER" -> "Beginner"
      "INTERMEDIATE" -> "Intermediate"
      "ADVANCED" -> "Advanced"
      "FLUENT" -> "Fluent"
      _ -> format_field(skills)
    end
  end

  defp format_gender(gender) do
    case gender do
      "male" -> "Male"
      "female" -> "Female"
      "other" -> "Other"
      "prefer_not_to_say" -> "Prefer not to say"
      _ -> format_field(gender)
    end
  end

  defp format_preferred_language(lang) do
    case lang do
      "en" -> "English"
      "es" -> "Spanish"
      "fr" -> "French"
      _ -> format_field(lang)
    end
  end
end
