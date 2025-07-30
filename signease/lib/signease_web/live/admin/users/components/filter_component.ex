defmodule SigneaseWeb.Admin.Users.Components.FilterComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    # Handle empty filters data
    assigns = case assigns.filters do
      %{} -> %{assigns | filters: %{search: "", status: "", user_type: "", role: "", date_from: "", date_to: ""}}
      filters when is_map(filters) and map_size(filters) > 0 -> assigns
      _ -> %{assigns | filters: %{search: "", status: "", user_type: "", role: "", date_from: "", date_to: ""}}
    end

    ~H"""
    <div class="mb-6" x-data="{ open: false }">
      <!-- Filter Toggle Button -->
      <div class="flex items-center justify-between mb-4">
        <button
          @click="open = !open"
          type="button"
          class="inline-flex items-center px-4 py-2 bg-white border border-gray-300 rounded-lg shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200"
        >
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.207A1 1 0 013 6.5V4z"></path>
          </svg>
          Filters
                    <svg
            class="w-4 h-4 ml-2 transition-transform duration-200"
            x-bind:class="open ? 'rotate-180' : ''"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
          </svg>
        </button>

        <button
          phx-click="clear_filters"
          class="text-sm text-gray-500 hover:text-gray-700 underline"
        >
          Clear all filters
        </button>
      </div>

      <!-- Filter Form (Collapsible) -->
      <div
        x-show="open"
        x-transition:enter="transition ease-out duration-200"
        x-transition:enter-start="opacity-0 transform -translate-y-2"
        x-transition:enter-end="opacity-100 transform translate-y-0"
        x-transition:leave="transition ease-in duration-150"
        x-transition:leave-start="opacity-100 transform translate-y-0"
        x-transition:leave-end="opacity-0 transform -translate-y-2"
        class="bg-white border border-gray-200 rounded-lg p-6 shadow-sm"
        style="display: none;"
      >
        <form phx-submit="filter" phx-target={@myself} class="space-y-4">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <!-- Search -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Search</label>
            <input
              type="text"
              name="search"
              value={Map.get(@filters, :search, "")}
              placeholder="Search by name or email..."
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <!-- Status -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
            <select
              name="status"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">All Statuses</option>
              <option value="ACTIVE" selected={Map.get(@filters, :status, "") == "ACTIVE"}>Active</option>
              <option value="INACTIVE" selected={Map.get(@filters, :status, "") == "INACTIVE"}>Inactive</option>
              <option value="PENDING_APPROVAL" selected={Map.get(@filters, :status, "") == "PENDING_APPROVAL"}>Pending Approval</option>
              <option value="APPROVED" selected={Map.get(@filters, :status, "") == "APPROVED"}>Approved</option>
              <option value="REJECTED" selected={Map.get(@filters, :status, "") == "REJECTED"}>Rejected</option>
              <option value="DISABLED" selected={Map.get(@filters, :status, "") == "DISABLED"}>Disabled</option>
            </select>
          </div>

          <!-- User Type -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">User Type</label>
            <select
              name="user_type"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">All Types</option>
              <option value="LEARNER" selected={Map.get(@filters, :user_type, "") == "LEARNER"}>Learner</option>
              <option value="INSTRUCTOR" selected={Map.get(@filters, :user_type, "") == "INSTRUCTOR"}>Instructor</option>
              <option value="ADMIN" selected={Map.get(@filters, :user_type, "") == "ADMIN"}>Admin</option>
              <option value="SUPPORT" selected={Map.get(@filters, :user_type, "") == "SUPPORT"}>Support</option>
            </select>
          </div>

          <!-- Role -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
            <select
              name="role"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">All Roles</option>
              <option value="1" selected={Map.get(@filters, :role, "") == "1"}>Super Admin</option>
              <option value="2" selected={Map.get(@filters, :role, "") == "2"}>Admin</option>
              <option value="3" selected={Map.get(@filters, :role, "") == "3"}>Instructor</option>
              <option value="4" selected={Map.get(@filters, :role, "") == "4"}>Learner</option>
            </select>
          </div>

          <!-- Date From -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Date From</label>
            <input
              type="date"
              name="date_from"
              value={Map.get(@filters, :date_from, "")}
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          <!-- Date To -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Date To</label>
            <input
              type="date"
              name="date_to"
              value={Map.get(@filters, :date_to, "")}
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>

        <div class="flex justify-end">
          <button
            type="submit"
            class="inline-flex items-center px-4 py-2 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
          >
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
            </svg>
            Apply Filters
          </button>
        </div>
      </form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("filter", params, socket) do
    send(socket.assigns.parent_pid, {:filter, params})
    {:noreply, socket}
  end
end
