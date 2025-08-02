defmodule Signease.Seeds.SetTestNotifications do
  alias Signease.Repo
  alias Signease.Notifications.{Notification, Sms, Email}

  def run do
    IO.puts("🌐 Creating test notifications...")

    # Create test notifications
    create_test_notifications()

    IO.puts("✅ Test notifications created successfully!")
  end

  defp create_test_notifications do
    # Create a main notification
    notification_params = %{
      title: "Welcome to SignEase - Account Created",
      message: "Your SignEase account has been created successfully. Username: testuser123, Password: TestPass123!",
      description: "Account creation notification for new learner",
      notification_type: "SECURITY_ALERT",
      priority: "HIGH",
      status: "ACTIVE",
      target_audience: "LEARNER",
      delivery_channels: "sms,email",
      created_by_id: 1,
      metadata: Jason.encode!(%{user_id: 1, username: "testuser123"})
    }

    case %Notification{} |> Notification.changeset(notification_params) |> Repo.insert() do
      {:ok, notification} ->
        # Create SMS notification
        sms_params = %{
          type: "PASSWORD_NOTIFICATION",
          mobile: "+1234567890",
          msg: "Welcome to SignEase! Your account has been created. Username: testuser123, Password: TestPass123! Please change your password after first login.",
          status: "SENT",
          msg_count: "2",
          date_sent: NaiveDateTime.utc_now() |> NaiveDateTime.add(-3600, :second),
          attempts: 1,
          notification_id: notification.id
        }

        case %Sms{} |> Sms.changeset(sms_params) |> Repo.insert() do
          {:ok, _sms} -> IO.puts("✅ SMS notification created")
          {:error, changeset} -> IO.puts("❌ SMS notification error: #{inspect(changeset.errors)}")
        end

        # Create Email notification
        email_params = %{
          subject: "Welcome to SignEase - Your Account Details",
          sender_email: "noreply@signease.com",
          sender_name: "SignEase System",
          mail_body: """
          Dear Test User,

          Your SignEase account has been created successfully.

          Account Details:
          - Username: testuser123
          - Password: TestPass123!

          Please login to your account and change your password for security.

          Best regards,
          SignEase Team
          """,
          recipient_email: "test@example.com",
          status: "SENT",
          attempts: "1",
          notification_id: notification.id
        }

        case %Email{} |> Email.changeset(email_params) |> Repo.insert() do
          {:ok, _email} -> IO.puts("✅ Email notification created")
          {:error, changeset} -> IO.puts("❌ Email notification error: #{inspect(changeset.errors)}")
        end

      {:error, changeset} ->
        IO.puts("❌ Notification error: #{inspect(changeset.errors)}")
    end

    # Create more test notifications with different statuses
    create_notification_with_status("SECURITY_ALERT", "FAILED", "+1987654321", "Password reset failed notification")
    create_notification_with_status("SECURITY_ALERT", "READY", "+1555123456", "Account alert pending notification")
    create_notification_with_status("SYSTEM_UPDATE", "DELIVERED", "+1444333222", "System update delivered notification")
    create_notification_with_status("SECURITY_ALERT", "SENT", "+1777888999", "Security alert sent notification")
  end

  defp create_notification_with_status(type, status, mobile, description) do
    notification_params = %{
      title: "#{type} - Test Notification",
      message: "This is a test #{String.downcase(type)} notification for #{mobile}",
      description: description,
      notification_type: type,
      priority: "MEDIUM",
      status: "ACTIVE",
      target_audience: "LEARNER",
      delivery_channels: "sms",
      created_by_id: 1,
      metadata: Jason.encode!(%{test: true, mobile: mobile})
    }

    case %Notification{} |> Notification.changeset(notification_params) |> Repo.insert() do
      {:ok, notification} ->
        sms_params = %{
          type: type,
          mobile: mobile,
          msg: "Test #{type} message: This is a test notification with status #{status}. Sent at #{NaiveDateTime.utc_now()}",
          status: status,
          msg_count: "1",
          date_sent: case status do
            "READY" -> nil
            _ -> NaiveDateTime.utc_now() |> NaiveDateTime.add(-Enum.random(1..3600), :second)
          end,
          attempts: case status do
            "FAILED" -> 3
            "READY" -> 0
            _ -> 1
          end,
          notification_id: notification.id
        }

        case %Sms{} |> Sms.changeset(sms_params) |> Repo.insert() do
          {:ok, _sms} -> IO.puts("✅ #{type} SMS notification created with status #{status}")
          {:error, changeset} -> IO.puts("❌ #{type} SMS error: #{inspect(changeset.errors)}")
        end

      {:error, changeset} ->
        IO.puts("❌ #{type} notification error: #{inspect(changeset.errors)}")
    end
  end
end
