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

defmodule Ramen.Config do
  defstruct [:client, :get]
end

defmodule Ramen do
  @spec new(String.t(), fun(), fun()) :: %Ramen.Config{}
  def new(token, client, get) do
    %Ramen.Config{client: client.(%{access_token: token}), get: get}
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
end
