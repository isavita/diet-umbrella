defmodule InfoSys.WolframApi do
  def fetch_xml(query), do: wolfram_api().fetch_xml(query)

  defp wolfram_api do
    Application.fetch_env!(:info_sys, :wolfram_api)[:adapter]
  end
end
