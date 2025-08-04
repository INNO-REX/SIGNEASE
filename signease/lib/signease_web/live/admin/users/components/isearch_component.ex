defmodule SigneaseWeb.Admin.Users.Components.ISearchComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative">
      <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
        <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
        </svg>
      </div>
      <input
        type="text"
        placeholder="Search by name, email, or username..."
        value={Map.get(@params, "search", "")}
        phx-keyup="iSearch"
        phx-target={@myself}
        phx-debounce="300"
        class="w-80 pl-10 pr-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white shadow-sm hover:shadow-md transition-all duration-200 text-sm placeholder-gray-500"
      />
      <%= if Map.get(@params, "search", "") != "" do %>
        <button
          phx-click="clearSearch"
          phx-target={@myself}
          class="absolute inset-y-0 right-0 pr-3 flex items-center"
        >
          <svg class="h-5 w-5 text-gray-400 hover:text-gray-600 transition-colors duration-150" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("iSearch", %{"value" => search_term}, socket) do
    current_params = socket.assigns.params
    new_params = Map.put(current_params, "search", search_term)
    new_params = Map.put(new_params, "page", "1") # Reset to first page when searching

    send(self(), {:fetch_data, new_params})
    {:noreply, socket}
  end

  @impl true
  def handle_event("clearSearch", _params, socket) do
    current_params = socket.assigns.params
    new_params = Map.delete(current_params, "search")
    new_params = Map.put(new_params, "page", "1") # Reset to first page when clearing

    send(self(), {:fetch_data, new_params})
    {:noreply, socket}
  end
end
