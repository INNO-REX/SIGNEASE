defmodule SigneaseWeb.Components.LoaderComponent do
  use Phoenix.Component

  def loader(assigns) do
    assigns = assign_new(assigns, :id, fn -> "loader" end)
    assigns = assign_new(assigns, :message, fn -> "Processing..." end)
    assigns = assign_new(assigns, :subtext, fn -> "Please wait while we complete your request" end)
    assigns = assign_new(assigns, :progress, fn -> 0 end)

    ~H"""
    <div id={@id} class="loader-overlay" phx-hook="LoaderHook">
      <div class="loader-container">
        <div class="loader-spinner"></div>
        <div class="loader-text">
          <%= @message %>
        </div>
        <div class="loader-subtext">
          <%= @subtext %>
        </div>
        <div class="loader-progress">
          <div class="loader-progress-bar" style={"width: #{@progress}%"}>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
