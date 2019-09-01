defmodule Diet.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :description, :text
      add :title, :string
      add :url, :string, null: false
      add :type, :string
      add :low_quality, :boolean, default: false, null: false
      add :published_at, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
    end

    create index(:articles, [:user_id])
    create index(:articles, [:category_id])
    create index(:articles, [:type])
    create unique_index(:articles, [:url, :user_id])
  end
end
