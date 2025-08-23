defmodule Signease.Seeds.SetLearning do
  @moduledoc """
  Seeds module for creating initial learning programs and courses for SignEase.
  """

  alias Signease.Repo
  alias Signease.Learning
  alias Signease.Accounts

  @doc """
  Runs the learning seeding process.
  Creates initial programs and courses for the SignEase system.
  """
  def run do
    IO.puts("🌱 Starting SignEase learning seeding process...")

    # Get existing users
    instructor = Repo.get_by(Accounts.User, email: "instructor@signease.com")
    admin = Repo.get_by(Accounts.User, email: "admin@signease.com")

    if is_nil(instructor) or is_nil(admin) do
      IO.puts("❌ Required users not found. Please run user seeds first.")
      exit(:error)
    end

    # Create programs first
    programs = create_programs(admin.id)

    # Create courses within programs
    create_courses(programs, instructor.id, admin.id)

    IO.puts("\n🎉 SignEase learning seeding completed successfully!")
    print_summary()
  end

  # Private functions

  defp create_programs(admin_id) do
    IO.puts("\n📚 Creating initial programs...")

    program_data = [
      %{
        name: "American Sign Language (ASL) Fundamentals",
        description: "A comprehensive introduction to American Sign Language for beginners. Learn basic vocabulary, grammar, and conversational skills.",
        code: "ASL101",
        duration_weeks: 12,
        max_learners: 25,
        status: "ACTIVE",
        start_date: ~D[2024-01-15],
        end_date: ~D[2024-04-15]
      },
      %{
        name: "Deaf Culture and Communication",
        description: "Explore the rich culture of the Deaf community and learn effective communication strategies.",
        code: "DCC201",
        duration_weeks: 8,
        max_learners: 20,
        status: "ACTIVE",
        start_date: ~D[2024-02-01],
        end_date: ~D[2024-03-29]
      },
      %{
        name: "Advanced ASL Interpretation",
        description: "Advanced training for ASL interpreters focusing on professional settings and specialized vocabulary.",
        code: "ASL301",
        duration_weeks: 16,
        max_learners: 15,
        status: "ACTIVE",
        start_date: ~D[2024-01-22],
        end_date: ~D[2024-05-20]
      }
    ]

    programs = Enum.map(program_data, fn program_attrs ->
      program_attrs = Map.put(program_attrs, :created_by, admin_id)

      case Repo.get_by(Learning.Program, code: program_attrs.code) do
        nil ->
          case Learning.create_program(program_attrs) do
            {:ok, program} ->
              IO.puts("  ✓ #{program.name} program created with ID: #{program.id}")
              program
            {:error, changeset} ->
              IO.puts("  ✗ Failed to create #{program_attrs.name} program: #{inspect(changeset.errors)}")
              exit(:error)
          end
        existing_program ->
          IO.puts("  ✓ #{existing_program.name} program already exists with ID: #{existing_program.id}")
          existing_program
      end
    end)

    IO.puts("✅ All programs created/verified successfully!")
    programs
  end

  defp create_courses(programs, instructor_id, admin_id) do
    IO.puts("\n📖 Creating initial courses...")

    course_data = [
      # ASL Fundamentals Program Courses
      %{
        name: "ASL Alphabet and Numbers",
        description: "Learn the ASL alphabet, numbers 1-100, and basic finger spelling techniques.",
        code: "ASL101-01",
        program_id: Enum.find(programs, &(&1.code == "ASL101")).id,
        instructor_id: instructor_id,
        duration_hours: 24,
        difficulty_level: "BEGINNER",
        max_students: 25,
        prerequisites: "None",
        learning_objectives: "Master ASL alphabet, numbers 1-100, and basic finger spelling"
      },
      %{
        name: "Basic ASL Vocabulary",
        description: "Essential everyday vocabulary including greetings, family, colors, and common phrases.",
        code: "ASL101-02",
        program_id: Enum.find(programs, &(&1.code == "ASL101")).id,
        instructor_id: instructor_id,
        duration_hours: 32,
        difficulty_level: "BEGINNER",
        max_students: 25,
        prerequisites: "ASL101-01",
        learning_objectives: "Build essential ASL vocabulary for daily communication"
      },
      %{
        name: "ASL Grammar and Sentence Structure",
        description: "Learn ASL grammar rules, sentence structure, and how to form basic sentences.",
        code: "ASL101-03",
        program_id: Enum.find(programs, &(&1.code == "ASL101")).id,
        instructor_id: instructor_id,
        duration_hours: 28,
        difficulty_level: "BEGINNER",
        max_students: 25,
        prerequisites: "ASL101-01, ASL101-02",
        learning_objectives: "Understand ASL grammar and construct basic sentences"
      },

      # Deaf Culture Program Courses
      %{
        name: "Introduction to Deaf Culture",
        description: "Explore the history, values, and traditions of Deaf culture.",
        code: "DCC201-01",
        program_id: Enum.find(programs, &(&1.code == "DCC201")).id,
        instructor_id: instructor_id,
        duration_hours: 20,
        difficulty_level: "BEGINNER",
        max_students: 20,
        prerequisites: "Basic ASL knowledge recommended",
        learning_objectives: "Understand Deaf culture, history, and community values"
      },
      %{
        name: "Effective Communication Strategies",
        description: "Learn strategies for effective communication with Deaf individuals in various settings.",
        code: "DCC201-02",
        program_id: Enum.find(programs, &(&1.code == "DCC201")).id,
        instructor_id: instructor_id,
        duration_hours: 24,
        difficulty_level: "INTERMEDIATE",
        max_students: 20,
        prerequisites: "DCC201-01",
        learning_objectives: "Develop effective communication strategies for Deaf individuals"
      },

      # Advanced ASL Program Courses
      %{
        name: "Professional ASL Vocabulary",
        description: "Specialized vocabulary for professional settings including medical, legal, and educational contexts.",
        code: "ASL301-01",
        program_id: Enum.find(programs, &(&1.code == "ASL301")).id,
        instructor_id: instructor_id,
        duration_hours: 36,
        difficulty_level: "ADVANCED",
        max_students: 15,
        prerequisites: "ASL101 completion or equivalent",
        learning_objectives: "Master professional ASL vocabulary for various work environments"
      },
      %{
        name: "ASL Interpretation Techniques",
        description: "Advanced interpretation skills including simultaneous and consecutive interpreting.",
        code: "ASL301-02",
        program_id: Enum.find(programs, &(&1.code == "ASL301")).id,
        instructor_id: instructor_id,
        duration_hours: 40,
        difficulty_level: "EXPERT",
        max_students: 15,
        prerequisites: "ASL301-01",
        learning_objectives: "Develop professional ASL interpretation skills"
      }
    ]

    Enum.each(course_data, fn course_attrs ->
      course_attrs = Map.merge(course_attrs, %{
        created_by: admin_id,
        status: "ACTIVE"
      })

      case Repo.get_by(Learning.Course, code: course_attrs.code) do
        nil ->
          case Learning.create_course(course_attrs) do
            {:ok, course} ->
              IO.puts("  ✓ #{course.name} course created with ID: #{course.id}")
            {:error, changeset} ->
              IO.puts("  ✗ Failed to create #{course_attrs.name} course: #{inspect(changeset.errors)}")
              exit(:error)
          end
        existing_course ->
          IO.puts("  ✓ #{existing_course.name} course already exists with ID: #{existing_course.id}")
      end
    end)

    IO.puts("✅ All courses created/verified successfully!")
  end

  defp print_summary do
    IO.puts("\n📋 Summary:")
    IO.puts("  • 3 programs created/verified (ASL Fundamentals, Deaf Culture, Advanced ASL)")
    IO.puts("  • 7 courses created/verified across all programs")
    IO.puts("  • Programs cover beginner to expert levels")
    IO.puts("  • Courses include prerequisites and learning objectives")
    IO.puts("\n🎯 Programs Available:")
    IO.puts("  • ASL101: American Sign Language (ASL) Fundamentals (12 weeks)")
    IO.puts("  • DCC201: Deaf Culture and Communication (8 weeks)")
    IO.puts("  • ASL301: Advanced ASL Interpretation (16 weeks)")
  end
end
