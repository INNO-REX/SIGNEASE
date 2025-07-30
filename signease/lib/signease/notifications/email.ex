defmodule Signease.Notifications.Email do
  use Ecto.Schema
  import Ecto.Changeset

  schema "email_notifications" do
    field :subject, :string
    field :sender_email, :string
    field :sender_name, :string
    field :mail_body, :string
    field :recipient_email, :string
    field :status, :string
    field :attempts, :string
    field :notification_id, :integer

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:subject, :sender_email, :sender_name, :mail_body, :recipient_email, :status, :attempts, :notification_id])
    |> validate_required([:subject, :sender_email, :recipient_email, :status])
    |> validate_inclusion(:status, ["READY", "SENT", "FAILED", "DELIVERED"])
  end
end
