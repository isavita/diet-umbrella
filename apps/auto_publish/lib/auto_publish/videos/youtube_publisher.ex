defmodule AutoPublish.Videos.YoutubePublisher do
  alias AutoPublish.YoutubeWebApi
  alias Diet.{Accounts, Multimedia, Repo}

  @admin_username "weighthater"
  @default_tag "Fitness"

  def publish_new_videos(opts \\ []) do
    opts = Keyword.put_new(opts, :video_count, 2)

    Multimedia.list_active_youtube_channel()
    |> Enum.shuffle()
    |> Enum.take(opts[:channel_count] || 3)
    |> Enum.each(fn channel ->
      Task.start(fn -> publish_channel_unpublished_videos(channel, opts) end)
    end)
  end

  defp publish_channel_unpublished_videos(channel, opts) do
    user = Accounts.user_by_username(@admin_username)
    tag = Multimedia.tag_by_name(@default_tag)
    videos = channel.videos

    case Enum.reject(videos, & &1.published) do
      [] ->
        # TODO: Move this to process and fix the logic for when are more than 50 videos
        %{"items" => items} = AutoPublish.YoutubeWebApi.list_channel_videos(channel.uid)

        Multimedia.update_youtube_channel(channel, %{
          videos: Enum.map(items, fn item -> %{data: item} end)
        })

        channel = Multimedia.get_youtube_channel(channel.id)
        publish_videos(channel, channel.videos, channel.videos, user, tag, opts)

      unpublished_videos ->
        publish_videos(channel, videos, unpublished_videos, user, tag, opts)
    end
  end

  defp publish_videos(channel, videos, unpublished_videos, user, tag, opts) do
    videos_to_publish = Enum.take(unpublished_videos, opts[:video_count])
    create_videos(videos_to_publish, user, tag)
    updated_videos = mark_as_published(videos, videos_to_publish)

    Multimedia.update_youtube_channel(
      channel,
      %{videos: Enum.map(updated_videos, &Map.from_struct/1)}
    )
  end

  defp mark_as_published(videos, published_videos) do
    Enum.map(videos, fn video ->
      if Enum.member?(published_videos, video) do
        %{video | published: true}
      else
        video
      end
    end)
  end

  defp create_videos(videos, user, tag) do
    Enum.each(videos, &create_video(&1, user, tag))
  end

  defp create_video(video, user, tag) do
    video = transform_video(video)
    IO.inspect(tag, label: "tag")

    Multimedia.create_video(user, %{
      url: "https://www.youtube.com/watch?v=#{video.uid}",
      title: video.title,
      description: video.description,
      tags: [tag.id],
      published_at: DateTime.utc_now()
    })
  end

  defp transform_video(video) do
    %{
      uid: get_in(video.data, ["snippet", "resourceId", "videoId"]),
      title: get_in(video.data, ["snippet", "title"]),
      description: get_in(video.data, ["snippet", "description"])
    }
  end
end
