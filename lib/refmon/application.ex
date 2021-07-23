defmodule Refmon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @default_adapter Refmon.Adapters.Default

  @impl true
  def start(_type, _args) do
    adapter = Refmon.get_env(:adapter, @default_adapter)
    otp_app = Refmon.get_env(:otp_app, Refmon.application())

    children = [
      # Starts a worker by calling: Refmon.Worker.start_link(arg)
      # {Refmon.Worker, arg}
      {Refmon.Server, adapter: adapter, otp_app: otp_app},
      {Cachex, name: Refmon.Cache}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Refmon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
