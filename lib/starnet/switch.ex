defmodule Starnet.Switch do
  @moduledoc """
    This module defines the connecting part in this network - the switch.
    It exchanges messages between nodes. Therefore it can accept data comming from a node 
    through a wire and sends the data to the specified receiver.
    A switch holds data just temporarily until the receiving part accepted the data package.
  """
alias Hex.Solver.Registry

  # NOTE: monitor if HashSet makes sense       /done/make c_nodes/c_wires accept nodes/wires just on time -> see what makes sense


    use GenServer
    require Logger
    
    def start_link(params) do
      Registry.start_link(keys: :duplicate, name: Registry.Servant)
      GenServer.start_link(__MODULE__, params)
    end

    def init(params) do
      Logger.debug("*** starting switch ***")

      {:ok, 
        %{
          ip: "94.54.102.1",
          name: params.name,
          ram: [],
          c_nodes: MapSet.new(),
          c_wires: MapSet.new(),
      }, {:continue, :setup}}
    end


    def handle_continue(:setup, state) do
      Phoenix.PubSub.subscribe(Nets.PubSub, "star")
      Phoenix.PubSub.subscribe(Nets.PubSub, "switch")
      {:noreply, state}
    end

  def lookup_node(node) do
    case Registry.values(Registry.UniqueLookupTest, node.ip, self()) do
      [] -> nil
      entry -> IO.inspect(entry)
    end
    node
  end

  defp lookup_wire(wire) do
    case Registry.values(Registry.UniqueLookupTest, wire.id, self()) do
      [] -> nil
      entry -> IO.inspect(entry)
    end
    wire
  end

  def handle_info({:transfer, %{node_a: Node, node_b: Node}}, state) do
    # TODO: lookup registry(lookup_wire()/lookup_node()) for ip's of nodes
    #       case ip_exists true -> lookup wires 
    #                     false -> ask missing node for ip, then continue with true


  end


    def handle_info({:new_connection, %{node: Node, wire: Wire}}, state) do

      # TODO: lookup registy(lookup_node()/lookup_wire()) for entries -> 
      #     case ip_exists true -> return ip through pubsub to calling node
      #                   false -> update c_nodes + update c_wires

      {:noreply, state}

    end

end

