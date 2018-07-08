defmodule Ramen.Decoder do
  @moduledoc """
  A module that knows how to translate GitHub's webhook
  payloads into understandable structs
  """

  alias Ramen.{
    PullRequest,
    Participant,
    Comment,
    PullRequestReview,
    ReviewRequest,
    BuildStatus,
    Issue
  }

  def decode(payload, into: [PullRequest]) do
    %{"title" => title,
      "number" => number,
      "requested_reviewers" => requested_reviewers} = payload

    requested_reviewers =
      Enum.map(requested_reviewers, fn x ->
        username = get_in(x, ["login"])
        %Participant{username: username}
      end)

    values = [title: title, number: number, requested_reviewers: requested_reviewers]

    struct(PullRequest, values)
  end

  def decode(payload, into: [Participant]) do
    payload
    |> get_in(["data", "repository", "pullRequest", "participants", "edges"])
    |> Enum.map(&get_in(&1, ["node", "login"]))
    |> Enum.map(&%Participant{username: &1})
  end

  @spec decode(map(), String.t()) :: {atom, atom, %Comment{}}
  def decode(%{"action" => "created"} = payload, "issue_comment") do
    values =
      :comment
      |> Ramen.Lenses.for()
      |> Ramen.Lenses.apply(payload)

    {:comment, :created, struct(Comment, values)}
  end

  @spec decode(map(), String.t()) :: {atom, atom, %Comment{}}
  def decode(%{"action" => "created"} = payload, "pull_request_review_comment") do
    values =
      :pull_request_review_comment
      |> Ramen.Lenses.for()
      |> Ramen.Lenses.apply(payload)

    {:comment, :created, struct(Comment, values)}
  end

  @spec decode(map(), String.t()) :: {atom, atom, %PullRequestReview{}}
  def decode(%{"action" => "submitted"} = payload, "pull_request_review") do
    values =
      :pull_request_review
      |> Ramen.Lenses.for()
      |> Ramen.Lenses.apply(payload)

    review_state = String.to_atom(values.state)

    {:pull_request_review, review_state, struct(PullRequestReview, values)}
  end

  @spec decode(map(), String.t()) :: {atom, atom, %ReviewRequest{}}
  def decode(%{"action" => "review_requested"} = payload, "pull_request") do
    values =
      :pull_request
      |> Ramen.Lenses.for()
      |> Ramen.Lenses.apply(payload)

    {:review_request, :created, struct(ReviewRequest, values)}
  end

  @spec decode(map(), String.t()) :: {atom, atom, %BuildStatus{}}
  def decode(payload, "status") do
    values =
      :build_status
      |> Ramen.Lenses.for()
      |> Ramen.Lenses.apply(payload)

    branch = List.first(values.branches) |> get_in(["name"])
    values = Map.put(values, :branch, branch)

    build_status = if values.state == "success", do: :success, else: :failure

    {:build_status, build_status, struct(BuildStatus, values)}
  end

  @spec decode(map(), String.t()) :: {atom, atom, %Issue{}}
  @doc """
  Decodes an issue event. The second attribute on the tuple, namely `action`, can
  be the following values:

  - :assigned
  - :unassigned
  - :labeled
  - :unlabeled
  - :opened
  - :edited
  - :milestoned
  - :demilestoned
  - :closed
  - :reopened

  Returns a tuple containing {:issue, action, struct}
  """
  def decode(%{"action" => state} = payload, "issues") do
    values =
      :issue
      |> Ramen.Lenses.for()
      |> Ramen.Lenses.apply(payload)

    {:issue, String.to_atom(state), struct(Issue, values)}
  end

  def decode(%{"action" => action} = _payload, event_name) do
    raise "Decoder not implemented for #{event_name} with action #{action}"
  end

  def decode(_payload, event_name) do
    raise "Decoder not implemented for #{event_name}"
  end
end
