defmodule SigneaseWeb.Admin.Users.Components.InstructorFormComponent do
  use SigneaseWeb, :live_component

  alias Signease.Accounts
  alias Signease.Accounts.User

  @impl true
  def update(%{id: :new} = assigns, socket) do
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
     |> assign(:changeset, changeset)
     |> assign(:current_step, 1)
     |> assign(:page_title, "Add New Instructor")}
  end

  @impl true
  def update(%{id: id} = assigns, socket) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user, user)
     |> assign(:changeset, changeset)
     |> assign(:current_step, 1)
     |> assign(:page_title, "Edit Instructor")}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    user = socket.assigns[:user] || %User{}
    changeset =
      user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    save_instructor(socket, socket.assigns.action, user_params)
  end

  @impl true
  def handle_event("close", _params, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.patch)}
  end

  @impl true
  def handle_event("next_step", _params, socket) do
    current_step = socket.assigns.current_step
    if current_step < 3 do
      # Validate current step before moving to next
      case validate_current_step(socket.assigns.changeset, current_step) do
        {:ok, _} ->
          {:noreply, assign(socket, :current_step, current_step + 1)}
        {:error, changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("previous_step", _params, socket) do
    current_step = socket.assigns.current_step
    if current_step > 1 do
      {:noreply, assign(socket, :current_step, current_step - 1)}
    else
      {:noreply, socket}
    end
  end

  defp save_instructor(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Instructor updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_instructor(socket, :new, user_params) do
    # Set instructor-specific values
    instructor_params = user_params
    |> Map.put("user_type", "INSTRUCTOR")
    |> Map.put("user_role", "TEACHER")
    |> Map.put("status", "PENDING_APPROVAL")
    |> Map.put("auto_pwd", "Y")

    case Accounts.create_user_with_auto_password(instructor_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Instructor created successfully with auto-generated password")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # Add step validation function
  defp validate_current_step(changeset, step) do
    case step do
      1 -> validate_step_1(changeset)
      2 -> validate_step_2(changeset)
      3 -> validate_step_3(changeset)
      _ -> {:ok, changeset}
    end
  end

  defp validate_step_1(changeset) do
    # Use Accounts changeset validation for step 1 fields
    user = Ecto.Changeset.apply_changes(changeset)
    validation_changeset = Accounts.change_user(user)

    # Only validate the fields for step 1
    step1_changeset = validation_changeset
    |> Ecto.Changeset.validate_required([:first_name, :last_name, :email, :phone])

    if step1_changeset.valid? do
      {:ok, changeset}
    else
      # Merge the validation errors back to the original changeset
      {:error, %{changeset | errors: step1_changeset.errors, valid?: false}}
    end
  end

  defp validate_step_2(changeset) do
    # Step 2 fields are optional, so just return success
    {:ok, changeset}
  end

  defp validate_step_3(changeset) do
    # Use Accounts changeset validation for step 3 fields
    user = Ecto.Changeset.apply_changes(changeset)
    validation_changeset = Accounts.change_user(user)

    # Only validate the fields for step 3
    step3_changeset = validation_changeset
    |> Ecto.Changeset.validate_required([:username, :hearing_status])

    if step3_changeset.valid? do
      {:ok, changeset}
    else
      # Merge the validation errors back to the original changeset
      {:error, %{changeset | errors: step3_changeset.errors, valid?: false}}
    end
  end
end
