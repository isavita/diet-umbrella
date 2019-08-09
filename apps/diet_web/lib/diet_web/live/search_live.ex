defmodule DietWeb.SearchLive do
  use Phoenix.LiveView

  def render(assigns) do
    DietWeb.SearchView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    socket =
      socket
      |> assign(:query, nil)
      |> assign(:loading, nil)
      |> assign(:results, [])

    {:ok, socket}
  end

  def handle_event("search", %{"q" => query}, socket) do
    results =
      case DietWeb.ContextualWebApi.search(query) do
        :error -> %{}
        results -> results
      end

    {:noreply, assign(socket, :results, results["value"] || [])}
  end
end
