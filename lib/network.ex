defmodule Network do
  
  use GenServer
  require Logger

  def add_device(name \\ "home", device) do
    GenServer.cast(String.to_atom(name), {:connect, device})
  end

  def detach_device(name \\ "home", device) do
    GenServer.cast(String.to_atom(name), {:dispatch, device})
  end

  def info(name \\ "home") do
    GenServer.call(String.to_atom(name), :info)
  end

  def start(name \\ "home") do
    GenServer.start_link(__MODULE__, nil, name: String.to_atom(name))
  end

  def init(_params) do
    Logger.debug("** [#{__MODULE__}] has started **")
    {:ok, %{devices: []}}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:connect, device}, state) do
    new_private_ip = ""
    new_device = %Device{device | ip: new_private_ip}
    {:noreply, %{state | devices: [new_device | state.devices]}}
  end

  def handle_cast({:dispatch, device}, state) do
    new_list = Enum.reject(state.devices, &(&1.mac == device.mac))
    {:noreply, %{state | devices: new_list}}
  end

end
