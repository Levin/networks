defmodule Connection do
require Logger

  #@derive {Inspect, only: :name}
  # use crypto.generate here, sha256 evtl.
  # THINK: how do we need to use this 
  defstruct [:uuid, :mac, :port]

  def get_connection_info() do
    GenServer.call(__MODULE__, :info)
  end

  def establish(conn_one, conn_two) do
    GenServer.cast(__MODULE__, {:establish, conn_one, conn_two})
  end

  # FIXME:  begin to use the uuid as the name + __MODULE__
  def start(params) do
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end


  # FIXME: think about good names for pubsub channels
  def init(params) do
    Phoenix.PubSub.subscribe(:networks, "connector")
    state = 
      params
      |> Map.put(:active_connections, [])
      |> Map.put(:old_connections, [])

    {:ok, state}

  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:establish, one, two}, state) do

    case is_port_used(one.mac, one.port, state) || is_port_used(two.mac, two.port, state) do
      :used -> 
        Logger.debug("[#{}]")
        {:noreply, state}
      :unused -> {:noreply, %{state | active_connections: [{one, two} | state.active_connections]}}
    end


  end

  defp is_port_used(mac, port, state) do
    
    case state.active_connections
    |> Enum.filter(fn {device_one, device_two} -> device_one.mac == mac && device_one.port == port || device_two.mac == mac && device_two.port == port end) do
      [] -> :unused
      [_value] -> :used

    end

  end


end
