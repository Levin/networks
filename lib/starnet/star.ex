defmodule Starnet.Switch do
  @moduledoc """
    This module defines the connecting part in this network - the switch.
    It exchanges messages between nodes. Therefore it can accept data comming from a node 
    through a wire and sends the data to the specified receiver.
    A switch holds data just temporarily until the receiving part accepted the data package.
  """




end



defmodule Startnet.Node do
  
  @moduledoc """
    This module defines the single nodes in the star network.
    A node holds state about the existing data on it.
  """

end



defmodule Starnet.Wire do
  

  @moduledoc """
    This module defines the wires which connect nodes to the switch.
    A wire holds information about the data passing through it.
    Each wire is connected to one wire.
  """

end
