defmodule PhoenixDevenv.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixDevenvWeb.Telemetry,
      PhoenixDevenv.Repo,
      {DNSCluster, query: Application.get_env(:phoenix_devenv, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixDevenv.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhoenixDevenv.Finch},
      # Start a worker by calling: PhoenixDevenv.Worker.start_link(arg)
      # {PhoenixDevenv.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixDevenvWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixDevenv.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixDevenvWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
