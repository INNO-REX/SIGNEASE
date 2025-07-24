defmodule SigneaseWeb.Admin.Components.PieChartComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="chart-container bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden hover:shadow-2xl transition-all duration-300 transform hover:scale-[1.02]">
        <!-- Header with gradient background -->
        <div class="px-6 py-5 bg-gradient-to-r from-blue-600 to-purple-600">
          <div class="flex items-center justify-between">
            <div>
              <h3 class="text-xl font-bold text-white"><%= @chart_title %></h3>
              <p class="text-blue-100 text-sm mt-1"><%= @chart_subtitle %></p>
            </div>
            <div class="flex items-center space-x-3">
              <div class="w-2 h-2 bg-white rounded-full animate-pulse"></div>
              <button phx-click="refresh-pie-chart" phx-target={@myself}
                      class="p-2 bg-white/20 hover:bg-white/30 rounded-lg transition-all duration-200 text-white hover:scale-110">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                </svg>
              </button>
            </div>
          </div>
        </div>

        <!-- Chart Content -->
        <div class="p-6">
          <!-- Chart Container with enhanced styling -->
          <div class="relative h-52 flex items-center justify-center bg-gradient-to-br from-gray-50 to-white rounded-xl border border-gray-100 mb-6">
            <div class="absolute inset-0 bg-gradient-to-br from-blue-50/50 to-purple-50/50 rounded-xl"></div>
            <!-- ApexCharts will be rendered here -->
            <div id={"pie-chart-#{@id}"} class="relative w-full h-full z-10" phx-hook="PieChart" data-chart-data={Jason.encode!(@pie_data)}></div>

            <!-- Center decoration -->
            <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-16 h-16 bg-white rounded-full shadow-lg border-4 border-blue-100 flex items-center justify-center z-20">
              <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
              </svg>
            </div>
          </div>

          <!-- Enhanced Legend -->
          <div class="space-y-3">
            <%= for {segment, _index} <- Enum.with_index(@pie_data) do %>
              <div class="group relative overflow-hidden bg-gradient-to-r from-gray-50 to-white rounded-xl border border-gray-100 hover:border-gray-200 transition-all duration-300 hover:shadow-md">
                <div class="flex items-center justify-between p-4">
                  <div class="flex items-center space-x-4">
                    <div class="relative">
                      <div class="w-5 h-5 rounded-full shadow-lg" style={"background: linear-gradient(135deg, #{segment.color}, #{segment.color}dd)"}></div>
                      <div class="absolute inset-0 w-5 h-5 rounded-full bg-white/30 animate-ping"></div>
                    </div>
                    <div>
                      <span class="text-sm font-semibold text-gray-800 group-hover:text-gray-900 transition-colors"><%= segment.label %></span>
                      <div class="text-xs text-gray-500 mt-1">Learning Type</div>
                    </div>
                  </div>
                  <div class="flex items-center space-x-3">
                    <div class="text-right">
                      <div class="text-lg font-bold text-gray-900" style={"color: #{segment.color}"}><%= segment.value %></div>
                      <div class="text-xs text-gray-500">sessions</div>
                    </div>
                    <div class="flex flex-col items-center">
                      <div class="text-sm font-bold text-gray-700"><%= Float.round(segment.percentage, 1) %>%</div>
                      <div class="w-12 h-1 bg-gray-200 rounded-full overflow-hidden">
                        <div class="h-full rounded-full transition-all duration-500 ease-out"
                             style={"background: linear-gradient(90deg, #{segment.color}, #{segment.color}dd); width: #{segment.percentage}%"}>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Hover effect overlay -->
                <div class="absolute inset-0 bg-gradient-to-r from-blue-500/5 to-purple-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              </div>
            <% end %>
          </div>

          <!-- Summary Stats -->
          <div class="mt-6 pt-6 border-t border-gray-100">
            <div class="grid grid-cols-2 gap-4">
              <div class="text-center p-3 bg-gradient-to-r from-blue-50 to-blue-100 rounded-lg">
                <div class="text-2xl font-bold text-blue-600">
                  <%= Enum.reduce(@pie_data, 0, fn segment, acc -> acc + segment.value end) %>
                </div>
                <div class="text-xs text-blue-700 font-medium">Total Sessions</div>
              </div>
              <div class="text-center p-3 bg-gradient-to-r from-purple-50 to-purple-100 rounded-lg">
                <div class="text-2xl font-bold text-purple-600">
                  <%= length(@pie_data) %>
                </div>
                <div class="text-xs text-purple-700 font-medium">Categories</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("refresh-pie-chart", _params, socket) do
    # TODO: Refresh pie chart data from parent
    {:noreply, socket}
  end
end
