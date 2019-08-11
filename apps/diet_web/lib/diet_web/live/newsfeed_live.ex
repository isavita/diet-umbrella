defmodule DietWeb.NewsfeedLive do
  use Phoenix.LiveView

  alias Diet.Multimedia

  def render(assigns) do
    DietWeb.PageView.render("newsfeed.html", assigns)
  end

  def mount(session, socket) do
    if connected?(socket), do: Multimedia.subscribe()
    videos = Multimedia.list_popular_videos()

    {:ok,
     assign(
       socket,
       current_user: session.current_user,
       videos: videos,
       videos_like_counts: videos_like_counts(videos)
     )}
  end

  def handle_event("like", video_id, socket) do
    video_id = String.to_integer(video_id)
    change = like_change(socket.assigns.current_user, video_id)

    {
      :noreply,
      update(
        socket,
        :videos_like_counts,
        fn map -> Map.update(map, video_id, change, &(&1 + change)) end
      )
    }
  end

  def handle_event("unlike", video_id, socket) do
    video_id = String.to_integer(video_id)
    change = unlike_change(socket.assigns.current_user, video_id)

    {
      :noreply,
      update(
        socket,
        :videos_like_counts,
        fn map -> Map.update(map, video_id, change, &(&1 - change)) end
      )
    }
  end

  def handle_info({Multimedia, {:video, _}, _}, socket) do
    {:noreply, assign(socket, videos: Multimedia.list_popular_videos())}
  end

  defp videos_like_counts(videos) do
    videos
    |> Enum.map(& &1.id)
    |> Multimedia.videos_like_counts()
    |> Enum.into(%{})
  end

  defp like_change(nil, _video_id), do: 0

  defp like_change(current_user, video_id) do
    if Multimedia.user_likes_video?(current_user.id, video_id) do
      0
    else
      {:ok, _} = Multimedia.like_video(current_user.id, video_id)
      1
    end
  end

  defp unlike_change(nil, _video_id), do: 0

  defp unlike_change(current_user, video_id) do
    if Multimedia.user_likes_video?(current_user.id, video_id) do
      {:ok, _} = Multimedia.unlike_video(current_user.id, video_id)
      1
    else
      0
    end
  end
end