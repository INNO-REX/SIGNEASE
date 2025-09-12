defmodule SigneaseWeb.Admin.Users.Components.InstructorFormComponent do
  use SigneaseWeb, :live_component
  import Ecto.Changeset, only: [validate_length: 3, validate_format: 4, validate_required: 2]

  alias Signease.Accounts
  alias Signease.Accounts.User

  @impl true
  def update(%{id: id} = assigns, socket) do
    if id == :new do
      # Create a changeset without validation to avoid showing errors initially
      changeset = %User{}
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:user_type, "INSTRUCTOR")
      |> Ecto.Changeset.put_change(:user_role, "TEACHER")
      |> Ecto.Changeset.put_change(:status, "PENDING_APPROVAL")
      |> Ecto.Changeset.put_change(:auto_pwd, "Y")

      {:ok,
       socket
       |> assign(assigns)
       |> assign(:user, %User{})
       |> assign(:changeset, changeset)
       |> assign(:current_step, 1)
       |> assign(:page_title, "Add New Instructor")
       |> assign(:validation_errors, [])
       |> assign(:show_errors, false)}
    else
      user = Accounts.get_user!(id)
      changeset = Accounts.change_user(user)

      {:ok,
       socket
       |> assign(assigns)
       |> assign(:user, user)
       |> assign(:changeset, changeset)
       |> assign(:current_step, 1)
       |> assign(:page_title, "Edit Instructor")
       |> assign(:validation_errors, [])
       |> assign(:show_errors, false)}
    end
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    # Convert string keys to atoms for Ecto
    atomized_params = for {key, value} <- user_params, into: %{} do
      {String.to_atom(key), value}
    end

    # Update the changeset with the current form data
    changeset = %User{}
    |> Ecto.Changeset.change(atomized_params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    # Add debugging to see if this is being called
    IO.inspect(user_params, label: "SAVE EVENT RECEIVED - User Params")
    IO.inspect(socket.assigns.action, label: "SAVE EVENT RECEIVED - Action")

    # Convert string keys to atoms for Ecto
    atomized_params = for {key, value} <- user_params, into: %{} do
      {String.to_atom(key), value}
    end

    # Validate all steps before saving
    case validate_all_steps(socket.assigns.changeset) do
      {:ok, _validated_changeset} ->
        save_instructor(socket, socket.assigns.action, atomized_params)

      {:error, changeset, errors} ->
        # Show validation errors and stay on current step
        {:noreply, socket
          |> assign(:changeset, changeset)
          |> assign(:validation_errors, errors)
          |> assign(:show_errors, true)}
    end
  end

  @impl true
  def handle_event("close", _params, socket) do
    # Add smooth exit animation delay
    Process.send_after(self(), :close_modal, 400)
    {:noreply, socket}
  end

  @impl true
  def handle_event("next_step", _params, socket) do
    current_step = socket.assigns.current_step

    if current_step < 3 do
      # Get the current form data from the changeset
      current_values = socket.assigns.changeset.changes

      # Create a new changeset with current values for validation
      validation_changeset = %User{}
      |> Ecto.Changeset.change(current_values)

      # Validate the current step before proceeding
      case validate_current_step(validation_changeset, current_step) do
        {:ok, _validated_changeset} ->
          # Create a new changeset with the current values for the next step
          updated_changeset = %User{}
          |> Ecto.Changeset.change(current_values)

          {:noreply, socket
            |> assign(:current_step, current_step + 1)
            |> assign(:changeset, updated_changeset)
            |> assign(:validation_errors, [])
            |> assign(:show_errors, false)}

        {:error, _changeset, errors} ->
          # Show validation errors and stay on current step
          {:noreply, socket
            |> assign(:validation_errors, errors)
            |> assign(:show_errors, true)}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("previous_step", _params, socket) do
    current_step = socket.assigns.current_step

    if current_step > 1 do
      # Get the current form data from the changeset
      current_values = socket.assigns.changeset.changes

      # Create a new changeset with the current values for the previous step
      updated_changeset = %User{}
      |> Ecto.Changeset.change(current_values)

      {:noreply, socket
        |> assign(:current_step, current_step - 1)
        |> assign(:changeset, updated_changeset)
        |> assign(:validation_errors, [])
        |> assign(:show_errors, false)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("clear_errors", _params, socket) do
    {:noreply,
     socket
     |> assign(:validation_errors, [])
     |> assign(:show_errors, false)}
  end

  defp save_instructor(socket, :edit, user_params) do
    # Convert atom keys to string keys to ensure consistency
    stringified_params = for {key, value} <- user_params, into: %{} do
      {to_string(key), value}
    end

    case Accounts.update_user(socket.assigns.user, stringified_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Instructor updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = format_changeset_errors(changeset)
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> assign(:validation_errors, errors)
         |> assign(:show_errors, true)}
    end
  end

  defp save_instructor(socket, :new, user_params) do
    # Convert atom keys to string keys to ensure consistency
    stringified_params = for {key, value} <- user_params, into: %{} do
      {to_string(key), value}
    end

    # Set instructor-specific values
    instructor_params = stringified_params
    |> Map.put("user_type", "INSTRUCTOR")
    |> Map.put("user_role", "TEACHER")
    |> Map.put("status", "PENDING_APPROVAL")
    |> Map.put("auto_pwd", "Y")

    case Accounts.create_user_with_auto_password(instructor_params) do
      {:ok, user, password} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Instructor created successfully with auto-generated password")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = format_changeset_errors(changeset)
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> assign(:validation_errors, errors)
         |> assign(:show_errors, true)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  def handle_info(data, socket) do
    case data do
      :close_modal ->
        notify_parent(:close_modal)
        {:noreply, socket}
      _ ->
        {:noreply, socket}
    end
  end

  # Enhanced step validation functions
  defp validate_current_step(changeset, step) do
    case step do
      1 -> validate_step_1(changeset)
      2 -> validate_step_2(changeset)
      3 -> validate_step_3(changeset)
      _ -> {:ok, changeset}
    end
  end

  defp validate_all_steps(changeset) do
    try do
      validation_changeset = changeset
      |> validate_required([
        :first_name, :last_name, :email, :phone, :gender, :id_type, :id_no,
        :date_of_birth, :education_level, :years_experience,
        :username, :hearing_status
      ])
      |> validate_field_sizes()
      |> validate_email_format()
      |> validate_phone_format()

      if validation_changeset.valid? do
        {:ok, changeset}
      else
        errors = format_changeset_errors(validation_changeset)
        {:error, changeset, errors}
      end
    rescue
      error ->
        {:error, changeset, ["Validation error: #{inspect(error)}"]}
    end
  end

  defp validate_step_1(changeset) do
    try do
      validation_changeset = changeset
      |> validate_required([:first_name, :last_name, :email, :phone, :gender, :id_type, :id_no])
      |> validate_field_sizes_step1()
      |> validate_email_format()
      |> validate_phone_format()

      if validation_changeset.valid? do
        {:ok, changeset}
      else
        errors = format_changeset_errors(validation_changeset)
        {:error, changeset, errors}
      end
    rescue
      error ->
        {:error, changeset, ["Validation error: #{inspect(error)}"]}
    end
  end

  defp validate_step_2(changeset) do
    try do
      validation_changeset = changeset
      |> validate_required([:date_of_birth, :education_level, :years_experience])

      if validation_changeset.valid? do
        {:ok, changeset}
      else
        errors = format_changeset_errors(validation_changeset)
        {:error, changeset, errors}
      end
    rescue
      error ->
        {:error, changeset, ["Validation error: #{inspect(error)}"]}
    end
  end

  defp validate_step_3(changeset) do
    try do
      validation_changeset = changeset
      |> validate_required([:username, :hearing_status])
      |> validate_field_sizes_step3()

      if validation_changeset.valid? do
        {:ok, changeset}
      else
        errors = format_changeset_errors(validation_changeset)
        {:error, changeset, errors}
      end
    rescue
      error ->
        {:error, changeset, ["Validation error: #{inspect(error)}"]}
    end
  end

  # Custom validation functions
  defp validate_field_sizes(changeset) do
    changeset
    |> validate_length(:username, min: 3, max: 30, message: "Username must be between 3 and 30 characters")
    |> validate_length(:first_name, min: 2, max: 50, message: "First name must be between 2 and 50 characters")
    |> validate_length(:last_name, min: 2, max: 50, message: "Last name must be between 2 and 50 characters")
    |> validate_length(:email, min: 5, max: 255, message: "Email must be between 5 and 255 characters")
    |> validate_length(:phone, min: 10, max: 15, message: "Phone number must be between 10 and 15 characters")
  end

  defp validate_field_sizes_step1(changeset) do
    changeset
    |> validate_length(:first_name, min: 2, max: 50, message: "First name must be between 2 and 50 characters")
    |> validate_length(:last_name, min: 2, max: 50, message: "Last name must be between 2 and 50 characters")
    |> validate_length(:email, min: 5, max: 255, message: "Email must be between 5 and 255 characters")
    |> validate_length(:phone, min: 10, max: 15, message: "Phone number must be between 10 and 15 characters")
  end

  defp validate_field_sizes_step3(changeset) do
    changeset
    |> validate_length(:username, min: 3, max: 30, message: "Username must be between 3 and 30 characters")
  end

  defp validate_email_format(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, "Please enter a valid email address")
  end

  defp validate_phone_format(changeset) do
    changeset
    |> validate_format(:phone, ~r/^[\d\s\-\+\(\)]+$/, "Please enter a valid phone number")
  end

  # Error formatting functions
  defp format_changeset_errors(changeset) do
    changeset.errors
    |> Enum.map(fn {field, {message, _}} ->
      %{
        field: field,
        message: format_error_message(field, message),
        step: get_field_step(field)
      }
    end)
  end

  defp format_error_message(field, message) do
    case field do
      :first_name -> "First name #{message}"
      :last_name -> "Last name #{message}"
      :email -> "Email #{message}"
      :phone -> "Phone number #{message}"
      :username -> "Username #{message}"
      :hearing_status -> "Hearing status #{message}"
      :date_of_birth -> "Date of birth #{message}"
      :gender -> "Gender #{message}"
      :id_type -> "ID type #{message}"
      :id_no -> "ID number #{message}"
      :education_level -> "Education level #{message}"
      :years_experience -> "Years of experience #{message}"
      :subjects_expertise -> "Subjects expertise #{message}"
      _ -> "#{String.replace(to_string(field), "_", " ")} #{message}"
    end
  end

  defp get_field_step(field) do
    case field do
      field when field in [:first_name, :last_name, :email, :phone, :gender, :id_type, :id_no] -> 1
      field when field in [:date_of_birth, :education_level, :years_experience, :subjects_expertise] -> 2
      field when field in [:username, :hearing_status] -> 3
      _ -> 1
    end
  end

  # Error formatting functions
  defp format_changeset_errors(changeset) do
    changeset.errors
    |> Enum.map(fn {field, {message, _}} ->
      %{
        field: field,
        message: format_error_message(field, message),
        step: get_field_step(field)
      }
    end)
  end

  # Helper functions for template
  defp has_field_error?(changeset, field) do
    Enum.any?(changeset.errors, fn {error_field, _} -> error_field == field end)
  end

  defp get_field_error(changeset, field) do
    case Enum.find(changeset.errors, fn {error_field, _} -> error_field == field end) do
      {_, {message, _}} -> message
      nil -> nil
    end
  end
end
