defmodule Signease.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    # Create notifications table
    create table(:notifications) do
      add :title, :string, null: false
      add :message, :text, null: false
      add :description, :text
      add :notification_type, :string, null: false
      add :priority, :string, null: false
      add :status, :string, null: false
      add :target_audience, :string, null: false
      add :delivery_channels, :string
      add :scheduled_at, :utc_datetime
      add :expires_at, :utc_datetime
      add :read_count, :integer, default: 0
      add :click_count, :integer, default: 0
      add :metadata, :text
      add :created_by_id, references(:users, on_delete: :nilify_all)
      add :approved_by_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    # Create sms_notifications table
    create table(:sms_notifications) do
      add :type, :string, null: false
      add :mobile, :string, null: false
      add :msg, :text, null: false
      add :status, :string, null: false
      add :msg_count, :string
      add :date_sent, :naive_datetime
      add :attempts, :integer, default: 0
      add :notification_id, references(:notifications, on_delete: :delete_all)

      timestamps()
    end

    # Create email_notifications table
    create table(:email_notifications) do
      add :subject, :string, null: false
      add :sender_email, :string, null: false
      add :sender_name, :string
      add :mail_body, :text, null: false
      add :recipient_email, :string, null: false
      add :status, :string, null: false
      add :attempts, :string
      add :notification_id, references(:notifications, on_delete: :delete_all)

      timestamps()
    end

    # Create indexes
    create index(:notifications, [:status])
    create index(:notifications, [:target_audience])
    create index(:notifications, [:notification_type])
    create index(:notifications, [:created_by_id])
    create index(:notifications, [:approved_by_id])
    create index(:notifications, [:inserted_at])

    create index(:sms_notifications, [:status])
    create index(:sms_notifications, [:mobile])
    create index(:sms_notifications, [:notification_id])
    create index(:sms_notifications, [:date_sent])

    create index(:email_notifications, [:status])
    create index(:email_notifications, [:recipient_email])
    create index(:email_notifications, [:notification_id])
    create index(:email_notifications, [:inserted_at])
  end
end
