defmodule Signease.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "notifications" do
    field :title, :string
    field :message, :string
    field :description, :string
    field :notification_type, :string  # SECURITY_ALERT, SYSTEM_UPDATE, LEARNING_REMINDER, etc.
    field :priority, :string           # LOW, MEDIUM, HIGH, CRITICAL
    field :status, :string             # PENDING_APPROVAL, ACTIVE, SENT, FAILED, CANCELLED
    field :target_audience, :string    # ALL, ADMIN, INSTRUCTOR, LEARNER
    field :delivery_channels, :string  # email, sms, in_app
    field :scheduled_at, :utc_datetime
    field :expires_at, :utc_datetime
    field :read_count, :integer, default: 0
    field :click_count, :integer, default: 0
    field :metadata, :string

    belongs_to :created_by, Signease.Accounts.User
    belongs_to :approved_by, Signease.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:title, :message, :description, :notification_type, :priority, :status,
                   :target_audience, :delivery_channels, :scheduled_at, :expires_at,
                   :read_count, :click_count, :metadata, :created_by_id, :approved_by_id])
    |> validate_required([:title, :message, :notification_type, :priority, :status, :target_audience])
    |> validate_inclusion(:priority, ["LOW", "MEDIUM", "HIGH", "CRITICAL"])
    |> validate_inclusion(:status, ["PENDING_APPROVAL", "ACTIVE", "SENT", "FAILED", "CANCELLED"])
    |> validate_inclusion(:target_audience, ["ALL", "ADMIN", "INSTRUCTOR", "LEARNER"])
    |> validate_inclusion(:notification_type, ["SECURITY_ALERT", "SYSTEM_UPDATE", "LEARNING_REMINDER", "SESSION_REMINDER", "GENERAL"])
  end
end
