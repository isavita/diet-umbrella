defmodule AutoPublish.YoutubeWebApi do
  @youtube_web_api Application.fetch_env!(:auto_publish, :youtube_web_api)[:adapter]

  def list_channel_videos(channel_id) do
    @youtube_web_api.list_channel_videos(channel_id)
  end
end
