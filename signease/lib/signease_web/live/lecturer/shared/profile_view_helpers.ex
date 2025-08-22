defmodule SigneaseWeb.Lecturer.Shared.ProfileViewHelpers do
  @moduledoc """
  Shared helpers for profile view functionality across lecturer pages
  """

  @doc """
  Adds profile view event handlers to a LiveView module
  """
  defmacro __using__(_opts) do
    quote do
      @impl true
      def handle_event("show_profile_view", _params, socket) do
        {:noreply, assign(socket, show_profile_view: true)}
      end

      @impl true
      def handle_event("close_profile_view", _params, socket) do
        {:noreply, assign(socket, show_profile_view: false)}
      end

      @impl true
      def handle_info(:show_profile_view, socket) do
        {:noreply, assign(socket, show_profile_view: true)}
      end

      defoverridable handle_event: 3, handle_info: 2
    end
  end

  @doc """
  Adds show_profile_view: false to socket assigns
  """
  def add_profile_view_assign(socket) do
    Phoenix.LiveView.assign(socket, show_profile_view: false)
  end
end
