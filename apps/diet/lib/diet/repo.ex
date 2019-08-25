defmodule Diet.Repo do
  use Ecto.Repo,
    otp_app: :diet,
    adapter: Ecto.Adapters.Postgres

  use Paginator
end
