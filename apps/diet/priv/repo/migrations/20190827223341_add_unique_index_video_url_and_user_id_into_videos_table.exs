defmodule Diet.Repo.Migrations.AddUniqueIndexVideoUrlAndUserIdIntoVideosTable do
  use Ecto.Migration

  def change do
    create unique_index(:videos, [:url, :user_id])
  end
end
