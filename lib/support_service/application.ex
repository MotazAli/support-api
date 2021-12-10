defmodule SupportService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SupportService.Repo,
      # Start the Telemetry supervisor
      SupportServiceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SupportService.PubSub},
      # Start the Endpoint (http/https)
      SupportServiceWeb.Endpoint,
      # Start a worker by calling: SupportService.Worker.start_link(arg)
      # {SupportService.Worker, arg}

      Supervisor.child_spec({Cachex, name: :support_users}, id: :support_users),
      Supervisor.child_spec({Cachex, name: :admin_users}, id: :admin_users)

      # {Cachex, name: :support_users}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SupportService.Supervisor]
    start_result = Supervisor.start_link(children, opts)
    # SupportService.Task.register_service_in_gateway
    start_result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SupportServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
