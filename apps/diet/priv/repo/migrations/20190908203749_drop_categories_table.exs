defmodule Diet.Repo.Migrations.DropCategoriesTable do
  use Ecto.Migration

  def up do
    alter table(:videos) do
      remove :category_id, :integer
    end

    alter table(:articles) do
      remove :category_id, :integer
    end

    drop table(:categories)
  end

  def down do
    create table(:categories) do
      add :name, :string
    end

    alter table(:videos) do
      add :category_id, references(:categories)
    end

    alter table(:articles) do
      add :category_id, references(:categories)
    end
  end
end
