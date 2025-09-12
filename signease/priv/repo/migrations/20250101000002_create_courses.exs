defmodule Signease.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string, null: false
      add :description, :text
      add :code, :string, null: false
      add :program_id, references(:programs, on_delete: :restrict), null: false
      add :instructor_id, references(:users, on_delete: :nilify_all)
      add :duration_hours, :integer
      add :difficulty_level, :string, default: "BEGINNER"
      add :status, :string, default: "ACTIVE"
      add :max_students, :integer
      add :prerequisites, :text
      add :learning_objectives, :text
      add :created_by, references(:users, on_delete: :nilify_all)
      add :updated_by, references(:users, on_delete: :nilify_all)
      add :deleted_by, references(:users, on_delete: :nilify_all)
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    # Create indexes
    create unique_index(:courses, [:code], name: :unique_course_code)
    create index(:courses, [:program_id])
    create index(:courses, [:instructor_id])
    create index(:courses, [:status])
    create index(:courses, [:difficulty_level])
    create index(:courses, [:created_by])
  end
end
