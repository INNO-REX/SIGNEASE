defmodule SigneaseWeb.Admin.Users.Components.FilterComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :filters, if(assigns.filters == %{}, do: %{search: "", hearing_status: "", gender: "", access_type: ""}, else: assigns.filters))

    ~H"""
    <div class="bg-white rounded-xl shadow-lg border border-gray-200 mb-6">
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">Filters</h3>
          <button
            type="button"
            x-data="{ open: false }"
            x-on:click="open = !open"
            class="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <svg
              x-bind:class="open ? 'rotate-180' : ''"
              class="w-5 h-5 transition-transform duration-200"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </button>
        </div>
      </div>

      <div x-data="{ open: false }" x-show="open" x-transition class="px-6 py-4">
        <form phx-change="filter" phx-target={@myself}>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div>
              <.input
                type="text"
                name="filters[search]"
                value={Map.get(@filters, :search, "")}
                label="Search"
                placeholder="Search by name, email, or username..."
              />
            </div>
            <div>
              <.input
                type="select"
                name="filters[hearing_status]"
                value={Map.get(@filters, :hearing_status, "")}
                label="Hearing Status"
                options={[
                  {"", "All Hearing Statuses"},
                  {"hearing", "Hearing"},
                  {"deaf", "Deaf"}
                ]}
              />
            </div>
            <div>
              <.input
                type="select"
                name="filters[gender]"
                value={Map.get(@filters, :gender, "")}
                label="Gender"
                options={[
                  {"", "All Genders"},
                  {"male", "Male"},
                  {"female", "Female"},
                  {"other", "Other"}
                ]}
              />
            </div>
            <div>
              <.input
                type="select"
                name="filters[access_type]"
                value={Map.get(@filters, :access_type, "")}
                label="Access Type"
                options={[
                  {"", "All Access Types"},
                  {"student", "Student"},
                  {"teacher", "Teacher"},
                  {"admin", "Admin"}
                ]}
              />
            </div>
          </div>

          <div class="flex justify-end space-x-3 mt-4 pt-4 border-t border-gray-200">
            <button
              type="button"
              phx-click="clear_filters"
              phx-target={@myself}
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Clear Filters
            </button>
            <button
              type="submit"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Apply Filters
            </button>
          </div>
        </form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("filter", %{"filters" => filters}, socket) do
    send(socket.assigns.parent_pid, {:filter, %{"filters" => filters}})
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    send(socket.assigns.parent_pid, {:filter, %{"filters" => %{}}})
    {:noreply, socket}
  end
end
