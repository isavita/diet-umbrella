defmodule Diet.Release do
  @start_apps [
    :ssl
  ]

  @app :diet

  def migrate do
    start_services()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          Ecto.Migrator.run(repo, :up, all: true)
        end)
    end

    stop_services()
  end

  def rollback(repo, version) do
    {:ok, _, _} =
      Ecto.Migrator.with_repo(repo, fn repo ->
        Ecto.Migrator.run(repo, :down, to: version)
      end)
  end

  defp start_services do
    Enum.each(@start_apps, &Application.ensure_all_started/1)
  end

  defp stop_services do
    Enum.each(@start_apps, &Application.stop/1)
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
