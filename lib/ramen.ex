defmodule PullRequest do
  defstruct [:title, :number, :participants]
end

defmodule Participant do
  defstruct [:username]
end

defmodule Decoder do
  def decode(payload, into: PullRequest) do
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
  defstruct [:token, :http_client]
end

defmodule Ramen do
  @spec new(String.t(), fun()) :: %Ramen.Config{}
  def new(token, http_client) do
    %Ramen.Config{token: token, http_client: http_client}
  end

  @spec list_pull_requests(String.t(), String.t(), %Ramen.Config{}) ::
          {:ok, [%PullRequest{}]} | {:error, String.t()}
  def list_pull_requests(owner, repository, config) do
    case do_list_pull_requests(owner, repository, config) do
      {:ok, %{status_code: 200, body: pull_requests}} ->
        prs =
          pull_requests
          |> Poison.decode!()
          |> Enum.map(&Decoder.decode(&1, into: PullRequest))

        {:ok, prs}

      {:ok, %{status_code: status_code, body: error_body}} ->
        {:error, Poison.decode!(error_body)}

      {:error, %{reason: reason}} ->
        {:error, reason}
    end
  end

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

  @spec add_participants(%PullRequest{}, list(Participant)) :: %PullRequest{
          participants: list(Participant)
        }
  defp add_participants(pull_request, participants),
    do: Map.put(pull_request, :participants, participants)

  defp do_list_pull_requests(owner, repository, config) do
    url = "https://api.github.com/repos/#{owner}/#{repository}/pulls"
    get_with_auth(url, config)
  end

  defp get_with_auth(url, config = %Ramen.Config{}) do
    headers = [{"Authorization", "Bearer #{config.token}"}]
    config.http_client.(:get, url, "", headers)
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
