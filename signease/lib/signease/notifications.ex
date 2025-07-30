defmodule Signease.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Signease.Repo
  alias Signease.Accounts
  alias Signease.Notifications.{Notification, Sms, Email}

  @doc """
  Returns the list of notifications.
  """
  def list_notifications do
    Repo.all(Notification)
  end

  @doc """
  Gets a single notification.
  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Creates a notification.
  """
  def create_notification(attrs \\ %{}) do
    case %Notification{} |> Notification.changeset(attrs) |> Repo.insert() do
      {:ok, notification} ->
        # Broadcast to all connected users
        Phoenix.PubSub.broadcast(Signease.PubSub, "notification_updates", {:notification_created, notification})
        {:ok, notification}
      error -> error
    end
  end

  @doc """
  Updates a notification.
  """
  def update_notification(%Notification{} = notification, attrs) do
    case notification |> Notification.changeset(attrs) |> Repo.update() do
      {:ok, notification} ->
        # Broadcast update
        Phoenix.PubSub.broadcast(Signease.PubSub, "notification_updates", {:notification_updated, notification})
        {:ok, notification}
      error -> error
    end
  end

  @doc """
  Deletes a notification.
  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.
  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end

  @doc """
  Creates a notification with delivery entries (SMS/Email).
  """
  def create_notification_with_delivery(notification_params) do
    Repo.transaction(fn ->
      # Create notification first
      {:ok, notification} = create_notification(notification_params)

      # Create SMS/Email entries based on delivery_channels
      delivery_results = create_delivery_entries_for_notification(notification)

      {notification, delivery_results}
    end)
  end

  @doc """
  Gets users by target audience.
  """
  def get_users_by_target_audience("ALL") do
    Accounts.User
    |> where([u], u.user_status == "ACTIVE" and u.disabled == false)
    |> Repo.all()
  end

  def get_users_by_target_audience("ADMIN") do
    Accounts.User
    |> where([u], u.user_type == "ADMIN" and u.user_status == "ACTIVE")
    |> Repo.all()
  end

  def get_users_by_target_audience("INSTRUCTOR") do
    Accounts.User
    |> where([u], u.user_type == "INSTRUCTOR" and u.user_status == "ACTIVE")
    |> Repo.all()
  end

  def get_users_by_target_audience("LEARNER") do
    Accounts.User
    |> where([u], u.user_type == "LEARNER" and u.user_status == "ACTIVE")
    |> Repo.all()
  end

  @doc """
  Creates SMS entries for notification.
  """
  def create_sms_entries_for_notification(notification) do
    users = get_users_by_target_audience(notification.target_audience)

    sms_entries = Enum.map(users, fn user ->
      %{
        type: "NOTIFICATION",
        mobile: user.phone || "",
        msg: notification.message,
        status: "READY",
        msg_count: "1",
        attempts: 0,
        notification_id: notification.id
      }
    end)

    Repo.insert_all(Sms, sms_entries)
  end

  @doc """
  Creates email entries for notification.
  """
  def create_email_entries_for_notification(notification) do
    users = get_users_by_target_audience(notification.target_audience)

    email_entries = Enum.map(users, fn user ->
      %{
        subject: notification.title,
        sender_email: "noreply@signease.com",
        sender_name: "SignEase System",
        mail_body: notification.message,
        recipient_email: user.email,
        status: "READY",
        attempts: "0",
        notification_id: notification.id
      }
    end)

    Repo.insert_all(Email, email_entries)
  end

  @doc """
  Creates delivery entries for notification based on delivery channels.
  """
  def create_delivery_entries_for_notification(notification) do
    channels = String.split(notification.delivery_channels || "", ",")

    results = []

    results = if "sms" in channels do
      results ++ [create_sms_entries_for_notification(notification)]
    else
      results
    end

    results = if "email" in channels do
      results ++ [create_email_entries_for_notification(notification)]
    else
      results
    end

    results
  end

  @doc """
  Gets notifications for a specific user based on their type.
  """
  def get_notifications_for_user(user) do
    user_type = user.user_type

    Notification
    |> where([n], n.status == "ACTIVE" or n.status == "SENT")
    |> where([n], n.target_audience == "ALL" or n.target_audience == ^user_type)
    |> order_by([n], [desc: n.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets unread notification count for a user.
  """
  def get_unread_notification_count(user) do
    notifications = get_notifications_for_user(user)
    # For now, we'll count all notifications as unread
    # In a real implementation, you'd track read status per user
    length(notifications)
  end

  @doc """
  Gets recent notifications for a user.
  """
  def get_recent_notifications_for_user(user, limit \\ 5) do
    user_type = user.user_type

    Notification
    |> where([n], n.status == "ACTIVE" or n.status == "SENT")
    |> where([n], n.target_audience == "ALL" or n.target_audience == ^user_type)
    |> order_by([n], [desc: n.inserted_at])
    |> limit(^limit)
    |> Repo.all()
  end

  # SMS Functions
  @doc """
  Returns the list of sms notifications.
  """
  def list_sms_notifications do
    Repo.all(Sms)
  end

  @doc """
  Gets a single sms notification.
  """
  def get_sms_notification!(id), do: Repo.get!(Sms, id)

  @doc """
  Creates a sms notification.
  """
  def create_sms_notification(attrs \\ %{}) do
    %Sms{} |> Sms.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Updates a sms notification.
  """
  def update_sms_notification(%Sms{} = sms, attrs) do
    sms |> Sms.changeset(attrs) |> Repo.update()
  end

  # Email Functions
  @doc """
  Returns the list of email notifications.
  """
  def list_email_notifications do
    Repo.all(Email)
  end

  @doc """
  Gets a single email notification.
  """
  def get_email_notification!(id), do: Repo.get!(Email, id)

  @doc """
  Creates an email notification.
  """
  def create_email_notification(attrs \\ %{}) do
    %Email{} |> Email.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Updates an email notification.
  """
  def update_email_notification(%Email{} = email, attrs) do
    email |> Email.changeset(attrs) |> Repo.update()
  end
end
