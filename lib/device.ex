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

  def filter_messages(mac) do
    GenServer.call(__MODULE__, {:filter, mac})
  end

  def search_connections, do: GenServer.cast(__MODULE__, :ping)

  def start(params) do
    ports = 
      for x <- 1..16 do
        %{port: x, status: :open}
      end

    state = %{mac: params.mac, connections: [], ports: ports, data: [], possible_connections: []}
    Logger.debug("*** [#{__MODULE__}] has started ")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.debug("*** starting device with mac #{inspect state.mac} ")
    Phoenix.PubSub.subscribe(:devices, "ports")
    Phoenix.PubSub.subscribe(:switches, "ports")


    {:ok, state}
  end

  def handle_call({:filter, mac}, _from, state) do

    logs? = case Enum.filter(state.connections, &(&1.device_one == mac || &1.device_two == mac)) do
      [] -> 
        Logger.debug("Sorry, no messages from this device #{mac} yet!")
        state.connections
      _result -> 
        Logger.debug("Found some activities around this #{mac} adress. This is the log: ")
        state.data
        |> Enum.filter(&(&1.from == mac || &1.to == mac))
        |> Enum.map(&("From: #{&1.from} to #{&1.to} : #{&1.data}"))
    end

    {:reply, logs?, state}
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

  def handle_cast(:ping, state) do
    Phoenix.PubSub.broadcast(:devices, "ports", {:ping_all, :open?})
    Phoenix.PubSub.broadcast(:switches, "ports", {:ping_all, :open?})
    {:noreply, state}
  end

  @impl true
  def handle_info({:ping_all, :open?}, state) do
    open_ports =  
      state.ports
      |> Enum.filter(&(&1.status == :open))

    Phoenix.PubSub.broadcast_from(:devices,  self(),"ports", {:ports, open_ports, create_handle(__MODULE__)})
    Phoenix.PubSub.broadcast_from(:switches,  self(),"ports", {:ports, open_ports, create_handle(__MODULE__)})
    Logger.debug("[#{__MODULE__}] sending data")
    {:noreply, state}
  end

  def handle_info({:ports, raw_ports, module}, state) do
    ports = 
      raw_ports
      |> Enum.map(fn {port, status} -> %{port: port, from: module, status: status} end)

    new_possible_connections = filter_possible_ports([ports | state.possible_connections])
    {:noreply, %{state | possible_connections: new_possible_connections}}
  end

  defp create_handle(module), do: "#{module}-#{inspect self()}"

  defp filter_possible_ports(portlist) do
    List.flatten(portlist) |> Enum.uniq()
  end

end
