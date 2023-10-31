defmodule Device do
  use GenServer
  require Logger


  def get_device_info() do
    GenServer.call(__MODULE__, :info)
  end

  def list_connections() do
    GenServer.call(__MODULE__, :list_connections)
  end

  def search_open_conns() do
    GenServer.call(__MODULE__, :search)
  end



  def start_link(params) do
    ports = 
      for x <- 1..16 do
        %{port: x, status: :open}
      end

    state = %{mac: params.mac, connections: [], ports: ports}
    Logger.debug("*** [#{__MODULE__}] has started ")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    Logger.debug("*** starting device with mac #{inspect state.mac} ")
    Phoenix.PubSub.subscribe(:networks, "connections")
    {:ok, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:list_connections, _from, state) do
    {:reply, state.connections, state}
  end

  def handle_call(:search, _from, state) do
    Phoenix.PubSub.broadcast(:networks, "connections", {:ping_all, :open?})
    {:reply, state, state}
  end

end
