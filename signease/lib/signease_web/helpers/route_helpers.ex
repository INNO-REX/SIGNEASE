defmodule SigneaseWeb.RouteHelpers do
  @moduledoc """
  Route helper functions for easy navigation across different dashboard types.
  Provides centralized route management and navigation utilities.
  """

  # ============================================================================
  # PUBLIC ROUTES
  # ============================================================================

  def home_path, do: "/"
  def login_path, do: "/"
  def logout_path, do: "/"

  # ============================================================================
  # ADMIN ROUTES
  # ============================================================================

  # Dashboard & Overview
  def admin_dashboard_path, do: "/admin/dashboard"
  def admin_overview_path, do: "/admin/overview"

  # User Management
  def admin_users_path, do: "/admin/users"
  def admin_learners_path, do: "/admin/learners"
  def admin_instructors_path, do: "/admin/instructors"
  def admin_admins_path, do: "/admin/admins"
  def admin_user_import_path, do: "/admin/user-import"

  # Role & Permission Management
  def admin_roles_path, do: "/admin/roles"
  def admin_role_assignments_path, do: "/admin/role-assignments"
  def admin_permissions_path, do: "/admin/permissions"

  # Learning Content Management
  def admin_courses_path, do: "/admin/courses"
  def admin_lessons_path, do: "/admin/lessons"
  def admin_sign_language_path, do: "/admin/sign-language"
  def admin_speech_to_text_path, do: "/admin/speech-to-text"
  def admin_assessments_path, do: "/admin/assessments"
  def admin_materials_path, do: "/admin/materials"

  # Content Moderation
  def admin_user_approvals_path, do: "/admin/user-approvals"
  def admin_content_moderation_path, do: "/admin/content-moderation"
  def admin_reported_issues_path, do: "/admin/reported-issues"

  # Analytics & Reporting
  def admin_learning_analytics_path, do: "/admin/learning-analytics"
  def admin_user_reports_path, do: "/admin/user-reports"
  def admin_system_reports_path, do: "/admin/system-reports"
  def admin_export_data_path, do: "/admin/export-data"

  # System Administration
  def admin_general_settings_path, do: "/admin/general-settings"
  def admin_security_path, do: "/admin/security"
  def admin_backups_path, do: "/admin/backups"
  def admin_system_logs_path, do: "/admin/system-logs"
  def admin_api_keys_path, do: "/admin/api-keys"
  def admin_maintenance_path, do: "/admin/maintenance"

  # ============================================================================
  # LEARNER ROUTES - ACCESSIBILITY FOCUSED
  # ============================================================================

  # Dashboard & Overview
  def learner_dashboard_path, do: "/learner/dashboard"
  def learner_overview_path, do: "/learner/overview"

  # Learning Management
  def learner_lessons_path, do: "/learner/lessons"
  def learner_progress_path, do: "/learner/progress"
  def learner_schedule_path, do: "/learner/schedule"
  def learner_certificates_path, do: "/learner/certificates"

  # Accessibility & Communication
  def learner_live_sessions_path, do: "/learner/live-sessions"
  def learner_communication_path, do: "/learner/communication"
  def learner_accessibility_path, do: "/learner/accessibility"

  # Practice & Resources
  def learner_practice_path, do: "/learner/practice"
  def learner_resources_path, do: "/learner/resources"
  def learner_support_path, do: "/learner/support"

  # ============================================================================
  # LECTURER ROUTES - INSTRUCTION FOCUSED
  # ============================================================================

  # Dashboard & Overview
  def lecturer_dashboard_path, do: "/lecturer/dashboard"
  def lecturer_overview_path, do: "/lecturer/overview"

  # Course Management
  def lecturer_courses_path, do: "/lecturer/courses"
  def lecturer_sessions_path, do: "/lecturer/sessions"
  def lecturer_materials_path, do: "/lecturer/materials"
  def lecturer_assessments_path, do: "/lecturer/assessments"

  # Student Management
  def lecturer_students_path, do: "/lecturer/students"
  def lecturer_groups_path, do: "/lecturer/groups"
  def lecturer_attendance_path, do: "/lecturer/attendance"

  # Teaching Tools
  def lecturer_live_teaching_path, do: "/lecturer/live-teaching"
  def lecturer_accessibility_tools_path, do: "/lecturer/accessibility-tools"
  def lecturer_communication_path, do: "/lecturer/communication"

  # Analytics & Reports
  def lecturer_analytics_path, do: "/lecturer/analytics"
  def lecturer_reports_path, do: "/lecturer/reports"
  def lecturer_performance_path, do: "/lecturer/performance"

  # ============================================================================
  # NAVIGATION HELPERS
  # ============================================================================

  @doc """
  Returns the appropriate dashboard path based on user role.
  """
  def dashboard_path_for_role("ADMIN"), do: admin_dashboard_path()
  def dashboard_path_for_role("INSTRUCTOR"), do: lecturer_dashboard_path()
  def dashboard_path_for_role("LEARNER"), do: learner_dashboard_path()
  def dashboard_path_for_role(_), do: home_path()

  @doc """
  Returns all navigation items for a specific role.
  """
  def navigation_items_for_role("ADMIN") do
    [
      %{label: "Dashboard", path: admin_dashboard_path(), icon: "dashboard"},
      %{label: "Users", path: admin_users_path(), icon: "users"},
      %{label: "Roles", path: admin_roles_path(), icon: "shield"},
      %{label: "Content", path: admin_courses_path(), icon: "book"},
      %{label: "Analytics", path: admin_learning_analytics_path(), icon: "chart"},
      %{label: "Settings", path: admin_general_settings_path(), icon: "cog"}
    ]
  end

  def navigation_items_for_role("INSTRUCTOR") do
    [
      %{label: "Dashboard", path: lecturer_dashboard_path(), icon: "dashboard"},
      %{label: "Courses", path: lecturer_courses_path(), icon: "book"},
      %{label: "Students", path: lecturer_students_path(), icon: "users"},
      %{label: "Live Teaching", path: lecturer_live_teaching_path(), icon: "video"},
      %{label: "Analytics", path: lecturer_analytics_path(), icon: "chart"}
    ]
  end

  def navigation_items_for_role("LEARNER") do
    [
      %{label: "Dashboard", path: learner_dashboard_path(), icon: "dashboard"},
      %{label: "Lessons", path: learner_lessons_path(), icon: "book"},
      %{label: "Live Sessions", path: learner_live_sessions_path(), icon: "video"},
      %{label: "Communication", path: learner_communication_path(), icon: "chat"},
      %{label: "Progress", path: learner_progress_path(), icon: "chart"}
    ]
  end

  def navigation_items_for_role(_), do: []

  @doc """
  Checks if a given path belongs to a specific role's section.
  """
  def path_belongs_to_role?(path, "ADMIN"), do: String.starts_with?(path, "/admin")
  def path_belongs_to_role?(path, "INSTRUCTOR"), do: String.starts_with?(path, "/lecturer")
  def path_belongs_to_role?(path, "LEARNER"), do: String.starts_with?(path, "/learner")
  def path_belongs_to_role?(_, _), do: false
end
