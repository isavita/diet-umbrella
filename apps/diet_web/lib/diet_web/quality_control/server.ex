defmodule DietWeb.QualityControl.Server do
  use GenServer

  alias  Diet.Multimedia

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    frequency = opts[:frequency] || frequency_ms()

    GenServer.start_link(__MODULE__, %{frequency: frequency}, name: opts[:name])
  end

  @impl true
  def init(state) do
    schedule_quality_check(state[:frequency])

    {:ok, state}
  end

  @impl true
  def handle_info(:quality_check, state) do
    Multimedia.mark_reported_videos(lower_quality_report_count())

    schedule_quality_check(state[:frequency])

    {:noreply, state}
  end

  defp schedule_quality_check(frequency) do
    Process.send_after(self(), :quality_check, frequency)
  end

  defp frequency_ms do
    Application.get_env(:diet_web, :runtime, %{})[:quality_check_frequency] || 600_000
  end

  defp lower_quality_report_count do
    Application.get_env(:diet_web, :runtime, %{})[:lower_quality_report_count] || 2
  end

  defp spam_report_count do
    Application.get_env(:diet_web, :runtime, %{})[:spam_report_count] || 2
  end
end