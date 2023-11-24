defmodule Connection do
  defstruct id: UUID.uuid1(), device_a: :string, device_b: :string, established: :string
end
