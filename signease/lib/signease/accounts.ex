defmodule Signease.Accounts do
  @moduledoc """
  The Accounts context.

  This module handles all user-related operations including:
  - User registration (learners only)
  - User authentication
  - User management
  - Password management
  - User onboarding (for non-learners)
  """

  import Ecto.Query, warn: false
  alias Signease.Repo
  alias Signease.Accounts.{User}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user by ID.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by ID without raising an error.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("user@example.com")
      %User{}

      iex> get_user_by_email("nonexistent@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by username.

  ## Examples

      iex> get_user_by_username("john_doe")
      %User{}

      iex> get_user_by_username("nonexistent")
      nil

  """
  def get_user_by_username(username) when is_binary(username) do
    Repo.get_by(User, username: username)
  end

  @doc """
  Gets a user by username and password for authentication.

  ## Examples

      iex> get_user_by_username_and_password("john_doe", "correct_password")
      %User{}

      iex> get_user_by_username_and_password("john_doe", "invalid_password")
      nil

  """
  def get_user_by_username_and_password(username, password)
    when is_binary(username) and is_binary(password) do
    user = Repo.get_by(User, username: username)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Creates a user (for internal use only).

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Registers a new learner (public signup).

  This is the only public registration method. All other user types
  must be created through internal onboarding.

  ## Examples

      iex> register_learner(%{first_name: "John", last_name: "Doe", email: "john@example.com", password: "password123", password_confirmation: "password123", hearing_status: "HEARING"})
      {:ok, %User{}}

      iex> register_learner(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_learner(attrs) do
    # Generate username from email
    username = generate_username_from_email(attrs["email"] || attrs[:email])
    attrs = Map.put(attrs, "username", username)

    %User{}
    |> User.learner_registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates an admin user (internal onboarding only).

  ## Examples

      iex> create_admin_user(%{first_name: "Admin", last_name: "User", email: "admin@example.com", username: "admin", user_type: "ADMIN", user_role: "ADMIN", hearing_status: "HEARING"})
      {:ok, %User{}}

  """
  def create_admin_user(attrs) do
    %User{}
    |> User.admin_creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_user(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user with password validation.

  ## Examples

      iex> update_user_with_password(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_with_password(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_with_password(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's password.

  ## Examples

      iex> update_user_password(user, "current_password", %{password: "new_password", password_confirmation: "new_password"})
      {:ok, %User{}}

      iex> update_user_password(user, "wrong_password", %{password: "new_password", password_confirmation: "new_password"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(%User{} = user, current_password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(current_password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Resets a user's password (for password reset flow).

  ## Examples

      iex> reset_user_password(user, %{password: "new_password", password_confirmation: "new_password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "new_password", password_confirmation: "wrong"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(%User{} = user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_reset_changeset(user, attrs))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking learner registration changes.

  ## Examples

      iex> change_learner_registration()
      %Ecto.Changeset{data: %User{}}

  """
  def change_learner_registration(attrs \\ %{}) do
    User.learner_registration_changeset(%User{}, attrs, hash_password: false, validate_email: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(%User{} = user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(%User{} = user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Returns the last 5 users inserted into the database.

  ## Examples

      iex> get_last_five_users()
      [%User{}, %User{}, %User{}, %User{}, %User{}]

  """
  def get_last_five_users do
    User
    |> order_by(desc: :inserted_at)
    |> limit(5)
    |> Repo.all()
  end

  @doc """
  Gets all learners.

  ## Examples

      iex> get_learners()
      [%User{}, ...]

  """
  def get_learners do
    User
    |> where([u], u.user_type == "LEARNER")
    |> order_by([u], [u.first_name, u.last_name])
    |> Repo.all()
  end

  @doc """
  Gets all pending approval users.

  ## Examples

      iex> get_pending_approval_users()
      [%User{}, ...]

  """
  def get_pending_approval_users do
    User
    |> where([u], u.status == "PENDING_APPROVAL")
    |> order_by([u], [desc: u.inserted_at])
    |> Repo.all()
  end

  @doc """
  Approves a user by ID.

  ## Examples

      iex> approve_user(user_id, approver_id)
      {:ok, %User{}}

  """
  def approve_user(user_id, approver_id) when is_binary(user_id) do
    approve_user(user_id |> String.to_integer(), approver_id)
  end

  def approve_user(user_id, approver_id) when is_integer(user_id) do
    case get_user(user_id) do
      nil -> {:error, "User not found"}
      user -> approve_user(user, approver_id)
    end
  end

  @doc """
  Approves a user.

  ## Examples

      iex> approve_user(user, approver_id)
      {:ok, %User{}}

  """
  def approve_user(%User{} = user, approver_id) do
    user
    |> User.status_changeset(%{
      status: "APPROVED",
      approved: true,
      approved_by: approver_id,
      approved_at: DateTime.utc_now()
    })
    |> Repo.update()
  end

  @doc """
  Rejects a user by ID.

  ## Examples

      iex> reject_user(user_id, rejector_id, "Invalid information")
      {:ok, %User{}}

  """
  def reject_user(user_id, rejector_id, reason) when is_binary(user_id) do
    reject_user(user_id |> String.to_integer(), rejector_id, reason)
  end

  def reject_user(user_id, rejector_id, reason) when is_integer(user_id) do
    case get_user(user_id) do
      nil -> {:error, "User not found"}
      user -> reject_user(user, rejector_id, reason)
    end
  end

  @doc """
  Rejects a user.

  ## Examples

      iex> reject_user(user, rejector_id, "Invalid information")
      {:ok, %User{}}

  """
  def reject_user(%User{} = user, rejector_id, reason) do
    user
    |> User.status_changeset(%{
      status: "REJECTED",
      rejected_by: rejector_id,
      rejected_at: DateTime.utc_now(),
      rejection_reason: reason
    })
    |> Repo.update()
  end

  @doc """
  Gets the total count of users.

  ## Examples

      iex> get_total_users_count()
      42

  """
  def get_total_users_count do
    User
    |> select([u], count(u.id))
    |> Repo.one()
  end

  @doc """
  Gets the count of users pending approval.

  ## Examples

      iex> get_pending_approval_users_count()
      5

  """
  def get_pending_approval_users_count do
    User
    |> where([u], u.status == "PENDING_APPROVAL")
    |> select([u], count(u.id))
    |> Repo.one()
  end

  @doc """
  Disables a user by ID.

  ## Examples

      iex> disable_user(user_id, disabler_id, "Violation of terms")
      {:ok, %User{}}

  """
  def disable_user(user_id, disabler_id, reason) when is_binary(user_id) do
    disable_user(user_id |> String.to_integer(), disabler_id, reason)
  end

  def disable_user(user_id, disabler_id, reason) when is_integer(user_id) do
    case get_user(user_id) do
      nil -> {:error, "User not found"}
      user -> disable_user(user, disabler_id, reason)
    end
  end

  @doc """
  Disables a user.

  ## Examples

      iex> disable_user(user, disabler_id, "Violation of terms")
      {:ok, %User{}}

  """
  def disable_user(%User{} = user, disabler_id, reason) do
    user
    |> User.status_changeset(%{
      disabled: true,
      disabled_reason: reason,
      updated_by: disabler_id
    })
    |> Repo.update()
  end

  @doc """
  Enables a user by ID.

  ## Examples

      iex> enable_user(user_id, enabler_id)
      {:ok, %User{}}

  """
  def enable_user(user_id, enabler_id) when is_binary(user_id) do
    enable_user(user_id |> String.to_integer(), enabler_id)
  end

  def enable_user(user_id, enabler_id) when is_integer(user_id) do
    case get_user(user_id) do
      nil -> {:error, "User not found"}
      user -> enable_user(user, enabler_id)
    end
  end

  @doc """
  Enables a user.

  ## Examples

      iex> enable_user(user, enabler_id)
      {:ok, %User{}}

  """
  def enable_user(%User{} = user, enabler_id) do
    user
    |> User.status_changeset(%{
      disabled: false,
      disabled_reason: nil,
      updated_by: enabler_id
    })
    |> Repo.update()
  end

  @doc """
  Deletes a user by ID.

  ## Examples

      iex> delete_user(user_id, deleter_id)
      {:ok, %User{}}

  """
  def delete_user(user_id, deleter_id) when is_binary(user_id) do
    delete_user(user_id |> String.to_integer(), deleter_id)
  end

  def delete_user(user_id, deleter_id) when is_integer(user_id) do
    case get_user(user_id) do
      nil -> {:error, "User not found"}
      user -> delete_user(user, deleter_id)
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user, deleter_id)
      {:ok, %User{}}

  """
  def delete_user(%User{} = user, deleter_id) do
    user
    |> User.status_changeset(%{
      deleted_by: deleter_id,
      deleted_at: DateTime.utc_now()
    })
    |> Repo.update()
  end

  # Private functions

  defp generate_username_from_email(email) when is_binary(email) do
    email
    |> String.split("@")
    |> List.first()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9_]/, "")
    |> ensure_unique_username()
  end

  defp generate_username_from_email(_), do: nil

  defp ensure_unique_username(base_username) do
    case get_user_by_username(base_username) do
      nil -> base_username
      _user ->
        # Try with random suffix
        suffix = :crypto.strong_rand_bytes(3) |> Base.encode16(case: :lower)
        new_username = "#{base_username}_#{suffix}"

        case get_user_by_username(new_username) do
          nil -> new_username
          _user -> ensure_unique_username(base_username)
        end
    end
  end
end
