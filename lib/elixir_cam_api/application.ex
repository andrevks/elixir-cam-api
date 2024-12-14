defmodule ElixirCamApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirCamApiWeb.Telemetry,
      ElixirCamApi.Repo,
      {DNSCluster, query: Application.get_env(:elixir_cam_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirCamApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ElixirCamApi.Finch},
      # Start a worker by calling: ElixirCamApi.Worker.start_link(arg)
      # {ElixirCamApi.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirCamApiWeb.Endpoint,
      {Task.Supervisor, name: ElixirCamApi.AsyncEmailSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirCamApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirCamApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
