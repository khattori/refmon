defmodule Refmon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @default_adapter Refmon.Adapters.Default

  @impl true
  def start(_type, _args) do
    adapter = Refmon.get_env(:adapter, @default_adapter)

    children = [
      # Starts a worker by calling: Refmon.Worker.start_link(arg)
      # {Refmon.Worker, arg}
      {Refmon.Server, adapter: adapter},
      {ConCache, name: Refmon.Cache, ttl_check_interval: false}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Refmon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
