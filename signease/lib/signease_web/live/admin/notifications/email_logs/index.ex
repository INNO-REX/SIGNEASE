defmodule SigneaseWeb.Admin.Notifications.EmailLogs.Index do
  use SigneaseWeb, :live_view

  alias Signease.Notifications
  import SigneaseWeb.Components.LoaderComponent

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Signease.PubSub, "notification_updates")
    end

    {:ok, assign(socket,
      email_notifications: [],
      current_user: get_current_user(),
      page_title: "Email Logs",
      current_path: "/admin/notifications/email-logs",
      current_page: "notifications",
      stats: get_notification_stats(),
      selected_email: nil,
      show_email_modal: false
    )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    email_notifications = try do
      Notifications.list_email_notifications()
    rescue
      _ -> []
    end

    {:noreply, assign(socket, email_notifications: email_notifications)}
  end

  @impl true
  def handle_event("resend_email", %{"id" => id}, socket) do
    email_notification = Enum.find(socket.assigns.email_notifications, &(&1.id == String.to_integer(id)))
    if email_notification do
      case Notifications.update_email_notification(email_notification, %{
        status: "READY",
        attempts: "0"
      }) do
        {:ok, _updated_email} ->
          {:noreply, put_flash(socket, :info, "Email queued for resend successfully!")}
        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to queue email for resend")}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("view_email", %{"id" => id}, socket) do
    email_notification = Enum.find(socket.assigns.email_notifications, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, selected_email: email_notification, show_email_modal: true)}
  end

  @impl true
  def handle_event("close_email_modal", _params, socket) do
    {:noreply, assign(socket, show_email_modal: false, selected_email: nil)}
  end

  @impl true
  def handle_event("delete_email", %{"id" => id}, socket) do
    email_notification = Enum.find(socket.assigns.email_notifications, &(&1.id == String.to_integer(id)))
    if email_notification do
      case Notifications.delete_email_notification(email_notification) do
        {:ok, _deleted_email} ->
          # Refresh the list after deletion
          email_notifications = try do
            Notifications.list_email_notifications()
          rescue
            _ -> socket.assigns.email_notifications
          end
          {:noreply, assign(socket, email_notifications: email_notifications) |> put_flash(:info, "Email notification deleted successfully!")}
        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to delete email notification")}
      end
    else
      {:noreply, put_flash(socket, :error, "Email notification not found")}
    end
  end

  @impl true
  def handle_info({:notification_created, _notification}, socket) do
    email_notifications = try do
      Notifications.list_email_notifications()
    rescue
      _ -> socket.assigns.email_notifications
    end

    {:noreply, assign(socket, email_notifications: email_notifications)}
  end

  def handle_info({:notification_updated, _notification}, socket) do
    email_notifications = try do
      Notifications.list_email_notifications()
    rescue
      _ -> socket.assigns.email_notifications
    end

    {:noreply, assign(socket, email_notifications: email_notifications)}
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
end
