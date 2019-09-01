defmodule Diet.Repo.Migrations.AddReporableIdAndReportableTypeIntoLikes do
  use Ecto.Migration

  def up do
    alter table(:reports) do
      add :reportable_id, :integer
      add :reportable_type, :string
      modify :video_id, :integer, null: true
    end

    create index(:reports, [:reportable_id, :reportable_type])
    create unique_index(:reports, [:user_id, :reportable_id, :reportable_type])
  end

  def down do
    drop index(:reports, [:reportable_id, :reportable_type])
    drop unique_index(:reports, [:user_id, :reportable_id, :reportable_type])

    alter table(:reports) do
      remove :reportable_id, :integer
      remove :reportable_type, :string
      modify :video_id, :integer, null: false
    end
  end
end
