defmodule DietWeb.EventfulWebApi.EventfulWebHTTPClient do
  @json Phoenix.json_library()

  def search(query) when is_binary(query) do
    query = URI.encode_www_form(query)
    url = web_search_event_url() <> search_params() <> "&q=#{query}"

    case HTTPoison.get(url) do
      {:ok, %{body: body}} -> @json.decode!(body)
      _error -> :error
    end
  end

  def search(_), do: :error

  defp search_params do
    "&location=London"
  end

  defp web_search_event_url do
    "http://#{api_host()}/json/events/search?app_key=#{api_key()}"
  end

  defp api_host do
    eventful_web_config()[:api_host]
  end

  defp api_key do
    eventful_web_config()[:api_key]
  end

  defp eventful_web_config do
    Application.fetch_env!(:diet_web, :eventful_web_api)
  end
end
