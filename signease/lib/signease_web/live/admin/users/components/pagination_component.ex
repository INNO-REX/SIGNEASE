defmodule SigneaseWeb.Admin.Users.Components.PaginationComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    # Handle empty pagination data
    assigns = case assigns.pagination do
      %{} -> assigns
      pagination when is_map(pagination) and map_size(pagination) > 0 -> assigns
      _ -> %{assigns | pagination: %{current_page: 1, per_page: 20, total_count: 0, total_pages: 0, has_prev: false, has_next: false}}
    end

    ~H"""
    <div class="flex items-center justify-between px-4 py-3 bg-white border-t border-gray-200 sm:px-6">
      <div class="flex items-center justify-between w-full">
        <!-- Results info -->
        <div class="flex items-center text-sm text-gray-700">
          <span>
            Showing
            <span class="font-medium"><%= (@pagination.current_page - 1) * @pagination.per_page + 1 %></span>
            to
            <span class="font-medium">
              <%= min(@pagination.current_page * @pagination.per_page, @pagination.total_count) %>
            </span>
            of
            <span class="font-medium"><%= @pagination.total_count %></span>
            results
          </span>
        </div>

        <!-- Per page selector -->
        <div class="flex items-center space-x-2">
          <span class="text-sm text-gray-700">Show:</span>
          <select
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

      <!-- Pagination controls -->
      <div class="flex items-center space-x-2">
        <!-- Previous button -->
        <button
          phx-click="change_page"
          phx-target={@myself}
          phx-value-page={@pagination.current_page - 1}
          disabled={!@pagination.has_prev}
          class="relative inline-flex items-center px-2 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-l-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd"></path>
          </svg>
        </button>

        <!-- Page numbers -->
        <div class="flex items-center space-x-1">
          <%= for page_num <- get_visible_pages(@pagination) do %>
            <%= if page_num == :gap do %>
              <span class="px-3 py-2 text-sm text-gray-500">...</span>
            <% else %>
              <button
                phx-click="change_page"
                phx-target={@myself}
                phx-value-page={page_num}
                class={[
                  "relative inline-flex items-center px-3 py-2 text-sm font-medium border",
                  if page_num == @pagination.current_page do
                    "z-10 bg-blue-50 border-blue-500 text-blue-600"
                  else
                    "bg-white border-gray-300 text-gray-500 hover:bg-gray-50"
                  end
                ]}
              >
                <%= page_num %>
              </button>
            <% end %>
          <% end %>
        </div>

        <!-- Next button -->
        <button
          phx-click="change_page"
          phx-target={@myself}
          phx-value-page={@pagination.current_page + 1}
          disabled={!@pagination.has_next}
          class="relative inline-flex items-center px-2 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-r-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd"></path>
          </svg>
        </button>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    send(socket.assigns.parent_pid, {:change_page, %{"page" => page}})
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_per_page", %{"value" => per_page}, socket) do
    send(socket.assigns.parent_pid, {:change_per_page, %{"per_page" => per_page}})
    {:noreply, socket}
  end

  defp get_visible_pages(pagination) do
    total_pages = pagination.total_pages
    current_page = pagination.current_page

    cond do
      total_pages <= 7 ->
        # Show all pages if 7 or fewer
        1..total_pages |> Enum.to_list()

      current_page <= 4 ->
        # Show first 5 pages + gap + last page
        [1, 2, 3, 4, 5, :gap, total_pages]

      current_page >= total_pages - 3 ->
        # Show first page + gap + last 5 pages
        [1, :gap, total_pages - 4, total_pages - 3, total_pages - 2, total_pages - 1, total_pages]

      true ->
        # Show first page + gap + current-1, current, current+1 + gap + last page
        [1, :gap, current_page - 1, current_page, current_page + 1, :gap, total_pages]
    end
  end
end
