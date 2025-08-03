defmodule SigneaseWeb.Components.PaginationComponent do
  use SigneaseWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @pagination_data && @pagination_data.page_info do %>
        <div class="flex items-center justify-between px-4 py-3 bg-white border-t border-gray-200 sm:px-6">
          <div class="flex flex-1 justify-between sm:hidden">
            <.link
              :if={@pagination_data.page_info.has_previous_page}
              patch={build_page_url(@params, @pagination_data.page_info.previous_page_number)}
              class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Previous
            </.link>
            <.link
              :if={@pagination_data.page_info.has_next_page}
              patch={build_page_url(@params, @pagination_data.page_info.next_page_number)}
              class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Next
            </.link>
          </div>
          <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
            <div>
              <p class="text-sm text-gray-700">
                Showing
                <span class="font-medium"><%= @pagination_data.page_info.start_index %></span>
                to
                <span class="font-medium"><%= @pagination_data.page_info.end_index %></span>
                of
                <span class="font-medium"><%= @pagination_data.page_info.total_count %></span>
                results
              </p>
            </div>
            <div>
              <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                <.link
                  :if={@pagination_data.page_info.has_previous_page}
                  patch={build_page_url(@params, @pagination_data.page_info.previous_page_number)}
                  class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                >
                  <span class="sr-only">Previous</span>
                  <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                  </svg>
                </.link>

                <%= for page_number <- @pagination_data.page_info.page_numbers do %>
                  <.link
                    patch={build_page_url(@params, page_number)}
                    class={[
                      "relative inline-flex items-center px-4 py-2 border text-sm font-medium",
                      if(page_number == @pagination_data.page_info.current_page_number,
                        do: "z-10 bg-purple-50 border-purple-500 text-purple-600",
                        else: "bg-white border-gray-300 text-gray-500 hover:bg-gray-50"
                      )
                    ]}
                  >
                    <%= page_number %>
                  </.link>
                <% end %>

                <.link
                  :if={@pagination_data.page_info.has_next_page}
                  patch={build_page_url(@params, @pagination_data.page_info.next_page_number)}
                  class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                >
                  <span class="sr-only">Next</span>
                  <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                  </svg>
                </.link>
              </nav>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp build_page_url(params, page_number) do
    params = Map.put(params, "page", Integer.to_string(page_number))
    query_string = URI.encode_query(params)
    "/admin/instructors?#{query_string}"
  end
end
