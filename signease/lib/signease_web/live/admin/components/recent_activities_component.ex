defmodule SigneaseWeb.Admin.Components.RecentActivitiesComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-xl shadow-lg border border-gray-200">
      <div class="px-4 py-3 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-sm font-semibold text-gray-900">Recent Activities</h3>
          <button phx-click="refresh-activities" phx-target={@myself}
                  class="text-xs text-gray-500 hover:text-gray-700 transition-colors">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
            </svg>
          </button>
        </div>
      </div>
      <div class="p-4">
        <div class="space-y-3 max-h-48 overflow-y-auto">
          <%= for activity <- @activities do %>
            <div class="flex items-start space-x-2">
              <div class={[
                "flex-shrink-0 w-2 h-2 rounded-full mt-2",
                activity.severity == "success" && "bg-green-500",
                activity.severity == "warning" && "bg-yellow-500",
                activity.severity == "error" && "bg-red-500",
                activity.severity == "info" && "bg-blue-500"
              ]}></div>
              <div class="flex-1 min-w-0">
                <p class="text-xs text-gray-900 leading-tight"><%= activity.message %></p>
                <p class="text-xs text-gray-500 mt-1">
                  <%= Calendar.strftime(activity.timestamp, "%b %d, %I:%M %p") %>
                </p>
              </div>
              <div class="flex-shrink-0">
                <span class={[
                  "inline-flex items-center px-1.5 py-0.5 rounded-full text-xs font-medium",
                  activity.severity == "success" && "bg-green-100 text-green-800",
                  activity.severity == "warning" && "bg-yellow-100 text-yellow-800",
                  activity.severity == "error" && "bg-red-100 text-red-800",
                  activity.severity == "info" && "bg-blue-100 text-blue-800"
                ]}>
                  <%= String.capitalize(activity.severity) %>
                </span>
              </div>
            </div>
          <% end %>
        </div>

        <!-- View All Activities Button -->
        <div class="mt-4 pt-3 border-t border-gray-100">
          <button phx-click="view-all-activities" phx-target={@myself}
                  class="w-full text-center text-xs text-gray-600 hover:text-gray-900 font-medium transition-colors">
            View All Activities
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("refresh-activities", _params, socket) do
    # TODO: Refresh activities from the parent
    {:noreply, socket}
  end

  @impl true
  def handle_event("view-all-activities", _params, socket) do
    # TODO: Navigate to full activities page
    {:noreply, socket}
  end
end
