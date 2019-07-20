defmodule DietWeb.AdminController do
  use DietWeb, :controller

  alias Diet.Multimedia

  def videos(conn, _params) do
    videos = Multimedia.list_videos()

    render(conn, "videos.html", videos: videos)
  end

  def publish(conn, %{"id" => id}) do
    video = Multimedia.get_video!(id)
    attrs = %{published_at: DateTime.utc_now()}

    with {:ok, _} <- Multimedia.update_video(video, attrs) do
      redirect(conn, to: Routes.admin_path(conn, :videos))
    end
  end

  def unpublish(conn, %{"id" => id}) do
    video = Multimedia.get_video!(id)
    attrs = %{published_at: nil}

    with {:ok, _} <- Multimedia.update_video(video, attrs) do
      redirect(conn, to: Routes.admin_path(conn, :videos))
    end
  end
end
