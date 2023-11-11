defmodule DeviceTest do
  require Logger
  use ExUnit.Case
  doctest Device
  describe "testing device functionality" do


    test "device holds his mac" do
      mac = "234d-df31-doo2-lmj3"
      Device.start_link(%{mac: "234d-df31-doo2-lmj3"})
      assert Device.get_device_info() != nil 
    end

    test "establish connection from device to device (mac - mac)" do
      mac_one = "234d-dfasdfasf"
      mac_two = "234d-df3"

      Device.link(mac_one, mac_two)
      %{connections: conns} = Device.get_device_info()
      assert length(conns) == 1

    end

    test "detach connection from two devices (mac - mac)" do
      mac_one = "234d-dfasdfasf"
      mac_two = "234d-df3"
      Device.detach(mac_one, mac_two)

      %{connections: conns} = Device.get_device_info()
      assert length(conns) == 0

    end


  end


end
