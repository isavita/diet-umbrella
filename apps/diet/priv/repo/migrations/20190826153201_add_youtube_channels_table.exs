defmodule Diet.Repo.Migrations.AddYoutubeChannelsTable do
  use Ecto.Migration

  def change do
    create table(:youtube_channels) do
      add :uid, :string, null: false
      add :name, :string
      add :active, :boolean, default: false, null: false
      add :videos, :jsonb, default: "[]", null: false

      timestamps()
    end

    create unique_index(:youtube_channels, [:uid])
  end
end
