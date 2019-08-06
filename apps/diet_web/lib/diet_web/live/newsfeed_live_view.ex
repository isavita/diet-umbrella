defmodule DietWeb.NewsfeedLiveView do
  use Phoenix.LiveView

  alias Diet.Multimedia

  def render(assigns) do
    DietWeb.PageView.render("newsfeed.html", assigns)
  end

  def mount(session, socket) do
    if connected?(socket), do: Multimedia.subscribe()
    likes_count = 42
    {:ok, assign(socket, videos: session.videos, likes_count: likes_count)}
  end

  def handle_event("like", video_id, socket) do
    {:noreply, update(socket, :likes_count, &(&1 + 1))}
  end

  def handle_event("unlike", video_id, socket) do
    {:noreply, update(socket, :likes_count, &(&1 - 1))}
  end

  def handle_info({Multimedia, {:video, _}, _}, socket) do
    videos = Multimedia.list_popular_videos()
    {:noreply, assign(socket, videos: videos)}
  end
end
