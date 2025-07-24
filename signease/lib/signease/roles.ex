defmodule Signease.Roles do
  @moduledoc """
  The Roles context.

  This module handles all role-related operations including:
  - Role creation and management
  - Permission management
  - Role assignment
  """

  import Ecto.Query, warn: false
  alias Signease.Repo
  alias Signease.Roles.UserRole

  @doc """
  Returns the list of user roles.

  ## Examples

      iex> list_user_roles()
      [%UserRole{}, ...]

  """
  def list_user_roles do
    Repo.all(UserRole)
  end

  @doc """
  Returns the list of user roles with permissions loaded.

  ## Examples

      iex> list_user_roles_with_permissions()
      [%UserRole{rights: %{}}, ...]

  """
  def list_user_roles_with_permissions do
    Repo.all(UserRole)
  end

  @doc """
  Gets a single user role.

  Raises `Ecto.NoResultsError` if the UserRole does not exist.

  ## Examples

      iex> get_user_role!(123)
      %UserRole{}

      iex> get_user_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_role!(id), do: Repo.get!(UserRole, id)

  @doc """
  Gets a single user role without raising an error.

  ## Examples

      iex> get_user_role(123)
      %UserRole{}

      iex> get_user_role(456)
      nil

  """
  def get_user_role(id), do: Repo.get(UserRole, id)

  @doc """
  Gets a user role by name.

  ## Examples

      iex> get_user_role_by_name("Admin")
      %UserRole{}

      iex> get_user_role_by_name("Nonexistent")
      nil

  """
  def get_user_role_by_name(name) when is_binary(name) do
    Repo.get_by(UserRole, name: name)
  end

  @doc """
  Creates a user role.

  ## Examples

      iex> create_user_role(%{field: value})
      {:ok, %UserRole{}}

      iex> create_user_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_role(attrs \\ %{}) do
    %UserRole{}
    |> UserRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a user role with creation changeset.

  ## Examples

      iex> create_user_role_with_rights(%{name: "Admin", rights: %{}})
      {:ok, %UserRole{}}

  """
  def create_user_role_with_rights(attrs \\ %{}) do
    %UserRole{}
    |> UserRole.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user role.

  ## Examples

      iex> update_user_role(user_role, %{field: new_value})
      {:ok, %UserRole{}}

      iex> update_user_role(user_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_role(%UserRole{} = user_role, attrs) do
    user_role
    |> UserRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user role.

  ## Examples

      iex> delete_user_role(user_role)
      {:ok, %UserRole{}}

      iex> delete_user_role(user_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_role(%UserRole{} = user_role) do
    Repo.delete(user_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user role changes.

  ## Examples

      iex> change_user_role(user_role)
      %Ecto.Changeset{data: %UserRole{}}

  """
  def change_user_role(%UserRole{} = user_role, attrs \\ %{}) do
    UserRole.changeset(user_role, attrs)
  end

  @doc """
  Gets all active roles.

  ## Examples

      iex> get_active_roles()
      [%UserRole{}, ...]

  """
  def get_active_roles do
    UserRole
    |> where([r], r.status == "ACTIVE")
    |> order_by([r], r.name)
    |> Repo.all()
  end

  @doc """
  Gets roles for selection (name and id pairs).

  ## Examples

      iex> get_roles_for_selection()
      [{"Admin", 1}, {"Learner", 2}]

  """
  def get_roles_for_selection do
    UserRole
    |> where([r], r.status == "ACTIVE")
    |> select([r], {r.name, r.id})
    |> order_by([r], r.name)
    |> Repo.all()
  end

  @doc """
  Updates role permissions.

  ## Examples

      iex> update_role_permissions(role, %{frontend: %{}, backend: %{}})
      {:ok, %UserRole{}}

  """
  def update_role_permissions(%UserRole{} = user_role, permissions) do
    user_role
    |> UserRole.changeset(%{rights: permissions})
    |> Repo.update()
  end

  @doc """
  Gets role permissions.

  ## Examples

      iex> get_role_permissions(role)
      %{frontend: %{}, backend: %{}}

  """
  def get_role_permissions(%UserRole{} = user_role) do
    user_role.rights || %{}
  end

  @doc """
  Checks if a role has a specific permission.

  ## Examples

      iex> has_permission?(role, "dashboard", "view")
      true

  """
  def has_permission?(%UserRole{} = user_role, module, action) do
    rights = get_role_permissions(user_role)

    case rights do
      %{backend: backend_rights} when is_map(backend_rights) ->
        case Map.get(backend_rights, String.to_atom(module)) do
          %{^action => true} -> true
          _ -> false
        end
      %{frontend: frontend_rights} when is_map(frontend_rights) ->
        case Map.get(frontend_rights, String.to_atom(module)) do
          %{^action => true} -> true
          _ -> false
        end
      _ -> false
    end
  end

  @doc """
  Gets all permissions for a role.

  ## Examples

      iex> get_all_permissions(role)
      [{"dashboard", "view"}, {"users", "create"}]

  """
  def get_all_permissions(%UserRole{} = user_role) do
    rights = get_role_permissions(user_role)

    backend_permissions =
      case rights do
        %{backend: backend_rights} when is_map(backend_rights) ->
          backend_rights
          |> Enum.flat_map(fn {module, permissions} ->
            permissions
            |> Enum.filter(fn {_action, value} -> value == true end)
            |> Enum.map(fn {action, _} -> {to_string(module), to_string(action)} end)
          end)
        _ -> []
      end

    frontend_permissions =
      case rights do
        %{frontend: frontend_rights} when is_map(frontend_rights) ->
          frontend_rights
          |> Enum.flat_map(fn {module, permissions} ->
            permissions
            |> Enum.filter(fn {_action, value} -> value == true end)
            |> Enum.map(fn {action, _} -> {to_string(module), to_string(action)} end)
          end)
        _ -> []
      end

    backend_permissions ++ frontend_permissions
  end

  @doc """
  Gets the total count of roles.

  ## Examples

      iex> get_total_roles_count()
      5

  """
  def get_total_roles_count do
    UserRole
    |> select([r], count(r.id))
    |> Repo.one()
  end
end
