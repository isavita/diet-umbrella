defmodule DietWeb.NewsfeedLive do
  use Phoenix.LiveView

  alias Diet.Multimedia

  @videos_per_scroll 5
  @newest_videos_count 10
  @newest_articles_count 5

  def render(assigns) do
    DietWeb.PageView.render("newsfeed.html", assigns)
  end

  def mount(%{current_user: current_user, csrf_token: csrf_token}, socket) do
    if connected?(socket), do: Multimedia.subscribe()

    {videos, next_cursor} = prepend_videos([], nil)
    newest_videos = Multimedia.list_newest_videos(@newest_videos_count)
    newest_articles = Multimedia.list_newest_articles(@newest_articles_count)
    tags = Multimedia.list_tags()

    # TODO: Remove this from here
    articles = Multimedia.list_newest_articles()

    socket =
      assign(
        socket,
        current_user: current_user,
        csrf_token: csrf_token,
        tags: tags,
        selected_tag_ids: [],
        videos: videos,
        articles: articles,
        next_cursor: next_cursor,
        newest_videos: newest_videos,
        newest_articles: newest_articles,
        like_counts: Map.merge(like_counts(videos, "Video"), like_counts(articles, "Article")),
        report_modal_open: false
      )

    {:ok, socket}
  end

  def handle_event("like", %{"id" => id, "type" => type}, socket) do
    id = String.to_integer(id)
    change = like_change(socket.assigns.current_user, id, type)

    {
      :noreply,
      update(
        socket,
        :like_counts,
        fn map -> Map.update(map, {id, type}, change, &(&1 + change)) end
      )
    }
  end

  def handle_event("unlike", %{"id" => id, "type" => type}, socket) do
    id = String.to_integer(id)
    change = unlike_change(socket.assigns.current_user, id, type)

    {
      :noreply,
      update(
        socket,
        :like_counts,
        fn map -> Map.update(map, {id, type}, change, &(&1 - change)) end
      )
    }
  end

  def handle_event("select", %{"filters" => %{"tags" => tag_ids}}, socket) do
    tag_ids = Enum.map(tag_ids, &parse_integer/1) |> Enum.reject(&is_nil/1)
    {videos, next_cursor} = prepend_videos([], nil, tag_ids)

    socket =
      assign(socket,
        selected_tag_ids: tag_ids,
        videos: videos,
        next_cursor: next_cursor
      )

    {:noreply, socket}
  end

  def handle_event("open-report-modal", _value, socket) do
    {:noreply, assign(socket, report_modal_open: true)}
  end

  def handle_event("load-more", "", socket), do: {:noreply, socket}

  def handle_event("load-more", cursor, socket) do
    {videos, next_cursor} =
      prepend_videos(socket.assigns.videos, cursor, socket.assigns.selected_tag_ids)

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
    {videos, next_cursor} = prepend_videos([], nil, socket.assigns.selected_tag_ids)

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

  defp like_counts(likeables, likeable_type) do
    likeables
    |> Enum.map(& &1.id)
    |> Multimedia.like_counts(likeable_type)
    |> Enum.map(fn {id, count} -> {{id, likeable_type}, count} end)
    |> Enum.into(%{})
  end

  defp like_change(nil, _likeable_id, _likeable_type), do: 0

  defp like_change(current_user, likeable_id, likeable_type) do
    if Multimedia.user_likes?(current_user.id, likeable_id, likeable_type) do
      0
    else
      {:ok, _} = Multimedia.like(current_user.id, likeable_id, likeable_type)
      1
    end
  end

  defp unlike_change(nil, _likeable_id, _likeable_type), do: 0

  defp unlike_change(current_user, likeable_id, likeable_type) do
    if Multimedia.user_likes?(current_user.id, likeable_id, likeable_type) do
      {:ok, _} = Multimedia.unlike(current_user.id, likeable_id, likeable_type)
      1
    else
      0
    end
  end

  defp prepend_videos(videos, next_cursor, tag_ids \\ nil) do
    tag_ids =
      case tag_ids do
        [_ | _tail] -> tag_ids
        _ -> nil
      end

    %{entries: old_videos, metadata: metadata} = next_videos(next_cursor, tag_ids)

    {Enum.uniq(videos ++ old_videos), metadata.after}
  end

  defp next_videos(next_cursor, tag_ids) do
    Multimedia.list_videos_paginated(
      after: next_cursor,
      cursor_fields: [{:published_at, :desc}],
      limit: @videos_per_scroll,
      tag_ids: tag_ids
    )
  end

  defp parse_integer(nil), do: nil

  defp parse_integer(val) do
    case Integer.parse(val) do
      {n, _} -> n
      _ -> nil
    end
  end
end
