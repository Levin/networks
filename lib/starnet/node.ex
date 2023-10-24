defmodule Starnet.Node do
  @moduledoc """
    This module defines the single nodes in the star network.
    A node holds state about the existing data on it.
  """

  use GenServer
  require Logger

  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  def init(params) do
    Logger.debug("*** starting node ***")

    {:ok,
     %{
       ip: "64.9.78.21",
       name: params.name,
       flash: [],
       c_wires: []
     }, {:continue, :setup}}
  end

  def handle_continue(:setup, state) do
    Phoenix.PubSub.subscribe(Nets.PubSub, "star")
    Phoenix.PubSub.subscribe(Nets.PubSub, "node")

    {:noreply, state}
  end

  def send_ping(ip_adress, state) do
    Phoenix.PubSub.broadcast(
      Nets.PubSub,
      "star",
      {:switch, {String.to_atom("node_#{state.name}"), ip_adress}}
    )
  end
end
