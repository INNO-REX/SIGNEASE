defmodule SigneaseWeb.Home.HomeLive do
  use SigneaseWeb, :live_view

  @doc """
  Mounts the home page LiveView.
  Sets up initial assigns and page title.
  """
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "SignEase - Inclusive Learning Platform",
      stats: get_platform_stats(),
      form_state: "login" # login, signup, forgot_password
    )}
  end

  def handle_event("start-learning", _params, socket) do
    # TODO: Implement navigation to learning dashboard
    {:noreply, socket}
  end

  def handle_event("watch-demo", _params, socket) do
    # TODO: Implement demo video modal
    {:noreply, socket}
  end

  def handle_event("sign-in", _params, socket) do
    # TODO: Implement sign in navigation
    {:noreply, socket}
  end

  def handle_event("get-started", _params, socket) do
    # TODO: Implement registration flow
    {:noreply, socket}
  end

  # Private functions

  defp get_platform_stats do
    %{
      active_learners: "1000+",
      languages_supported: "50+",
      accuracy_rate: "99%",
      support_availability: "24/7"
    }
  end

end
