defmodule Signease.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(id first_name last_name email password hashed_password user_type user_role status
    user_status auto_pwd id_type id_no phone maker_id updated_by login_id
    approved disabled disabled_reason blocked branch_code branch_id username profile_picture
    last_pwd_update role_id hearing_status learning_preferences accessibility_needs
    preferred_language sign_language_skills inserted_at updated_at approved_by approved_at
    rejected_by rejected_at rejection_reason deleted_by deleted_at)a

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :hashed_password, :string
    field :user_type, :string, default: "LEARNER" # LEARNER, INSTRUCTOR, ADMIN, SUPPORT
    field :user_role, :string, default: "STUDENT" # STUDENT, TEACHER, ADMIN, SUPPORT
    field :status, :string, default: "PENDING_APPROVAL"
    field :user_status, :string, default: "ACTIVE"
    field :auto_pwd, :string, default: "Y"
    field :id_type, :string
    field :id_no, :string
    field :phone, :string
    field :maker_id, :id
    field :updated_by, :id
    field :login_id, :string
    field :approved, :boolean, default: false
    field :disabled, :boolean, default: false
    field :blocked, :boolean, default: false
    field :disabled_reason, :string
    field :branch_code, :string
    field :branch_id, :id
    field :username, :string
    field :profile_picture, :string
    field :last_pwd_update, :naive_datetime

    # SignEase specific fields
    field :hearing_status, :string # HEARING, DEAF, HARD_OF_HEARING
    field :learning_preferences, :map, default: %{}
    field :accessibility_needs, :map, default: %{}
    field :preferred_language, :string, default: "en"
    field :sign_language_skills, :string, default: "BEGINNER" # BEGINNER, INTERMEDIATE, ADVANCED, FLUENT

    # Approval tracking
    belongs_to :approver, Signease.Accounts.User,
      foreign_key: :approved_by,
      type: :id
    field :approved_at, :utc_datetime

    # Rejection tracking
    belongs_to :rejector, Signease.Accounts.User,
      foreign_key: :rejected_by,
      type: :id
    field :rejected_at, :utc_datetime
    field :rejection_reason, :string

    # Deletion tracking
    belongs_to :deleter, Signease.Accounts.User,
      foreign_key: :deleted_by,
      type: :id
    field :deleted_at, :utc_datetime

    belongs_to :role, Signease.Roles.UserRole, foreign_key: :role_id, type: :id

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for general user updates
  """
  def changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @fields)
    |> validate_required([:first_name, :last_name, :email, :username, :phone])
    |> validate_conditional_role_id()
    |> validate_email(opts)
    |> validate_username()
    |> validate_password(opts)
    |> validate_user_role()
    |> validate_hearing_status()
  end

  @doc """
  Changeset for user updates
  """
  def update_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @fields)
    |> validate_required([:first_name, :last_name, :email, :username, :phone])
    |> validate_conditional_role_id()
    |> validate_email(opts)
    |> validate_username()
    |> maybe_hash_password(opts)
    |> validate_user_role()
    |> validate_hearing_status()
  end

  @doc """
  Changeset for user updates without password validation
  """
  def update_user(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @fields)
    |> validate_required([:first_name, :last_name, :email, :username, :phone])
    |> validate_conditional_role_id()
    |> validate_email(opts)
  end

  @doc """
  Changeset for learner registration (public signup)
  """
  def learner_registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @fields)
    |> validate_required([:first_name, :last_name, :email, :password, :password_confirmation, :hearing_status])
    |> validate_field_sizes()
    |> validate_name_format()
    |> validate_email(opts)
    |> validate_username()
    |> validate_password(opts)
    |> validate_password_confirmation()
    |> validate_learner_only()
    |> validate_hearing_status()
    |> set_default_learner_values()
  end

  @doc """
  Changeset for admin user creation (internal onboarding)
  """
  def admin_creation_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @fields)
    |> validate_required([:first_name, :last_name, :email, :username, :phone, :user_type, :user_role, :hearing_status])
    |> validate_field_sizes()
    |> validate_name_format()
    |> validate_email(opts)
    |> validate_username()
    |> validate_password(opts)
    |> validate_user_role()
    |> validate_hearing_status()
    |> validate_conditional_role_id()
  end

  @doc """
  Changeset for password updates
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_password(opts)
    |> validate_password_confirmation()
    |> put_change(:last_pwd_update, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
  end

  @doc """
  Changeset for password reset
  """
  def password_reset_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password, :password_confirmation, :last_pwd_update])
    |> validate_required([:password, :password_confirmation])
    |> validate_password(opts)
    |> validate_password_confirmation()
    |> put_change(:last_pwd_update, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
  end

  @doc """
  Changeset for status updates
  """
  def status_changeset(user, attrs) do
    user
    |> cast(attrs, [:status, :user_status, :disabled_reason])
  end

  # Private validation functions

  defp validate_field_sizes(changeset) do
    changeset
    |> validate_required([:username, :last_name, :first_name, :phone])
    |> validate_length(:username, min: 3, max: 30)
    |> validate_length(:first_name, min: 2, max: 50)
    |> validate_length(:last_name, min: 2, max: 50)
    |> validate_length(:email, min: 5, max: 255)
    |> validate_length(:phone, min: 10, max: 15)
  end

  defp validate_name_format(changeset) do
    changeset
    |> validate_format(:first_name, ~r/^[a-zA-Z\s\-']+$/,
        message: "should only contain letters, spaces, hyphens, and apostrophes")
    |> validate_format(:last_name, ~r/^[a-zA-Z\s\-']+$/,
        message: "should only contain letters, spaces, hyphens, and apostrophes")
  end

  defp validate_conditional_role_id(changeset) do
    user_type = get_field(changeset, :user_type)

    case user_type do
      "ADMIN" ->
        validate_required(changeset, [:role_id])
      _ ->
        changeset
    end
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/,
        message: "must be a valid email address")
    |> validate_length(:email, min: 5, max: 255)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username])
    |> validate_length(:username, min: 3, max: 30)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/,
        message: "only letters, numbers, and underscores allowed")
    |> unsafe_validate_unique(:username, Signease.Repo)
    |> unique_constraint(:username, name: :unique_username,
        message: "username already exists")
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 128,
        message: "should be at least 8 characters long")
    |> maybe_hash_password(opts)
  end

  defp validate_password_confirmation(changeset) do
    changeset
    |> validate_confirmation(:password,
        message: "does not match password")
  end

  defp validate_learner_only(changeset) do
    changeset
    |> put_change(:user_type, "LEARNER")
    |> put_change(:user_role, "STUDENT")
    |> put_change(:status, "PENDING_APPROVAL")
  end

  defp validate_user_role(
         %Ecto.Changeset{valid?: true, changes: %{user_type: type, user_role: role}} = changeset
       ) do
    case role == "ADMIN" && type == "LEARNER" do
      true ->
        add_error(changeset, :user_role, "learners cannot be admin")
      _ ->
        changeset
    end
  end

  defp validate_user_role(changeset), do: changeset

  defp validate_hearing_status(changeset) do
    changeset
    |> validate_required([:hearing_status])
    |> validate_inclusion(:hearing_status, ["HEARING", "DEAF", "HARD_OF_HEARING"],
        message: "must be HEARING, DEAF, or HARD_OF_HEARING")
  end

  defp set_default_learner_values(changeset) do
    changeset
    |> put_change(:learning_preferences, %{
        "speech_to_text" => true,
        "sign_language" => true,
        "visual_aids" => true,
        "audio_captions" => true
      })
    |> put_change(:accessibility_needs, %{
        "screen_reader" => false,
        "high_contrast" => false,
        "large_text" => false,
        "keyboard_navigation" => true
      })
    |> put_change(:preferred_language, "en")
    |> put_change(:sign_language_skills, "BEGINNER")
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if is_nil(password) do
      changeset
    else
      if hash_password? && password && changeset.valid? do
        changeset
        |> put_change(:hashed_password, encrypt_password(password))
        |> put_change(:last_pwd_update, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
        |> delete_change(:password)
      else
        changeset
        |> put_change(:password, encrypt_password(password))
      end
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Signease.Repo)
      |> unique_constraint(:email, name: :unique_email,
          message: "email already exists")
    else
      changeset
    end
  end

  # Password encryption and validation

  @spec encrypt_password(binary) :: binary
  def encrypt_password(password), do: Base.encode16(:crypto.hash(:sha512, password))

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  a dummy hash to avoid timing attacks.
  """
  def valid_password?(%Signease.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    encrypt_password(password) == hashed_password
  end

  def valid_password?(_, _) do
    encrypt_password("dummy_password")
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  # Email and username changesets

  @doc """
  A user changeset for changing the email.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the username.
  """
  def username_changeset(user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_username()
    |> case do
      %{changes: %{username: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :username, "did not change")
    end
  end
end
