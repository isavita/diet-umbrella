defmodule DietWeb.NewsfeedLive do
  use Phoenix.LiveView

  alias Diet.Multimedia

  @videos_per_scroll 5
  @newest_videos_count 10

  def render(assigns) do
    DietWeb.PageView.render("newsfeed.html", assigns)
  end

  def mount(%{current_user: current_user, csrf_token: csrf_token}, socket) do
    if connected?(socket), do: Multimedia.subscribe()

    {videos, next_cursor} = prepend_videos([], nil)
    newest_videos = Multimedia.list_newest_videos(@newest_videos_count)

    socket =
      assign(
        socket,
        current_user: current_user,
        csrf_token: csrf_token,
        videos: videos,
        next_cursor: next_cursor,
        newest_videos: newest_videos,
        videos_like_counts: videos_like_counts(videos),
        report_modal_open: false
      )

    {:ok, socket}
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

  def handle_event("open-report-modal", _value, socket) do
    {:noreply, assign(socket, report_modal_open: true)}
  end

  def handle_event("load-more", "", socket), do: {:noreply, socket}

  def handle_event("load-more", cursor, socket) do
    {videos, next_cursor} = prepend_videos(socket.assigns.videos, cursor)

    {
      :noreply,
      assign(
        socket,
        videos: videos,
        next_cursor: next_cursor
      )
    }
  end

  def handle_info({Multimedia, {:video, _}, _}, socket) do
    {videos, next_cursor} = prepend_videos([], nil)

    {
      :noreply,
      assign(
        socket,
        videos: videos,
        next_cursor: next_cursor,
        newest_videos: Multimedia.list_newest_videos()
      )
    }
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

  defp prepend_videos(videos, next_cursor) do
    %{entries: old_videos, metadata: metadata} = next_videos(next_cursor)

    {videos ++ old_videos, metadata.after}
  end

  defp next_videos(next_cursor) do
    Multimedia.list_videos_paginated(
      after: next_cursor,
      cursor_fields: [{:published_at, :desc}],
      limit: @videos_per_scroll
    )
  end
end
