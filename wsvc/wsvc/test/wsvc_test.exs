defmodule WsvcTest do
  use ExUnit.Case
  doctest Wsvc

  test "greets the world" do
    assert Wsvc.hello() == :world
  end
end
