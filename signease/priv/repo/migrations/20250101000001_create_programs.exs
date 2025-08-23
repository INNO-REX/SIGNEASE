defmodule Signease.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string, null: false
      add :description, :text
      add :code, :string, null: false
      add :duration_weeks, :integer
      add :max_learners, :integer
      add :status, :string, default: "ACTIVE"
      add :start_date, :date
      add :end_date, :date
      add :created_by, references(:users, on_delete: :nilify_all)
      add :updated_by, references(:users, on_delete: :nilify_all)
      add :deleted_by, references(:users, on_delete: :nilify_all)
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    # Create indexes
    create unique_index(:programs, [:code], name: :unique_program_code)
    create index(:programs, [:status])
    create index(:programs, [:created_by])
  end
end
