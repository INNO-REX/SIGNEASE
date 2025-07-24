defmodule SigneaseWeb.Admin.Components.ChartComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-xl shadow-lg border border-gray-200">
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">User Activity Overview</h3>
          <div class="flex items-center space-x-2">
            <span class="text-sm text-gray-500">Last 7 days</span>
            <button phx-click="refresh-chart" phx-target={@myself}
                    class="text-sm text-gray-500 hover:text-gray-700 transition-colors">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>
      <div class="p-6">
        <!-- Chart Container -->
        <div class="relative h-64">
          <!-- Y-axis labels -->
          <div class="absolute left-0 top-0 bottom-0 flex flex-col justify-between text-xs text-gray-500 w-8">
            <span>100</span>
            <span>75</span>
            <span>50</span>
            <span>25</span>
            <span>0</span>
          </div>

          <!-- Chart bars -->
          <div class="ml-8 h-full flex items-end justify-between space-x-2">
            <%= for {day, data} <- @chart_data do %>
              <div class="flex-1 flex flex-col items-center">
                <!-- Bar -->
                <div class="relative w-full">
                  <div class="bg-gradient-to-t from-blue-600 to-blue-400 rounded-t-lg transition-all duration-300 hover:from-blue-700 hover:to-blue-500"
                       style={"height: #{data.value}%"}>
                    <!-- Bar value tooltip -->
                    <div class="absolute -top-8 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 whitespace-nowrap">
                      <%= data.value %> users
                    </div>
                  </div>
                </div>
                <!-- Day label -->
                <div class="mt-2 text-xs text-gray-600 font-medium">
                  <%= day %>
                </div>
              </div>
            <% end %>
          </div>

          <!-- Grid lines -->
          <div class="absolute inset-0 ml-8 pointer-events-none">
            <div class="h-full flex flex-col justify-between">
              <%= for _i <- 1..4 do %>
                <div class="border-t border-gray-200"></div>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Chart Legend -->
        <div class="mt-6 flex items-center justify-center space-x-6">
          <div class="flex items-center space-x-2">
            <div class="w-3 h-3 bg-gradient-to-r from-blue-600 to-blue-400 rounded"></div>
            <span class="text-sm text-gray-600">Active Users</span>
          </div>
          <div class="flex items-center space-x-2">
            <div class="w-3 h-3 bg-gradient-to-r from-green-600 to-green-400 rounded"></div>
            <span class="text-sm text-gray-600">New Registrations</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("refresh-chart", _params, socket) do
    # TODO: Refresh chart data from parent
    {:noreply, socket}
  end
end
