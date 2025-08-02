defmodule SigneaseWeb.Admin.Users.Components.LearnerFormComponent do
  use SigneaseWeb, :live_component

  alias Signease.Learners
  alias Signease.Learners.Learner

  @impl true
  def update(%{id: id} = assigns, socket) do
    learner = if id == "new", do: %Learner{}, else: Learners.get_learner!(id)
    changeset = Learners.Learner.changeset(learner, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:learner, learner)
     |> assign(:changeset, changeset)
     |> assign(:page_title, if(id == "new", do: "New Learner", else: "Edit Learner"))}
  end

  @impl true
  def handle_event("validate", %{"learner" => learner_params}, socket) do
    changeset =
      socket.assigns.learner
      |> Learners.Learner.changeset(learner_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"learner" => learner_params}, socket) do
    save_learner(socket, socket.assigns.action, learner_params)
  end

  @impl true
  def handle_event("close", _params, socket) do
    send(socket.assigns.parent_pid, {__MODULE__, :close_modal})
    {:noreply, socket}
  end

  defp save_learner(socket, :edit, learner_params) do
    case Learners.update_learner(socket.assigns.learner, learner_params) do
      {:ok, learner} ->
        notify_parent({:saved, learner})

        {:noreply,
         socket
         |> put_flash(:info, "Learner updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_learner(socket, :new, learner_params) do
    case Learners.register_learner(learner_params) do
      {:ok, learner} ->
        notify_parent({:saved, learner})

        # Show the generated password to the user
        generated_password = learner.generated_password
        message = "Learner created successfully! Generated password: #{generated_password}"

        {:noreply,
         socket
         |> put_flash(:info, message)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  @impl true
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" id="learner-modal">
      <div class="relative top-20 mx-auto p-5 border w-11/12 max-w-2xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <!-- Header -->
          <div class="flex items-center justify-between mb-6">
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
            phx-change="validate"
            phx-submit="save"
            class="space-y-6"
          >
            <!-- Basic Information -->
            <div class="bg-gray-50 p-6 rounded-lg">
              <h4 class="text-lg font-semibold text-gray-900 mb-4">Basic Information</h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <.input
                    type="text"
                    name="learner[first_name]"
                    value={Ecto.Changeset.get_field(@changeset, :first_name)}
                    label="First Name"
                    required
                  />
                </div>
                <div>
                  <.input
                    type="text"
                    name="learner[last_name]"
                    value={Ecto.Changeset.get_field(@changeset, :last_name)}
                    label="Last Name"
                    required
                  />
                </div>
                <div>
                  <.input
                    type="text"
                    name="learner[username]"
                    value={Ecto.Changeset.get_field(@changeset, :username)}
                    label="Username"
                    required
                  />
                </div>
                <div>
                  <.input
                    type="email"
                    name="learner[email]"
                    value={Ecto.Changeset.get_field(@changeset, :email)}
                    label="Email Address"
                    required
                  />
                </div>
                <div>
                  <.input
                    type="tel"
                    name="learner[phone_number]"
                    value={Ecto.Changeset.get_field(@changeset, :phone_number)}
                    label="Phone Number"
                  />
                </div>
                <div>
                  <.input
                    type="date"
                    name="learner[date_of_birth]"
                    value={Ecto.Changeset.get_field(@changeset, :date_of_birth)}
                    label="Date of Birth"
                  />
                </div>
                <div>
                  <.input
                    type="select"
                    name="learner[gender]"
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
            <div class="bg-gray-50 p-6 rounded-lg">
              <h4 class="text-lg font-semibold text-gray-900 mb-4">Hearing Status</h4>
              <div class="grid grid-cols-1 gap-6">
                <div>
                  <.input
                    type="select"
                    name="learner[hearing_status]"
                    value={Ecto.Changeset.get_field(@changeset, :hearing_status)}
                    label="Hearing Status"
                    options={[
                      {"hearing", "Hearing"},
                      {"deaf", "Deaf"}
                    ]}
                  />
                </div>
              </div>
            </div>

            <!-- Form Actions -->
            <div class="flex justify-end space-x-4 pt-6 border-t">
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
