defmodule SigneaseWeb.Admin.Components.ServiceUsageComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">Learning Progress</h3>
          <div class="flex items-center space-x-2">
            <span class="text-sm text-gray-500">Progress Overview</span>
            <button phx-click="refresh-service-usage" phx-target={@myself}
                    class="text-sm text-gray-500 hover:text-gray-700 transition-colors">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>
      <div class="p-6">
        <div class="space-y-6">
          <%= for service <- @services do %>
            <div class="space-y-2">
              <div class="flex items-center justify-between">
                <div class="flex items-center space-x-3">
                  <div class="w-3 h-3 rounded-full" style={"background-color: #{service.color}"}></div>
                  <span class="text-sm font-medium text-gray-700"><%= service.name %></span>
                </div>
                <div class="flex items-center space-x-2">
                  <span class="text-sm font-semibold text-gray-900"><%= service.value %></span>
                  <span class="text-xs text-gray-500">(<%= service.percentage %>%)</span>
                </div>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
                <div class="h-full rounded-full progress-animate hover:scale-y-110"
                     style={"width: #{service.percentage}%; background: linear-gradient(90deg, #{service.color}, #{service.color}dd);"}></div>
              </div>
              <div class="flex items-center justify-between text-xs text-gray-500">
                <span>Target: <%= service.target %></span>
                <span>Last Month: <%= service.last_month %></span>
              </div>
            </div>
          <% end %>
        </div>

        <!-- Summary Stats -->
        <div class="mt-6 pt-6 border-t border-gray-200">
          <div class="grid grid-cols-2 gap-4">
            <div class="text-center">
              <div class="text-2xl font-bold text-gray-900"><%= @total_usage %></div>
              <div class="text-xs text-gray-500">Total Sessions</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-green-600"><%= @growth_rate %>%</div>
              <div class="text-xs text-gray-500">Growth Rate</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("refresh-service-usage", _params, socket) do
    # TODO: Refresh service usage data from parent
    {:noreply, socket}
  end
end
