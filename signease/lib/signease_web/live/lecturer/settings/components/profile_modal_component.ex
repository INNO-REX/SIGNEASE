defmodule SigneaseWeb.Lecturer.Settings.Components.ProfileModalComponent do
  use SigneaseWeb, :live_component

  alias Signease.Accounts

  @impl true
  def update(%{id: _id} = assigns, socket) do
    user = assigns.current_user
    changeset = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:user, user)
     |> assign(:changeset, changeset)
     |> assign(:validation_errors, [])
     |> assign(:show_errors, false)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = socket.assigns.user
    |> Accounts.change_user(user_params)
    |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, updated_user} ->
        send(self(), {:profile_updated, updated_user})
        
        {:noreply,
         socket
         |> put_flash(:info, "Profile updated successfully!")
         |> push_event("close_modal", %{})}

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = format_changeset_errors(changeset)
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> assign(:validation_errors, errors)
         |> assign(:show_errors, true)}
    end
  end

  @impl true
  def handle_event("close", _params, socket) do
    send(self(), :close_profile_modal)
    {:noreply, socket}
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp has_error?(changeset, field) do
    case Ecto.Changeset.get_field(changeset, field) do
      nil -> false
      "" -> false
      _ -> false
    end
  end

  defp get_error(changeset, field) do
    case Ecto.Changeset.get_field(changeset, field) do
      nil -> nil
      _ -> 
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
        Map.get(errors, field, []) |> List.first()
    end
  end
end
