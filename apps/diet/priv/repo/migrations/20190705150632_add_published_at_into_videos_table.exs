defmodule Diet.Repo.Migrations.AddPublishedAtIntoVideosTable do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :published_at, :utc_datetime_usec
    end
  end
end
