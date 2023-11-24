defmodule Nets.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Nets.Worker.start_link(arg)
      Supervisor.child_spec({Phoenix.PubSub, name: :devices}, id: :pubsub_0),
      Supervisor.child_spec({Phoenix.PubSub, name: :switches}, id: :pubsub_1),
      %{
        id: Devices,
        start: {Devices, :start, [%{mac: "as4d-5gw3-alg3"}]}
      },
      %{
        id: Switch,
        start: {Switch, :start, [%{ports: 8}]}
      },
      %{id: Network,
        start: {Network, :start, ["home"]}
      },
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nets.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
