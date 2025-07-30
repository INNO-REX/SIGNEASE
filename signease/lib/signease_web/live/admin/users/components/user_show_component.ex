defmodule SigneaseWeb.Admin.Users.Components.UserShowComponent do
  use SigneaseWeb, :live_component

  alias Signease.Accounts

  @impl true
  def update(%{id: id} = assigns, socket) do
    user = Accounts.get_user!(id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user, user)}
  end

  def format_user_status(status) do
    case status do
      "ACTIVE" -> "Active"
      "INACTIVE" -> "Inactive"
      "PENDING_APPROVAL" -> "Pending Approval"
      "APPROVED" -> "Approved"
      "REJECTED" -> "Rejected"
      "DISABLED" -> "Disabled"
      _ -> "Unknown"
    end
  end

  def format_user_type(type) do
    case type do
      "LEARNER" -> "Learner"
      "INSTRUCTOR" -> "Instructor"
      "ADMIN" -> "Admin"
      "SUPPORT" -> "Support"
      _ -> type || "N/A"
    end
  end

  def format_hearing_status(status) do
    case status do
      "HEARING" -> "Hearing"
      "DEAF" -> "Deaf"
      "HARD_OF_HEARING" -> "Hard of Hearing"
      _ -> status || "N/A"
    end
  end

  def format_sign_language_skills(skills) do
    case skills do
      "BEGINNER" -> "Beginner"
      "INTERMEDIATE" -> "Intermediate"
      "ADVANCED" -> "Advanced"
      "FLUENT" -> "Fluent"
      _ -> skills || "N/A"
    end
  end

  def get_status_class(status) do
    case status do
      "ACTIVE" -> "bg-green-100 text-green-800"
      "INACTIVE" -> "bg-gray-100 text-gray-800"
      "PENDING_APPROVAL" -> "bg-yellow-100 text-yellow-800"
      "APPROVED" -> "bg-blue-100 text-blue-800"
      "REJECTED" -> "bg-red-100 text-red-800"
      "DISABLED" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end
end
