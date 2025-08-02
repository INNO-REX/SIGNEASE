defmodule SigneaseWeb.MainSettingsLive.ForcePasswordChangeLive do
  use SigneaseWeb, :live_view

  alias Signease.Accounts
  alias Signease.Accounts.User

    @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      user: nil,
      changeset: User.password_changeset(%User{}, %{}),
      page_title: "Change Password Required",
      error_message: "",
      success_message: ""
    )}
  end

  @impl true
  def handle_params(%{"user_id" => user_id}, _url, socket) do
    user = Accounts.get_user!(user_id)

    if user && user.auto_pwd == "Y" do
      # User has auto-generated password, show force change form
      changeset = User.password_changeset(%User{}, %{})

      {:noreply, assign(socket,
        user: user,
        changeset: changeset
      )}
    else
      # User doesn't need to change password, redirect to appropriate dashboard
      {:noreply, redirect(socket, to: get_dashboard_path(user))}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, redirect(socket, to: "/")}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      User.password_changeset(%User{}, user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user_password(socket.assigns.user, user_params["current_password"], user_params) do
      {:ok, updated_user} ->
        # Update user to mark password as changed
        Accounts.update_user(updated_user, %{auto_pwd: "N"})

        # Show success message and redirect
        {:noreply,
         socket
         |> put_flash(:success, "Password changed successfully! Welcome to your dashboard.")
         |> redirect(to: get_dashboard_path(updated_user))}

      {:error, changeset} ->
        error_message = format_changeset_errors(changeset)
        {:noreply, assign(socket, changeset: changeset, error_message: error_message)}
    end
  end

  defp get_dashboard_path(user) do
    case user.user_type do
      "ADMIN" -> "/admin/dashboard"
      "LEARNER" -> "/learner/dashboard"
      "INSTRUCTOR" -> "/lecturer/dashboard"
      _ -> "/"
    end
  end

  defp format_changeset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map_join(", ", fn {_field, errors} ->
      Enum.join(errors, ", ")
    end)
  end
end
