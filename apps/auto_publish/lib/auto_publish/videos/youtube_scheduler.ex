defmodule AutoPublish.Videos.YoutubeScheduler do
  use GenServer

  alias AutoPublish.Videos.YoutubePublisher

  # 6 hours
  @publish_every_ms 21_600_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    schedule_publish_videos()
    {:ok, :ok}
  end

  @impl true
  def handle_info(:publish_videos, state) do
    YoutubePublisher.publish_new_videos()

    schedule_publish_videos()
    {:noreply, state}
  end

  defp schedule_publish_videos do
    Process.send_after(self(), :publish_videos, @publish_every_ms)
  end
end
