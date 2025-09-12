defmodule SigneaseWeb.Admin.Users.Components.FilterComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    assigns = assign_new(assigns, :filter_params, fn -> %{} end)
    assigns = assign_new(assigns, :user_type, fn -> "users" end)

    ~H"""
    <div class="px-4 py-5 sm:p-6">
      <h3 class="text-base font-semibold leading-6 text-gray-900 mb-4">
        Filter <%= String.capitalize(@user_type) %>
      </h3>

      <.simple_form for={%{}} as={:filter} phx-submit="filter" phx-target={@myself}>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input
            name="filter[search]"
            type="text"
            label="Search"
            value={Map.get(@filter_params, "search", "")}
            placeholder="Search by name, email, or username"
          />

          <.input
            name="filter[status]"
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
            name="filter[hearing_status]"
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

          <%= if @user_type == "instructors" do %>
            <.input
              name="filter[gender]"
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
          <% end %>

          <%= if @user_type == "users" do %>
            <.input
              name="filter[user_type]"
              type="select"
              label="User Type"
              value={Map.get(@filter_params, "user_type", "")}
              options={[
                {"All User Types", ""},
                {"Learner", "LEARNER"},
                {"Instructor", "INSTRUCTOR"},
                {"Admin", "ADMIN"}
              ]}
            />
          <% end %>
        </div>

        <:actions>
          <button type="submit" class="inline-flex items-center px-3 py-1.5 text-sm font-medium text-white bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 rounded-md shadow-sm transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
            <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"></path>
            </svg>
            Apply Filters
          </button>
          <button type="button" phx-click="clear_filters" phx-target={@myself} class="inline-flex items-center px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 hover:border-gray-400 rounded-md shadow-sm transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
            <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
            Clear Filters
          </button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

    @impl true
  def handle_event("filter", %{"filter" => filter_params}, socket) do
    # Send the filter event to the parent LiveView with the correct format
    send(self(), {:filter, %{"filter" => filter_params}})

    # Close the modal after applying filters
    send(self(), :close_modal)

    {:noreply, socket}
  end

    @impl true
  def handle_event("clear_filters", _params, socket) do
    # Send the filter event to the parent LiveView with empty filters
    send(self(), {:filter, %{"filter" => %{}}})

    # Close the modal after clearing filters
    send(self(), :close_modal)

    {:noreply, socket}
  end
end
