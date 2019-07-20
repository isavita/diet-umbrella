defmodule Diet.Repo.Migrations.AddPositionIntoCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :position, :integer, default: 0
    end

    create index(:categories, [:position])
  end
end
