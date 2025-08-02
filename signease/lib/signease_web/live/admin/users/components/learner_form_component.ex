defmodule SigneaseWeb.Admin.Users.Components.LearnerFormComponent do
  use SigneaseWeb, :live_component

  alias Signease.Accounts
  alias Signease.Accounts.User
  alias Signease.Notifications

  @impl true
  def update(%{id: id} = assigns, socket) do
    user = if id == "new", do: %User{}, else: Accounts.get_user!(id)
    changeset = Accounts.User.changeset(user, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user, user)
     |> assign(:changeset, changeset)
     |> assign(:page_title, if(id == "new", do: "New Learner", else: "Edit Learner"))}
  end



  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  @impl true
  def handle_event("close", _params, socket) do
    send(socket.assigns.parent_pid, {__MODULE__, :close_modal})
    {:noreply, socket}
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

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  @impl true
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" id="learner-modal">
      <div class="relative top-5 mx-auto p-4 border w-11/12 max-w-3xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <!-- Header -->
          <div class="flex items-center justify-between mb-3">
            <h3 class="text-2xl font-bold text-gray-900">
              <%= @page_title %>
            </h3>
            <button
              phx-click="close"
              phx-target={@myself}
              class="text-gray-400 hover:text-gray-600"
            >
              <.icon name="hero-x-mark" class="h-6 w-6" />
            </button>
          </div>

          <!-- Form -->
          <.form
            for={@changeset}
            id="learner-form"
            phx-target={@myself}
            phx-submit="save"
            class="space-y-3"
          >
            <!-- Basic Information -->
            <div class="bg-gray-50 p-3 rounded-lg">
              <h4 class="text-md font-semibold text-gray-900 mb-3">Basic Information</h4>
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                <div>
                  <.input
                    type="text"
                    name="user[first_name]"
                    value={Ecto.Changeset.get_field(@changeset, :first_name)}
                    label="First Name"
                    required
                  />
                </div>
                <div>
                  <.input
                    type="text"
                    name="user[last_name]"
                    value={Ecto.Changeset.get_field(@changeset, :last_name)}
                    label="Last Name"
                    required
                  />
                </div>
                <div>
                  <.input
                    type="text"
                    name="user[username]"
                    value={Ecto.Changeset.get_field(@changeset, :username)}
                    label="Username"
                    required
                  />
                </div>
                <div>
                  <.input
                    type="email"
                    name="user[email]"
                    value={Ecto.Changeset.get_field(@changeset, :email)}
                    label="Email Address"
                    required
                  />
                </div>
                <div>
                  <.input
                    type="tel"
                    name="user[phone]"
                    value={Ecto.Changeset.get_field(@changeset, :phone)}
                    label="Phone Number"
                  />
                </div>
                <div>
                  <.input
                    type="date"
                    name="user[date_of_birth]"
                    value={Ecto.Changeset.get_field(@changeset, :date_of_birth)}
                    label="Date of Birth"
                  />
                </div>
                <div>
                  <.input
                    type="select"
                    name="user[gender]"
                    value={Ecto.Changeset.get_field(@changeset, :gender)}
                    label="Gender"
                    options={[
                      {"", ""},
                      {"male", "Male"},
                      {"female", "Female"},
                      {"other", "Other"}
                    ]}
                  />
                </div>
              </div>
            </div>

            <!-- Hearing Status -->
            <div class="bg-gray-50 p-3 rounded-lg">
              <h4 class="text-md font-semibold text-gray-900 mb-3">Hearing Status</h4>
              <div class="grid grid-cols-1 gap-3">
                <div>
                  <.input
                    type="select"
                    name="user[hearing_status]"
                    value={Ecto.Changeset.get_field(@changeset, :hearing_status)}
                    label="Hearing Status"
                    options={[
                      {"HEARING", "Hearing"},
                      {"DEAF", "Deaf"},
                      {"HARD_OF_HEARING", "Hard of Hearing"}
                    ]}
                  />
                </div>
              </div>
            </div>

            <!-- Form Actions -->
            <div class="flex justify-end space-x-3 pt-3 border-t">
              <button
                type="button"
                phx-click="close"
                phx-target={@myself}
                class="px-6 py-2 border border-gray-300 rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
              >
                Cancel
              </button>
              <button
                type="submit"
                class="px-6 py-2 bg-gradient-to-r from-blue-600 to-blue-700 text-white font-medium rounded-md hover:from-blue-700 hover:to-blue-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200"
              >
                <%= if @action == :new, do: "Create Learner", else: "Update Learner" %>
              </button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end
end
