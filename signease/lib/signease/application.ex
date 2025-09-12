defmodule Signease.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SigneaseWeb.Telemetry,
      Signease.Repo,
      {DNSCluster, query: Application.get_env(:signease, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Signease.PubSub},
      {Finch, name: Signease.Finch},
      SigneaseWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Signease.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SigneaseWeb.Endpoint.config_change(changed, removed)
    :ok
  end


end
