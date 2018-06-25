defmodule RamenTest do
  use ExUnit.Case
  doctest Ramen

  test "new/3" do
    assert %{client: _, token: "test_token", http_client: _, get: _} =
             Ramen.new("test_token", empty(), empty(), empty())
  end

  describe "list_pull_requests/3" do
    test "returns a tuple with a list of Pull Requests when given correct information" do
      get = fn _, _, _, _ -> {200, [%{"title" => "hello", "number" => 2}], %{}} end
      config = Ramen.new("valid_token", empty(), get, empty())

      assert {:ok, [%PullRequest{participants: nil} | _]} =
               Ramen.list_pull_requests("jaya", "jaya_bot_lab", config)
    end

    test "returns a tuple with an error given incorrect information" do
      get = fn _, _, _, _ -> {404, %{"error" => "not found"}, %{}} end
      config = Ramen.new("invalid_token", empty(), get, empty())

      assert {:error, _} = Ramen.list_pull_requests("jaya", "jaya_bot_lab", config)
    end

    test "returns a tuple with a list of Pull Requests and participants" do
      body =
        "{\"data\":{\"repository\":{\"pullRequest\":{\"participants\":{\"edges\":[{\"node\":{\"login\":\"MarcusSky\"}}]}}}}}"

      get = fn _, _, _, _ -> {200, [%{"title" => "hello", "number" => 2}], %{}} end
      http_client = fn _, _, _, _ -> {:ok, %{status_code: 200, body: body}} end
      config = Ramen.new("valid_token", empty(), get, http_client)

      assert {:ok, [%PullRequest{participants: [%Participant{}]} | _]} =
               Ramen.list_pull_requests("jaya", "jaya_bot_lab", config, with_participants: true)
    end
  end

  describe "fetch_participants/4" do
    test "retuns a tuple with a list of Participants" do
      body =
        "{\"data\":{\"repository\":{\"pullRequest\":{\"participants\":{\"edges\":[{\"node\":{\"login\":\"MarcusSky\"}}]}}}}}"

      http_client = fn _, _, _, _ -> {:ok, %{status_code: 200, body: body}} end
      config = Ramen.new("valid_token", empty(), empty(), http_client)

      assert {:ok, [%Participant{} | _]} =
               Ramen.fetch_participants("jaya", "jaya_bot_lab", 2, config)
    end

    test "retuns a tuple with errors and status code" do
      body = "{\"data\":{\"message\":\"invalid token\"}}"

      http_client = fn _, _, _, _ -> {:ok, %{status_code: 401, body: body}} end
      config = Ramen.new("invalid_token", empty(), empty(), http_client)

      assert {:error, 401, _} = Ramen.fetch_participants("jaya", "jaya_bot_lab", 2, config)
    end

    test "retuns a tuple with error and reason" do
      http_client = fn _, _, _, _ -> {:error, %{reason: "client broke"}} end
      config = Ramen.new("invalid_token", empty(), empty(), http_client)

      assert {:error, "client broke"} =
               Ramen.fetch_participants("jaya", "jaya_bot_lab", 2, config)
    end
  end

  defp empty, do: fn _ -> {} end
end
