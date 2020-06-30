defmodule PhoenixCms.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PhoenixCmsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PhoenixCms.PubSub},

      # Start cache processes
      %{
        id: ArticlesCache,
        start: {PhoenixCms.Repo.Cache, :start_link, [[name: ArticlesCache]]}
      },
      %{
        id: ContentsCache,
        start: {PhoenixCms.Repo.Cache, :start_link, [[name: ContentsCache]]}
      },

      # Start the Endpoint (http/https)
      PhoenixCmsWeb.Endpoint
      # Start a worker by calling: PhoenixCms.Worker.start_link(arg)
      # {PhoenixCms.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixCms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhoenixCmsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
