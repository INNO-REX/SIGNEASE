defmodule Signease.Repo.Migrations.AddLearnerFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :program, :string
      add :enrolled_year, :integer
      add :semester, :string
    end

    # Add indexes for better query performance
    create index(:users, [:program])
    create index(:users, [:enrolled_year])
    create index(:users, [:semester])
    create index(:users, [:program, :enrolled_year])
    create index(:users, [:program, :semester])
  end
end
