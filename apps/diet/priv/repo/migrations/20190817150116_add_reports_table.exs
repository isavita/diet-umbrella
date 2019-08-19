defmodule Diet.Repo.Migrations.AddReportsTable do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :video_id, references(:videos, on_delete: :delete_all), null: false
      add :spam_or_abuse, :boolean, null: false, default: false
      add :not_interested, :boolean, null: false, default: false

      timestamps()
    end

    create index(:reports, [:user_id])
    create index(:reports, [:video_id])
    create unique_index(:reports, [:user_id, :video_id], name: :reports_user_id_video_id_index)
  end
end
