defmodule AutoPublish.YoutubeWebApi.YoutubeWebHTTPClient do
  @endpoint "https://www.googleapis.com/youtube/v3"

  def list_channel_videos(channel_id) do
    channel_id
    |> get_uploads_id()
    |> get_videos_info()
  end

  defp get_channel_info(channel_id) do
    case HTTPoison.get(channel_by_id(channel_id)) do
      {:ok, %{body: body}} -> Jason.decode!(body)
      _ -> :error
    end
  end

  defp channel_by_id(channel_id) do
    "#{@endpoint}/channels?id=#{channel_id}&part=contentDetails&key=#{api_key()}"
  end

  defp get_uploads_id(channel_id) do
    case get_channel_info(channel_id) do
      %{"items" => [item | _]} -> get_in(item, ["contentDetails", "relatedPlaylists", "uploads"])
      # TODO: raise error
      _ -> :error
    end
  end

  defp get_videos_info(uploads_id) do
    case HTTPoison.get(videos_by_uploads_id(uploads_id)) do
      {:ok, %{body: body}} -> Jason.decode!(body)
      _ -> :error
    end
  end

  defp videos_by_uploads_id(uploads_id) do
    "#{@endpoint}/playlistItems?playlistId=#{uploads_id}&part=snippet&maxResults=50&key=#{
      api_key()
    }"
  end

  defp api_key do
    youtube_web_config()[:api_key]
  end

  defp youtube_web_config do
    Application.fetch_env!(:auto_publish, :youtube_web_api)
  end

  # TODO: Delete if not needed
  defp channel_by_user(username) do
    "#{@endpoint}/channels?forUsername=#{username}&part=contentDetails&key=#{api_key()}"
  end
end
