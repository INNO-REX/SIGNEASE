defmodule Signease.Repo.Migrations.AddInstructorFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # Instructor specific fields
      add :gender, :string
      add :date_of_birth, :date
      add :education_level, :string
      add :years_experience, :integer
      add :subjects_expertise, :text
    end

    # Create indexes for better performance
    create index(:users, [:gender])
    create index(:users, [:date_of_birth])
    create index(:users, [:education_level])
  end
end
