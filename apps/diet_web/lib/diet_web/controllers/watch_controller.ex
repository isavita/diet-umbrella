defmodule DietWeb.WatchController do
  use DietWeb, :controller

  alias Diet.Multimedia

  def show(conn, %{"id" => id}) do
    video = Multimedia.get_video!(id)

    render(conn, "show.html", video: video)
  end
end
