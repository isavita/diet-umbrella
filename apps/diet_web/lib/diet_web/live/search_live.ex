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
      |> assign(:eventful_results, [])
      |> assign(:food_fork_results, [])

    {:ok, socket}
  end

  def handle_event("search", %{"q" => query}, socket) do
    results = searches(query)

    socket =
      socket
      |> assign(:contextual_results, Map.get(results, :contextual_results, []))
      |> assign(:faroo_results, Map.get(results, :faroo_results, []))
      |> assign(:eventful_results, Map.get(results, :eventful_results, []))
      |> assign(:food_fork_results, Map.get(results, :food_fork_results, []))

    {:noreply, socket}
  end

  def searches(query) do
    [
      search_task(fn -> {:contextual_results, contextual_search(query)} end),
      search_task(fn -> {:faroo_results, faroo_search(query)} end),
      search_task(fn -> {:eventful_results, eventful_search(query)} end),
      search_task(fn -> {:food_fork_results, food_fork_search(query)} end)
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

  def eventful_search(query) do
    case DietWeb.EventfulWebApi.search(query) do
      :error -> []
      results -> get_in(results, ["events", "event"]) || []
    end
  end

  def food_fork_search(query) do
    case DietWeb.FoodForkWebApi.search(query) do
      :error -> []
      results -> Map.get(results, "recipes") || []
    end
  end
end
