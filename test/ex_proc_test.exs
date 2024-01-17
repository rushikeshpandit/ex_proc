defmodule ExProcTest do
  use ExUnit.Case
  doctest ExProc

  test "greets the world" do
    assert ExProc.hello() == :world
  end
end
