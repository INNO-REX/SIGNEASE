defmodule Signease.Learning.ProgramEnrollment do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "program_enrollments" do
    field :enrollment_date, :date
    field :completion_date, :date
    field :status, :string, default: "ENROLLED"
    field :progress_percentage, :decimal, default: Decimal.new(0)
    field :notes, :string
    field :deleted_at, :utc_datetime

    # Associations
    belongs_to :program, Signease.Learning.Program
    belongs_to :learner, Signease.Accounts.User, foreign_key: :learner_id
    belongs_to :enroller, Signease.Accounts.User, foreign_key: :enrolled_by
    belongs_to :creator, Signease.Accounts.User, foreign_key: :created_by
    belongs_to :updater, Signease.Accounts.User, foreign_key: :updated_by
    belongs_to :deleter, Signease.Accounts.User, foreign_key: :deleted_by

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(program_enrollment, attrs) do
    program_enrollment
    |> cast(attrs, [
      :program_id, :learner_id, :enrollment_date, :completion_date,
      :status, :progress_percentage, :notes, :enrolled_by,
      :created_by, :updated_by
    ])
    |> validate_required([:program_id, :learner_id, :enrollment_date])
    |> validate_inclusion(:status, ["ENROLLED", "IN_PROGRESS", "COMPLETED", "WITHDRAWN", "SUSPENDED"])
    |> validate_number(:progress_percentage, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> validate_date_range()
    |> unique_constraint([:program_id, :learner_id], name: :unique_program_learner_enrollment)
    |> foreign_key_constraint(:program_id)
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
  def by_program(program_id) do
    from(pe in __MODULE__,
      where: pe.program_id == ^program_id and is_nil(pe.deleted_at),
      order_by: [desc: pe.enrollment_date]
    )
  end

  def by_learner(learner_id) do
    from(pe in __MODULE__,
      where: pe.learner_id == ^learner_id and is_nil(pe.deleted_at),
      order_by: [desc: pe.enrollment_date]
    )
  end

  def active_enrollments do
    from(pe in __MODULE__,
      where: pe.status in ["ENROLLED", "IN_PROGRESS"] and is_nil(pe.deleted_at),
      order_by: [desc: pe.enrollment_date]
    )
  end

  def with_program_and_learner do
    from(pe in __MODULE__,
      left_join: p in assoc(pe, :program),
      left_join: l in assoc(pe, :learner),
      where: is_nil(pe.deleted_at),
      preload: [program: p, learner: l],
      order_by: [desc: pe.enrollment_date]
    )
  end
end
