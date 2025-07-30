defmodule SigneaseWeb.Admin.Components.NotificationBellComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative" x-data="{ open: false }">
      <!-- Notification Bell Button -->
      <button
        @click="open = !open"
        @click.away="open = false"
        class="relative p-2 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 rounded-lg transition-colors duration-200"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM10.5 3.75a6 6 0 00-6 6v3.75a6 6 0 006 6h3a6 6 0 006-6V9.75a6 6 0 00-6-6h-3z"></path>
        </svg>

        <!-- Notification Badge -->
        <%= if @unread_count > 0 do %>
          <span class="absolute -top-1 -right-1 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-500 rounded-full">
            <%= if @unread_count > 99 do %>
              99+
            <% else %>
              <%= @unread_count %>
            <% end %>
          </span>
        <% end %>
      </button>

      <!-- Notification Dropdown -->
      <div
        x-show="open"
        x-transition:enter="transition ease-out duration-200"
        x-transition:enter-start="transform opacity-0 scale-95"
        x-transition:enter-end="transform opacity-100 scale-100"
        x-transition:leave="transition ease-in duration-150"
        x-transition:leave-start="transform opacity-100 scale-100"
        x-transition:leave-end="transform opacity-0 scale-95"
        class="absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 z-50"
        style="display: none;"
      >
        <div class="p-4">
          <!-- Header -->
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900">Notifications</h3>
            <%= if @unread_count > 0 do %>
              <button
                phx-click="mark_all_read"
                phx-target={@myself}
                class="text-sm text-blue-600 hover:text-blue-800 underline"
              >
                Mark all read
              </button>
            <% end %>
          </div>

          <!-- Notification List -->
          <div class="space-y-3 max-h-96 overflow-y-auto">
            <%= if Enum.empty?(@notifications) do %>
              <div class="text-center py-8">
                <svg class="mx-auto h-8 w-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM10.5 3.75a6 6 0 00-6 6v3.75a6 6 0 006 6h3a6 6 0 006-6V9.75a6 6 0 00-6-6h-3z"></path>
                </svg>
                <p class="mt-2 text-sm text-gray-500">No notifications</p>
              </div>
            <% else %>
              <%= for notification <- @notifications do %>
                <div class="flex items-start space-x-3 p-3 rounded-lg hover:bg-gray-50 transition-colors duration-150">
                  <!-- Notification Icon -->
                  <div class="flex-shrink-0">
                    <div class={[
                      "w-8 h-8 rounded-full flex items-center justify-center",
                      get_notification_icon_class(notification.notification_type)
                    ]}>
                      <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <%= get_notification_icon(notification.notification_type) %>
                      </svg>
                    </div>
                  </div>

                  <!-- Notification Content -->
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 truncate">
                      <%= notification.title %>
                    </p>
                    <p class="text-sm text-gray-500 mt-1 line-clamp-2">
                      <%= notification.message %>
                    </p>
                    <div class="flex items-center justify-between mt-2">
                      <span class={[
                        "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium",
                        get_priority_class(notification.priority)
                      ]}>
                        <%= notification.priority %>
                      </span>
                      <span class="text-xs text-gray-400">
                        <%= format_time_ago(notification.inserted_at) %>
                      </span>
                    </div>
                  </div>

                  <!-- Unread Indicator -->
                  <%= if notification.status == "ACTIVE" do %>
                    <div class="flex-shrink-0">
                      <div class="w-2 h-2 bg-blue-500 rounded-full"></div>
                    </div>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>

          <!-- Footer -->
          <div class="mt-4 pt-4 border-t border-gray-200">
            <.link
              navigate={~p"/admin/notifications"}
              class="block w-full text-center text-sm text-blue-600 hover:text-blue-800 font-medium"
            >
              View all notifications
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Signease.PubSub, "notification_updates")
    end

    {:ok, socket}
  end

    @impl true
  def update(assigns, socket) do
    # Safely get notifications, handle case when tables don't exist yet
    notifications = try do
      Signease.Notifications.get_recent_notifications_for_user(assigns.current_user, 5)
    rescue
      _ -> []
    end

    unread_count = try do
      Signease.Notifications.get_unread_notification_count(assigns.current_user)
    rescue
      _ -> 0
    end

    socket = assign(socket,
      current_user: assigns.current_user,
      notifications: notifications,
      unread_count: unread_count
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("mark_all_read", _params, socket) do
    # In a real implementation, you would mark notifications as read
    # For now, we'll just refresh the notifications
    notifications = Signease.Notifications.get_recent_notifications_for_user(socket.assigns.current_user, 5)
    unread_count = 0

    {:noreply, assign(socket, notifications: notifications, unread_count: unread_count)}
  end

    def handle_info({:notification_created, _notification}, socket) do
    notifications = try do
      Signease.Notifications.get_recent_notifications_for_user(socket.assigns.current_user, 5)
    rescue
      _ -> socket.assigns.notifications
    end

    unread_count = try do
      Signease.Notifications.get_unread_notification_count(socket.assigns.current_user)
    rescue
      _ -> socket.assigns.unread_count
    end

    {:noreply, assign(socket, notifications: notifications, unread_count: unread_count)}
  end

  def handle_info({:notification_updated, _notification}, socket) do
    notifications = try do
      Signease.Notifications.get_recent_notifications_for_user(socket.assigns.current_user, 5)
    rescue
      _ -> socket.assigns.notifications
    end

    unread_count = try do
      Signease.Notifications.get_unread_notification_count(socket.assigns.current_user)
    rescue
      _ -> socket.assigns.unread_count
    end

    {:noreply, assign(socket, notifications: notifications, unread_count: unread_count)}
  end

  # Helper functions
  defp get_notification_icon_class("SECURITY_ALERT"), do: "bg-red-500"
  defp get_notification_icon_class("SYSTEM_UPDATE"), do: "bg-blue-500"
  defp get_notification_icon_class("LEARNING_REMINDER"), do: "bg-green-500"
  defp get_notification_icon_class("SESSION_REMINDER"), do: "bg-yellow-500"
  defp get_notification_icon_class(_), do: "bg-gray-500"

  defp get_notification_icon("SECURITY_ALERT") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>)
  end

  defp get_notification_icon("SYSTEM_UPDATE") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>)
  end

  defp get_notification_icon("LEARNING_REMINDER") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>)
  end

  defp get_notification_icon("SESSION_REMINDER") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>)
  end

  defp get_notification_icon(_) do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>)
  end

  defp get_priority_class("CRITICAL"), do: "bg-red-100 text-red-800"
  defp get_priority_class("HIGH"), do: "bg-orange-100 text-orange-800"
  defp get_priority_class("MEDIUM"), do: "bg-yellow-100 text-yellow-800"
  defp get_priority_class("LOW"), do: "bg-green-100 text-green-800"
  defp get_priority_class(_), do: "bg-gray-100 text-gray-800"

  defp format_time_ago(datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 -> "Just now"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86400 -> "#{div(diff, 3600)}h ago"
      diff < 2592000 -> "#{div(diff, 86400)}d ago"
      true -> "#{div(diff, 2592000)}mo ago"
    end
  end
end
