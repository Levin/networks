defmodule Connection do
  use GenServer
  require Logger

  def info() do
    GenServer.call(__MODULE__, :info)
  end

  def establish(device_one, device_two) do
    GenServer.cast(__MODULE__, {:establish, {device_one, device_two}})
  end

  def detach(device_one, device_two) do
    GenServer.cast(__MODULE__, {:detach, {device_one, device_two}})
  end

  # FIXME:  begin to use the uuid as the name + __MODULE__
  def start() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(params) do
    state = 
      params
      |> Map.put(:active_connections, [])
      |> Map.put(:old_connections, [])

    {:ok, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end


  def handle_cast({:establish, {one, two}}, state) do
    new_connections = [%{device_one: one, device_two: two} | state.active_connections]

    {:noreply, %{state | active_connections: new_connections}}
  end

  def handle_cast({:detach, {one, two}}, state) do
    conns = 
      case state.active_connections
      |> Enum.reject(&((&1.device_one != one && &1.device_two != two) || (&1.device_one != two && &1.device_two != one))) do
        [] -> :no_connection
        list -> list
    end
    {:noreply, state}
  end 


end
