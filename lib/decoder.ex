defmodule Ramen.Decoder do
  @moduledoc """
  A module that knows how to translate GitHub's webhook
  payloads into understandable structs
  """

  alias Ramen.{PullRequest, Participant, Comment}

  def decode(payload, into: [PullRequest]) do
    %{"title" => title, "number" => number} = payload

    %PullRequest{title: title, number: number}
  end

  def decode(payload, into: [Participant]) do
    payload
    |> get_in(["data", "repository", "pullRequest", "participants", "edges"])
    |> Enum.map(&get_in(&1, ["node", "login"]))
    |> Enum.map(&%Participant{username: &1})
  end

  @spec decode(map(), String.t()) :: {atom, atom, %Comment{}}
  def decode(payload, "issue_comment") do
    %{
      "action" => "created",
      "comment" => %{
        "body" => body,
        "html_url" => url,
        "user" => %{
          "login" => comment_author
        }
      },
      "issue" => %{
        "title" => title,
        "number" => issue_number
      },
      "repository" => %{
        "name" => repo_name,
        "owner" => %{
          "login" => organization
        }
      }
    } = payload

    {:issue_comment, :created,
     %Comment{
       body: body,
       url: url,
       comment_author: comment_author,
       title: title,
       issue_number: issue_number,
       repository: repo_name,
       organization: organization
     }}
  end

  def decode(_payload, event_name) do
    raise "Decoder not implemented for #{event_name}"
  end
end
