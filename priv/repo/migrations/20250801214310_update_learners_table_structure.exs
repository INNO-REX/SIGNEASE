defmodule Signease.Repo.Migrations.UpdateLearnersTableStructure do
  use Ecto.Migration

  def change do
    # Drop the existing learners table and recreate it with the new structure
    drop table(:learners)

    create table(:learners) do
      # Basic Information
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :username, :string, null: false
      add :email, :string, null: false
      add :phone_number, :string
      add :hearing_status, :string, default: "hearing" # "deaf" or "hearing"
      add :gender, :string # "male", "female", "other"
      add :date_of_birth, :date
      add :access_type, :string, default: "student" # "student", "teacher", "admin"
      add :password_hash, :string, null: false

      timestamps(type: :utc_datetime)
    end

    # Indexes for performance
    create unique_index(:learners, [:email])
    create unique_index(:learners, [:username])
    create index(:learners, [:hearing_status])
    create index(:learners, [:access_type])
  end
end
