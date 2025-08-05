defmodule SigneaseWeb.Admin.Users.Components.LearnerFormComponent do
  use SigneaseWeb, :live_component

  alias Signease.Accounts
  alias Signease.Accounts.User
  alias Signease.Notifications

  @impl true
  def update(%{id: id} = assigns, socket) do
    if id == :new do
      # Create a changeset without validation to avoid showing errors initially
      changeset = %User{}
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:user_type, "LEARNER")
      |> Ecto.Changeset.put_change(:user_role, "STUDENT")
      |> Ecto.Changeset.put_change(:status, "ACTIVE")
      |> Ecto.Changeset.put_change(:user_status, "ACTIVE")
      |> Ecto.Changeset.put_change(:approved, true)

      {:ok,
       socket
       |> assign(assigns)
       |> assign(:user, %User{})
       |> assign(:changeset, changeset)
       |> assign(:current_step, 1)
       |> assign(:validation_errors, [])
       |> assign(:show_errors, false)
       |> assign(:title, "Learner Registration")
       |> assign(:page_title, "New Learner")}
    else
      user = Accounts.get_user!(id)
      changeset = Accounts.change_user(user)

      {:ok,
       socket
       |> assign(assigns)
       |> assign(:user, user)
       |> assign(:changeset, changeset)
       |> assign(:current_step, 1)
       |> assign(:validation_errors, [])
       |> assign(:show_errors, false)
       |> assign(:title, "Learner Information")
       |> assign(:page_title, "Edit Learner")}
    end
  end

  @impl true
  def handle_event("next_step", _params, socket) do
    case validate_current_step(socket.assigns.changeset, socket.assigns.current_step) do
      {:ok, _} ->
        next_step = min(socket.assigns.current_step + 1, 3)
        {:noreply, assign(socket, :current_step, next_step)}

      {:error, errors} ->
        {:noreply,
         socket
         |> assign(:validation_errors, errors)
         |> assign(:show_errors, true)}
    end
  end

  @impl true
  def handle_event("previous_step", _params, socket) do
    previous_step = max(socket.assigns.current_step - 1, 1)
    {:noreply, assign(socket, :current_step, previous_step)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case validate_all_steps(user_params) do
      {:ok, _} ->
        save_user(socket, socket.assigns.action, user_params)

      {:error, errors} ->
        {:noreply,
         socket
         |> assign(:validation_errors, errors)
         |> assign(:show_errors, true)}
    end
  end

  @impl true
  def handle_event("close", _params, socket) do
    notify_parent(:close_modal)
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_errors", _params, socket) do
    {:noreply,
     socket
     |> assign(:validation_errors, [])
     |> assign(:show_errors, false)}
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Learner updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user(socket, :new, user_params) do
    # Clean up empty strings and fix hearing_status
    cleaned_params = user_params
    |> Map.update("phone", "", &if(&1 == "", do: nil, else: &1))
    |> Map.update("date_of_birth", "", &if(&1 == "", do: nil, else: &1))
    |> Map.update("gender", "", &if(&1 == "", do: nil, else: &1))
    |> Map.update("hearing_status", "", &String.upcase/1)
    |> Map.update("enrolled_year", "", &if(&1 == "", do: nil, else: String.to_integer(&1)))

    # Add learner-specific attributes
    user_params = cleaned_params
    |> Map.put("user_type", "LEARNER")
    |> Map.put("user_role", "STUDENT")
    |> Map.put("status", "ACTIVE")
    |> Map.put("user_status", "ACTIVE")
    |> Map.put("approved", true)

    case Accounts.create_user_with_auto_password(user_params) do
      {:ok, user, generated_password} ->
        # Send password creation notification
        Notifications.send_password_creation_notification(user, generated_password)

        notify_parent({:saved, user})

        # Show the generated password to the user
        message = "Learner created successfully! Generated password: #{generated_password}. Notification sent to user."

        {:noreply,
         socket
         |> put_flash(:info, message)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors, label: "Changeset errors")
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp validate_current_step(changeset, step) do
    case step do
      1 -> validate_step_1(changeset)
      2 -> validate_step_2(changeset)
      3 -> validate_step_3(changeset)
      _ -> {:ok, changeset}
    end
  end

  defp validate_step_1(changeset) do
    required_fields = [:first_name, :last_name, :email, :phone, :username]
    errors = validate_required_fields(changeset, required_fields, 1)

    if Enum.empty?(errors), do: {:ok, changeset}, else: {:error, errors}
  end

  defp validate_step_2(changeset) do
    required_fields = [:program, :enrolled_year, :semester]
    errors = validate_required_fields(changeset, required_fields, 2)

    if Enum.empty?(errors), do: {:ok, changeset}, else: {:error, errors}
  end

  defp validate_step_3(changeset) do
    required_fields = [:hearing_status]
    errors = validate_required_fields(changeset, required_fields, 3)

    if Enum.empty?(errors), do: {:ok, changeset}, else: {:error, errors}
  end

  defp validate_all_steps(user_params) do
    changeset = %User{}
    |> Accounts.change_user(user_params)

    all_required_fields = [:first_name, :last_name, :email, :phone, :username, :program, :enrolled_year, :semester, :hearing_status]
    errors = validate_required_fields(changeset, all_required_fields, 1)

    if Enum.empty?(errors), do: {:ok, changeset}, else: {:error, errors}
  end

  defp validate_required_fields(changeset, fields, step) do
    Enum.reduce(fields, [], fn field, acc ->
      case Ecto.Changeset.get_field(changeset, field) do
        nil -> [%{field: field, message: "#{format_field_name(field)} is required", step: step} | acc]
        "" -> [%{field: field, message: "#{format_field_name(field)} is required", step: step} | acc]
        _ -> acc
      end
    end)
  end

  defp format_field_name(field) do
    field
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # Helper functions for template
  defp has_field_error?(changeset, field) do
    case Ecto.Changeset.get_field(changeset, field) do
      nil -> false
      "" -> false
      _ -> false
    end
  end

  defp get_field_error(changeset, field) do
    case Ecto.Changeset.get_field(changeset, field) do
      nil -> "#{format_field_name(field)} is required"
      "" -> "#{format_field_name(field)} is required"
      _ -> ""
    end
  end
end
