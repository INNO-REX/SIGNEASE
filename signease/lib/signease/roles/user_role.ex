defmodule Signease.Roles.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_roles" do
    field :name, :string
    field :status, :string, default: "ACTIVE"
    field :created_by, :integer
    field :updated_by, :integer
    field :rights, :map, default: %{}

    has_many :users, Signease.Accounts.User, foreign_key: :role_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :created_by, :updated_by, :status, :rights])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_inclusion(:status, ["ACTIVE", "INACTIVE"],
        message: "must be ACTIVE or INACTIVE")
    |> unsafe_validate_unique(:name, Signease.Repo)
    |> unique_constraint(:name, name: :unique_role_name,
        message: "role name already exists")
  end

  @doc """
  Creates a changeset for role creation with default rights.
  """
  def creation_changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :created_by, :updated_by, :status, :rights])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_inclusion(:status, ["ACTIVE", "INACTIVE"],
        message: "must be ACTIVE or INACTIVE")
    |> unsafe_validate_unique(:name, Signease.Repo)
    |> unique_constraint(:name, name: :unique_role_name,
        message: "role name already exists")
    |> put_default_rights()
  end

  # Private functions

  defp put_default_rights(changeset) do
    case get_field(changeset, :rights) do
      nil -> put_change(changeset, :rights, %{})
      _ -> changeset
    end
  end
end
