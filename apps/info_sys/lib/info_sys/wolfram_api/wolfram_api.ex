defmodule InfoSys.WolframApi do
  @wolfram_api Application.fetch_env!(:info_sys, :wolfram_api)[:adapter]

  def fetch_xml(query), do: @wolfram_api.fetch_xml(query)
end
