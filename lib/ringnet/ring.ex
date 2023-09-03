# TODO: 
#       Ring:
#       create 5 nodes(workers) from Ring.Ring -> function a for this
#       subscribe each node(worker) to the pubsub from worker.id+1 -> Enum.map(function b)
#       subscribe last one to worker.id = 0 -> case in function b
#       
#       Worker:
#       let every worker say its worker it and to which he is passing the connection
#       the last one should say goodby and end the program
#       

defmodule Ring.Ring do
  @moduledoc """
  {:ok, pid_r} = GenServer.start_link(Ring.Ring, "start") 
  {:ok, pid_w} = GenServer.start_link(Ring.Worker, %{id: 1})
  Ring.Ring.send_work({:todo, %{id: 0, task: "init db"}}) 
  Ring.Ring.send_work({:todo, %{id: 1, task: "create tables"}})
  Ring.Ring.send_work({:todo, %{id: 2, task: "insert data"}})  
  """
  require Logger
  use GenServer

  # startlink generic
  def start_link(params) do
    Logger.debug("*** starting #{__MODULE__}'s server ***")
    GenServer.start_link(__MODULE__, params)
  end

  # init -> sets up socket with array of running workers ~> starts pubsub setup 
  def init(params) do
    Logger.debug("*** initializing server ***")
    {:ok, %{workers: []}, {:continue, :setup_pubsub}}
  end

  # setup pubsub -> subscribes to ring channel
  def handle_continue(:setup_pubsub, state) do
    Logger.debug("*** setting up pubsub ***")
    handle_continue(:setup_ring, state)
    {:noreply, state}
  end

  # sets up the ring 
  # TODO: create list of numbers[worker id's] 
  # map number to start worker process (map(fn x -> Ring.Worker.handle_info({:start_worker, %{id: x}} end))) / startlink
  # call them indefinately
  def handle_continue(:setup_ring, state) do
    ids = [1,2,3,4,5,6,7,8]
    |> Enum.map(fn x -> ping_worker(x) end)


    [1,2,3,4,5,6,7,8]
    |> Enum.map(fn x -> Phoenix.PubSub.broadcast(Nets.PubSub, "ring", {:exit, %{w_id: x}}) end)


    {:noreply, %{state | workers: [ids | state.workers]}}
  end


  defp ping_worker(id) do
    worker = {:ping, %{w_id: id, message: "ping from worker-#{id}"}}
    Ring.Worker.start_link(%{w_id: id})
    Phoenix.PubSub.broadcast(Nets.PubSub, "ring", worker)
  end

end

defmodule Ring.Worker do
  require Logger
  use GenServer

  # starts the worker genserver with an worker id
  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
    Logger.debug("*** starting #{__MODULE__} #{inspect(params.w_id)} ***")
  end

  # initializes the Worker, subscribes to ring too + TODO: update workers list with new id
  def init(params) do
    Logger.debug("*** initializing #{__MODULE__} server ***")
    Phoenix.PubSub.subscribe(Nets.PubSub, "ring")

    {:ok,
     %{
        worker: params.w_id
      }}
  end

  # subscribes to the next workers channel TODO: and sends him a message to call the next one
  def handle_info({:ping, %{w_id: id, message: msg}} = ping, state) do
    Logger.debug("*** working ping #{id} sending message: #{msg}***")
    Phoenix.PubSub.broadcast(Nets.PubSub, "ring", {:next, %{w_id: id+1}})

    {:noreply, state}
  end

  def handle_info({:next, %{w_id: id}}, state) do
    case id do
      nil 
        ->
          Logger.debug(" *** worker lost ***")

      _  
        -> 
          Logger.debug("*** got ping from worker-#{id-1} ***")
          Logger.debug("*** giving ping to worker-#{id+1} ***")
    end

    {:noreply, state} 
  end 

  def handle_info({:exit, %{w_id: id}}, state) do
    Logger.debug("*** worker-#{id} is shutting down ***")
    {:noreply, %{state | worker: nil}}   
  end

end
