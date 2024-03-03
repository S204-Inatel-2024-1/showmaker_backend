defmodule ShowmakerBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ShowmakerBackend.AppInfo

  @impl true
  def start(_type, _args) do
    AppInfo.set_start_time()

    children = [
      ShowmakerBackendWeb.Telemetry,
      ShowmakerBackend.Repo,
      {DNSCluster, query: Application.get_env(:showmaker_backend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ShowmakerBackend.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ShowmakerBackend.Finch},
      # Start a worker by calling: ShowmakerBackend.Worker.start_link(arg)
      # {ShowmakerBackend.Worker, arg},
      # Start to serve requests, typically the last entry
      ShowmakerBackendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ShowmakerBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShowmakerBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
