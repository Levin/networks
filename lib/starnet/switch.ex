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
      # TODO: think about building registries for wires/nodes/switches
      Elixir.Registry.start_link(keys: :duplicate, name: Registry.Servant)
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
      Elixir.Registry.register(Registry.Servant, :ip_switch, state.ip)
      {:noreply, state}
    end

  # TODO: make this behave like -> got entry -> true -> entry
  #                                          -> false -> ask for creating new entry -> create it then
  def lookup_node(node) do
    case Elixir.Registry.values(Registry.Servant, node.ip, self()) do
      [] -> nil
      entry -> IO.inspect(entry)
    end
    node
  end

  # TODO: make this behave like -> got entry -> true -> entry
  #                                         -> false -> ask for creating new entry -> create it then
  defp lookup_wire(wire) do
    case Elixir.Registry.values(Registry.Servant, wire.id, self()) do
      [] -> nil
      entry -> IO.inspect(entry)
    end
    wire
  end

  # TODO: different switches/nodes/wires
  def lookup_ip_from(elem) do
    term = case elem do
      :switch -> :ip_switch 
      :node -> :ip_node
      :wire -> :ip_wire
    end
      Elixir.Registry.lookup(Registry.Servant, term)
  end

  def handle_info({:transfer, %{node_a: node_a, node_b: node_b}}, state) do
    # TODO: lookup registry(lookup_wire()/lookup_node()) for ip's of nodes
    nodea = lookup_ip_from(node_a.name)
    nodeb = lookup_ip_from(node_b.name)
    #       case ip_exists true -> lookup wires 
    #                     false -> ask missing node for ip, then continue with true

    cond do
      nodea == [] -> nodea# TODO: request nodea's ip
      nodeb == [] -> nodeb# TODO: request nodeb's ip
      nodea == [] && nodeb == [] -> {nodea, nodeb}# TODO: send request to both nodes for gathering theyr ip's
      true -> Logger.debug("*** init sending ***")# TODO: success -> initiate the transfer
    end

    {:noreply, state}
  end
  
  def handle_info({:register, %{node: %{ip: ip, name: name} = _node}}, state) do
    node = case Elixir.Registry.lookup(Registry.Servant, ip)  do
      [] -> Elixir.Registry.register(Registry.Servant, name, ip)
      entry -> entry
    end
    {:noreply, %{state | c_nodes: [node | state.c_nodes]}}
  end
  
  def handle_info({:register, %{wire: %{ip: ip, name: name} = _wire}}, state) do
    wire = case Elixir.Registry.lookup(Registry.Servant, ip)  do
      [] -> Elixir.Registry.register(Registry.Servant, name, ip)
      wire -> wire
    end
    {:noreply, %{state | c_wires: [wire | state.c_wires]}}
  end


    def handle_info({:new_connection, %{node: node, wire: wire}}, state) do
      # TODO: lookup registy(lookup_node()/lookup_wire()) for entries -> 
      node = lookup_ip_from(node.name)
      wire = lookup_ip_from(wire.name)
      #     case ip_exists true -> return ip through pubsub to calling node
      #                   false -> update c_nodes + update c_wires

      

      {:noreply,state}

    end

end

