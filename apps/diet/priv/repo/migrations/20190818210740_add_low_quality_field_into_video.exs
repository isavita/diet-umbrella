defmodule Diet.Repo.Migrations.AddLowQualityFieldIntoVideo do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :low_quality, :boolean, null: false, default: false
    end
  end
end
