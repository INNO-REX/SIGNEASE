defmodule Signease.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :user_type, :string, default: "LEARNER"
      add :user_role, :string, default: "STUDENT"
      add :status, :string, default: "PENDING_APPROVAL"
      add :user_status, :string, default: "ACTIVE"
      add :auto_pwd, :string, default: "Y"
      add :id_type, :string
      add :id_no, :string
      add :phone, :string, null: false
      add :maker_id, :bigint
      add :updated_by, :bigint
      add :login_id, :string
      add :approved, :boolean, default: false
      add :disabled, :boolean, default: false
      add :blocked, :boolean, default: false
      add :disabled_reason, :text
      add :branch_code, :string
      add :branch_id, :bigint
      add :username, :string, null: false
      add :profile_picture, :string
      add :last_pwd_update, :naive_datetime

      # SignEase specific fields
      add :hearing_status, :string, null: false
      add :learning_preferences, :map, default: %{}
      add :accessibility_needs, :map, default: %{}
      add :preferred_language, :string, default: "en"
      add :sign_language_skills, :string, default: "BEGINNER"

      # Approval tracking
      add :approved_by, :bigint
      add :approved_at, :utc_datetime

      # Rejection tracking
      add :rejected_by, :bigint
      add :rejected_at, :utc_datetime
      add :rejection_reason, :text

      # Deletion tracking
      add :deleted_by, :bigint
      add :deleted_at, :utc_datetime

      # Role association
      add :role_id, :bigint

      timestamps(type: :utc_datetime)
    end

    # Create indexes
    create unique_index(:users, [:email], name: :unique_email)
    create unique_index(:users, [:username], name: :unique_username)
    create index(:users, [:user_type])
    create index(:users, [:status])
    create index(:users, [:hearing_status])
    create index(:users, [:role_id])
  end
end
