defmodule Diet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Diet.Repo
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: Diet.Supervisor
    )
  end
end
