defmodule Diet.Repo.Migrations.AddTagsTable do
  use Ecto.Migration

  def change do
    create table("tags") do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:tags, [:name])
  end
end
