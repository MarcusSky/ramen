defmodule PullRequest do
  defstruct [:title, :number]
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
  end
end

defmodule Ramen.Config do
  defstruct [:token, :client, :get]
end

defmodule Ramen do
  @spec new(String.t(), fun(), fun()) :: %Ramen.Config{}
  def new(token, client, get) do
    %Ramen.Config{token: token, client: client.(%{access_token: token}), get: get}
  end

  @spec list_pull_requests(String.t(), String.t(), %Ramen.Config{}) ::
          {:ok, [%PullRequest{}]} | {:error, String.t()}
  def list_pull_requests(owner, repository, config) do
    case do_list_pull_requests(owner, repository, config) do
      {200, pull_requests, _} -> {:ok, Enum.map(pull_requests, &Decoder.decode(&1))}
      {_, error_body, _} -> {:error, error_body}
    end
  end

  defp do_list_pull_requests(owner, repository, config) do
    config.get.(config.client, owner, repository, %{state: "open"})
  end

  def fetch_participants(owner, repository, number, config) do
    case do_fetch_participants(owner, repository, number, config) do
      {:ok, %{body: response_body}} -> 
        decoded_body = Poison.decode!(response_body)
        {:ok, decoded_body}
      {:error, error} -> {:error, error}
    end
  end

  defp do_fetch_participants(owner, repository, number, config) do
    body =
      "{ repository(owner: \"#{owner}\", name: \"#{repository}\") { pullRequest(number: #{number}) { participants(first: 100) { edges { node { login } } } } } }"

    encoded_body = Poison.encode!(%{query: body})

    HTTPoison.request(:post, "https://api.github.com/graphql", encoded_body, [
      {"Authorization", "Bearer #{config.token}"}
    ])
  end
end
