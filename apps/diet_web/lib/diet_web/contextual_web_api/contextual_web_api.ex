defmodule DietWeb.ContextualWebApi do
  @contextual_web_api Application.fetch_env!(:diet_web, :contextual_web_api)[:adapter]

  def search(query) do
    @contextual_web_api.search(query)
  end
end
