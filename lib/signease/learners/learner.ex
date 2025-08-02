defmodule Signease.Learners.Learner do
  use Ecto.Schema
  import Ecto.Changeset

  @fields ~w(id first_name last_name username email phone_number hearing_status gender date_of_birth access_type password_hash created_at updated_at)a

  schema "learners" do
    # Basic Information
    field :first_name, :string
    field :last_name, :string
    field :username, :string
    field :email, :string
    field :phone_number, :string
    field :hearing_status, :string, default: "hearing"
    field :gender, :string
    field :date_of_birth, :date
    field :access_type, :string, default: "student"

    # Authentication
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating a new learner.
  """
  def changeset(learner, attrs) do
    learner
    |> cast(attrs, [:first_name, :last_name, :username, :email, :phone_number, :hearing_status, :gender, :date_of_birth, :access_type, :password])
    |> validate_required([:first_name, :last_name, :username, :email, :password])
    |> validate_email()
    |> validate_username()
    |> validate_password()
    |> validate_hearing_status()
    |> validate_gender()
    |> validate_access_type()
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> hash_password()
  end

  @doc """
  Changeset for updating a learner.
  """
  def update_changeset(learner, attrs) do
    learner
    |> cast(attrs, [:first_name, :last_name, :username, :email, :phone_number, :hearing_status, :gender, :date_of_birth, :access_type])
    |> validate_required([:first_name, :last_name, :username, :email])
    |> validate_email()
    |> validate_username()
    |> validate_hearing_status()
    |> validate_gender()
    |> validate_access_type()
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  @doc """
  Changeset for registration (creating a new learner).
  """
  def registration_changeset(learner, attrs) do
    learner
    |> changeset(attrs)
    |> put_change(:access_type, "student")
    |> validate_required([:first_name, :last_name, :username, :email])
  end

  # Private validation functions

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end

  defp validate_username(changeset) do
    changeset
    |> validate_length(:username, min: 3, max: 50)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/, message: "must contain only letters, numbers, and underscores")
  end

  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 6, max: 72)
    |> validate_format(:password, ~r/[a-z]/, message: "must include at least one lowercase letter")
    |> validate_format(:password, ~r/[A-Z]/, message: "must include at least one uppercase letter")
    |> validate_format(:password, ~r/[0-9]/, message: "must include at least one number")
  end

  defp validate_hearing_status(changeset) do
    changeset
    |> validate_inclusion(:hearing_status, ["deaf", "hearing"], message: "must be either 'deaf' or 'hearing'")
  end

  defp validate_gender(changeset) do
    changeset
    |> validate_inclusion(:gender, ["male", "female", "other"], message: "must be 'male', 'female', or 'other'")
  end

  defp validate_access_type(changeset) do
    changeset
    |> validate_inclusion(:access_type, ["student", "teacher", "admin"], message: "must be 'student', 'teacher', or 'admin'")
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, encrypt_password(password))
      _ ->
        changeset
    end
  end

  # Password encryption and validation

  @spec encrypt_password(binary) :: binary
  def encrypt_password(password), do: Base.encode16(:crypto.hash(:sha512, password))

  def valid_password?(%Signease.Learners.Learner{password_hash: password_hash}, password)
      when is_binary(password_hash) and byte_size(password) > 0 do
    encrypt_password(password) == password_hash
  end

  def valid_password?(_, _), do: false

  # Helper functions

  def full_name(%Signease.Learners.Learner{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end

  def display_name(%Signease.Learners.Learner{username: username, first_name: first_name, last_name: last_name}) do
    if username && username != "", do: username, else: full_name(%Signease.Learners.Learner{first_name: first_name, last_name: last_name})
  end

  def deaf?(%Signease.Learners.Learner{hearing_status: "deaf"}), do: true
  def deaf?(_), do: false

  def hearing?(%Signease.Learners.Learner{hearing_status: "hearing"}), do: true
  def hearing?(_), do: false

  def student?(%Signease.Learners.Learner{access_type: "student"}), do: true
  def student?(_), do: false

  def teacher?(%Signease.Learners.Learner{access_type: "teacher"}), do: true
  def teacher?(_), do: false

  def admin?(%Signease.Learners.Learner{access_type: "admin"}), do: true
  def admin?(_), do: false
end
