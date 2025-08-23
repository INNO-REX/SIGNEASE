defmodule Signease.Learning.CourseEnrollment do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "course_enrollments" do
    field :enrollment_date, :date
    field :completion_date, :date
    field :status, :string, default: "ENROLLED"
    field :progress_percentage, :decimal, default: Decimal.new(0)
    field :grade, :string
    field :certificate_issued, :boolean, default: false
    field :certificate_issued_at, :utc_datetime
    field :notes, :string
    field :deleted_at, :utc_datetime

    # Associations
    belongs_to :course, Signease.Learning.Course
    belongs_to :learner, Signease.Accounts.User, foreign_key: :learner_id
    belongs_to :enroller, Signease.Accounts.User, foreign_key: :enrolled_by
    belongs_to :creator, Signease.Accounts.User, foreign_key: :created_by
    belongs_to :updater, Signease.Accounts.User, foreign_key: :updated_by
    belongs_to :deleter, Signease.Accounts.User, foreign_key: :deleted_by

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course_enrollment, attrs) do
    course_enrollment
    |> cast(attrs, [
      :course_id, :learner_id, :enrollment_date, :completion_date,
      :status, :progress_percentage, :grade, :certificate_issued,
      :certificate_issued_at, :notes, :enrolled_by,
      :created_by, :updated_by
    ])
    |> validate_required([:course_id, :learner_id, :enrollment_date])
    |> validate_inclusion(:status, ["ENROLLED", "IN_PROGRESS", "COMPLETED", "WITHDRAWN", "SUSPENDED"])
    |> validate_inclusion(:grade, ["A+", "A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D+", "D", "D-", "F", "PASS", "FAIL"])
    |> validate_number(:progress_percentage, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> validate_date_range()
    |> unique_constraint([:course_id, :learner_id], name: :unique_course_learner_enrollment)
    |> foreign_key_constraint(:course_id)
    |> foreign_key_constraint(:learner_id)
    |> foreign_key_constraint(:enrolled_by)
  end

  defp validate_date_range(changeset) do
    case {get_field(changeset, :enrollment_date), get_field(changeset, :completion_date)} do
      {enrollment_date, completion_date} when not is_nil(enrollment_date) and not is_nil(completion_date) ->
        if Date.compare(enrollment_date, completion_date) == :gt do
          add_error(changeset, :completion_date, "must be after enrollment date")
        else
          changeset
        end
      _ ->
        changeset
    end
  end

  # Queries
  def by_course(course_id) do
    from(ce in __MODULE__,
      where: ce.course_id == ^course_id and is_nil(ce.deleted_at),
      order_by: [desc: ce.enrollment_date]
    )
  end

  def by_learner(learner_id) do
    from(ce in __MODULE__,
      where: ce.learner_id == ^learner_id and is_nil(ce.deleted_at),
      order_by: [desc: ce.enrollment_date]
    )
  end

  def active_enrollments do
    from(ce in __MODULE__,
      where: ce.status in ["ENROLLED", "IN_PROGRESS"] and is_nil(ce.deleted_at),
      order_by: [desc: ce.enrollment_date]
    )
  end

  def completed_enrollments do
    from(ce in __MODULE__,
      where: ce.status == "COMPLETED" and is_nil(ce.deleted_at),
      order_by: [desc: ce.completion_date]
    )
  end

  def with_course_and_learner do
    from(ce in __MODULE__,
      left_join: c in assoc(ce, :course),
      left_join: l in assoc(ce, :learner),
      where: is_nil(ce.deleted_at),
      preload: [course: c, learner: l],
      order_by: [desc: ce.enrollment_date]
    )
  end
end
