defmodule RamenTest do
  use ExUnit.Case
  doctest Ramen

  test "greets the world" do
    assert Ramen.hello() == :world
  end
end
