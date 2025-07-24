defmodule SigneaseWeb.Learner.Components.SideNavComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-64 bg-white shadow-xl border-r border-gray-200 flex flex-col h-full">
      <!-- Sidebar Header -->
      <div class="flex items-center justify-center h-16 px-4 bg-gradient-to-r from-indigo-600 to-purple-600 flex-shrink-0">
        <h1 class="text-lg font-bold text-white">Accessibility Portal</h1>
      </div>

      <!-- Navigation Menu -->
      <nav class="px-2 py-4 bg-white space-y-1 flex-1 overflow-y-auto">
        <!-- Dashboard -->
        <a href="/learner/dashboard" class={[
          "group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors duration-200",
          @current_page == "learner_dashboard" && "bg-indigo-100 text-indigo-700",
          @current_page != "learner_dashboard" && "text-gray-700 hover:bg-gray-100 hover:text-gray-900"
        ]}>
          <svg class={[
            "mr-3 h-5 w-5",
            @current_page == "learner_dashboard" && "text-indigo-500",
            @current_page != "learner_dashboard" && "text-gray-400 group-hover:text-gray-500"
          ]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5a2 2 0 012-2h4a2 2 0 012 2v6H8V5z"/>
          </svg>
          Dashboard
        </a>

        <!-- My Lessons -->
        <a href="/learner/lessons" class="group flex items-center px-3 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-100 hover:text-gray-900 transition-colors duration-200">
          <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
          </svg>
          My Lessons
        </a>

        <!-- Progress Tracking -->
        <a href="/learner/progress" class="group flex items-center px-3 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-100 hover:text-gray-900 transition-colors duration-200">
          <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
          </svg>
          Progress
        </a>

        <!-- Schedule -->
        <a href="/learner/schedule" class="group flex items-center px-3 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-100 hover:text-gray-900 transition-colors duration-200">
          <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
          </svg>
          Schedule
        </a>

        <!-- Live Sessions -->
        <a href="/learner/live-sessions" class={[
          "group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors duration-200",
          @current_page == "learner_live_sessions" && "bg-indigo-100 text-indigo-700",
          @current_page != "learner_live_sessions" && "text-gray-700 hover:bg-gray-100 hover:text-gray-900"
        ]}>
          <svg class={[
            "mr-3 h-5 w-5",
            @current_page == "learner_live_sessions" && "text-indigo-500",
            @current_page != "learner_live_sessions" && "text-gray-400 group-hover:text-gray-500"
          ]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"/>
          </svg>
          Live Sessions
        </a>

        <!-- Communication Tools -->
        <a href="/learner/communication" class="group flex items-center px-3 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-100 hover:text-gray-900 transition-colors duration-200">
          <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4"/>
          </svg>
          Communication Tools
        </a>

        <!-- Certificates -->
        <a href="/learner/certificates" class="group flex items-center px-3 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-100 hover:text-gray-900 transition-colors duration-200">
          <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"/>
          </svg>
          Certificates
        </a>

        <!-- Resources -->
        <a href="/learner/resources" class="group flex items-center px-3 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-100 hover:text-gray-900 transition-colors duration-200">
          <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
          </svg>
          Resources
        </a>

        <!-- Support -->
        <a href="/learner/support" class="group flex items-center px-3 py-2 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-100 hover:text-gray-900 transition-colors duration-200">
          <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192L5.636 18.364M12 2.25a9.75 9.75 0 100 19.5 9.75 9.75 0 000-19.5z"/>
          </svg>
          Support
        </a>
      </nav>

      <!-- Footer -->
      <div class="flex-shrink-0 p-4 border-t border-gray-200">
        <div class="flex items-center justify-between">
          <div class="text-xs text-gray-500">
            <p>Accessibility Usage</p>
            <p class="font-medium text-gray-700"><%= Map.get(@stats, :speech_transcriptions, 0) %> transcriptions</p>
          </div>
          <div class="w-12 h-12 bg-gradient-to-br from-indigo-400 to-purple-500 rounded-lg flex items-center justify-center">
            <span class="text-white text-sm font-bold"><%= Map.get(@stats, :chat_messages_sent, 0) %></span>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
