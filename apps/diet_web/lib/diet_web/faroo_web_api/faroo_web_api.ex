defmodule DietWeb.FarooWebApi do
  @faroo_web_api Application.fetch_env!(:diet_web, :faroo_web_api)[:adapter]

  def search(query) do
    @faroo_web_api.search(query)
  end
end
