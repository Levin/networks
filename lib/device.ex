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

  def link(mac_one, mac_two) do
    GenServer.cast(__MODULE__, {:link, {mac_one, mac_two}})
  end

  def detach(mac_one, mac_two) do
    GenServer.call(__MODULE__, {:detach, {mac_one, mac_two}})
  end

  def send(data, {mac_one, mac_two}) do
    GenServer.cast(__MODULE__, {:send, {data, mac_one, mac_two}})
  end

  def start_link(params) do
    ports = 
      for x <- 1..16 do
        %{port: x, status: :open}
      end

    state = %{mac: params.mac, connections: [], ports: ports, data: []}
    Logger.debug("*** [#{__MODULE__}] has started ")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    Logger.debug("*** starting device with mac #{inspect state.mac} ")
    Phoenix.PubSub.subscribe(:networks, "connections")
    {:ok, state}
  end

  def handle_call({:detach, {one, two}}, _from, state) do
    new_connections = Enum.reject(state.connections, &(&1.device_one == one && &1.device_two == two))
    {:reply, state, %{state | connections: new_connections}}
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

  def handle_cast({:send, {data, sender, receiver}}, state) do
    case Enum.filter(state.connections, &((&1.device_one == sender && &1.device_two == receiver)) || (&1.device_one == receiver && &1.device_two == sender)) do
      [] -> 
        Logger.debug("Sorry, #{sender} could not send data #{data} to #{receiver}")
        :failed
        {:noreply, state}
      _entry -> 
        Logger.debug("Sorry, #{sender} could not send data #{data} to #{receiver}")
        new_data = [%{from: sender, to: receiver, data: data} | state.data]
        {:noreply, %{state | data: new_data}}
        
    end
  end

  def handle_cast({:link, {one, two}}, state) do
    new_connections = [%{device_one: one, device_two: two} | state.connections]
    {:noreply, %{state | connections: new_connections}}
  end

end
