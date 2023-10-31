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
  end
end
