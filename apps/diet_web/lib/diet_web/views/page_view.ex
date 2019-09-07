defmodule DietWeb.PageView do
  use DietWeb, :view

  @minute 60
  @hour 3600
  @day 24 * 3600

  def embedded_url(video) do
    String.replace(video.url, "/watch?v=", "/embed/")
  end

  def posted_on(time) do
    now = DateTime.utc_now()
    posted_time_utc = DateTime.from_naive!(time, "Etc/UTC")
    seconds_ago = DateTime.diff(now, posted_time_utc, :second)
    time_format(seconds_ago, posted_time_utc)
  end

  defp time_format(seconds_ago, posted_time) do
    cond do
      seconds_ago < 2 * @minute -> "now"
      seconds_ago < @hour -> "#{div(seconds_ago, @minute)} minutes ago"
      seconds_ago < 2 * @hour -> "an hour ago"
      seconds_ago < @day -> "#{div(seconds_ago, @hour)} hours ago"
      true -> DateTime.to_date(posted_time)
    end
  end

  defp reportable_type(reportable) do
    reportable.__struct__
    |> to_string()
    |> String.split(".")
    |> List.last()
  end
end
