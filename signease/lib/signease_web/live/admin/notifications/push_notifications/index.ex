defmodule SigneaseWeb.Admin.Notifications.PushNotifications.Index do
  use SigneaseWeb, :live_view

  alias Signease.Notifications
  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Signease.PubSub, "notification_updates")
    end

    {:ok, assign(socket,
      notifications: [],
      current_user: get_current_user(),
      page_title: "Push Notifications",
      current_path: "/admin/notifications/push_notifications",
      current_page: "notifications",
      stats: get_notification_stats(),
      selected_notification: nil
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    notifications = try do
      Notifications.list_notifications()
    rescue
      _ -> []
    end

    {:noreply, assign(socket, notifications: notifications)}
  end

  @impl true
  def handle_event("create_sample_notification", _params, socket) do
    # Create a sample notification for testing
    notification_params = %{
      title: "Welcome to SignEase!",
      message: "Thank you for joining our platform. We're excited to help you with your learning journey.",
      description: "A welcome message for new users",
      notification_type: "GENERAL",
      priority: "MEDIUM",
      status: "ACTIVE",
      target_audience: "ALL",
      delivery_channels: "in_app",
      created_by_id: socket.assigns.current_user.id
    }

    case Notifications.create_notification(notification_params) do
      {:ok, _notification} ->
        {:noreply, put_flash(socket, :info, "Sample notification created successfully!")}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create sample notification")}
    end
  end

  @impl true
  def handle_event("view_notification", %{"id" => id}, socket) do
    notification = Enum.find(socket.assigns.notifications, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_notification: notification)}
  end

  @impl true
  def handle_event("close_notification_modal", _params, socket) do
    {:noreply, assign(socket, selected_notification: nil)}
  end

  @impl true
  def handle_info({:notification_created, _notification}, socket) do
    notifications = try do
      Notifications.list_notifications()
    rescue
      _ -> socket.assigns.notifications
    end

    {:noreply, assign(socket, notifications: notifications)}
  end

  @impl true
  def handle_info({:notification_updated, _notification}, socket) do
    notifications = try do
      Notifications.list_notifications()
    rescue
      _ -> socket.assigns.notifications
    end

    {:noreply, assign(socket, notifications: notifications)}
  end

  defp get_current_user do
    # For now, return a mock user. In a real app, this would come from authentication
    %{
      id: 1,
      first_name: "System",
      last_name: "Admin",
      email: "admin@signease.com",
      user_type: "ADMIN",
      user_role: "ADMIN"
    }
  end

  defp format_notification_type("SECURITY_ALERT"), do: "Security Alert"
  defp format_notification_type("SYSTEM_UPDATE"), do: "System Update"
  defp format_notification_type("LEARNING_REMINDER"), do: "Learning Reminder"
  defp format_notification_type("SESSION_REMINDER"), do: "Session Reminder"
  defp format_notification_type("GENERAL"), do: "General"
  defp format_notification_type(type), do: type

  defp get_priority_class("CRITICAL"), do: "bg-red-100 text-red-800"
  defp get_priority_class("HIGH"), do: "bg-orange-100 text-orange-800"
  defp get_priority_class("MEDIUM"), do: "bg-yellow-100 text-yellow-800"
  defp get_priority_class("LOW"), do: "bg-green-100 text-green-800"
  defp get_priority_class(_), do: "bg-gray-100 text-gray-800"

  defp get_status_class("ACTIVE"), do: "bg-green-100 text-green-800"
  defp get_status_class("PENDING_APPROVAL"), do: "bg-yellow-100 text-yellow-800"
  defp get_status_class("SENT"), do: "bg-blue-100 text-blue-800"
  defp get_status_class("FAILED"), do: "bg-red-100 text-red-800"
  defp get_status_class("CANCELLED"), do: "bg-gray-100 text-gray-800"
  defp get_status_class(_), do: "bg-gray-100 text-gray-800"

  defp get_notification_stats do
    # Mock stats for notifications - in a real app, you'd fetch these from the database
    %{
      total_users: 0,
      total_notifications: 0,
      pending_notifications: 0,
      sent_notifications: 0
    }
  end
end
