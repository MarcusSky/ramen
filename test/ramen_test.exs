defmodule RamenTest do
  use ExUnit.Case
  doctest Ramen

  test "new/3" do
    assert %{client: _, get: _} = Ramen.new("test_token", fn token -> token end, fn -> {} end) 
  end

  describe "list_pull_requests/3" do
    test "returns a tuple with a list of Pull Requests when given correct information" do
      get = fn _, _, _, _ -> {200, [%{"title" => "hello"}], %{}} end
      client = fn _ -> {} end
      config = Ramen.new("valid_token", client, get)

      assert {:ok, [%PullRequest{} | _]} =
               Ramen.list_pull_requests("jaya", "jaya_bot_lab", config)
    end

    test "returns a tuple with an error given incorrect information" do
      get = fn _, _, _, _ -> {404, %{"error" => "not found"}, %{}} end
      client = fn _ -> {} end
      config = Ramen.new("fake_token", client, get)

      assert {:error, _} = Ramen.list_pull_requests("jaya", "jaya_bot_lab", config)
    end
  end
end
