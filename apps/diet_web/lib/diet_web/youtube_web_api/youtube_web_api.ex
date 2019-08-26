defmodule DietWeb.YoutubeWebApi do
  @youtube_web_api Application.fetch_env!(:diet_web, :youtube_web_api)[:adapter]

  def search(query) do
    @youtube_web_api.search(query)
  end
end
