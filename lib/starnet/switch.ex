defmodule Starnet.Switch do
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
    GenServer.call(__MODULE__, :list_used_ports)
  end

  def start_link(params) do
    Logger.debug("[#{__MODULE__}] has started")
    GenServer.start_link(__MODULE__, params, name: __MODULE__)
  end

  def init(params) do
    {:params, %{ports: ports}} = List.first(params)
    Logger.debug("*** starting switch with #{inspect ports} ports ***")
    Phoenix.PubSub.subscribe(:networks, "connections")
    ports = 
      for x <- 1..ports do
        {x, :closed}
      end
    Logger.debug("creating ports #{inspect ports}")

    {:ok,
     %{
       mac: ~c"00-B0-D0-63-C2-26",
       ports: ports,
       devices: [],
     }, {:continue, :setup}}
  end

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

end
