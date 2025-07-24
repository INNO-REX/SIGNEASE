defmodule SigneaseWeb.Admin.Components.SystemHealthComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-xl shadow-lg border border-gray-200">
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">System Health</h3>
          <button phx-click="refresh-health" phx-target={@myself}
                  class="text-sm text-gray-500 hover:text-gray-700 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
            </svg>
          </button>
        </div>
      </div>
      <div class="p-6">
        <div class="space-y-4">
          <%= for {service, status} <- @system_health do %>
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <div class={[
                  "w-3 h-3 rounded-full",
                  status == "healthy" && "bg-green-500",
                  status == "warning" && "bg-yellow-500",
                  status == "error" && "bg-red-500"
                ]}></div>
                <span class="text-sm font-medium text-gray-700 capitalize"><%= service %></span>
              </div>
              <span class={[
                "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                status == "healthy" && "bg-green-100 text-green-800",
                status == "warning" && "bg-yellow-100 text-yellow-800",
                status == "error" && "bg-red-100 text-red-800"
              ]}>
                <%= status %>
              </span>
            </div>
          <% end %>
        </div>

        <!-- Overall Status -->
        <div class="mt-6 pt-4 border-t border-gray-100">
          <div class="flex items-center justify-between">
            <span class="text-sm font-medium text-gray-700">Overall Status</span>
            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
              All Systems Operational
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("refresh-health", _params, socket) do
    # TODO: Refresh system health from the parent
    {:noreply, socket}
  end
end
