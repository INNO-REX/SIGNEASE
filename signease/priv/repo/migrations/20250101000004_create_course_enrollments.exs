defmodule Signease.Repo.Migrations.CreateCourseEnrollments do
  use Ecto.Migration

  def change do
    create table(:course_enrollments) do
      add :course_id, references(:courses, on_delete: :restrict), null: false
      add :learner_id, references(:users, on_delete: :restrict), null: false
      add :enrollment_date, :date, null: false
      add :completion_date, :date
      add :status, :string, default: "ENROLLED"
      add :progress_percentage, :decimal, precision: 5, scale: 2, default: 0.0
      add :grade, :string
      add :certificate_issued, :boolean, default: false
      add :certificate_issued_at, :utc_datetime
      add :enrolled_by, references(:users, on_delete: :nilify_all)
      add :notes, :text
      add :created_by, references(:users, on_delete: :nilify_all)
      add :updated_by, references(:users, on_delete: :nilify_all)
      add :deleted_by, references(:users, on_delete: :nilify_all)
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    # Create indexes
    create unique_index(:course_enrollments, [:course_id, :learner_id], name: :unique_course_learner_enrollment)
    create index(:course_enrollments, [:course_id])
    create index(:course_enrollments, [:learner_id])
    create index(:course_enrollments, [:status])
    create index(:course_enrollments, [:enrollment_date])
    create index(:course_enrollments, [:enrolled_by])
    create index(:course_enrollments, [:grade])
  end
end
