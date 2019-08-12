defmodule DietWeb.FoodForkWebApi.FoodForkWebHTTPClient do
  @json Phoenix.json_library()
  @search_url "https://www.food2fork.com/api/search"
  @recipe_url "https://www.food2fork.com/api/get"

  def search(query) when is_binary(query) do
    query = URI.encode_www_form(query)
    url = web_search_url() <> "&q=#{query}"

    case HTTPoison.get(url) do
      {:ok, %{body: body}} -> @json.decode!(body)
      _error -> :error
    end
  end

  def search(_), do: :error

  defp web_search_url do
    "#{@search_url}?key=#{api_key()}"
  end

  defp get_recipe_url do
    "#{@recipe_url}?key=#{api_key()}"
  end

  defp api_key do
    food_fork_web_config()[:api_key]
  end

  defp food_fork_web_config do
    Application.fetch_env!(:diet_web, :food_fork_web_api)
  end
end
