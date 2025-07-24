defmodule Signease.Seeds.SetUser do
  @moduledoc """
  Seeds module for creating initial users and roles for SignEase.
  Follows the Smartpay pattern for consistent seeding across the application.
  """

  alias Signease.Repo
  alias Signease.Accounts.User
  alias Signease.Roles.UserRole

  @doc """
  Runs the user seeding process.
  Creates initial roles and users for the SignEase system.
  """
  def run do
    IO.puts("🌱 Starting SignEase user seeding process...")

    # Create roles first
    roles = create_roles()

    # Create users with the created roles
    create_users(roles)

    IO.puts("\n🎉 SignEase user seeding completed successfully!")
    print_summary()
  end

  # Private functions

  defp create_roles do
    IO.puts("\n📋 Creating initial roles...")

    roles = %{
      super_admin: create_role("Super Admin", super_admin_rights()),
      admin: create_role("Admin", admin_rights()),
      instructor: create_role("Instructor", instructor_rights()),
      support: create_role("Support", support_rights()),
      learner: create_role("Learner", learner_rights())
    }

    IO.puts("✅ All roles created/verified successfully!")
    roles
  end

  defp create_role(name, rights) do
    case Repo.get_by(UserRole, name: name) do
      nil ->
        role = %UserRole{
          name: name,
          status: "ACTIVE",
          rights: rights
        }
        case Repo.insert(role) do
          {:ok, role} ->
            IO.puts("  ✓ #{name} role created with ID: #{role.id}")
            role
          {:error, changeset} ->
            IO.puts("  ✗ Failed to create #{name} role: #{inspect(changeset.errors)}")
            exit(:error)
        end
      existing_role ->
        IO.puts("  ✓ #{name} role already exists with ID: #{existing_role.id}")
        existing_role
    end
  end

  defp create_users(roles) do
    IO.puts("\n👥 Creating initial users...")

    create_user(%{
      first_name: "Super",
      last_name: "Admin",
      email: "superadmin@signease.com",
      username: "superadmin",
      password: "SuperAdmin123!",
      user_type: "ADMIN",
      user_role: "ADMIN",
      phone: "+1234567890",
      hearing_status: "HEARING",
      learning_preferences: %{
        "speech_to_text" => true,
        "sign_language" => true,
        "visual_aids" => true,
        "audio_captions" => true
      },
      accessibility_needs: %{
        "screen_reader" => false,
        "high_contrast" => false,
        "large_text" => false,
        "keyboard_navigation" => true
      },
      preferred_language: "en",
      sign_language_skills: "FLUENT"
    }, roles.super_admin)

    create_user(%{
      first_name: "System",
      last_name: "Admin",
      email: "admin@signease.com",
      username: "admin",
      password: "Admin123!",
      user_type: "ADMIN",
      user_role: "ADMIN",
      phone: "+1234567891",
      hearing_status: "HEARING",
      learning_preferences: %{
        "speech_to_text" => true,
        "sign_language" => true,
        "visual_aids" => true,
        "audio_captions" => true
      },
      accessibility_needs: %{
        "screen_reader" => false,
        "high_contrast" => false,
        "large_text" => false,
        "keyboard_navigation" => true
      },
      preferred_language: "en",
      sign_language_skills: "ADVANCED"
    }, roles.admin)

    create_user(%{
      first_name: "John",
      last_name: "Instructor",
      email: "instructor@signease.com",
      username: "instructor",
      password: "Instructor123!",
      user_type: "INSTRUCTOR",
      user_role: "TEACHER",
      phone: "+1234567892",
      hearing_status: "HEARING",
      learning_preferences: %{
        "speech_to_text" => true,
        "sign_language" => true,
        "visual_aids" => true,
        "audio_captions" => true
      },
      accessibility_needs: %{
        "screen_reader" => false,
        "high_contrast" => false,
        "large_text" => false,
        "keyboard_navigation" => true
      },
      preferred_language: "en",
      sign_language_skills: "ADVANCED"
    }, roles.instructor)

    create_user(%{
      first_name: "Sarah",
      last_name: "Support",
      email: "support@signease.com",
      username: "support",
      password: "Support123!",
      user_type: "SUPPORT",
      user_role: "SUPPORT",
      phone: "+1234567893",
      hearing_status: "HEARING",
      learning_preferences: %{
        "speech_to_text" => true,
        "sign_language" => true,
        "visual_aids" => true,
        "audio_captions" => true
      },
      accessibility_needs: %{
        "screen_reader" => false,
        "high_contrast" => false,
        "large_text" => false,
        "keyboard_navigation" => true
      },
      preferred_language: "en",
      sign_language_skills: "INTERMEDIATE"
    }, roles.support)

    create_user(%{
      first_name: "Alex",
      last_name: "Learner",
      email: "learner@signease.com",
      username: "learner",
      password: "Learner123!",
      user_type: "LEARNER",
      user_role: "STUDENT",
      phone: "+1234567894",
      hearing_status: "DEAF",
      learning_preferences: %{
        "speech_to_text" => true,
        "sign_language" => true,
        "visual_aids" => true,
        "audio_captions" => false
      },
      accessibility_needs: %{
        "screen_reader" => false,
        "high_contrast" => true,
        "large_text" => true,
        "keyboard_navigation" => true
      },
      preferred_language: "en",
      sign_language_skills: "BEGINNER"
    }, roles.learner)

    IO.puts("✅ All users created/verified successfully!")
  end

  defp create_user(user_attrs, role) do
    case Repo.get_by(User, email: user_attrs.email) do
      nil ->
        user = %User{
          first_name: user_attrs.first_name,
          last_name: user_attrs.last_name,
          email: user_attrs.email,
          username: user_attrs.username,
          hashed_password: User.encrypt_password(user_attrs.password),
          user_type: user_attrs.user_type,
          user_role: user_attrs.user_role,
          status: "ACTIVE",
          user_status: "ACTIVE",
          approved: true,
          phone: user_attrs.phone,
          hearing_status: user_attrs.hearing_status,
          learning_preferences: user_attrs.learning_preferences,
          accessibility_needs: user_attrs.accessibility_needs,
          preferred_language: user_attrs.preferred_language,
          sign_language_skills: user_attrs.sign_language_skills,
          role_id: role.id,
          approved_by: nil,
          approved_at: DateTime.utc_now() |> DateTime.truncate(:second),
          last_pwd_update: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
        case Repo.insert(user) do
          {:ok, user} ->
            IO.puts("  ✓ #{user_attrs.first_name} #{user_attrs.last_name} user created with ID: #{user.id}")
            IO.puts("    Email: #{user.email}")
            IO.puts("    Username: #{user.username}")
            IO.puts("    Password: #{user_attrs.password}")
            user
          {:error, changeset} ->
            IO.puts("  ✗ Failed to create #{user_attrs.first_name} #{user_attrs.last_name} user: #{inspect(changeset.errors)}")
            exit(:error)
        end
      existing_user ->
        IO.puts("  ✓ #{user_attrs.first_name} #{user_attrs.last_name} user already exists with ID: #{existing_user.id}")
        existing_user
    end
  end

  defp print_summary do
    IO.puts("\n📋 Summary:")
    IO.puts("  • 5 roles created/verified (Super Admin, Admin, Instructor, Support, Learner)")
    IO.puts("  • 5 users created/verified with different roles and permissions")
    IO.puts("\n🔑 Default Login Credentials:")
    IO.puts("  Super Admin: superadmin@signease.com / SuperAdmin123!")
    IO.puts("  Admin: admin@signease.com / Admin123!")
    IO.puts("  Instructor: instructor@signease.com / Instructor123!")
    IO.puts("  Support: support@signease.com / Support123!")
    IO.puts("  Sample Learner: learner@signease.com / Learner123!")
    IO.puts("\n⚠️  IMPORTANT: Change these passwords in production!")
  end

  # Role rights definitions

  defp super_admin_rights do
    %{
      backend: %{
        dashboard: %{view: true, edit: true, delete: true},
        user_mgt: %{view: true, create: true, edit: true, delete: true, approve: true, reject: true},
        role_mgt: %{view: true, create: true, edit: true, delete: true},
        course_mgt: %{view: true, create: true, edit: true, delete: true, publish: true},
        speech_to_text: %{view: true, create: true, edit: true, delete: true, configure: true},
        sign_language: %{view: true, create: true, edit: true, delete: true, configure: true},
        accessibility: %{view: true, create: true, edit: true, delete: true, configure: true},
        qa_system: %{view: true, create: true, edit: true, delete: true, moderate: true},
        analytics: %{view: true, export: true, configure: true},
        settings: %{view: true, edit: true, configure: true},
        system_mgt: %{view: true, edit: true, configure: true, backup: true, restore: true}
      },
      frontend: %{
        dashboard: %{view: true, edit: true, delete: true},
        user_mgt: %{view: true, create: true, edit: true, delete: true, approve: true, reject: true},
        role_mgt: %{view: true, create: true, edit: true, delete: true},
        course_mgt: %{view: true, create: true, edit: true, delete: true, publish: true},
        speech_to_text: %{view: true, create: true, edit: true, delete: true, configure: true},
        sign_language: %{view: true, create: true, edit: true, delete: true, configure: true},
        accessibility: %{view: true, create: true, edit: true, delete: true, configure: true},
        qa_system: %{view: true, create: true, edit: true, delete: true, moderate: true},
        analytics: %{view: true, export: true, configure: true},
        settings: %{view: true, edit: true, configure: true},
        system_mgt: %{view: true, edit: true, configure: true, backup: true, restore: true}
      }
    }
  end

  defp admin_rights do
    %{
      backend: %{
        dashboard: %{view: true, edit: true},
        user_mgt: %{view: true, create: true, edit: true, approve: true, reject: true},
        role_mgt: %{view: true},
        course_mgt: %{view: true, create: true, edit: true, delete: true, publish: true},
        speech_to_text: %{view: true, create: true, edit: true, configure: true},
        sign_language: %{view: true, create: true, edit: true, configure: true},
        accessibility: %{view: true, create: true, edit: true, configure: true},
        qa_system: %{view: true, create: true, edit: true, moderate: true},
        analytics: %{view: true, export: true},
        settings: %{view: true, edit: true}
      },
      frontend: %{
        dashboard: %{view: true, edit: true},
        user_mgt: %{view: true, create: true, edit: true, approve: true, reject: true},
        role_mgt: %{view: true},
        course_mgt: %{view: true, create: true, edit: true, delete: true, publish: true},
        speech_to_text: %{view: true, create: true, edit: true, configure: true},
        sign_language: %{view: true, create: true, edit: true, configure: true},
        accessibility: %{view: true, create: true, edit: true, configure: true},
        qa_system: %{view: true, create: true, edit: true, moderate: true},
        analytics: %{view: true, export: true},
        settings: %{view: true, edit: true}
      }
    }
  end

  defp instructor_rights do
    %{
      backend: %{
        dashboard: %{view: true},
        user_mgt: %{view: true},
        course_mgt: %{view: true, create: true, edit: true},
        speech_to_text: %{view: true, create: true, edit: true},
        sign_language: %{view: true, create: true, edit: true},
        accessibility: %{view: true, create: true, edit: true},
        qa_system: %{view: true, create: true, edit: true},
        analytics: %{view: true}
      },
      frontend: %{
        dashboard: %{view: true},
        user_mgt: %{view: true},
        course_mgt: %{view: true, create: true, edit: true},
        speech_to_text: %{view: true, create: true, edit: true},
        sign_language: %{view: true, create: true, edit: true},
        accessibility: %{view: true, create: true, edit: true},
        qa_system: %{view: true, create: true, edit: true},
        analytics: %{view: true}
      }
    }
  end

  defp support_rights do
    %{
      backend: %{
        dashboard: %{view: true},
        user_mgt: %{view: true, edit: true},
        course_mgt: %{view: true},
        speech_to_text: %{view: true},
        sign_language: %{view: true},
        accessibility: %{view: true},
        qa_system: %{view: true, moderate: true},
        analytics: %{view: true}
      },
      frontend: %{
        dashboard: %{view: true},
        user_mgt: %{view: true, edit: true},
        course_mgt: %{view: true},
        speech_to_text: %{view: true},
        sign_language: %{view: true},
        accessibility: %{view: true},
        qa_system: %{view: true, moderate: true},
        analytics: %{view: true}
      }
    }
  end

  defp learner_rights do
    %{
      backend: %{
        dashboard: %{view: true},
        course_mgt: %{view: true},
        speech_to_text: %{view: true},
        sign_language: %{view: true},
        accessibility: %{view: true},
        qa_system: %{view: true, create: true}
      },
      frontend: %{
        dashboard: %{view: true},
        course_mgt: %{view: true},
        speech_to_text: %{view: true},
        sign_language: %{view: true},
        accessibility: %{view: true},
        qa_system: %{view: true, create: true}
      }
    }
  end
end
