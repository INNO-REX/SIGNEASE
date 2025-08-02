defmodule SigneaseWeb.Admin.Notifications.SmsLogs.Index do
  use SigneaseWeb, :live_view

  alias Signease.Notifications
  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Signease.PubSub, "notification_updates")
    end

    {:ok, assign(socket,
      sms_notifications: [],
      current_user: get_current_user(),
      page_title: "SMS Notification Center",
      current_path: "/admin/notifications/sms-logs",
      current_page: "notifications",
      stats: get_notification_stats(),
      filters: %{},
      selected_sms: nil,
      show_message_modal: false
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    sms_notifications = try do
      Notifications.list_sms_notifications()
    rescue
      _ -> []
    end

    {:noreply, assign(socket, sms_notifications: sms_notifications)}
  end

  @impl true
  def handle_event("resend_sms", %{"id" => id}, socket) do
    sms_notification = Enum.find(socket.assigns.sms_notifications, &(&1.id == String.to_integer(id)))
    if sms_notification do
      case Notifications.update_sms_notification(sms_notification, %{
        status: "READY",
        attempts: 0
      }) do
        {:ok, _updated_sms} ->
          {:noreply, put_flash(socket, :info, "SMS queued for resend successfully!")}
        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to queue SMS for resend")}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("view_message", %{"id" => id}, socket) do
    sms_notification = Enum.find(socket.assigns.sms_notifications, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_sms: sms_notification, show_message_modal: true)}
  end

  @impl true
  def handle_event("delete_sms", %{"id" => id}, socket) do
    sms_notification = Enum.find(socket.assigns.sms_notifications, &(&1.id == String.to_integer(id)))
    if sms_notification do
      case Notifications.delete_sms_notification(sms_notification) do
        {:ok, _deleted_sms} ->
          # Refresh the list after deletion
          sms_notifications = try do
            Notifications.list_sms_notifications()
          rescue
            _ -> socket.assigns.sms_notifications
          end
          {:noreply, assign(socket, sms_notifications: sms_notifications) |> put_flash(:info, "SMS notification deleted successfully!")}
        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to delete SMS notification")}
      end
    else
      {:noreply, put_flash(socket, :error, "SMS notification not found")}
    end
  end

  @impl true
  def handle_event("close_message_modal", _params, socket) do
    {:noreply, assign(socket, show_message_modal: false, selected_sms: nil)}
  end

  @impl true
  def handle_event("filter_sms", %{"filters" => filters}, socket) do
    filtered_sms = apply_filters(socket.assigns.sms_notifications, filters)
    {:noreply, assign(socket, sms_notifications: filtered_sms, filters: filters)}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    sms_notifications = try do
      Notifications.list_sms_notifications()
    rescue
      _ -> []
    end
    {:noreply, assign(socket, sms_notifications: sms_notifications, filters: %{})}
  end

  @impl true
  def handle_info({:notification_created, _notification}, socket) do
    sms_notifications = try do
      Notifications.list_sms_notifications()
    rescue
      _ -> socket.assigns.sms_notifications
    end

    {:noreply, assign(socket, sms_notifications: sms_notifications)}
  end

  def handle_info({:notification_updated, _notification}, socket) do
    sms_notifications = try do
      Notifications.list_sms_notifications()
    rescue
      _ -> socket.assigns.sms_notifications
    end

    {:noreply, assign(socket, sms_notifications: sms_notifications)}
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

  defp get_status_class("READY"), do: "bg-yellow-100 text-yellow-800"
  defp get_status_class("SENT"), do: "bg-green-100 text-green-800"
  defp get_status_class("FAILED"), do: "bg-red-100 text-red-800"
  defp get_status_class("DELIVERED"), do: "bg-blue-100 text-blue-800"
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

  defp apply_filters(sms_notifications, filters) do
    sms_notifications
    |> filter_by_status(filters["status"])
    |> filter_by_type(filters["type"])
    |> filter_by_mobile(filters["mobile"])
  end

  defp filter_by_status(sms_notifications, nil), do: sms_notifications
  defp filter_by_status(sms_notifications, ""), do: sms_notifications
  defp filter_by_status(sms_notifications, status) do
    Enum.filter(sms_notifications, &(&1.status == status))
  end

  defp filter_by_type(sms_notifications, nil), do: sms_notifications
  defp filter_by_type(sms_notifications, ""), do: sms_notifications
  defp filter_by_type(sms_notifications, type) do
    Enum.filter(sms_notifications, &(&1.type == type))
  end

  defp filter_by_mobile(sms_notifications, nil), do: sms_notifications
  defp filter_by_mobile(sms_notifications, ""), do: sms_notifications
  defp filter_by_mobile(sms_notifications, mobile) do
    Enum.filter(sms_notifications, &String.contains?(&1.mobile, mobile))
  end
end
