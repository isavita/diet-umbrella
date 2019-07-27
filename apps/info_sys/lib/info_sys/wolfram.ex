defmodule InfoSys.Wolfram do
  import SweetXml

  alias InfoSys.{Result, WolframApi}

  @behaviour InfoSys.Backend

  @impl true
  def name, do: "wolfram"

  @impl true
  def compute(query, _opts) do
    query
    |> WolframApi.fetch_xml()
    |> parse_content()
    |> build_results()
  end

  defp parse_content(xml) do
    xpath(
      xml,
      ~x"/queryresult/pod[contains(@title, 'Result') or contains(@title, 'Definitions')] /subpod/plaintext/text()"
    )
  end

  defp build_results(nil), do: []

  defp build_results(answer) do
    [%Result{backend: __MODULE__, score: 95, text: to_string(answer)}]
  end
end
