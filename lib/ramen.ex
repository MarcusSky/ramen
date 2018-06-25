defmodule PullRequest do
  defstruct [:title, :number, :participants]
end

defmodule Participant do
  defstruct [:username]
end

defmodule Decoder do
  @spec decode(%{}) :: %PullRequest{}
  def decode(payload) do
    %{"title" => title, "number" => number} = payload

    %PullRequest{title: title, number: number}
  end

  def decode(payload, into: Participant) do
    payload
    |> get_in(["data", "repository", "pullRequest", "participants", "edges"])
    |> Enum.map(&get_in(&1, ["node", "login"]))
    |> Enum.map(&%Participant{username: &1})
  end
end

defmodule Ramen.Config do
  defstruct [:token, :client, :get, :http_client]
end

defmodule Ramen do
  @spec new(String.t(), fun(), fun(), fun()) :: %Ramen.Config{}
  def new(token, client, get, http_client) do
    %Ramen.Config{
      token: token,
      client: client.(%{access_token: token}),
      get: get,
      http_client: http_client
    }
  end

  @spec list_pull_requests(String.t(), String.t(), %Ramen.Config{}) ::
          {:ok, [%PullRequest{}]} | {:error, String.t()}
  def list_pull_requests(owner, repository, config, opts \\ []) do
    case do_list_pull_requests(owner, repository, config) do
      {200, pull_requests, _} ->
        prs = decode_pull_requests(pull_requests)

        if should_fetch_participants?(opts) do
          {:ok, Enum.map(prs, &add_participants(&1, owner, repository, config))}
        else
          {:ok, prs}
        end

      {_, error_body, _} ->
        {:error, error_body}
    end
  end

  defp should_fetch_participants?(opts), do: Keyword.get(opts, :with_participants)
  defp decode_pull_requests(body), do: Enum.map(body, &Decoder.decode(&1))

  def fetch_participants(owner, repository, number, config) do
    case do_fetch_participants(owner, repository, number, config) do
      {:ok, %{status_code: 200, body: response_body}} ->
        participants =
          response_body
          |> Poison.decode!()
          |> Decoder.decode(into: Participant)

        {:ok, participants}

      {:ok, %{status_code: status_code, body: error_body}} ->
        decoded_body = Poison.decode!(error_body)
        {:error, status_code, decoded_body}

      {:error, %{reason: reason}} ->
        {:error, reason}
    end
  end

  defp add_participants(pr, owner, repository, config) do
    case fetch_participants(owner, repository, pr.number, config) do
      {:ok, participants} ->
        Map.put(pr, :participants, participants)
    end
  end

  defp do_list_pull_requests(owner, repository, config) do
    config.get.(config.client, owner, repository, %{state: "open"})
  end

  defp do_fetch_participants(owner, repository, number, config) do
    body =
      "{ repository(owner: \"#{owner}\", name: \"#{repository}\") { pullRequest(number: #{number}) { participants(first: 100) { edges { node { login } } } } } }"

    encoded_body = Poison.encode!(%{query: body})

    config.http_client.(:post, "https://api.github.com/graphql", encoded_body, [
      {"Authorization", "Bearer #{config.token}"}
    ])
  end
end
