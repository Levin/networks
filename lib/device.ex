defmodule Device do
  use GenServer
  require Logger


  def get_device_info() do
    GenServer.call(__MODULE__, :info)
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
    Logger.debug("*** starting device with mac #{inspect state.mac} }")
    {:ok, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

end
