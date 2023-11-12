defmodule ConnectionTest do
  require Logger
  use ExUnit.Case
  doctest Connection

  describe "testing connection functionality" do
    
    test "creation of connection works" do
      Connection.start()
      %{active_connections: conns, old_connections: o_conns} = Connection.info()

      assert (conns == [] && o_conns == [])
    end

    test "adding a connection works" do
      
      Connection.start()

      mac_one = "asdf-31asdf-23d2d-23d"
      mac_two = "a-23d2d32--d-23d2d-dd"

      Connection.establish(mac_one, mac_two)
      status = Connection.info()
      assert length(status.active_connections) == 1

    end

    test "removeing a connection works" do
      
    end

  end


end
