defmodule SwitchTest do
  alias Starnet.Switch
  use ExUnit.Case
  doctest Switch

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
  end

  test "close open port" do
    opened_ports = Switch.list_open_ports()
    Switch.open_port(4)

    assert length(opened_ports) == 1

    Switch.close_port(4)

    closed_ports = Switch.list_closed_ports()

    assert length(closed_ports) == 8

  end
end
