defmodule Signease.Learning do
  @moduledoc """
  The Learning context.
  """

  import Ecto.Query, warn: false
  alias Signease.Repo

  # Program functions
  alias Signease.Learning.Program
  alias Signease.Learning.Course
  alias Signease.Learning.ProgramEnrollment
  alias Signease.Learning.CourseEnrollment

  @doc """
  Returns the list of programs.
  """
  def list_programs do
    Repo.all(Program)
  end

  @doc """
  Returns the list of active programs.
  """
  def list_active_programs do
    Repo.all(Program.active_programs())
  end

  @doc """
  Gets a single program.
  """
  def get_program!(id), do: Repo.get!(Program, id)

  @doc """
  Gets a single program with courses.
  """
  def get_program_with_courses!(id) do
    Repo.one!(Program.with_courses() |> where([p], p.id == ^id))
  end

  @doc """
  Gets a single program with enrollments.
  """
  def get_program_with_enrollments!(id) do
    Repo.one!(Program.with_enrollments() |> where([p], p.id == ^id))
  end

  @doc """
  Creates a program.
  """
  def create_program(attrs \\ %{}) do
    %Program{}
    |> Program.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a program.
  """
  def update_program(%Program{} = program, attrs) do
    program
    |> Program.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a program.
  """
  def delete_program(%Program{} = program, user_id) do
    program
    |> Ecto.Changeset.change(%{deleted_by: user_id, deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  # Course functions
  @doc """
  Returns the list of courses.
  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
  Returns the list of active courses.
  """
  def list_active_courses do
    Repo.all(Course.active_courses())
  end

  @doc """
  Returns the list of courses by program.
  """
  def list_courses_by_program(program_id) do
    Repo.all(Course.by_program(program_id))
  end

  @doc """
  Returns the list of courses by instructor.
  """
  def list_courses_by_instructor(instructor_id) do
    Repo.all(Course.by_instructor(instructor_id))
  end

  @doc """
  Gets a single course.
  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Gets a single course with program and instructor.
  """
  def get_course_with_program_and_instructor!(id) do
    Repo.one!(Course.with_program_and_instructor() |> where([c], c.id == ^id))
  end

  @doc """
  Creates a course.
  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.
  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course.
  """
  def delete_course(%Course{} = course, user_id) do
    course
    |> Ecto.Changeset.change(%{deleted_by: user_id, deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  # Program Enrollment functions
  @doc """
  Returns the list of program enrollments.
  """
  def list_program_enrollments do
    Repo.all(ProgramEnrollment)
  end

  @doc """
  Returns the list of program enrollments by program.
  """
  def list_program_enrollments_by_program(program_id) do
    Repo.all(ProgramEnrollment.by_program(program_id))
  end

  @doc """
  Returns the list of program enrollments by learner.
  """
  def list_program_enrollments_by_learner(learner_id) do
    Repo.all(ProgramEnrollment.by_learner(learner_id))
  end

  @doc """
  Gets a single program enrollment.
  """
  def get_program_enrollment!(id), do: Repo.get!(ProgramEnrollment, id)

  @doc """
  Creates a program enrollment.
  """
  def create_program_enrollment(attrs \\ %{}) do
    %ProgramEnrollment{}
    |> ProgramEnrollment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a program enrollment.
  """
  def update_program_enrollment(%ProgramEnrollment{} = enrollment, attrs) do
    enrollment
    |> ProgramEnrollment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a program enrollment.
  """
  def delete_program_enrollment(%ProgramEnrollment{} = enrollment, user_id) do
    enrollment
    |> Ecto.Changeset.change(%{deleted_by: user_id, deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  # Course Enrollment functions
  @doc """
  Returns the list of course enrollments.
  """
  def list_course_enrollments do
    Repo.all(CourseEnrollment)
  end

  @doc """
  Returns the list of course enrollments by course.
  """
  def list_course_enrollments_by_course(course_id) do
    Repo.all(CourseEnrollment.by_course(course_id))
  end

  @doc """
  Returns the list of course enrollments by learner.
  """
  def list_course_enrollments_by_learner(learner_id) do
    Repo.all(CourseEnrollment.by_learner(learner_id))
  end

  @doc """
  Gets a single course enrollment.
  """
  def get_course_enrollment!(id), do: Repo.get!(CourseEnrollment, id)

  @doc """
  Creates a course enrollment.
  """
  def create_course_enrollment(attrs \\ %{}) do
    %CourseEnrollment{}
    |> CourseEnrollment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course enrollment.
  """
  def update_course_enrollment(%CourseEnrollment{} = enrollment, attrs) do
    enrollment
    |> CourseEnrollment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course enrollment.
  """
  def delete_course_enrollment(%CourseEnrollment{} = enrollment, user_id) do
    enrollment
    |> Ecto.Changeset.change(%{deleted_by: user_id, deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  # Utility functions
  @doc """
  Assigns an instructor to a course.
  """
  def assign_instructor_to_course(course_id, instructor_id, user_id) do
    get_course!(course_id)
    |> update_course(%{instructor_id: instructor_id, updated_by: user_id})
  end

  @doc """
  Enrolls a learner in a program.
  """
  def enroll_learner_in_program(program_id, learner_id, user_id) do
    create_program_enrollment(%{
      program_id: program_id,
      learner_id: learner_id,
      enrollment_date: Date.utc_today(),
      enrolled_by: user_id,
      created_by: user_id
    })
  end

  @doc """
  Enrolls a learner in a course.
  """
  def enroll_learner_in_course(course_id, learner_id, user_id) do
    create_course_enrollment(%{
      course_id: course_id,
      learner_id: learner_id,
      enrollment_date: Date.utc_today(),
      enrolled_by: user_id,
      created_by: user_id
    })
  end

  @doc """
  Updates enrollment progress.
  """
  def update_enrollment_progress(enrollment_type, enrollment_id, progress_percentage, user_id) do
    case enrollment_type do
      :program ->
        get_program_enrollment!(enrollment_id)
        |> update_program_enrollment(%{progress_percentage: progress_percentage, updated_by: user_id})
      
      :course ->
        get_course_enrollment!(enrollment_id)
        |> update_course_enrollment(%{progress_percentage: progress_percentage, updated_by: user_id})
    end
  end

  # Statistics functions
  @doc """
  Returns the count of programs.
  """
  def count_programs do
    Repo.aggregate(Program, :count, :id)
  end

  @doc """
  Returns the count of active programs.
  """
  def count_active_programs do
    Program.active_programs()
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Returns the count of courses.
  """
  def count_courses do
    Repo.aggregate(Course, :count, :id)
  end

  @doc """
  Returns the count of all enrollments.
  """
  def count_enrollments do
    program_enrollments = Repo.aggregate(ProgramEnrollment, :count, :id)
    course_enrollments = Repo.aggregate(CourseEnrollment, :count, :id)
    program_enrollments + course_enrollments
  end
end
