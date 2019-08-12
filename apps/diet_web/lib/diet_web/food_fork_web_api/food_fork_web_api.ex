defmodule DietWeb.FoodForkWebApi do
  @food_fork_web_api Application.fetch_env!(:diet_web, :food_fork_web_api)[:adapter]

  def search(query) do
    @food_fork_web_api.search(query)
  end
end
