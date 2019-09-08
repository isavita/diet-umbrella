defmodule Diet.Repo.Migrations.AddVideosAndArticlesTagsTable do
  use Ecto.Migration

  def change do
    create table("videos_tags", primary_key: false) do
      add :video_id, references(:videos)
      add :tag_id, references(:tags)
    end

    create table("articles_tags", primary_key: false) do
      add :article_id, references(:articles)
      add :tag_id, references(:tags)
    end
  end
end
