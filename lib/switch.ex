defmodule Switch do
  @moduledoc """
    This module defines the connecting part in this network - the switch.
    It exchanges messages between nodes. Therefore it can accept data comming from a node 
    through a wire and sends the data to the specified receiver.
    A switch holds data just temporarily until the receiving part accepted the data package.
  """

  # NOTE: monitor if HashSet makes sense       /done/make c_nodes/c_wires accept nodes/wires just on time -> see what makes sense

  use GenServer
  require Logger


  
  def connect_device(mac, port) do
    GenServer.cast(__MODULE__, {:connect_device, {mac, port}})
  end

  def dispatch_device(mac) do
    GenServer.cast(__MODULE__, {:dispatch_device, mac})
  end

  def open_port(port) do
    GenServer.cast(__MODULE__, {:open_port, port})
  end

  def close_port(port) do
    GenServer.cast(__MODULE__, {:close_port, port})
  end

  def get_switch_info() do
    GenServer.call(__MODULE__, :info)
  end

  def list_devices() do
    GenServer.call(__MODULE__, :list_devices)
  end

  def get_ports() do
    GenServer.call(__MODULE__, :list_ports)
  end

  def list_open_ports() do
    GenServer.call(__MODULE__, :list_open_ports)
  end

  def list_closed_ports() do
    GenServer.call(__MODULE__, :list_closed_ports)
  end

  def list_used_ports() do
    GenSever.call(__MODULE__, :list_used_ports)
  end

  def search_connections, do: GenServer.cast(__MODULE__, :ping)

  def start(params) do
    Logger.debug("[#{__MODULE__}] has started")
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end

  @impl true
  def init(%{ports: ports} = _params) when is_number(ports) do
    Logger.debug("*** starting switch with #{inspect ports} ports ***")
    ports = 
      for x <- 1..ports do
        {x, :closed}
      end
    Logger.debug("creating ports #{inspect ports}")
    Phoenix.PubSub.subscribe(:switches, "ports")
    Phoenix.PubSub.subscribe(:devices, "ports")

    {:ok,
      %{
        mac: ~c"00-B0-D0-63-C2-26",
        ports: ports,
        devices: [],
        possible_ports: [],
      }, {:continue, :setup}}
  end

  @impl true
  def handle_cast({:close_port, open_port}, state) do
    changed_port = 
      state.ports
      |> Enum.filter(fn {port, _status} -> port == open_port end)
      |> Enum.map(fn {port, _status} -> {port, :closed} end)

    filtered_ports = 
      Enum.reject(
        state.ports, 
        fn {port, _status} -> port == open_port end
      )

    Logger.debug("all ports == #{inspect changed_port ++ filtered_ports}")

    {:noreply, %{state | ports: changed_port ++ filtered_ports}}
  end

  def handle_cast(:ping, state) do
    Logger.debug("called ping on switch")
    Phoenix.PubSub.broadcast(:devices, "ports", {:ping_all, :open?})
    Phoenix.PubSub.broadcast(:switches, "ports", {:ping_all, :open?})
    {:noreply, state}
  end

  def handle_cast({:open_port, closed_port}, state) do
    changed_port = 
      state.ports
      |> Enum.filter(fn {port, _status} -> port == closed_port end)
      |> Enum.map(fn {port, _status} -> {port, :open} end)

    filtered_ports = state.ports
    |> Enum.reject(fn {port, _} -> port == closed_port end)

    {:noreply, %{state | ports: filtered_ports ++ changed_port}}
  end

  def handle_cast({:connect_device, {mac, port}}, state) do
    old_devices = state.devices
    case Enum.filter(old_devices, &(&1.device == mac)) do
      [] -> {:noreply, %{state |devices: [%{device: mac, port: port} | old_devices]}}
      [_value] -> {:noreply, state}
    end
  end

  def handle_cast({:dispatch_device, mac}, state) do

    case Enum.filter(state.devices, &(&1.device == mac)) do
      [] -> {:noreply, state}
      [_value] -> 
        new_devices = Enum.reject(state.devices, &(&1.device == mac))
        {:noreply, %{state | devices: new_devices}}
    end
  end

  def handle_continue(:setup, state) do
    {:noreply, state}
  end

  def handle_call(:info, _form ,state) do
    {:reply, state, state}
  end

  def handle_call(:list_devices, _from, state) do
    {:reply, state.devices, state}
  end

  def handle_call(:list_ports, _from, state) do
    {:reply, state.ports, state}
  end

  def handle_call(:list_open_ports, _from, state) do
    open_ports = 
      state.ports
      |> Enum.filter(fn {_port, status} -> status == :open end)

    {:reply, open_ports, state}
  end

  def handle_call(:list_closed_ports, _from, state) do
    closed_ports = 
      state.ports
      |> Enum.filter(fn {_port, status} -> status == :closed end)

    {:reply, closed_ports, state}
  end

  @impl true
  def handle_info({:ping_all, :open?}, state) do
    open_ports =
      state.ports
      |> Enum.map(fn {port, _status} -> {port, :open} end)

    Phoenix.PubSub.broadcast_from(:switches, self(), "ports", {:ports, open_ports, create_handle(__MODULE__)})
    Phoenix.PubSub.broadcast_from(:devices, self(), "ports", {:ports, open_ports, create_handle(__MODULE__)})
    Logger.debug("[#{__MODULE__}] sending data")
    {:noreply, state}
  end

  def handle_info({:ports, raw_ports, module}, state) do
    ports = 
      raw_ports
      |> Enum.map(fn info -> Map.put(info, :from, module) end)

    new_possible_ports = filter_possible_ports([ports | state.possible_ports])
    {:noreply, %{state | possible_ports: new_possible_ports}}
  end

  defp change_state(:open, {port, status} = port_change, searched_port) do
    Logger.debug("change: #{inspect port_change}")
    case port == searched_port do
      true -> {port, :open}
      false -> {port, status}
    end
  end

  def port_open?(port_number) do
    port_list = list_open_ports()
    case Enum.reject(port_list, fn {port, _status} -> port != port_number end) do
      [] -> :false
      [port] -> :true
    end
  end

  def get_connected_device(port) do
      port
  end


  defp create_handle(module), do: "#{module}-#{inspect self()}"

  defp filter_possible_ports(portlist) do
    List.flatten(portlist) |> Enum.uniq()
  end

end
