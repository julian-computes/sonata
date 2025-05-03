defmodule Orchestra.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OrchestraWeb.Telemetry,
      Orchestra.Repo,
      {DNSCluster, query: Application.get_env(:orchestra, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Orchestra.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Orchestra.Finch},
      # Start a worker by calling: Orchestra.Worker.start_link(arg)
      # {Orchestra.Worker, arg},
      # Start to serve requests, typically the last entry
      OrchestraWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Orchestra.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OrchestraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
