defmodule SigneaseWeb.Admin.Users.Components.FilterComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-5 sm:p-6">
      <h3 class="text-base font-semibold leading-6 text-gray-900 mb-4">
        Filter Instructors
      </h3>

      <.simple_form for={%{}} as={:filter} phx-submit="filter" phx-target={@myself}>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input
            field={{:filter, :search}}
            type="text"
            label="Search"
            value={Map.get(@filter_params, "search", "")}
            placeholder="Search by name, email, or username"
          />

          <.input
            field={{:filter, :status}}
            type="select"
            label="Status"
            value={Map.get(@filter_params, "status", "")}
            options={[
              {"All Statuses", ""},
              {"Active", "ACTIVE"},
              {"Pending Approval", "PENDING_APPROVAL"},
              {"Approved", "APPROVED"},
              {"Rejected", "REJECTED"},
              {"Disabled", "DISABLED"}
            ]}
          />

          <.input
            field={{:filter, :hearing_status}}
            type="select"
            label="Hearing Status"
            value={Map.get(@filter_params, "hearing_status", "")}
            options={[
              {"All Hearing Statuses", ""},
              {"Hearing", "HEARING"},
              {"Deaf", "DEAF"},
              {"Hard of Hearing", "HARD_OF_HEARING"}
            ]}
          />

          <.input
            field={{:filter, :gender}}
            type="select"
            label="Gender"
            value={Map.get(@filter_params, "gender", "")}
            options={[
              {"All Genders", ""},
              {"Male", "male"},
              {"Female", "female"},
              {"Other", "other"},
              {"Prefer not to say", "prefer_not_to_say"}
            ]}
          />
        </div>

        <:actions>
          <button type="submit" class="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg">
            Apply Filters
          </button>
          <button type="button" phx-click="clear_filters" phx-target={@myself} class="ml-2 bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg">
            Clear Filters
          </button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("filter", %{"filter" => filter_params}, socket) do
    send(self(), {:fetch_instructors, filter_params})
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    send(self(), {:fetch_instructors, %{}})
    {:noreply, socket}
  end
end
