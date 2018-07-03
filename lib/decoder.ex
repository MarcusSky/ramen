defmodule Ramen.Decoder do
  @moduledoc """
  A module that knows how to translate GitHub's webhook
  payloads into understandable structs
  """

  alias Ramen.{PullRequest, Participant, Comment, PullRequestReview, ReviewRequest, BuildStatus}

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
  def decode(%{"action" => "created"} = payload, "issue_comment") do
    %{
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

    {:comment, :created,
     %Comment{
       body: body,
       url: url,
       comment_author: comment_author,
       title: title,
       number: issue_number,
       repository: repo_name,
       organization: organization
     }}
  end

  @spec decode(map(), String.t()) :: {atom, atom, %Comment{}}
  def decode(%{"action" => "created"} = payload, "pull_request_review_comment") do
    %{
      "comment" => %{
        "body" => body,
        "html_url" => url,
        "user" => %{
          "login" => comment_author
        }
      },
      "pull_request" => %{
        "title" => title,
        "number" => number
      },
      "repository" => %{
        "name" => repo_name,
        "owner" => %{
          "login" => organization
        }
      }
    } = payload

    {:comment, :created,
     %Comment{
       body: body,
       url: url,
       comment_author: comment_author,
       title: title,
       number: number,
       repository: repo_name,
       organization: organization
     }}
  end

  @spec decode(map(), String.t()) :: {atom, atom, %PullRequestReview{}}
  def decode(%{"action" => "submitted"} = payload, "pull_request_review") do
    %{
      "review" => %{
        "html_url" => url,
        "state" => state,
        "user" => %{
          "login" => reviewer
        }
      },
      "pull_request" => %{
        "title" => title,
        "number" => number
      },
      "repository" => %{
        "name" => repo_name,
        "owner" => %{
          "login" => organization
        }
      }
    } = payload

    review_state = if state == "approved", do: :approved, else: :changes_requested

    {:pull_request_review, review_state,
     %PullRequestReview{
       url: url,
       author: reviewer,
       title: title,
       number: number,
       repository: repo_name,
       organization: organization
     }}
  end

  @spec decode(map(), String.t()) :: {atom, atom, %ReviewRequest{}}
  def decode(%{"action" => "review_requested"} = payload, "pull_request") do
    %{
      "requested_reviewer" => %{
        "login" => reviewer
      },
      "pull_request" => %{
        "html_url" => url,
        "title" => title,
        "number" => number,
        "user" => %{
          "login" => requester
        }
      },
      "repository" => %{
        "name" => repo_name,
        "owner" => %{
          "login" => organization
        }
      }
    } = payload

    {:review_request, :created,
     %ReviewRequest{
       requester: requester,
       reviewer: reviewer,
       title: title,
       url: url,
       number: number,
       repository: repo_name,
       organization: organization
     }}
  end

  @spec decode(map(), String.t()) :: {atom, atom, %BuildStatus{}}
  def decode(payload, "status") do
    %{
      "state" => state,
      "target_url" => url,
      "commit" => %{
        "committer" => %{
          "login" => author
       }
      },
      "branches" => branches
    } = payload

    branch = List.first(branches) |> get_in(["name"])
    build_status = if state == "success", do: :success, else: :failure

    {:build_status, build_status,
     %BuildStatus{
       author: author,
       url: url,
       branch: branch
     }}
  end

  def decode(%{"action" => action} = _payload, event_name) do
    raise "Decoder not implemented for #{event_name} with action #{action}"
  end

  def decode(_payload, event_name) do
    raise "Decoder not implemented for #{event_name}"
  end
end
