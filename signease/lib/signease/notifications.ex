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
    import Ecto.Query
    Repo.all(from n in Notification, order_by: [desc: n.inserted_at])
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

  # =============================================================================
  # PASSWORD MANAGEMENT NOTIFICATIONS
  # =============================================================================

  @doc """
  Sends password creation notification via SMS and Email.
  """
  def send_password_creation_notification(user, generated_password) do
    # Create notification record
    notification_params = %{
      title: "Welcome to SignEase - Your Account Details",
      message: "Your SignEase account has been created successfully. Username: #{user.username}, Password: #{generated_password}. Please change your password after first login.",
      notification_type: "SECURITY_ALERT",
      priority: "HIGH",
      status: "ACTIVE",
      target_audience: "LEARNER",
      delivery_channels: "sms,email",
      created_by_id: 1, # System admin
      metadata: Jason.encode!(%{user_id: user.id, username: user.username})
    }

    case create_notification(notification_params) do
      {:ok, notification} ->
        IO.puts("✅ Notification created with ID: #{notification.id}")
        # Send SMS notification
        send_password_sms(user, generated_password, notification)
        # Send Email notification
        send_password_email(user, generated_password, notification)
        {:ok, notification}
      {:error, changeset} ->
        IO.puts("❌ Notification creation error: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  @doc """
  Sends password reset notification via SMS and Email.
  """
  def send_password_reset_notification(user, new_password) do
    # Create notification record
    notification_params = %{
      title: "SignEase - Password Reset",
      message: "Your password has been reset. New password: #{new_password}. Please change your password after login.",
      notification_type: "SECURITY_ALERT",
      priority: "HIGH",
      status: "ACTIVE",
      target_audience: "LEARNER",
      delivery_channels: "sms,email",
      created_by_id: 1, # System admin
      metadata: Jason.encode!(%{user_id: user.id, username: user.username})
    }

    case create_notification(notification_params) do
      {:ok, notification} ->
        IO.puts("✅ Password reset notification created with ID: #{notification.id}")
        # Send SMS notification
        send_password_sms(user, new_password, notification)
        # Send Email notification
        send_password_email(user, new_password, notification)
        {:ok, notification}
      {:error, changeset} ->
        IO.puts("❌ Password reset notification creation error: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  defp send_password_sms(user, password, notification) do
    # Only send SMS if user has a phone number
    if user.phone && user.phone != "" do
      sms_params = %{
        type: "PASSWORD_NOTIFICATION",
        mobile: user.phone,
        msg: "SignEase: Your account details - Username: #{user.username}, Password: #{password}. Please change password after login.",
        status: "READY",
        msg_count: "1",
        attempts: 0,
        notification_id: notification.id
      }

      case %Sms{} |> Sms.changeset(sms_params) |> Repo.insert() do
        {:ok, sms} ->
          # In a real implementation, you would integrate with an SMS service here
          # For now, we'll just mark it as sent
          update_sms_status(sms, "SENT")
          {:ok, sms}
        {:error, changeset} ->
          IO.puts("❌ SMS creation error: #{inspect(changeset.errors)}")
          {:error, changeset}
      end
    else
      IO.puts("⚠️  Skipping SMS notification - no phone number for user #{user.username}")
      {:ok, nil}
    end
  end

  defp send_password_email(user, password, notification) do
    # Only send email if user has an email address
    if user.email && user.email != "" do
      email_params = %{
        subject: "SignEase - Your Account Details",
        sender_email: "noreply@signease.com",
        sender_name: "SignEase System",
        mail_body: """
        Dear #{user.first_name} #{user.last_name},

        Your SignEase account has been created successfully.

        Account Details:
        - Username: #{user.username}
        - Password: #{password}

        Please login to your account and change your password for security.

        Best regards,
        SignEase Team
        """,
        recipient_email: user.email,
        status: "READY",
        attempts: "0",
        notification_id: notification.id
      }

      case %Email{} |> Email.changeset(email_params) |> Repo.insert() do
        {:ok, email} ->
          # In a real implementation, you would integrate with an email service here
          # For now, we'll just mark it as sent
          update_email_status(email, "SENT")
          {:ok, email}
        {:error, changeset} ->
          IO.puts("❌ Email creation error: #{inspect(changeset.errors)}")
          {:error, changeset}
      end
    else
      IO.puts("⚠️  Skipping email notification - no email for user #{user.username}")
      {:ok, nil}
    end
  end

  @doc """
  Updates SMS status.
  """
  def update_sms_status(%Sms{} = sms, status) do
    sms |> Sms.changeset(%{status: status, date_sent: NaiveDateTime.utc_now()}) |> Repo.update()
  end

  @doc """
  Updates Email status.
  """
  def update_email_status(%Email{} = email, status) do
    email |> Email.changeset(%{status: status}) |> Repo.update()
  end

  # SMS Functions
  @doc """
  Returns the list of sms notifications.
  """
  def list_sms_notifications do
    import Ecto.Query
    Repo.all(from s in Sms, order_by: [desc: s.inserted_at])
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

  @doc """
  Deletes a sms notification.
  """
  def delete_sms_notification(%Sms{} = sms) do
    Repo.delete(sms)
  end

  # Email Functions
  @doc """
  Returns the list of email notifications.
  """
  def list_email_notifications do
    import Ecto.Query
    Repo.all(from e in Email, order_by: [desc: e.inserted_at])
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

  @doc """
  Deletes an email notification.
  """
  def delete_email_notification(%Email{} = email) do
    Repo.delete(email)
  end

  @doc """
  Sends approval notification to user.
  """
  def send_approval_notification(user) do
    notification_params = %{
      title: "SignEase - Account Approved",
      message: "Congratulations! Your SignEase account has been approved. You can now access all features.",
      notification_type: "ACCOUNT_UPDATE",
      priority: "MEDIUM",
      status: "ACTIVE",
      target_audience: "LEARNER",
      delivery_channels: "in_app,email",
      created_by_id: 1, # System admin
      metadata: Jason.encode!(%{user_id: user.id, username: user.username})
    }

    case create_notification(notification_params) do
      {:ok, notification} ->
        IO.puts("✅ Approval notification created with ID: #{notification.id}")
        # Send email notification
        send_approval_email(user, notification)
        {:ok, notification}
      {:error, changeset} ->
        IO.puts("❌ Approval notification creation error: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  @doc """
  Sends rejection notification to user.
  """
  def send_rejection_notification(user, reason) do
    notification_params = %{
      title: "SignEase - Account Application Update",
      message: "Your account application has been reviewed. Unfortunately, it was not approved at this time.",
      notification_type: "ACCOUNT_UPDATE",
      priority: "MEDIUM",
      status: "ACTIVE",
      target_audience: "LEARNER",
      delivery_channels: "in_app,email",
      created_by_id: 1, # System admin
      metadata: Jason.encode!(%{user_id: user.id, username: user.username, reason: reason})
    }

    case create_notification(notification_params) do
      {:ok, notification} ->
        IO.puts("✅ Rejection notification created with ID: #{notification.id}")
        # Send email notification
        send_rejection_email(user, reason, notification)
        {:ok, notification}
      {:error, changeset} ->
        IO.puts("❌ Rejection notification creation error: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  defp send_approval_email(user, notification) do
    if user.email && user.email != "" do
      email_params = %{
        subject: "SignEase - Account Approved",
        sender_email: "noreply@signease.com",
        sender_name: "SignEase Team",
        mail_body: """
        Dear #{user.first_name} #{user.last_name},

        Great news! Your SignEase account has been approved.

        You can now:
        - Access all learning materials
        - Participate in live sessions
        - Track your progress
        - Connect with instructors

        Login to your account at: https://signease.com

        Welcome to SignEase!

        Best regards,
        SignEase Team
        """,
        recipient_email: user.email,
        status: "READY",
        attempts: "0",
        notification_id: notification.id
      }

      case %Email{} |> Email.changeset(email_params) |> Repo.insert() do
        {:ok, email} ->
          update_email_status(email, "SENT")
          {:ok, email}
        {:error, changeset} ->
          IO.puts("❌ Approval email creation error: #{inspect(changeset.errors)}")
          {:error, changeset}
      end
    else
      IO.puts("⚠️  Skipping approval email - no email for user #{user.username}")
      {:ok, nil}
    end
  end

  defp send_rejection_email(user, reason, notification) do
    if user.email && user.email != "" do
      email_params = %{
        subject: "SignEase - Account Application Update",
        sender_email: "noreply@signease.com",
        sender_name: "SignEase Team",
        mail_body: """
        Dear #{user.first_name} #{user.last_name},

        Thank you for your interest in SignEase.

        After careful review of your application, we regret to inform you that your account has not been approved at this time.

        Reason: #{reason}

        If you believe this decision was made in error or if you have additional information to provide, please contact our support team.

        We appreciate your understanding.

        Best regards,
        SignEase Team
        """,
        recipient_email: user.email,
        status: "READY",
        attempts: "0",
        notification_id: notification.id
      }

      case %Email{} |> Email.changeset(email_params) |> Repo.insert() do
        {:ok, email} ->
          update_email_status(email, "SENT")
          {:ok, email}
        {:error, changeset} ->
          IO.puts("❌ Rejection email creation error: #{inspect(changeset.errors)}")
          {:error, changeset}
      end
    else
      IO.puts("⚠️  Skipping rejection email - no email for user #{user.username}")
      {:ok, nil}
    end
  end
end
