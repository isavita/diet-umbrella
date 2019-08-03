defmodule DietWeb.NewsfeedLiveView do
  use Phoenix.LiveView

  alias Diet.Multimedia

  def render(assigns) do
    DietWeb.PageView.render("newsfeed.html", assigns)
  end

  def mount(session, socket) do
    if connected?(socket), do: Multimedia.subscribe()
    {:ok, assign(socket, videos: session.videos)}
  end

  def handle_info({Multimedia, {:video, _}, _}, socket) do
    videos = Multimedia.list_popular_videos()
    {:noreply, assign(socket, videos: videos)}
  end
end
