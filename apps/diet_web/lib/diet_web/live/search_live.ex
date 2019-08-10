defmodule DietWeb.SearchLive do
  use Phoenix.LiveView

  @task_timeout :timer.seconds(10000)

  def render(assigns) do
    DietWeb.SearchView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    socket =
      socket
      |> assign(:query, nil)
      |> assign(:loading, nil)
      |> assign(:contextual_results, [])
      |> assign(:faroo_results, [])

    {:ok, socket}
  end

  def handle_event("search", %{"q" => query}, socket) do
    results = searches(query)

    socket =
      socket
      |> assign(:contextual_results, Map.get(results, :contextual_results, []))
      |> assign(:faroo_results, Map.get(results, :faroo_results, []))

    {:noreply, socket}
  end

  def searches(query) do
    [
      search_task(fn -> {:contextual_results, contextual_search(query)} end),
      search_task(fn -> {:faroo_results, faroo_search(query)} end)
    ]
    |> Task.yield_many(@task_timeout)
    |> Enum.filter(fn
      {_task, {:ok, result}} -> true
      _ -> false
    end)
    |> Enum.map(fn {_task, {:ok, result}} -> result end)
    |> Enum.into(%{})
  end

  def search_task(task) do
    Task.Supervisor.async_nolink(
      DietWeb.TaskSupervisor,
      task,
      shut_down: :brutal_kill
    )
  end

  def contextual_search(query) do
    case DietWeb.ContextualWebApi.search(query) do
      :error -> []
      results -> Map.get(results, "value", [])
    end
  end

  def faroo_search(query) do
    case DietWeb.FarooWebApi.search(query) do
      :error -> []
      results -> Map.get(results, "results", [])
    end
  end
end
