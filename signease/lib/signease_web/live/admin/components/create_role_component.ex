defmodule SigneaseWeb.Admin.Components.CreateRoleComponent do
  use SigneaseWeb, :live_component

  alias Signease.Roles.UserRole

  @impl true
  def mount(socket) do
    {:ok, assign(socket, changeset: UserRole.changeset(%UserRole{}, %{}), show_modal: false)}
  end

  @impl true
  def update(%{id: id} = assigns, socket) do
    {:ok,
     socket
     |> assign(id: id)
     |> assign(assigns)}
  end

  @impl true
  def handle_event("show-modal", _params, socket) do
    changeset = UserRole.changeset(%UserRole{}, %{})
    {:noreply, assign(socket, show_modal: true, changeset: changeset)}
  end

  @impl true
  def handle_event("hide-modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  @impl true
  def handle_event("create-role", %{"user_role" => role_params}, socket) do
    role_params = Map.put(role_params, "created_by", socket.assigns.current_user.id)
    role_params = Map.put(role_params, "updated_by", socket.assigns.current_user.id)

    case socket.assigns.create_role_callback.(role_params) do
      {:ok, _role} ->
        # Send message to parent to refresh roles list
        send(socket.assigns.parent_pid, {:role_created, :ok})
        {:noreply,
         socket
         |> assign(show_modal: false)
         |> put_flash(:info, "Role created successfully.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <!-- Create Role Button -->
      <button phx-click="show-modal" phx-target={@myself}
              class="inline-flex items-center px-4 py-2 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-medium rounded-lg hover:from-indigo-700 hover:to-purple-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105">
        <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
        Create Role
      </button>

      <!-- Create Role Modal -->
      <%= if @show_modal do %>
        <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50" id="create-role-modal">
          <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div class="mt-3">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-medium text-gray-900">Create New Role</h3>
                <button phx-click="hide-modal" phx-target={@myself} class="text-gray-400 hover:text-gray-600">
                  <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                  </svg>
                </button>
              </div>

              <.form for={@changeset} phx-submit="create-role" phx-target={@myself} class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700">Role Name</label>
                  <.input name="user_role[name]" value={@changeset.changes[:name] || @changeset.data.name} type="text" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500" placeholder="Enter role name" />
                  <%= if @changeset.errors[:name] do %>
                    <.error><%= elem(@changeset.errors[:name], 0) %></.error>
                  <% end %>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700">Status</label>
                  <.input name="user_role[status]" value={@changeset.changes[:status] || @changeset.data.status} type="select" options={[{"Active", "ACTIVE"}, {"Inactive", "INACTIVE"}]} class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500" />
                  <%= if @changeset.errors[:status] do %>
                    <.error><%= elem(@changeset.errors[:status], 0) %></.error>
                  <% end %>
                </div>

                <div class="flex justify-end space-x-3 pt-4">
                  <button type="button" phx-click="hide-modal" phx-target={@myself} class="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                    Cancel
                  </button>
                  <button type="submit" class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                    Create Role
                  </button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
