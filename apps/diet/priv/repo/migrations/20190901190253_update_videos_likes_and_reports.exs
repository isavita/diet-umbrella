defmodule Diet.Repo.Migrations.UpdateVideosLikesAndReports do
  use Ecto.Migration

  def up do
    update_all_videos_likes()
    update_all_videos_reports()
  end

  def down, do: nil

  defp update_all_videos_likes do
    Enum.each(Diet.Repo.all(Diet.Multimedia.Like), fn like ->
      like
      |> Diet.Multimedia.Like.changeset(%{likeable_id: like.video_id, likeable_type: "Video"})
      |> Diet.Repo.update!()
    end)
  end

  defp update_all_videos_reports do
    Enum.each(Diet.Repo.all(Diet.Multimedia.Like), fn report ->
      report
      |> Diet.Multimedia.Like.changeset(%{reportable_id: report.video_id, reportable_type: "Video"})
      |> Diet.Repo.update!()
    end)
  end
end
