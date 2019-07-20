defmodule Diet.Repo.Migrations.AddCategoryIdIntoVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :category_id, references(:categories)
    end

    create index(:videos, [:category_id])
  end
end
