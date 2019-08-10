defmodule DietWeb.FarooWebApi.FarooWebHTTPClient do
  @json Phoenix.json_library()

  def search(query) when is_binary(query) do
    query = URI.encode_www_form(query)
    url = web_search_url() <> "q=#{query}"

    case HTTPoison.get(url, headers()) do
      {:ok, %{body: body}} -> @json.decode!(body)
      _error -> :error
    end
  end

  def search(_), do: :error

  defp web_search_url do
    "https://#{api_host()}/api?"
  end

  defp headers do
    %{
      "X-RapidAPI-Host" => api_host(),
      "X-RapidAPI-Key" => api_key()
    }
  end

  defp api_host do
    faroo_web_config()[:api_host]
  end

  defp api_key do
    faroo_web_config()[:api_key]
  end

  defp faroo_web_config do
    Application.fetch_env!(:diet_web, :faroo_web_api)
  end
end
