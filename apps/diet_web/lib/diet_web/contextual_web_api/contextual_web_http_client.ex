defmodule DietWeb.ContextualWebApi.ContextualWebHTTPClient do
  @json Phoenix.json_library()

  def search(query) when is_binary(query) do
    query = URI.encode_www_form(query)
    url = web_search_url() <> search_params() <> "&q=#{query}"

    case HTTPoison.get(url, headers()) do
      {:ok, %{body: body}} -> @json.decode!(body)
      _error -> :error
    end
  end

  def search(_), do: :error

  defp search_params do
    "autoCorrect=true&pageNumber=1&pageSize=10"
  end

  defp web_search_url do
    "https://#{api_host()}/api/Search/WebSearchAPI?"
  end

  defp headers do
    %{
      "X-RapidAPI-Host" => api_host(),
      "X-RapidAPI-Key" => api_key()
    }
  end

  defp api_host do
    contextual_web_config()[:api_host]
  end

  defp api_key do
    contextual_web_config()[:api_key]
  end

  defp contextual_web_config do
    Application.fetch_env!(:diet_web, :contextual_web_api)
  end
end
