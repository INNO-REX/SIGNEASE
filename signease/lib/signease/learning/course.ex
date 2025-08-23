defmodule Signease.Learning.Course do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "courses" do
    field :name, :string
    field :description, :string
    field :code, :string
    field :duration_hours, :integer
    field :difficulty_level, :string, default: "BEGINNER"
    field :status, :string, default: "ACTIVE"
    field :max_students, :integer
    field :prerequisites, :string
    field :learning_objectives, :string
    field :deleted_at, :utc_datetime

    # Associations
    belongs_to :program, Signease.Learning.Program
    belongs_to :instructor, Signease.Accounts.User, foreign_key: :instructor_id
    belongs_to :creator, Signease.Accounts.User, foreign_key: :created_by
    belongs_to :updater, Signease.Accounts.User, foreign_key: :updated_by
    belongs_to :deleter, Signease.Accounts.User, foreign_key: :deleted_by
    has_many :course_enrollments, Signease.Learning.CourseEnrollment
    has_many :enrolled_learners, through: [:course_enrollments, :learner]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [
      :name, :description, :code, :program_id, :instructor_id, :duration_hours,
      :difficulty_level, :status, :max_students, :prerequisites, :learning_objectives,
      :created_by, :updated_by
    ])
    |> validate_required([:name, :code, :program_id])
    |> validate_length(:name, min: 2, max: 255)
    |> validate_length(:code, min: 2, max: 50)
    |> validate_number(:duration_hours, greater_than: 0)
    |> validate_number(:max_students, greater_than: 0)
    |> validate_inclusion(:difficulty_level, ["BEGINNER", "INTERMEDIATE", "ADVANCED", "EXPERT"])
    |> validate_inclusion(:status, ["ACTIVE", "INACTIVE", "COMPLETED", "CANCELLED"])
    |> unique_constraint(:code, name: :unique_course_code)
    |> foreign_key_constraint(:program_id)
    |> foreign_key_constraint(:instructor_id)
  end

  # Queries
  def active_courses do
    from(c in __MODULE__,
      where: c.status == "ACTIVE" and is_nil(c.deleted_at),
      order_by: [asc: c.name]
    )
  end

  def by_program(program_id) do
    from(c in __MODULE__,
      where: c.program_id == ^program_id and is_nil(c.deleted_at),
      order_by: [asc: c.name]
    )
  end

  def by_instructor(instructor_id) do
    from(c in __MODULE__,
      where: c.instructor_id == ^instructor_id and is_nil(c.deleted_at),
      order_by: [asc: c.name]
    )
  end

  def with_program_and_instructor do
    from(c in __MODULE__,
      left_join: p in assoc(c, :program),
      left_join: i in assoc(c, :instructor),
      where: is_nil(c.deleted_at),
      preload: [program: p, instructor: i],
      order_by: [asc: c.name]
    )
  end

  def with_enrollments do
    from(c in __MODULE__,
      left_join: ce in assoc(c, :course_enrollments),
      left_join: l in assoc(ce, :learner),
      where: is_nil(c.deleted_at),
      preload: [course_enrollments: {ce, learner: l}],
      order_by: [asc: c.name]
    )
  end
end
