defmodule DietWeb.PageController do
  use DietWeb, :controller

  alias Diet.Multimedia

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def newsfeed(conn, _params) do
    videos = Multimedia.list_popular_videos()
    live_render(conn, DietWeb.NewsfeedLiveView, session: %{videos: videos})
  end
end
