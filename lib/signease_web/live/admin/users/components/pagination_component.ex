defmodule SigneaseWeb.Admin.Users.Components.PaginationComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :pagination, if(assigns.pagination == %{}, do: %{current_page: 1, per_page: 20, total_count: 0, total_pages: 1, has_prev: false, has_next: false}, else: assigns.pagination))

    ~H"""
    <div class="bg-white rounded-xl shadow-lg border border-gray-200 px-6 py-4">
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-4">
          <span class="text-sm text-gray-700">
            Showing <%= (@pagination.current_page - 1) * @pagination.per_page + 1 %> to <%= min(@pagination.current_page * @pagination.per_page, @pagination.total_count) %> of <%= @pagination.total_count %> results
          </span>

          <div class="flex items-center space-x-2">
            <label for="per-page" class="text-sm text-gray-700">Show:</label>
            <select
              id="per-page"
              phx-change="change_per_page"
              phx-target={@myself}
              class="text-sm border border-gray-300 rounded-md px-2 py-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="10" selected={@pagination.per_page == 10}>10</option>
              <option value="20" selected={@pagination.per_page == 20}>20</option>
              <option value="50" selected={@pagination.per_page == 50}>50</option>
              <option value="100" selected={@pagination.per_page == 100}>100</option>
            </select>
            <span class="text-sm text-gray-700">per page</span>
          </div>
        </div>

        <div class="flex items-center space-x-2">
          <button
            phx-click="change_page"
            phx-value-page={@pagination.current_page - 1}
            phx-target={@myself}
            disabled={!@pagination.has_prev}
            class="px-3 py-1 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Previous
          </button>

          <div class="flex items-center space-x-1">
            <%= for page <- get_visible_pages(@pagination) do %>
              <%= if page == :ellipsis do %>
                <span class="px-3 py-1 text-sm text-gray-500">...</span>
              <% else %>
                <button
                  phx-click="change_page"
                  phx-value-page={page}
                  phx-target={@myself}
                  class={[
                    "px-3 py-1 text-sm font-medium rounded-md",
                    if(page == @pagination.current_page,
                      do: "text-white bg-blue-600",
                      else: "text-gray-500 bg-white border border-gray-300 hover:bg-gray-50"
                    )
                  ]}
                >
                  <%= page %>
                </button>
              <% end %>
            <% end %>
          </div>

          <button
            phx-click="change_page"
            phx-value-page={@pagination.current_page + 1}
            phx-target={@myself}
            disabled={!@pagination.has_next}
            class="px-3 py-1 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Next
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    send(socket.assigns.parent_pid, {:change_page, %{"page" => page}})
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_per_page", %{"value" => per_page}, socket) do
    per_page = String.to_integer(per_page)
    send(socket.assigns.parent_pid, {:change_per_page, %{"per_page" => per_page}})
    {:noreply, socket}
  end

  defp get_visible_pages(pagination) do
    current_page = pagination.current_page
    total_pages = pagination.total_pages

    cond do
      total_pages <= 7 ->
        Enum.to_list(1..total_pages)

      current_page <= 4 ->
        [1, 2, 3, 4, 5, :ellipsis, total_pages]

      current_page >= total_pages - 3 ->
        [1, :ellipsis, total_pages - 4, total_pages - 3, total_pages - 2, total_pages - 1, total_pages]

      true ->
        [1, :ellipsis, current_page - 1, current_page, current_page + 1, :ellipsis, total_pages]
    end
  end
end
