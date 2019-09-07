defmodule Diet.Repo.Migrations.RemoveVideoIdFromLikesAndReports do
  use Ecto.Migration

  def change do
    alter table(:likes) do
      remove :video_id, :integer
    end

    alter table(:reports) do
      remove :video_id, :integer
    end
  end
end
