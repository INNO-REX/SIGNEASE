defmodule Signease.Learning.Program do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "programs" do
    field :name, :string
    field :description, :string
    field :code, :string
    field :duration_weeks, :integer
    field :max_learners, :integer
    field :status, :string, default: "ACTIVE"
    field :start_date, :date
    field :end_date, :date
    field :deleted_at, :utc_datetime

    # Associations
    belongs_to :creator, Signease.Accounts.User, foreign_key: :created_by
    belongs_to :updater, Signease.Accounts.User, foreign_key: :updated_by
    belongs_to :deleter, Signease.Accounts.User, foreign_key: :deleted_by
    has_many :courses, Signease.Learning.Course
    has_many :program_enrollments, Signease.Learning.ProgramEnrollment
    has_many :enrolled_learners, through: [:program_enrollments, :learner]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(program, attrs) do
    program
    |> cast(attrs, [
      :name, :description, :code, :duration_weeks, :max_learners,
      :status, :start_date, :end_date, :created_by, :updated_by
    ])
    |> validate_required([:name, :code])
    |> validate_length(:name, min: 2, max: 255)
    |> validate_length(:code, min: 2, max: 50)
    |> validate_number(:duration_weeks, greater_than: 0)
    |> validate_number(:max_learners, greater_than: 0)
    |> validate_inclusion(:status, ["ACTIVE", "INACTIVE", "COMPLETED", "CANCELLED"])
    |> validate_date_range()
    |> unique_constraint(:code, name: :unique_program_code)
  end

  defp validate_date_range(changeset) do
    case {get_field(changeset, :start_date), get_field(changeset, :end_date)} do
      {start_date, end_date} when not is_nil(start_date) and not is_nil(end_date) ->
        if Date.compare(start_date, end_date) == :gt do
          add_error(changeset, :end_date, "must be after start date")
        else
          changeset
        end
      _ ->
        changeset
    end
  end

  # Queries
  def active_programs do
    from(p in __MODULE__,
      where: p.status == "ACTIVE" and is_nil(p.deleted_at),
      order_by: [asc: p.name]
    )
  end

  def with_courses do
    from(p in __MODULE__,
      left_join: c in assoc(p, :courses),
      where: is_nil(p.deleted_at),
      preload: [courses: c],
      order_by: [asc: p.name]
    )
  end

  def with_enrollments do
    from(p in __MODULE__,
      left_join: pe in assoc(p, :program_enrollments),
      left_join: l in assoc(pe, :learner),
      where: is_nil(p.deleted_at),
      preload: [program_enrollments: {pe, learner: l}],
      order_by: [asc: p.name]
    )
  end
end
