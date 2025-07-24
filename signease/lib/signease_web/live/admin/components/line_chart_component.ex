defmodule SigneaseWeb.Admin.Components.LineChartComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="chart-container bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
        <div class="px-6 py-4 border-b border-gray-200">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold text-gray-900"><%= @chart_title %></h3>
            <div class="flex items-center space-x-2">
              <span class="text-sm text-gray-500"><%= @chart_subtitle %></span>
              <button phx-click="refresh-line-chart" phx-target={@myself}
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
            <div id={"line-chart-#{@id}"} class="w-full h-full" phx-hook="LineChart" data-chart-data={Jason.encode!(@chart_data)}></div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("refresh-line-chart", _params, socket) do
    # TODO: Refresh line chart data from parent
    {:noreply, socket}
  end
end
