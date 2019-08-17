defmodule DietWeb.PageController do
  use DietWeb, :controller

  alias DietWeb.NewsfeedLive

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def newsfeed(conn, _params) do
    live_render(
      conn,
      NewsfeedLive,
      session: %{
        current_user: conn.assigns.current_user,
        csrf_token: Phoenix.Controller.get_csrf_token()
      }
    )
  end
end
