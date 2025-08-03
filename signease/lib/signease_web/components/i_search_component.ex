defmodule SigneaseWeb.Components.ISearchComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center space-x-4">
      <div class="relative">
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
          </svg>
        </div>
        <input
          type="text"
          name="search"
          value={Map.get(@params, "search", "")}
          placeholder="Search instructors..."
          class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-purple-500 focus:border-purple-500 sm:text-sm"
          phx-keyup="iSearch"
          phx-target={@myself}
          phx-debounce="300"
        />
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("iSearch", %{"value" => search_term}, socket) do
    params = Map.put(socket.assigns.params, "search", search_term)
    send(self(), {:fetch_instructors, params})
    {:noreply, socket}
  end
end
