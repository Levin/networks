defmodule Starnet.Switch do
  @moduledoc """
    This module defines the connecting part in this network - the switch.
    It exchanges messages between nodes. Therefore it can accept data comming from a node 
    through a wire and sends the data to the specified receiver.
    A switch holds data just temporarily until the receiving part accepted the data package.
  """


    use GenServer
    require Logger

    def start_link(params) do
      GenServer.start_link(__MODULE__, params)
    end

    def init(params) do
      Logger.debug("*** starting switch ***")
    
      {:ok, 
        %{
          ip: "94.54.102.1",
          name: params.name,
          c_nodes: [],
          c_wires: []
      }, {:continue, :setup}}
    end


    def handle_continue(:setup, state) do
      Phoenix.PubSub.subscribe(Nets.PubSub, "star")
      Phoenix.PubSub.subscribe(Nets.PubSub, "switch")
      {:noreply, state}
    end

end



defmodule Startnet.Node do
  
  @moduledoc """
    This module defines the single nodes in the star network.
    A node holds state about the existing data on it.
  """

end



defmodule Starnet.Wire do
  

  @moduledoc """
    This module defines the wires which connect nodes to the switch.
    A wire holds information about the data passing through it.
    Each wire is connected to one wire.
  """

end
