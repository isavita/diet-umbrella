defmodule DietWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      DietWeb.Endpoint,
      # Starts a worker by calling: DietWeb.Worker.start_link(arg)
      # {DietWeb.Worker, arg},
      DietWeb.Presence,
      {DietWeb.QualityControl.Server, [[]]},
      {Task.Supervisor, name: DietWeb.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DietWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DietWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
