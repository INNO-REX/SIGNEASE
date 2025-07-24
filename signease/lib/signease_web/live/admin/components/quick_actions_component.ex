defmodule SigneaseWeb.Admin.Components.QuickActionsComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-xl shadow-lg border border-gray-200">
      <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-900">Quick Actions</h3>
      </div>
      <div class="p-6">
        <div class="space-y-3">
          <!-- Add New User -->
          <button phx-click="add-new-user" phx-target={@myself}
                  class="w-full flex items-center justify-center px-4 py-2 bg-gradient-to-r from-orange-600 to-red-600 text-white font-medium rounded-lg hover:from-orange-700 hover:to-red-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
            </svg>
            Add New User
          </button>

          <!-- Generate Report -->
          <button phx-click="generate-report" phx-target={@myself}
                  class="w-full flex items-center justify-center px-4 py-2 bg-gray-100 text-gray-700 font-medium rounded-lg hover:bg-gray-200 transition-all duration-200">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            Generate Report
          </button>

          <%= if @current_user.user_role == "SUPER_ADMIN" do %>
            <!-- System Settings (Super Admin Only) -->
            <button phx-click="system-settings" phx-target={@myself}
                    class="w-full flex items-center justify-center px-4 py-2 bg-gray-100 text-gray-700 font-medium rounded-lg hover:bg-gray-200 transition-all duration-200">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
              System Settings
            </button>

            <!-- Database Backup (Super Admin Only) -->
            <button phx-click="database-backup" phx-target={@myself}
                    class="w-full flex items-center justify-center px-4 py-2 bg-gray-100 text-gray-700 font-medium rounded-lg hover:bg-gray-200 transition-all duration-200">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"></path>
              </svg>
              Database Backup
            </button>

            <!-- View Logs (Super Admin Only) -->
            <button phx-click="view-logs" phx-target={@myself}
                    class="w-full flex items-center justify-center px-4 py-2 bg-gray-100 text-gray-700 font-medium rounded-lg hover:bg-gray-200 transition-all duration-200">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              View Logs
            </button>
          <% end %>

          <!-- User Management (All Admins) -->
          <button phx-click="user-management" phx-target={@myself}
                  class="w-full flex items-center justify-center px-4 py-2 bg-blue-100 text-blue-700 font-medium rounded-lg hover:bg-blue-200 transition-all duration-200">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
            </svg>
            User Management
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("add-new-user", _params, socket) do
    # TODO: Navigate to add user page or open modal
    {:noreply, socket}
  end

  @impl true
  def handle_event("generate-report", _params, socket) do
    # TODO: Generate and download report
    {:noreply, socket}
  end

  @impl true
  def handle_event("system-settings", _params, socket) do
    # TODO: Navigate to system settings
    {:noreply, socket}
  end

  @impl true
  def handle_event("database-backup", _params, socket) do
    # TODO: Initiate database backup
    {:noreply, socket}
  end

  @impl true
  def handle_event("view-logs", _params, socket) do
    # TODO: Navigate to logs page
    {:noreply, socket}
  end

  @impl true
  def handle_event("user-management", _params, socket) do
    # TODO: Navigate to user management page
    {:noreply, socket}
  end
end
