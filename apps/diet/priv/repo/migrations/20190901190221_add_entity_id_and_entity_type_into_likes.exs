defmodule Diet.Repo.Migrations.AddEntityIdAndEntityTypeIntoLikes do
  use Ecto.Migration

  def up do
    alter table(:likes) do
      add :likeable_id, :integer
      add :likeable_type, :string
      modify :video_id, :integer, null: true
    end

    create index(:likes, [:likeable_id, :likeable_type])
    create unique_index(:likes, [:user_id, :likeable_id, :likeable_type])
  end

  def down do
    drop index(:likes, [:likeable_id, :likeable_type])
    drop unique_index(:likes, [:user_id, :likeable_id, :likeable_type])

    alter table(:likes) do
      remove :likeable_id, :integer
      remove :likeable_type, :string
      modify :video_id, :integer, null: false
    end
  end
end
