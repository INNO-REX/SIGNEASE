defmodule SigneaseWeb.Components.CompactLoaderComponent do
  use SigneaseWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="loader-compact">
      <div class="loader-compact-spinner"></div>
      <span><%= @text || "Loading..." %></span>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, text: "Loading...")}
  end

  def update(%{text: text}, socket) do
    {:ok, assign(socket, text: text)}
  end

  def update(_, socket) do
    {:ok, assign(socket, text: "Loading...")}
  end
end
