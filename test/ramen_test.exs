defmodule RamenTest do
  use ExUnit.Case
  doctest Ramen

  test "new/3" do
    assert %{client: _, token: "test_token", http_client: _, get: _} =
             Ramen.new("test_token", empty(), empty(), empty())
  end

  describe "list_pull_requests/3" do
    setup do
      get = get(200, [%{"title" => "hello", "number" => 2}])

      %{get: get}
    end

    test "returns a tuple with a list of Pull Requests when given correct information", %{get: get} do
      config = Ramen.new("valid_token", empty(), get, empty())

      assert {:ok, [%PullRequest{participants: nil} | _]} =
               Ramen.list_pull_requests("jaya", "jaya_bot_lab", config)
    end

    test "returns a tuple with an error given incorrect information" do
      get = get(404, %{"error" => "not found"})
      config = Ramen.new("invalid_token", empty(), get, empty())

      assert {:error, _} = Ramen.list_pull_requests("jaya", "jaya_bot_lab", config)
    end

    test "returns a tuple with a list of Pull Requests and participants", %{get: get} do
      body =
        "{\"data\":{\"repository\":{\"pullRequest\":{\"participants\":{\"edges\":[{\"node\":{\"login\":\"MarcusSky\"}}]}}}}}"
      http_client = http_client(:ok, %{status_code: 200, body: body})

      config = Ramen.new("valid_token", empty(), get, http_client)

      assert {:ok, [%PullRequest{participants: [%Participant{}]} | _]} =
               Ramen.list_pull_requests("jaya", "jaya_bot_lab", config, with_participants: true)
    end
  end

  describe "fetch_participants/4" do
    test "retuns a tuple with a list of Participants" do
      body =
        "{\"data\":{\"repository\":{\"pullRequest\":{\"participants\":{\"edges\":[{\"node\":{\"login\":\"MarcusSky\"}}]}}}}}"
      http_client = http_client(:ok, %{status_code: 200, body: body})

      config = Ramen.new("valid_token", empty(), empty(), http_client)

      assert {:ok, [%Participant{} | _]} =
               Ramen.fetch_participants("jaya", "jaya_bot_lab", 2, config)
    end

    test "retuns a tuple with errors and status code" do
      body = "{\"data\":{\"message\":\"invalid token\"}}"
      http_client = http_client(:ok, %{status_code: 401, body: body})

      config = Ramen.new("invalid_token", empty(), empty(), http_client)

      assert {:error, 401, _} = Ramen.fetch_participants("jaya", "jaya_bot_lab", 2, config)
    end

    test "retuns a tuple with error and reason" do
      http_client = http_client(:error, %{reason: "client broke"})
      config = Ramen.new("invalid_token", empty(), empty(), http_client)

      assert {:error, "client broke"} =
               Ramen.fetch_participants("jaya", "jaya_bot_lab", 2, config)
    end
  end

  defp empty, do: fn _ -> {} end
  defp get(status_code, body), do: fn _, _, _, _ -> {status_code, body, %{}} end
  defp http_client(status_atom, body), do: fn _, _, _, _ -> {status_atom, body} end
end
