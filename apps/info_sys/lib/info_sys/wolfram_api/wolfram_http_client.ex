defmodule InfoSys.WolframApi.WolframHTTPClient do
  @base "http://api.wolframalpha.com/v2/query"

  def fetch_xml(query) do
    {:ok, {_, _, body}} =
      query
      |> url()
      |> String.to_charlist()
      |> :httpc.request()

    body
  end

  defp url(input) do
    "#{@base}?" <>
      URI.encode_query(appid: app_id(), input: input, format: "plaintext")
  end

  defp app_id, do: Application.fetch_env!(:info_sys, :wolfram_api)[:app_id]
end
