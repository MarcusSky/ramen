defmodule PullRequest do
  defstruct [:title]
end

defmodule Decoder do
  @spec decode(%{}) :: %PullRequest{}
  def decode(payload) do
    %{"title" => title} = payload

    %PullRequest{title: title}
  end
end

defmodule Ramen do
  @spec new(String.t()) :: %{access_token: String.t()}
  def new(access_token) do
    %{access_token: access_token}
  end

  @spec list_pull_requests(String.t(), String.t(), struct()) ::
          {:ok, [%PullRequest{}]} | {:error, String.t()}
  def list_pull_requests(owner, repository, client) do
    case do_list_pull_requests(owner, repository, client) do
      {200, pull_requests, _} -> {:ok, Enum.map(pull_requests, &Decoder.decode(&1))}
      {_, error_body, _} -> {:error, error_body}
    end
  end

  defp do_list_pull_requests(owner, repository, client) do
    Tentacat.Pulls.filter(Tentacat.Client.new(client), owner, repository, %{state: "open"})
  end
end
