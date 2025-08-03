defmodule SigneaseWeb.Helpers.Utils do
  @moduledoc """
  Utility functions for the SignEase web application.
  """

  def status_class(status) do
    case status do
      "ACTIVE" -> "bg-green-100 text-green-800"
      "INACTIVE" -> "bg-gray-100 text-gray-800"
      "PENDING_APPROVAL" -> "bg-yellow-100 text-yellow-800"
      "APPROVED" -> "bg-blue-100 text-blue-800"
      "REJECTED" -> "bg-red-100 text-red-800"
      "DISABLED" -> "bg-red-100 text-red-800"
      "PENDING" -> "bg-yellow-100 text-yellow-800"
      "COMPLETED" -> "bg-green-100 text-green-800"
      "CANCELLED" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  def status_display_name(status) do
    case status do
      "ACTIVE" -> "Active"
      "INACTIVE" -> "Inactive"
      "PENDING_APPROVAL" -> "Pending Approval"
      "APPROVED" -> "Approved"
      "REJECTED" -> "Rejected"
      "DISABLED" -> "Disabled"
      "PENDING" -> "Pending"
      "COMPLETED" -> "Completed"
      "CANCELLED" -> "Cancelled"
      _ -> status || "Unknown"
    end
  end

  def hearing_status_class(status) do
    case status do
      "HEARING" -> "bg-green-100 text-green-800"
      "DEAF" -> "bg-blue-100 text-blue-800"
      "HARD_OF_HEARING" -> "bg-yellow-100 text-yellow-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  def hearing_status_display_name(status) do
    case status do
      "HEARING" -> "Hearing"
      "DEAF" -> "Deaf"
      "HARD_OF_HEARING" -> "Hard of Hearing"
      _ -> status || "N/A"
    end
  end

  def format_date(datetime) do
    case datetime do
      nil -> "N/A"
      datetime -> Calendar.strftime(datetime, "%Y-%m-%d")
    end
  end

  def format_datetime(datetime) do
    case datetime do
      nil -> "N/A"
      datetime -> Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")
    end
  end

  def generate_pagination_details(data) do
    # This is a simplified pagination - you might want to implement proper pagination
    %{
      page_info: %{
        current_page_number: 1,
        total_count: length(data),
        page_size: 20,
        start_index: 1,
        end_index: length(data),
        has_previous_page: false,
        has_next_page: false,
        previous_page_number: nil,
        next_page_number: nil,
        page_numbers: [1]
      }
    }
  end
end
