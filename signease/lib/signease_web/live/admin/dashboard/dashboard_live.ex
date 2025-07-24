defmodule SigneaseWeb.Admin.DashboardLive do
  use SigneaseWeb, :live_view

  alias Signease.Accounts
  import SigneaseWeb.Components.LoaderComponent
  alias Signease.Roles

  @impl true
  def mount(params, session, socket) do
    # Get current user from session or URL params
    current_user = get_current_user(session, params)

    # Get dashboard statistics
    stats = get_dashboard_stats()

    # Determine page title based on admin type
    page_title = case current_user.user_role do
      "SUPER_ADMIN" -> "Super Admin Dashboard - SignEase"
      "ADMIN" -> "Admin Dashboard - SignEase"
      _ -> "Admin Dashboard - SignEase"
    end

    socket = assign(socket,
      current_user: current_user,
      stats: stats,
      current_page: "dashboard",
      page_title: page_title
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("refresh-stats", _params, socket) do
    stats = get_dashboard_stats()
    {:noreply, assign(socket, stats: stats)}
  end

  @impl true
  def handle_event("approve-user", %{"user-id" => _user_id}, socket) do
    # TODO: Implement user approval logic
    {:noreply, socket}
  end

  @impl true
  def handle_event("reject-user", %{"user-id" => _user_id}, socket) do
    # TODO: Implement user rejection logic
    {:noreply, socket}
  end

  # Private functions

    defp get_current_user(session, params) do
    # Try to get user_id from URL params first, then from session
    user_id = params["user_id"] || session["user_id"]

    case user_id do
      nil ->
        # Default admin for development when no session or params
        %{
          id: 2,
          first_name: "System",
          last_name: "Admin",
          email: "admin@signease.com",
          user_type: "ADMIN",
          user_role: "ADMIN"
        }
      user_id ->
        case Accounts.get_user(user_id) do
          nil ->
            %{
              id: 2,
              first_name: "System",
              last_name: "Admin",
              email: "admin@signease.com",
              user_type: "ADMIN",
              user_role: "ADMIN"
            }
                    user ->
            admin_type = case user.role_id do
              1 -> "SUPER_ADMIN"
              2 -> "ADMIN"
              _ -> "ADMIN"
            end

            %{
              id: user.id,
              first_name: user.first_name,
              last_name: user.last_name,
              email: user.email,
              user_type: user.user_type,
              user_role: admin_type
            }
        end
      _ ->
        %{
          id: 2,
          first_name: "System",
          last_name: "Admin",
          email: "admin@signease.com",
          user_type: "ADMIN",
          user_role: "ADMIN"
        }
    end
  end

  defp get_dashboard_stats do
    %{
      total_users: Accounts.get_total_users_count(),
      pending_approvals: Accounts.get_pending_approval_users_count(),
      total_roles: Roles.get_total_roles_count(),
      active_sessions: 0, # TODO: Implement session tracking
      recent_activities: get_recent_activities(),
      system_health: get_system_health(),
      chart_data: get_chart_data(),
      transaction_distribution: get_transaction_distribution_data(),
      service_usage_pie: get_service_usage_data(),
      service_usage: get_service_usage_progress_data()
    }
  end

  defp get_recent_activities do
    [
      %{
        id: 1,
        type: "user_registration",
        message: "New learner registration: john.doe@example.com",
        timestamp: DateTime.utc_now() |> DateTime.add(-3600, :second),
        severity: "info"
      },
      %{
        id: 2,
        type: "user_approval",
        message: "User approved: jane.smith@example.com",
        timestamp: DateTime.utc_now() |> DateTime.add(-7200, :second),
        severity: "success"
      },
      %{
        id: 3,
        type: "system_alert",
        message: "Database backup completed successfully",
        timestamp: DateTime.utc_now() |> DateTime.add(-10800, :second),
        severity: "info"
      }
    ]
  end

  defp get_system_health do
    %{
      database: "healthy",
      cache: "healthy",
      storage: "healthy",
      api: "healthy"
    }
  end

  defp get_chart_data do
    %{
      "Mon" => %{value: 85},
      "Tue" => %{value: 92},
      "Wed" => %{value: 78},
      "Thu" => %{value: 95},
      "Fri" => %{value: 88},
      "Sat" => %{value: 65},
      "Sun" => %{value: 72}
    }
  end

  defp get_transaction_distribution_data do
    [
      %{label: "Sign Language", value: 65, percentage: 65.0, color: "#0c2f9d"},
      %{label: "Speech-to-Text", value: 35, percentage: 35.0, color: "#e55d0a"}
    ]
  end



  defp get_service_usage_data do
    [
      %{label: "ASL", value: 45, percentage: 45.0, color: "#0c2f9d"},
      %{label: "BSL", value: 25, percentage: 25.0, color: "#e55d0a"},
      %{label: "ISL", value: 20, percentage: 20.0, color: "#10B981"},
      %{label: "Other", value: 10, percentage: 10.0, color: "#F59E0B"}
    ]
  end

  defp get_service_usage_progress_data do
    %{
      services: [
        %{name: "ASL", value: 450, percentage: 85, target: 500, last_month: 420, color: "#0c2f9d"},
        %{name: "BSL", value: 280, percentage: 70, target: 400, last_month: 260, color: "#e55d0a"},
        %{name: "ISL", value: 320, percentage: 80, target: 400, last_month: 300, color: "#10B981"},
        %{name: "Q&A", value: 180, percentage: 60, target: 300, last_month: 170, color: "#F59E0B"}
      ],
      total_usage: 1230,
      growth_rate: 12.5
    }
  end

end
