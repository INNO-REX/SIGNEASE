defmodule SigneaseWeb.NavigationComponent do
  @moduledoc """
  Universal navigation component that provides role-based navigation across all dashboard types.
  Uses the RouteHelpers module for consistent route management.
  """

  use SigneaseWeb, :live_component
  alias SigneaseWeb.RouteHelpers

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-64 bg-white shadow-xl border-r border-gray-200 flex flex-col h-full">
      <!-- Sidebar Header -->
      <div class="flex items-center justify-center h-16 px-4 bg-gradient-to-r from-indigo-600 to-purple-600 flex-shrink-0">
        <h1 class="text-lg font-bold text-white">
          <%= get_portal_title(@current_user.user_type) %>
        </h1>
      </div>

      <!-- Navigation Menu -->
      <nav class="px-2 py-4 bg-white space-y-1 flex-1 overflow-y-auto">
        <%= for item <- get_navigation_items(@current_user.user_type) do %>
          <a href={item.path} class={[
            "group flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors duration-200",
            is_current_page?(@current_page, item.path) && get_active_styles(@current_user.user_type),
            !is_current_page?(@current_page, item.path) && "text-gray-700 hover:bg-gray-100 hover:text-gray-900"
          ]}>
            <svg class={[
              "mr-3 h-5 w-5",
              is_current_page?(@current_page, item.path) && get_active_icon_color(@current_user.user_type),
              !is_current_page?(@current_page, item.path) && "text-gray-400 group-hover:text-gray-500"
            ]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <%= render_icon(item.icon) %>
            </svg>
            <%= item.label %>
          </a>
        <% end %>
      </nav>

      <!-- Footer -->
      <div class="flex-shrink-0 p-4 border-t border-gray-200">
        <div class="flex items-center justify-between">
          <div class="text-xs text-gray-500">
            <p><%= get_footer_title(@current_user.user_type) %></p>
            <p class="font-medium text-gray-700"><%= get_footer_stat(@current_user.user_type, @stats) %></p>
          </div>
          <div class={[
            "w-12 h-12 rounded-lg flex items-center justify-center",
            get_footer_gradient(@current_user.user_type)
          ]}>
            <span class="text-white text-sm font-bold"><%= get_footer_value(@current_user.user_type, @stats) %></span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ============================================================================
  # PRIVATE FUNCTIONS
  # ============================================================================

  defp get_portal_title("ADMIN"), do: "Admin Portal"
  defp get_portal_title("INSTRUCTOR"), do: "Teaching Portal"
  defp get_portal_title("LEARNER"), do: "Accessibility Portal"
  defp get_portal_title(_), do: "Learning Portal"

  defp get_navigation_items("ADMIN") do
    [
      %{label: "Dashboard", path: RouteHelpers.admin_dashboard_path(), icon: "dashboard"},
      %{label: "Users", path: RouteHelpers.admin_users_path(), icon: "users"},
      %{label: "Roles", path: RouteHelpers.admin_roles_path(), icon: "shield"},
      %{label: "Content", path: RouteHelpers.admin_courses_path(), icon: "book"},
      %{label: "Analytics", path: RouteHelpers.admin_learning_analytics_path(), icon: "chart"},
      %{label: "Settings", path: RouteHelpers.admin_general_settings_path(), icon: "cog"}
    ]
  end

  defp get_navigation_items("INSTRUCTOR") do
    [
      %{label: "Dashboard", path: RouteHelpers.lecturer_dashboard_path(), icon: "dashboard"},
      %{label: "Courses", path: RouteHelpers.lecturer_courses_path(), icon: "book"},
      %{label: "Students", path: RouteHelpers.lecturer_students_path(), icon: "users"},
      %{label: "Live Teaching", path: RouteHelpers.lecturer_live_teaching_path(), icon: "video"},
      %{label: "Analytics", path: RouteHelpers.lecturer_analytics_path(), icon: "chart"}
    ]
  end

  defp get_navigation_items("LEARNER") do
    [
      %{label: "Dashboard", path: RouteHelpers.learner_dashboard_path(), icon: "dashboard"},
      %{label: "Lessons", path: RouteHelpers.learner_lessons_path(), icon: "book"},
      %{label: "Live Sessions", path: RouteHelpers.learner_live_sessions_path(), icon: "video"},
      %{label: "Communication", path: RouteHelpers.learner_communication_path(), icon: "chat"},
      %{label: "Progress", path: RouteHelpers.learner_progress_path(), icon: "chart"}
    ]
  end

  defp get_navigation_items(_), do: []

  defp is_current_page?(current_page, path) do
    String.contains?(current_page, path) || String.contains?(path, current_page)
  end

  defp get_active_styles("ADMIN"), do: "bg-red-100 text-red-700"
  defp get_active_styles("INSTRUCTOR"), do: "bg-emerald-100 text-emerald-700"
  defp get_active_styles("LEARNER"), do: "bg-indigo-100 text-indigo-700"
  defp get_active_styles(_), do: "bg-gray-100 text-gray-700"

  defp get_active_icon_color("ADMIN"), do: "text-red-500"
  defp get_active_icon_color("INSTRUCTOR"), do: "text-emerald-500"
  defp get_active_icon_color("LEARNER"), do: "text-indigo-500"
  defp get_active_icon_color(_), do: "text-gray-500"

  defp get_footer_title("ADMIN"), do: "System Status"
  defp get_footer_title("INSTRUCTOR"), do: "Teaching Stats"
  defp get_footer_title("LEARNER"), do: "Accessibility Usage"
  defp get_footer_title(_), do: "Learning Progress"

  defp get_footer_stat("ADMIN", stats), do: "#{stats.total_users || 0} users managed"
  defp get_footer_stat("INSTRUCTOR", stats), do: "#{stats.total_students || 0} students"
  defp get_footer_stat("LEARNER", stats), do: "#{stats.speech_transcriptions || 0} transcriptions"
  defp get_footer_stat(_, stats), do: "#{stats.total_lessons_completed || 0} lessons completed"

  defp get_footer_gradient("ADMIN"), do: "bg-gradient-to-br from-red-400 to-orange-500"
  defp get_footer_gradient("INSTRUCTOR"), do: "bg-gradient-to-br from-emerald-400 to-teal-500"
  defp get_footer_gradient("LEARNER"), do: "bg-gradient-to-br from-indigo-400 to-purple-500"
  defp get_footer_gradient(_), do: "bg-gradient-to-br from-gray-400 to-gray-500"

  defp get_footer_value("ADMIN", stats), do: "#{stats.system_health || 98}%"
  defp get_footer_value("INSTRUCTOR", stats), do: "#{stats.courses_taught || 0}"
  defp get_footer_value("LEARNER", stats), do: "#{stats.chat_messages_sent || 0}"
  defp get_footer_value(_, stats), do: "#{stats.average_score || 0}%"

  defp render_icon("dashboard") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5a2 2 0 012-2h4a2 2 0 012 2v6H8V5z"/>)
  end

  defp render_icon("users") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"/>)
  end

  defp render_icon("shield") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>)
  end

  defp render_icon("book") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>)
  end

  defp render_icon("chart") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>)
  end

  defp render_icon("cog") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>)
  end

  defp render_icon("video") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>)
  end

  defp render_icon("chat") do
    ~s(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>)
  end

  defp render_icon(_), do: ""
end
