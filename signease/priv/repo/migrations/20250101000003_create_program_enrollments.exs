defmodule Signease.Repo.Migrations.CreateProgramEnrollments do
  use Ecto.Migration

  def change do
    create table(:program_enrollments) do
      add :program_id, references(:programs, on_delete: :restrict), null: false
      add :learner_id, references(:users, on_delete: :restrict), null: false
      add :enrollment_date, :date, null: false
      add :completion_date, :date
      add :status, :string, default: "ENROLLED"
      add :progress_percentage, :decimal, precision: 5, scale: 2, default: 0.0
      add :enrolled_by, references(:users, on_delete: :nilify_all)
      add :notes, :text
      add :created_by, references(:users, on_delete: :nilify_all)
      add :updated_by, references(:users, on_delete: :nilify_all)
      add :deleted_by, references(:users, on_delete: :nilify_all)
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    # Create indexes
    create unique_index(:program_enrollments, [:program_id, :learner_id], name: :unique_program_learner_enrollment)
    create index(:program_enrollments, [:program_id])
    create index(:program_enrollments, [:learner_id])
    create index(:program_enrollments, [:status])
    create index(:program_enrollments, [:enrollment_date])
    create index(:program_enrollments, [:enrolled_by])
  end
end
