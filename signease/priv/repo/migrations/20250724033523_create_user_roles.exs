defmodule Signease.Repo.Migrations.CreateUserRoles do
  use Ecto.Migration

  def change do
    create table(:user_roles) do
      add :name, :string, null: false
      add :status, :string, default: "ACTIVE"
      add :created_by, :integer
      add :updated_by, :integer
      add :rights, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    # Create indexes
    create unique_index(:user_roles, [:name], name: :unique_role_name)
    create index(:user_roles, [:status])
  end
end
