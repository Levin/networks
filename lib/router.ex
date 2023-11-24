defmodule Router do
  use GenServer
  require Logger

  def ipv4(device_one, device_two) do
    GenServer.cast(__MODULE__, {:ipv4, device_one, device_two})
  end

  def info() do
    GenServer.call(__MODULE__, :info)
  end

  def start(ports \\ 24, mac \\ "dsg2-hefv-o645-3rgf") do
    Logger.debug("[#{__MODULE__}] is starting with #{ports} and #{mac}")
    GenServer.start_link(__MODULE__, %{ports: ports, mac: mac}, name: __MODULE__)
  end

  def init(params) do
    ports =
      Enum.to_list(
        for x <- 1..params.ports do
          {x, :closed}
        end
      )

    {:ok, %{ports: ports, mac: params.mac, connections: []}}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:ipv4, ip_o, ip_t}, state) do
    {:noreply, state}
  end
end
