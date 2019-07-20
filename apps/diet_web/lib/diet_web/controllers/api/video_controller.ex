defmodule DietWeb.Api.VideoController do
  use DietWeb, :controller

  alias Diet.Multimedia

  def index(conn, _params) do
    videos = Multimedia.list_videos()

    render(conn, "index.json", videos: videos)
  end

  def popular_videos(conn, _params) do
    videos = Multimedia.list_popular_videos()

    render(conn, "index.json", videos: videos)
  end
end
