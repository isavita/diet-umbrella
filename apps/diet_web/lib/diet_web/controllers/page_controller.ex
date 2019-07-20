defmodule DietWeb.PageController do
  use DietWeb, :controller

  alias Diet.Multimedia

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def newsfeed(conn, _params) do
    render(conn, "newsfeed.html")
  end
end
