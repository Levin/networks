defmodule Connections do
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
    e_time = DateTime.utc_now()
    n_conn = %Connection{device_a: one, device_b: two, established: DateTime.to_string(e_time)}
    new_connections = [n_conn | state.active_connections]
    {:noreply, %{state | active_connections: new_connections}}
  end

  def handle_cast({:detach, {one, two}}, state) do
    state.active_connections
    |> Enum.filter(&(&1.device_a == one && &1.device_b == two || &1.device_a == two && &1.device_b == one))
    |> case do
      l_value -> 
        value = List.first(l_value)
        n_active = 
          Enum.filter(state.active_connections, &(&1.device_a == value.device_a && &1.device_b == value.device_b))

        n_old = [value |state.old_connections]
        {:noreply, %{active_connections: n_active, old_connections: n_old}}
      [] -> 
        {:noreply, state}

    end
  end 


end
