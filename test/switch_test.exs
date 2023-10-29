defmodule SwitchTest do
  require Logger
  alias Starnet.Switch
  use ExUnit.Case
  doctest Switch

  describe "testing switch functionality" do

    test "portlist is 8 items long" do
      portlist = Switch.get_ports()
      assert length(portlist) == 8
    end

    test "only open ports in portlist" do
      portlist = Enum.reject(Switch.list_open_ports(), fn {_port, status} -> status == :open end)
      assert portlist == []
    end

    test "only closed ports in portlist" do
      portlist = Enum.reject(Switch.list_closed_ports(), fn {_port, status} -> status == :closed end)
      assert portlist == []
    end

    test "open closed port" do
      {port, status}  = {4, :closed}
      closed_ports = Switch.list_closed_ports()
      assert length(closed_ports) == 8
      Switch.open_port(port)
      opened_ports = Switch.list_open_ports()
      assert length(opened_ports) == 1
      Switch.close_port(port)
      Switch.close_port port
    end

    test "close open port" do
      opened_ports = Switch.list_open_ports()
      assert length(opened_ports) == 0
      Switch.open_port(4)
      new_opened_ports = Switch.list_open_ports()
      assert length(new_opened_ports) == 1
      Switch.close_port(4)
      old_opened_ports = Switch.list_open_ports()
      assert length(old_opened_ports) == 0
    end

    test "test open port" do
      port_number = 5
      Switch.open_port(5)
      assert Switch.port_open?(port_number) == :true
      Switch.close_port(5)
    end

    test "list devices/used ports -> empty" do
      devices = Switch.list_devices()
      assert Enum.reject(devices, &(&1.device)) == []
    end

    test "list devices/used ports -> 1 item" do
      device = "asdf-asdf-3asd-ddf2"
      port = 4

      Switch.open_port(4)
      Switch.connect_device(device, port)

      assert length(Switch.list_devices()) == 1

      Switch.close_port(4)
    end

    test "dispatch device from port" do
      device = "asdf-asdf-3asd-ddf2"
      port = 4

      Switch.open_port(port)
      Switch.connect_device(device, port)
      old_length = length(Switch.list_devices)
      Logger.debug("** switch holds #{old_length} devices")

      Switch.dispatch_device(device)
      new_length = length(Switch.list_devices)
      Logger.debug("** switch holds #{new_length} devices")
      assert old_length > new_length
      Switch.close_port(port)
    end

    test "provide port size" do
      port_sizes = [4, 8, 16, 32, 64, 128, 256]
      assert length(Switch.get_ports()) in port_sizes == true
    end

  end

  describe "testing device functionality" do
   

    test "device holds his mac" do
      mac = "234d-df31-doo2-lmj3"
      Device.start_link(%{mac: "234d-df31-doo2-lmj3"})
      assert Device.get_device_info() != nil
    end


  end



end
