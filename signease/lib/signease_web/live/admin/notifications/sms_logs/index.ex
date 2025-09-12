defmodule SigneaseWeb.Admin.Notifications.SmsLogs.Index do
  use SigneaseWeb, :live_view

  alias Signease.Notifications
  import SigneaseWeb.Components.LoaderComponent
  alias SigneaseWeb.Admin.Users.Components.UserShowComponent
  alias SigneaseWeb.Admin.Users.Components.FilterComponent
  alias SigneaseWeb.Admin.Users.Components.PaginationComponent
  alias SigneaseWeb.Admin.Users.Components.ISearchComponent

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Signease.PubSub, "notification_updates")
    end

    {:ok, assign_initial_state(socket)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    apply_action(socket, :show, %{"id" => id})
  end

  @impl true
  def handle_params(%{"action" => "filter"}, _url, socket) do
    apply_action(socket, :filter, %{})
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, fetch_sms_logs_for_params(socket, socket.assigns.params)}
  end

  @impl true
  def handle_info({:fetch_data, params}, socket) do
    {:noreply, fetch_sms_logs(socket, params)}
  end

  @impl true
  def handle_info({:fetch_sms_logs, params}, socket) do
    {:noreply, fetch_sms_logs(socket, params)}
  end

  @impl true
  def handle_info({:notification_created, _notification}, socket) do
    {:noreply, fetch_sms_logs(socket, socket.assigns.params)}
  end

  @impl true
  def handle_info({:notification_updated, _notification}, socket) do
    {:noreply, fetch_sms_logs(socket, socket.assigns.params)}
  end

  @impl true
  def handle_event("resend_sms", %{"id" => id}, socket) do
    sms_notification = Enum.find(socket.assigns.sms_notifications, &(&1.id == String.to_integer(id)))
    if sms_notification do
      case Notifications.update_sms_notification(sms_notification, %{
        status: "READY",
        attempts: 0
      }) do
        {:ok, _updated_sms} ->
          {:noreply,
           socket
           |> put_flash(:info, "SMS queued for resend successfully!")
           |> fetch_sms_logs(socket.assigns.params)}
        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to queue SMS for resend")}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("view_message", %{"id" => id}, socket) do
    sms_notification = Enum.find(socket.assigns.sms_notifications, &(&1.id == String.to_integer(id)))
    {:noreply, push_patch(socket, to: ~p"/admin/notifications/sms-logs/#{id}")}
  end

  @impl true
  def handle_event("delete_sms", %{"id" => id}, socket) do
    sms_notification = Enum.find(socket.assigns.sms_notifications, &(&1.id == String.to_integer(id)))
    if sms_notification do
      case Notifications.delete_sms_notification(sms_notification) do
        {:ok, _deleted_sms} ->
          {:noreply,
           socket
           |> put_flash(:info, "SMS notification deleted successfully!")
           |> fetch_sms_logs(socket.assigns.params)}
        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to delete SMS notification")}
      end
    else
      {:noreply, put_flash(socket, :error, "SMS notification not found")}
    end
  end

  @impl true
  def handle_event("open_filter", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin/notifications/sms-logs/filter")}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "SMS Details")
    |> assign(:live_action, :show)
    |> assign(:selected_sms, get_sms_notification(id))
  end

  defp apply_action(socket, :filter, _params) do
    socket
    |> assign(:page_title, "Filter SMS Logs")
    |> assign(:filter_modal, true)
  end

  defp assign_initial_state(socket) do
    socket
    |> assign(:page_title, "SMS Notification Center")
    |> assign(:title, "SMS Notification Center")
    |> assign(:description, "Professional SMS notification tracking and management system")
    |> assign(:sms_notifications, [])
    |> assign(:pagination, %{})
    |> assign(:params, %{})
    |> assign(:filter_params, %{})
    |> assign(:stats, get_sms_stats())
    |> assign(:data_loader, true)
    |> assign(:selected_sms, nil)
    |> assign(:live_action, nil)
    |> assign(:current_user, get_current_user())
    |> fetch_initial_data(%{})
  end

  defp fetch_initial_data(socket, params) do
    {sms_notifications, pagination} = get_sms_logs_with_pagination(params)
    stats = get_sms_stats()

    socket
    |> assign(:sms_notifications, sms_notifications)
    |> assign(:pagination, pagination)
    |> assign(:params, params)
    |> assign(:stats, stats)
    |> assign(:data_loader, false)
  end

  defp fetch_sms_logs_for_params(socket, params) do
    {sms_notifications, pagination} = get_sms_logs_with_pagination(params)
    stats = get_sms_stats()

    socket
    |> assign(:sms_notifications, sms_notifications)
    |> assign(:pagination, pagination)
    |> assign(:params, params)
    |> assign(:stats, stats)
    |> assign(:data_loader, false)
  end

  defp fetch_sms_logs(socket, params) do
    {sms_notifications, pagination} = get_sms_logs_with_pagination(params)
    stats = get_sms_stats()

    # Hide loader and update data
    socket = push_event(socket, "hide-loader", %{id: "sms-logs-loader"})

    {:noreply,
     socket
     |> assign(:sms_notifications, sms_notifications)
     |> assign(:pagination, pagination)
     |> assign(:params, params)
     |> assign(:stats, stats)
     |> assign(:data_loader, false)}
  end

  defp get_sms_logs_with_pagination(params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "20")
    offset = (page - 1) * per_page

    # Get filtered SMS logs
    sms_logs = get_sms_logs(params)
    total_count = length(sms_logs)

    # Apply pagination
    paginated_logs = sms_logs |> Enum.slice(offset, per_page)

    pagination = %{
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: ceil(total_count / per_page),
      sort_field: params["sort_field"] || "inserted_at",
      sort_direction: params["sort_direction"] || "desc"
    }

    {paginated_logs, pagination}
  end

  defp get_sms_logs(params) do
    try do
      Notifications.list_sms_notifications()
      |> apply_filters(params)
      |> apply_sorting(params)
    rescue
      _ -> []
    end
  end

  defp apply_filters(sms_logs, params) do
    filters = extract_filters(params)

    sms_logs
    |> filter_by_status(filters["status"])
    |> filter_by_type(filters["type"])
    |> filter_by_mobile(filters["mobile"])
    |> filter_by_search(filters["search"])
  end

  defp apply_sorting(sms_logs, params) do
    sort_field = params["sort_field"] || "inserted_at"
    sort_direction = params["sort_direction"] || "desc"

    case sort_field do
      "inserted_at" ->
        Enum.sort_by(sms_logs, & &1.inserted_at, if(sort_direction == "desc", do: :desc, else: :asc))
      "status" ->
        Enum.sort_by(sms_logs, & &1.status, if(sort_direction == "desc", do: :desc, else: :asc))
      "type" ->
        Enum.sort_by(sms_logs, & &1.type, if(sort_direction == "desc", do: :desc, else: :asc))
      "mobile" ->
        Enum.sort_by(sms_logs, & &1.mobile, if(sort_direction == "desc", do: :desc, else: :asc))
      _ ->
        Enum.sort_by(sms_logs, & &1.inserted_at, :desc)
    end
  end

  defp extract_filters(params) do
    %{
      "status" => params["filters"]["status"],
      "type" => params["filters"]["type"],
      "mobile" => params["filters"]["mobile"],
      "search" => params["search"]
    }
  end

  defp filter_by_status(sms_logs, nil), do: sms_logs
  defp filter_by_status(sms_logs, ""), do: sms_logs
  defp filter_by_status(sms_logs, status) do
    Enum.filter(sms_logs, &(&1.status == status))
  end

  defp filter_by_type(sms_logs, nil), do: sms_logs
  defp filter_by_type(sms_logs, ""), do: sms_logs
  defp filter_by_type(sms_logs, type) do
    Enum.filter(sms_logs, &(&1.type == type))
  end

  defp filter_by_mobile(sms_logs, nil), do: sms_logs
  defp filter_by_mobile(sms_logs, ""), do: sms_logs
  defp filter_by_mobile(sms_logs, mobile) do
    Enum.filter(sms_logs, &String.contains?(&1.mobile, mobile))
  end

  defp filter_by_search(sms_logs, nil), do: sms_logs
  defp filter_by_search(sms_logs, ""), do: sms_logs
  defp filter_by_search(sms_logs, search) do
    search_lower = String.downcase(search)
    Enum.filter(sms_logs, fn sms ->
      String.contains?(String.downcase(sms.mobile), search_lower) or
      String.contains?(String.downcase(sms.type), search_lower) or
      String.contains?(String.downcase(sms.msg), search_lower)
    end)
  end

  defp get_sms_notification(id) do
    try do
      Notifications.get_sms_notification!(id)
    rescue
      _ -> nil
    end
  end

  defp get_sms_stats do
    sms_logs = try do
      Notifications.list_sms_notifications()
    rescue
      _ -> []
    end

    total_sms = length(sms_logs)
    sent_sms = Enum.count(sms_logs, &(&1.status == "SENT"))
    pending_sms = Enum.count(sms_logs, &(&1.status == "READY"))
    failed_sms = Enum.count(sms_logs, &(&1.status == "FAILED"))

    %{
      total_sms: total_sms,
      sent_sms: sent_sms,
      pending_sms: pending_sms,
      failed_sms: failed_sms,
      stats_cards: [
        %{color: "blue", icon: "message", title: "Total SMS", value: total_sms},
        %{color: "green", icon: "check-circle", title: "Sent", value: sent_sms},
        %{color: "yellow", icon: "clock", title: "Pending", value: pending_sms},
        %{color: "red", icon: "x-circle", title: "Failed", value: failed_sms}
      ]
    }
  end

  defp get_current_user do
    # For now, return a mock user. In a real app, this would come from authentication
    %{
      id: 1,
      first_name: "System",
      last_name: "Admin",
      email: "admin@signease.com",
      user_type: "ADMIN",
      user_role: "ADMIN"
    }
  end

  defp get_status_class("READY"), do: "bg-yellow-100 text-yellow-800"
  defp get_status_class("SENT"), do: "bg-green-100 text-green-800"
  defp get_status_class("FAILED"), do: "bg-red-100 text-red-800"
  defp get_status_class("DELIVERED"), do: "bg-blue-100 text-blue-800"
  defp get_status_class(_), do: "bg-gray-100 text-gray-800"
end
