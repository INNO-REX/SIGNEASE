defmodule Signease.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SigneaseWeb.Telemetry,
      Signease.Repo,
      {DNSCluster, query: Application.get_env(:signease, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Signease.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Signease.Finch},
      # Start a worker by calling: Signease.Worker.start_link(arg)
      # {Signease.Worker, arg},
      # Start to serve requests, typically the last entry
      SigneaseWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Signease.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SigneaseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
