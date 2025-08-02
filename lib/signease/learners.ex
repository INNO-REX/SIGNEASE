defmodule Signease.Learners do
  @moduledoc """
  The Learners context.
  """

  import Ecto.Query, warn: false
  alias Signease.Repo
  alias Signease.Learners.Learner

  @doc """
  Returns the list of learners.
  """
  def list_learners do
    Repo.all(Learner)
  end

  @doc """
  Returns the list of learners with pagination and filtering.
  """
  def list_learners_with_pagination(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    filters = Keyword.get(opts, :filters, %{})

    Learner
    |> apply_filters(filters)
    |> apply_sorting(Keyword.get(opts, :sort_by, :inserted_at), Keyword.get(opts, :sort_order, :desc))
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
    |> then(fn learners ->
      total_count = get_total_count(filters)
      %{
        learners: learners,
        pagination: %{
          current_page: page,
          per_page: per_page,
          total_count: total_count,
          total_pages: ceil(total_count / per_page),
          has_prev: page > 1,
          has_next: page < ceil(total_count / per_page)
        }
      }
    end)
  end

  @doc """
  Gets a single learner.
  """
  def get_learner!(id), do: Repo.get!(Learner, id)

  @doc """
  Gets a single learner.
  """
  def get_learner(id), do: Repo.get(Learner, id)

  @doc """
  Gets a learner by email.
  """
  def get_learner_by_email(email) when is_binary(email) do
    Repo.get_by(Learner, email: email)
  end

  @doc """
  Gets a learner by username.
  """
  def get_learner_by_username(username) when is_binary(username) do
    Repo.get_by(Learner, username: username)
  end

  @doc """
  Gets a learner by email and password.
  """
  def get_learner_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    learner = Repo.get_by(Learner, email: email)
    if Learner.valid_password?(learner, password), do: learner
  end

  @doc """
  Gets a learner by username and password.
  """
  def get_learner_by_username_and_password(username, password)
      when is_binary(username) and is_binary(password) do
    learner = Repo.get_by(Learner, username: username)
    if Learner.valid_password?(learner, password), do: learner
  end

  @doc """
  Creates a learner.
  """
  def create_learner(attrs \\ %{}) do
    %Learner{}
    |> Learner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Registers a new learner with auto-generated password.
  """
  def register_learner(attrs \\ %{}) do
    # Generate a random password
    generated_password = generate_random_password()

    # Add the generated password to the attributes
    attrs_with_password = Map.put(attrs, "password", generated_password)

    case %Learner{}
         |> Learner.registration_changeset(attrs_with_password)
         |> Repo.insert() do
      {:ok, learner} ->
        # Return the learner with the generated password for display
        {:ok, Map.put(learner, :generated_password, generated_password)}
      error -> error
    end
  end

  @doc """
  Generates a random password.
  """
  def generate_random_password do
    # Generate a 12-character password with letters, numbers, and symbols
    :crypto.strong_rand_bytes(8)
    |> Base.encode16()
    |> binary_part(0, 12)
  end

  @doc """
  Updates a learner.
  """
  def update_learner(%Learner{} = learner, attrs) do
    learner
    |> Learner.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a learner.
  """
  def delete_learner(%Learner{} = learner) do
    Repo.delete(learner)
  end

  @doc """
  Gets learners by hearing status.
  """
  def get_learners_by_hearing_status(hearing_status) do
    Repo.all(from l in Learner, where: l.hearing_status == ^hearing_status)
  end

  @doc """
  Gets learners by access type.
  """
  def get_learners_by_access_type(access_type) do
    Repo.all(from l in Learner, where: l.access_type == ^access_type)
  end

  @doc """
  Gets learners by gender.
  """
  def get_learners_by_gender(gender) do
    Repo.all(from l in Learner, where: l.gender == ^gender)
  end

  @doc """
  Gets learners by date of birth range.
  """
  def get_learners_by_date_of_birth_range(from_date, to_date) do
    Repo.all(from l in Learner, where: l.date_of_birth >= ^from_date and l.date_of_birth <= ^to_date)
  end

  @doc """
  Gets learner statistics.
  """
  def get_learner_stats do
    total_count = Repo.aggregate(Learner, :count, :id)
    hearing_count = Repo.aggregate(from(l in Learner, where: l.hearing_status == "hearing"), :count, :id)
    deaf_count = Repo.aggregate(from(l in Learner, where: l.hearing_status == "deaf"), :count, :id)
    student_count = Repo.aggregate(from(l in Learner, where: l.access_type == "student"), :count, :id)
    teacher_count = Repo.aggregate(from(l in Learner, where: l.access_type == "teacher"), :count, :id)
    admin_count = Repo.aggregate(from(l in Learner, where: l.access_type == "admin"), :count, :id)

    %{
      total_learners: total_count,
      hearing_learners: hearing_count,
      deaf_learners: deaf_count,
      students: student_count,
      teachers: teacher_count,
      admins: admin_count
    }
  end

  # Private functions

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      case {key, value} do
        {:search, search} when is_binary(search) and byte_size(search) > 0 ->
          search_term = "%#{search}%"
          from(l in acc,
            where: ilike(l.first_name, ^search_term) or
                   ilike(l.last_name, ^search_term) or
                   ilike(l.username, ^search_term) or
                   ilike(l.email, ^search_term)
          )

        {:hearing_status, status} when is_binary(status) and byte_size(status) > 0 ->
          from(l in acc, where: l.hearing_status == ^status)

        {:gender, gender} when is_binary(gender) and byte_size(gender) > 0 ->
          from(l in acc, where: l.gender == ^gender)

        {:access_type, access_type} when is_binary(access_type) and byte_size(access_type) > 0 ->
          from(l in acc, where: l.access_type == ^access_type)

        _ ->
          acc
      end
    end)
  end

  defp apply_sorting(query, sort_by, sort_order) do
    case sort_by do
      :first_name -> from(l in query, order_by: [{^sort_order, l.first_name}])
      :last_name -> from(l in query, order_by: [{^sort_order, l.last_name}])
      :username -> from(l in query, order_by: [{^sort_order, l.username}])
      :email -> from(l in query, order_by: [{^sort_order, l.email}])
      :hearing_status -> from(l in query, order_by: [{^sort_order, l.hearing_status}])
      :access_type -> from(l in query, order_by: [{^sort_order, l.access_type}])
      :date_of_birth -> from(l in query, order_by: [{^sort_order, l.date_of_birth}])
      _ -> from(l in query, order_by: [{^sort_order, l.inserted_at}])
    end
  end

  defp get_total_count(filters) do
    Learner
    |> apply_filters(filters)
    |> Repo.aggregate(:count, :id)
  end
end
