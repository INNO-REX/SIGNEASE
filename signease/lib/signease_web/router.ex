defmodule SigneaseWeb.Router do
  use SigneaseWeb, :router

  # ============================================================================
  # ROUTE STRUCTURE OVERVIEW
  # ============================================================================
  #
  # PUBLIC ROUTES (/)
  # ├── Home page with authentication
  #
  # ADMIN ROUTES (/admin/*)
  # ├── Dashboard & Overview
  # ├── User Management (Users, Learners, Instructors, Admins)
  # ├── Role & Permission Management
  # ├── Learning Content Management
  # ├── Content Moderation
  # ├── Analytics & Reporting
  # └── System Administration
  #
  # LEARNER ROUTES (/learner/*) - ACCESSIBILITY FOCUSED
  # ├── Dashboard & Overview
  # ├── Learning Management (Lessons, Progress, Schedule, Certificates)
  # ├── Accessibility & Communication (Live Sessions, Communication Tools)
  # └── Practice & Resources
  #
  # LECTURER ROUTES (/lecturer/*) - INSTRUCTION FOCUSED
  # ├── Dashboard & Overview
  # ├── Course Management
  # ├── Student Management
  # ├── Teaching Tools
  # └── Analytics & Reports
  #
  # ============================================================================

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SigneaseWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # ============================================================================
  # PUBLIC ROUTES
  # ============================================================================
  scope "/", SigneaseWeb do
    pipe_through :browser

    # Home page and public access
    live "/", Home.HomeLive

    # Force password change for users with default passwords
    live "/force-password-change", MainSettingsLive.ForcePasswordChangeLive

    # Authentication routes (handled by HomeLive component)
    # Note: Login/logout functionality is embedded in the home page
    # No separate routes needed as it's handled via LiveView events
  end

  # ============================================================================
  # ADMIN ROUTES - SYSTEM MANAGEMENT FOCUSED
  # ============================================================================
  scope "/admin", SigneaseWeb.Admin do
    pipe_through :browser

    # Dashboard & Overview
    # --------------------
    live "/dashboard", DashboardLive                           # Main admin dashboard
    live "/overview", Overview.OverviewLive                   # System overview and stats

    # User Management
    # ---------------
    live "/users", Users.AllUsers.UsersLive                   # All users management
    live "/users/new", Users.AllUsers.UsersLive, :new
    live "/users/filter", Users.AllUsers.UsersLive, :filter
    live "/users/:id", Users.AllUsers.UsersLive, :show
    live "/users/:id/edit", Users.AllUsers.UsersLive, :edit
    live "/learners", Users.Learners.LearnersLive             # Learner-specific management
    live "/learners/new", Users.Learners.LearnersLive, :new
    live "/learners/filter", Users.Learners.LearnersLive, :filter
    live "/learners/:id", Users.Learners.LearnersLive, :show
    live "/learners/:id/edit", Users.Learners.LearnersLive, :edit
    live "/instructors", Users.Instructors.InstructorsLive    # Instructor management
    live "/instructors/new", Users.Instructors.InstructorsLive, :new
    live "/instructors/filter", Users.Instructors.InstructorsLive, :filter
    live "/instructors/:id", Users.Instructors.InstructorsLive, :show
    live "/instructors/:id/edit", Users.Instructors.InstructorsLive, :edit
    live "/admins", Users.Admins.AdminsLive                   # Admin user management
    live "/admins/new", Users.Admins.AdminsLive, :new
    live "/admins/filter", Users.Admins.AdminsLive, :filter
    live "/admins/:id", Users.Admins.AdminsLive, :show
    live "/admins/:id/edit", Users.Admins.AdminsLive, :edit
    live "/user-import", Users.UserImportLive                 # Bulk user import

    # Role & Permission Management
    # ----------------------------
    live "/roles", RolesLive                                  # Role creation and management
    live "/role-assignments", RoleAssignmentsLive             # User-role assignments
    live "/permissions", Permissions.PermissionsLive          # Permission management

    # Learning Content Management
    # ---------------------------
    live "/programs", Learning.ProgramsLive                   # Program management
    live "/courses", Learning.CoursesLive                     # Course management
    live "/lessons", Learning.LessonsLive                     # Lesson management
    live "/sign-language", Learning.SignLanguageLive          # Sign language content
    live "/speech-to-text", Learning.SpeechToTextLive         # Speech recognition tools
    live "/assessments", Learning.AssessmentsLive             # Assessment management
    live "/materials", Learning.MaterialsLive                 # Learning materials

    # Content Moderation
    # ------------------
    live "/user-approvals", Moderation.UserApprovalsLive      # User approval queue
    live "/user-approvals/filter", Moderation.UserApprovalsLive, :filter
    live "/user-approvals/:id", Moderation.UserApprovalsLive, :show
    live "/blocked-users", Moderation.BlockedUsersLive        # Blocked and rejected users
    live "/blocked-users/filter", Moderation.BlockedUsersLive, :filter
    live "/blocked-users/:id", Moderation.BlockedUsersLive, :show
    live "/content-moderation", Moderation.ContentModerationLive # Content moderation
    live "/reported-issues", Moderation.ReportedIssuesLive    # Issue reports

    # Analytics & Reporting
    # ---------------------
    live "/learning-analytics", Analytics.LearningAnalyticsLive # Learning analytics
    live "/user-reports", Analytics.UserReportsLive           # User activity reports
    live "/system-reports", Analytics.SystemReportsLive       # System performance
    live "/export-data", Analytics.ExportDataLive             # Data export

    # Notifications
    # --------------
    live "/notifications", Notifications.PushNotifications.Index                    # View all notifications
    live "/notifications/manage", Notifications.Manage.Index                       # Manage notifications
    live "/notifications/email-logs", Notifications.EmailLogs.Index               # Email notification logs
    live "/notifications/sms-logs", Notifications.SmsLogs.Index, as: :sms_logs                   # SMS notification logs
    live "/notifications/sms-logs/filter", Notifications.SmsLogs.Index, :filter, as: :sms_logs
    live "/notifications/sms-logs/:id", Notifications.SmsLogs.Index, :show, as: :sms_logs

    # System Administration
    # ---------------------
    live "/general-settings", Settings.GeneralSettingsLive    # General settings
    live "/security", Settings.SecurityLive                   # Security settings
    live "/backups", Settings.BackupsLive                     # Backup management
    live "/system-logs", Settings.SystemLogsLive              # System logs
    live "/api-keys", Settings.ApiKeysLive                    # API key management
    live "/maintenance", Settings.MaintenanceLive             # System maintenance
  end

  # ============================================================================
  # LEARNER ROUTES - ACCESSIBILITY FOCUSED
  # ============================================================================
  scope "/learner", SigneaseWeb.Learner do
    pipe_through :browser

    # Dashboard & Overview
    # --------------------
    live "/dashboard", Dashboard.LearnerDashboardLive        # Main accessibility dashboard
    live "/overview", Overview.OverviewLive                  # Learning overview and stats

    # Learning Management
    # -------------------
    live "/lessons", Lessons.LessonsLive                     # Lesson access and progress
    live "/progress", Progress.ProgressLive                  # Learning progress tracking
    live "/schedule", Schedule.ScheduleLive                  # Lesson schedule management
    live "/certificates", Certificates.CertificatesLive      # Earned certificates

    # Accessibility & Communication
    # -----------------------------
    live "/live-sessions", LiveSessions.LiveSessionsLive     # Real-time interactive sessions
    live "/communication", Communication.CommunicationLive   # Speech-to-text, chat tools
    live "/accessibility", Accessibility.AccessibilityLive   # Accessibility features & settings

    # Practice & Resources
    # --------------------
    live "/practice", Practice.PracticeLive                  # Individual practice sessions
    live "/resources", Resources.ResourcesLive               # Learning materials & tools
    live "/support", Support.SupportLive                     # Help and assistance
  end

  # ============================================================================
  # LECTURER ROUTES - INSTRUCTION FOCUSED
  # ============================================================================
  scope "/lecturer", SigneaseWeb.Lecturer do
    pipe_through :browser

    # Dashboard & Overview
    # --------------------
    live "/dashboard", Dashboard.LecturerDashboardLive        # Main instructor dashboard
    live "/overview", Overview.OverviewLive                   # Teaching overview and stats

    # Course Management
    # -----------------
    live "/courses", Courses.CoursesLive                      # Course creation and management
    live "/sessions", Sessions.SessionsLive                   # Live session management
    live "/materials", Materials.MaterialsLive                # Teaching materials & resources
    live "/assessments", Assessments.AssessmentsLive          # Assessment creation & grading

    # Student Management
    # ------------------
    live "/students", Students.StudentsLive                   # Student roster and progress
    live "/groups", Groups.GroupsLive                         # Group management
    live "/attendance", Attendance.AttendanceLive             # Attendance tracking

    # Teaching Tools
    # --------------
    live "/live-teaching", LiveTeaching.LiveTeachingLive      # Real-time teaching interface
    live "/accessibility-tools", AccessibilityTools.AccessibilityToolsLive # Accessibility features
    live "/communication", Communication.CommunicationLive    # Student communication tools

    # Content & Calendar
    # ------------------
    live "/content", Content.ContentLive                      # Content library management
    live "/calendar", Calendar.CalendarLive                   # Calendar and scheduling

    # Analytics & Reports
    # -------------------
    live "/analytics", Analytics.AnalyticsLive                # Course analytics and insights
    live "/reports", Reports.ReportsLive                      # Student progress reports
    live "/performance", Performance.PerformanceLive          # Teaching performance metrics

    # Settings
    # --------
    live "/settings", Settings.SettingsLive                   # Lecturer settings and preferences


  end

  # ============================================================================
  # API ROUTES (Future Implementation)
  # ============================================================================
  # scope "/api", SigneaseWeb do
  #   pipe_through :api
  # end

  # ============================================================================
  # DEVELOPMENT ROUTES
  # ============================================================================
  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:signease, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SigneaseWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
