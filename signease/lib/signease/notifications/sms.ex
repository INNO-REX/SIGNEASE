defmodule Signease.Notifications.Sms do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sms_notifications" do
    field :type, :string
    field :mobile, :string
    field :msg, :string
    field :status, :string
    field :msg_count, :string
    field :date_sent, :naive_datetime
    field :attempts, :integer, default: 0
    field :notification_id, :integer

    timestamps()
  end

  @doc false
  def changeset(sms, attrs) do
    sms
    |> cast(attrs, [:type, :mobile, :msg, :status, :msg_count, :date_sent, :attempts, :notification_id])
    |> validate_required([:type, :mobile, :msg, :status])
    |> validate_inclusion(:status, ["READY", "SENT", "FAILED", "DELIVERED"])
  end
end
