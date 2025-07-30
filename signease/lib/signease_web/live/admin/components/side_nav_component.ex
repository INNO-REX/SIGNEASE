defmodule SigneaseWeb.Admin.Components.SideNavComponent do
  use SigneaseWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, current_user: nil)}
  end

  @impl true
  def update(%{id: id, current_page: current_page, stats: stats, current_user: current_user}, socket) do
    {:ok, assign(socket, id: id, current_page: current_page, stats: stats, current_user: current_user)}
  end

    @impl true
  def render(assigns) do
    ~H"""
    <div class="flex min-h-screen">
      <!-- Sidebar -->
      <div class="w-64 bg-gray-800 shadow-xl flex flex-col">
        <!-- Sidebar Header -->
        <div class="flex items-center justify-center h-16 px-4 bg-gray-900 flex-shrink-0">
          <h1 class="text-xl font-bold text-white">SignEase Admin</h1>
        </div>

        <!-- Sidebar Content -->
        <div class="flex-1 overflow-y-auto">
          <nav class="px-2 py-4 bg-gray-800 space-y-1" x-data="{ activeDropdown: null, handleButtonClick(dropdownName) { this.activeDropdown = dropdownName; } }">

            <!-- Dashboard -->
            <button phx-click="navigate-to-dashboard" phx-target={@myself}
                    class={[
                      "group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg",
                      @current_page == "dashboard" && "bg-gray-900 text-white",
                      @current_page != "dashboard" && "text-gray-300 hover:bg-gray-700 hover:text-white"
                    ]}>
              <svg class={[
                "mr-3 flex-shrink-0 h-6 w-6",
                @current_page == "dashboard" && "text-white",
                @current_page != "dashboard" && "text-gray-400 group-hover:text-gray-300"
              ]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5a2 2 0 012-2h4a2 2 0 012 2v6H8V5z"></path>
              </svg>
              Dashboard
            </button>

            <!-- User Management Dropdown -->
            <div class="space-y-1">
                              <button @click="activeDropdown = activeDropdown === 'user-management' ? null : 'user-management'"
                        class="group flex items-center justify-between w-full px-2 py-2 text-sm font-medium rounded-md text-gray-300 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                <div class="flex items-center">
                  <svg class="mr-3 flex-shrink-0 h-6 w-6 text-gray-400 group-hover:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                  </svg>
                  User Management
                  <span class="ml-2 bg-gray-700 text-gray-300 text-xs font-medium px-2 py-0.5 rounded-full">
                    <%= Map.get(@stats, :total_users, 0) %>
                  </span>
                </div>
                <svg class="w-4 h-4 transition-transform duration-200"  fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>

              <div x-show="activeDropdown === 'user-management'"
                   x-transition:enter="transition ease-out duration-500"
                   x-transition:enter-start="opacity-0 transform -translate-y-2"
                   x-transition:enter-end="opacity-100 transform translate-y-0"
                   x-transition:leave="transition ease-in duration-300"
                   x-transition:leave-start="opacity-100 transform translate-y-0"
                   x-transition:leave-end="opacity-0 transform -translate-y-2"
                   class="ml-4 space-y-1 overflow-hidden" style="display: none;">
                <button @click="handleButtonClick('user-management')" phx-click="navigate-to-all-users" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                  </svg>
                  All Users
                </button>
                <button @click="handleButtonClick('user-management')" phx-click="navigate-to-learners" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>
                  </svg>
                  Learners
                </button>
                <button @click="handleButtonClick('user-management')" phx-click="navigate-to-instructors" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2-2v2m8 0V6a2 2 0 012 2v6a2 2 0 01-2 2H8a2 2 0 01-2-2V8a2 2 0 012-2V6"></path>
                  </svg>
                  Instructors
                </button>
                <button @click="handleButtonClick('user-management')" phx-click="navigate-to-admins" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                  </svg>
                  Administrators
                </button>
                <button @click="handleButtonClick('user-management')" phx-click="navigate-to-user-import" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                  </svg>
                  Import Users
                </button>
              </div>
            </div>

            <!-- Learning Management Dropdown -->
            <div class="space-y-1">
              <button @click="activeDropdown = activeDropdown === 'learning-management' ? null : 'learning-management'"
                      class="group flex items-center justify-between w-full px-2 py-2 text-xs font-medium rounded-md text-gray-300 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                <div class="flex items-center min-w-0">
                  <svg class="mr-2 flex-shrink-0 h-5 w-5 text-gray-400 group-hover:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>
                  </svg>
                  <span class="truncate">Learning</span>
                </div>
                <svg class="w-4 h-4 transition-transform duration-200 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>

              <div x-show="activeDropdown === 'learning-management'"
                   x-transition:enter="transition ease-out duration-500"
                   x-transition:enter-start="opacity-0 transform -translate-y-2"
                   x-transition:enter-end="opacity-100 transform translate-y-0"
                   x-transition:leave="transition ease-in duration-300"
                   x-transition:leave-start="opacity-100 transform translate-y-0"
                   x-transition:leave-end="opacity-0 transform -translate-y-2"
                   class="ml-4 space-y-1 overflow-hidden" style="display: none;">
                <button @click="handleButtonClick('learning-management')" phx-click="navigate-to-courses" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                  </svg>
                  Courses
                </button>
                <button @click="handleButtonClick('learning-management')" phx-click="navigate-to-lessons" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                  </svg>
                  Lessons
                </button>
                <button @click="handleButtonClick('learning-management')" phx-click="navigate-to-sign-language" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 4V2a1 1 0 011-1h8a1 1 0 011 1v2m-9 0h10m-10 0a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V6a2 2 0 00-2-2"></path>
                  </svg>
                  Sign Language Types
                </button>
                <button @click="handleButtonClick('learning-management')" phx-click="navigate-to-speech-to-text" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"></path>
                  </svg>
                  Speech-to-Text
                </button>
                <button @click="handleButtonClick('learning-management')" phx-click="navigate-to-assessments" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                  Assessments
                </button>
              </div>
            </div>

            <!-- Roles & Permissions Dropdown -->
            <div class="space-y-1">
              <button @click="activeDropdown = activeDropdown === 'roles-permissions' ? null : 'roles-permissions'"
                      class={[
                        "group flex items-center justify-between w-full px-2 py-2 text-xs font-medium rounded-md transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg",
                        (@current_page == "roles" || @current_page == "permissions" || @current_page == "role_assignments") && "bg-gray-700 text-white",
                        (@current_page != "roles" && @current_page != "permissions" && @current_page != "role_assignments") && "text-gray-300 hover:bg-gray-700 hover:text-white"
                      ]}>
                <div class="flex items-center min-w-0">
                  <svg class={[
                    "mr-2 flex-shrink-0 h-5 w-5",
                    (@current_page == "roles" || @current_page == "permissions" || @current_page == "role_assignments") && "text-white",
                    (@current_page != "roles" && @current_page != "permissions" && @current_page != "role_assignments") && "text-gray-400 group-hover:text-gray-300"
                  ]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                  </svg>
                  <span class="truncate">Roles</span>
                  <span class="ml-1 bg-gray-700 text-gray-300 text-xs font-medium px-1.5 py-0.5 rounded-full flex-shrink-0">
                    <%= Map.get(@stats, :total_roles, 0) %>
                  </span>
                </div>
                <svg class="w-4 h-4 transition-transform duration-200 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>

              <div x-show="activeDropdown === 'roles-permissions'"
                   x-transition:enter="transition ease-out duration-500"
                   x-transition:enter-start="opacity-0 transform -translate-y-2"
                   x-transition:enter-end="opacity-100 transform translate-y-0"
                   x-transition:leave="transition ease-in duration-300"
                   x-transition:leave-start="opacity-100 transform translate-y-0"
                   x-transition:leave-end="opacity-0 transform -translate-y-2"
                   class="ml-4 space-y-1 overflow-hidden" style="display: none;">
                <button @click="handleButtonClick('roles-permissions')" phx-click="navigate-to-roles" phx-target={@myself}
                        class={[
                          "group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg",
                          @current_page == "roles" && "bg-gray-700 text-white",
                          @current_page != "roles" && "text-gray-400 hover:bg-gray-700 hover:text-white"
                        ]}>
                  <span class="mr-3 flex-shrink-0 h-4 w-4 flex items-center justify-center text-xs font-bold">👥</span>
                  Manage Roles
                </button>
                <button @click="handleButtonClick('roles-permissions')" phx-click="navigate-to-permissions" phx-target={@myself}
                        class={[
                          "group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg",
                          @current_page == "permissions" && "bg-gray-700 text-white",
                          @current_page != "permissions" && "text-gray-400 hover:bg-gray-700 hover:text-white"
                        ]}>
                  <span class="mr-3 flex-shrink-0 h-4 w-4 flex items-center justify-center text-xs font-bold">🔒</span>
                  Permissions
                </button>
                <button @click="handleButtonClick('roles-permissions')" phx-click="navigate-to-role-assignments" phx-target={@myself}
                        class={[
                          "group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg",
                          @current_page == "role_assignments" && "bg-gray-700 text-white",
                          @current_page != "role_assignments" && "text-gray-400 hover:bg-gray-700 hover:text-white"
                        ]}>
                  <span class="mr-3 flex-shrink-0 h-4 w-4 flex items-center justify-center text-xs font-bold">⚙️</span>
                  Role Assignments
                </button>
              </div>
            </div>

            <!-- Approvals & Moderation Dropdown -->
            <div class="space-y-1">
              <button @click="activeDropdown = activeDropdown === 'approvals-moderation' ? null : 'approvals-moderation'"
                      class="group flex items-center justify-between w-full px-2 py-2 text-xs font-medium rounded-md text-gray-300 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                <div class="flex items-center min-w-0">
                  <svg class="mr-2 flex-shrink-0 h-5 w-5 text-gray-400 group-hover:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                  <span class="truncate">Approvals</span>
                  <span class="ml-1 bg-gray-700 text-gray-300 text-xs font-medium px-1.5 py-0.5 rounded-full flex-shrink-0">
                    <%= Map.get(@stats, :pending_approvals, 0) %>
                  </span>
                </div>
                <svg class="w-4 h-4 transition-transform duration-200 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>

              <div x-show="activeDropdown === 'approvals-moderation'"
                   x-transition:enter="transition ease-out duration-500"
                   x-transition:enter-start="opacity-0 transform -translate-y-2"
                   x-transition:enter-end="opacity-100 transform translate-y-0"
                   x-transition:leave="transition ease-in duration-300"
                   x-transition:leave-start="opacity-100 transform translate-y-0"
                   x-transition:leave-end="opacity-0 transform -translate-y-2"
                   class="ml-4 space-y-1 overflow-hidden" style="display: none;">
                <button @click="handleButtonClick('approvals-moderation')" phx-click="navigate-to-user-approvals" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                  </svg>
                  User Approvals
                </button>
                <button @click="handleButtonClick('approvals-moderation')" phx-click="navigate-to-content-moderation" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                  </svg>
                  Content Moderation
                </button>
                <button @click="handleButtonClick('approvals-moderation')" phx-click="navigate-to-reported-issues" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                  </svg>
                  Reported Issues
                </button>
              </div>
            </div>

            <!-- Notifications Dropdown -->
            <div class="space-y-1">
              <button @click="activeDropdown = activeDropdown === 'notifications' ? null : 'notifications'"
                      class="group flex items-center justify-between w-full px-2 py-2 text-xs font-medium rounded-md text-gray-300 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                <div class="flex items-center min-w-0">
                  <svg class="mr-2 flex-shrink-0 h-5 w-5 text-gray-400 group-hover:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM10.5 3.75a6 6 0 00-6 6v3.75a6 6 0 006 6h3a6 6 0 006-6V9.75a6 6 0 00-6-6h-3z"></path>
                  </svg>
                  <span class="truncate">Notifications</span>
                </div>
                <svg class="w-4 h-4 transition-transform duration-200 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>

              <div x-show="activeDropdown === 'notifications'"
                   x-transition:enter="transition ease-out duration-500"
                   x-transition:enter-start="opacity-0 transform -translate-y-2"
                   x-transition:enter-end="opacity-100 transform translate-y-0"
                   x-transition:leave="transition ease-in duration-300"
                   x-transition:leave-start="opacity-100 transform translate-y-0"
                   x-transition:leave-end="opacity-0 transform -translate-y-2"
                   class="ml-4 space-y-1 overflow-hidden" style="display: none;">
                <button @click="handleButtonClick('notifications')" phx-click="navigate-to-notifications" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM10.5 3.75a6 6 0 00-6 6v3.75a6 6 0 006 6h3a6 6 0 006-6V9.75a6 6 0 00-6-6h-3z"></path>
                  </svg>
                  View Notifications
                </button>
                <button @click="handleButtonClick('notifications')" phx-click="navigate-to-manage-notifications" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                  </svg>
                  Manage Notifications
                </button>
                <button @click="handleButtonClick('notifications')" phx-click="navigate-to-email-logs" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                  </svg>
                  Email Logs
                </button>
                <button @click="handleButtonClick('notifications')" phx-click="navigate-to-sms-logs" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                  </svg>
                  SMS Logs
                </button>
              </div>
            </div>

            <!-- Analytics & Reports Dropdown -->
            <div class="space-y-1">
              <button @click="activeDropdown = activeDropdown === 'analytics-reports' ? null : 'analytics-reports'"
                      class="group flex items-center justify-between w-full px-2 py-2 text-xs font-medium rounded-md text-gray-300 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                <div class="flex items-center min-w-0">
                  <svg class="mr-2 flex-shrink-0 h-5 w-5 text-gray-400 group-hover:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                  </svg>
                  <span class="truncate">Analytics</span>
                </div>
                <svg class="w-4 h-4 transition-transform duration-200 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>

              <div x-show="activeDropdown === 'analytics-reports'"
                   x-transition:enter="transition ease-out duration-500"
                   x-transition:enter-start="opacity-0 transform -translate-y-2"
                   x-transition:enter-end="opacity-100 transform translate-y-0"
                   x-transition:leave="transition ease-in duration-300"
                   x-transition:leave-start="opacity-100 transform translate-y-0"
                   x-transition:leave-end="opacity-0 transform -translate-y-2"
                   class="ml-4 space-y-1 overflow-hidden" style="display: none;">
                <button @click="handleButtonClick('analytics-reports')" phx-click="navigate-to-learning-analytics" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                  </svg>
                  Learning Analytics
                </button>
                <button @click="handleButtonClick('analytics-reports')" phx-click="navigate-to-user-reports" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                  </svg>
                  User Reports
                </button>
                <button @click="handleButtonClick('analytics-reports')" phx-click="navigate-to-system-reports" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                  </svg>
                  System Reports
                </button>
                <button @click="handleButtonClick('analytics-reports')" phx-click="navigate-to-export-data" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                  </svg>
                  Export Data
                </button>
              </div>
            </div>

            <!-- System Management Dropdown -->
            <div class="space-y-1">
              <button @click="activeDropdown = activeDropdown === 'system-management' ? null : 'system-management'"
                      class="group flex items-center justify-between w-full px-2 py-2 text-xs font-medium rounded-md text-gray-300 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                <div class="flex items-center min-w-0">
                  <svg class="mr-2 flex-shrink-0 h-5 w-5 text-gray-400 group-hover:text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                  </svg>
                  <span class="truncate">System</span>
                </div>
                <svg class="w-4 h-4 transition-transform duration-200 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>

              <div x-show="activeDropdown === 'system-management'"
                   x-transition:enter="transition ease-out duration-500"
                   x-transition:enter-start="opacity-0 transform -translate-y-2"
                   x-transition:enter-end="opacity-100 transform translate-y-0"
                   x-transition:leave="transition ease-in duration-300"
                   x-transition:leave-start="opacity-100 transform translate-y-0"
                   x-transition:leave-end="opacity-0 transform -translate-y-2"
                   class="ml-4 space-y-1 overflow-hidden" style="display: none;">
                <button @click="handleButtonClick('system-management')" phx-click="navigate-to-general-settings" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                  </svg>
                  General Settings
                </button>
                <button @click="handleButtonClick('system-management')" phx-click="navigate-to-security" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                  </svg>
                  Security
                </button>
                <button @click="handleButtonClick('system-management')" phx-click="navigate-to-backups" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                  </svg>
                  Backups
                </button>
                <button @click="handleButtonClick('system-management')" phx-click="navigate-to-system-logs" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                  </svg>
                  System Logs
                </button>
                <button @click="handleButtonClick('system-management')" phx-click="navigate-to-api-keys" phx-target={@myself}
                        class="group flex items-center px-2 py-2 text-sm font-medium rounded-md text-gray-400 hover:bg-gray-700 hover:text-white transition-all duration-300 ease-in-out transform hover:scale-[1.02] hover:shadow-lg">
                  <svg class="mr-3 flex-shrink-0 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"></path>
                  </svg>
                  API Keys
                </button>
              </div>
            </div>
          </nav>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("navigate-to-dashboard", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/dashboard")}
  end

  # Dashboard Events
  def handle_event("navigate-to-dashboard", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/dashboard")}
  end

  # User Management Events
  def handle_event("navigate-to-all-users", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/users")}
  end

  def handle_event("navigate-to-learners", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/learners")}
  end

  def handle_event("navigate-to-instructors", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/instructors")}
  end

  def handle_event("navigate-to-admins", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/admins")}
  end

  def handle_event("navigate-to-user-import", _params, socket) do
    {:noreply, put_flash(socket, :info, "User Import - Coming Soon! This feature is currently under development.")}
  end

  # Notifications Events
  def handle_event("navigate-to-notifications", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/notifications")}
  end

  def handle_event("navigate-to-manage-notifications", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/notifications/manage")}
  end

  def handle_event("navigate-to-email-logs", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/notifications/email-logs")}
  end

  def handle_event("navigate-to-sms-logs", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/notifications/sms-logs")}
  end

  # Learning Management Events (Not yet implemented)
  def handle_event("navigate-to-courses", _params, socket) do
    {:noreply, put_flash(socket, :info, "Course Management - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-lessons", _params, socket) do
    {:noreply, put_flash(socket, :info, "Lesson Management - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-sign-language", _params, socket) do
    {:noreply, put_flash(socket, :info, "Sign Language Content - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-speech-to-text", _params, socket) do
    {:noreply, put_flash(socket, :info, "Speech-to-Text - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-assessments", _params, socket) do
    {:noreply, put_flash(socket, :info, "Assessment Management - Coming Soon! This feature is currently under development.")}
  end

  # Roles & Permissions Events
  def handle_event("navigate-to-roles", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/roles")}
  end

  def handle_event("navigate-to-permissions", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/permissions")}
  end

  def handle_event("navigate-to-role-assignments", _params, socket) do
    {:noreply, push_navigate(socket, to: "/admin/role-assignments")}
  end

  # Approvals & Moderation Events (Not yet implemented)
  def handle_event("navigate-to-user-approvals", _params, socket) do
    {:noreply, put_flash(socket, :info, "User Approvals - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-content-moderation", _params, socket) do
    {:noreply, put_flash(socket, :info, "Content Moderation - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-reported-issues", _params, socket) do
    {:noreply, put_flash(socket, :info, "Reported Issues - Coming Soon! This feature is currently under development.")}
  end

  # Analytics & Reports Events (Not yet implemented)
  def handle_event("navigate-to-learning-analytics", _params, socket) do
    {:noreply, put_flash(socket, :info, "Learning Analytics - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-user-reports", _params, socket) do
    {:noreply, put_flash(socket, :info, "User Reports - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-system-reports", _params, socket) do
    {:noreply, put_flash(socket, :info, "System Reports - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-export-data", _params, socket) do
    {:noreply, put_flash(socket, :info, "Data Export - Coming Soon! This feature is currently under development.")}
  end

  # System Management Events (Not yet implemented)
  def handle_event("navigate-to-general-settings", _params, socket) do
    {:noreply, put_flash(socket, :info, "General Settings - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-security", _params, socket) do
    {:noreply, put_flash(socket, :info, "Security Settings - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-backups", _params, socket) do
    {:noreply, put_flash(socket, :info, "Backup Management - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-system-logs", _params, socket) do
    {:noreply, put_flash(socket, :info, "System Logs - Coming Soon! This feature is currently under development.")}
  end

  def handle_event("navigate-to-api-keys", _params, socket) do
    {:noreply, put_flash(socket, :info, "API Keys - Coming Soon! This feature is currently under development.")}
  end
end
