defmodule DietWeb.EventfulWebApi do
  @eventful_web_api Application.fetch_env!(:diet_web, :eventful_web_api)[:adapter]

  def search(query) do
    @eventful_web_api.search(query)
  end
end
