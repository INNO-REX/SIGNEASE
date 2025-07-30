defmodule SigneaseWeb.Admin.Notifications.Manage.Index do
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
      page_title: "Manage Notifications",
      current_path: "/admin/notifications/manage",
      current_page: "notifications",
      stats: get_notification_stats(),
      show_create_modal: false,
      show_edit_modal: false,
      show_view_modal: false,
      selected_notification: nil,
      notification_form: %{}
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
  def handle_event("show_create_modal", _params, socket) do
    {:noreply, assign(socket, show_create_modal: true, notification_form: %{})}
  end

  def handle_event("hide_create_modal", _params, socket) do
    {:noreply, assign(socket, show_create_modal: false, notification_form: %{})}
  end

  def handle_event("show_edit_modal", %{"id" => id}, socket) do
    notification = Enum.find(socket.assigns.notifications, &(&1.id == String.to_integer(id)))
    if notification do
      {:noreply, assign(socket, show_edit_modal: true, selected_notification: notification, notification_form: %{
        title: notification.title,
        message: notification.message,
        description: notification.description,
        notification_type: notification.notification_type,
        priority: notification.priority,
        target_audience: notification.target_audience,
        delivery_channels: notification.delivery_channels
      })}
    else
      {:noreply, socket}
    end
  end

  def handle_event("hide_edit_modal", _params, socket) do
    {:noreply, assign(socket, show_edit_modal: false, selected_notification: nil, notification_form: %{})}
  end

  def handle_event("show_view_modal", %{"id" => id}, socket) do
    notification = Enum.find(socket.assigns.notifications, &(&1.id == String.to_integer(id)))
    if notification do
      {:noreply, assign(socket, show_view_modal: true, selected_notification: notification)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("hide_view_modal", _params, socket) do
    {:noreply, assign(socket, show_view_modal: false, selected_notification: nil)}
  end

  def handle_event("create_notification", %{"notification" => params}, socket) do
    notification_params = Map.merge(params, %{
      status: "PENDING_APPROVAL",
      created_by_id: socket.assigns.current_user.id
    })

    case Notifications.create_notification(notification_params) do
      {:ok, _notification} ->
        {:noreply,
         socket
         |> put_flash(:info, "Notification created successfully!")
         |> assign(show_create_modal: false, notification_form: %{})}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create notification")}
    end
  end

  def handle_event("update_notification", %{"notification" => params}, socket) do
    case Notifications.update_notification(socket.assigns.selected_notification, params) do
      {:ok, _notification} ->
        {:noreply,
         socket
         |> put_flash(:info, "Notification updated successfully!")
         |> assign(show_edit_modal: false, selected_notification: nil, notification_form: %{})}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update notification")}
    end
  end

  def handle_event("delete_notification", %{"id" => id}, socket) do
    notification = Enum.find(socket.assigns.notifications, &(&1.id == String.to_integer(id)))
    if notification do
      case Notifications.update_notification(notification, %{status: "CANCELLED"}) do
        {:ok, _notification} ->
          {:noreply, put_flash(socket, :info, "Notification cancelled successfully!")}
        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to cancel notification")}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("approve_notification", %{"id" => id}, socket) do
    notification = Enum.find(socket.assigns.notifications, &(&1.id == String.to_integer(id)))
    if notification do
      case Notifications.update_notification(notification, %{
        status: "ACTIVE",
        approved_by_id: socket.assigns.current_user.id
      }) do
        {:ok, _notification} ->
          {:noreply, put_flash(socket, :info, "Notification approved successfully!")}
        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to approve notification")}
      end
    else
      {:noreply, socket}
    end
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
