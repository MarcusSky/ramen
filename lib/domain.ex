defmodule Ramen.PullRequest do
  defstruct [:title, :number, :participants]
end

defmodule Ramen.PullRequestReview do
  defstruct [:author, :approved, :changes_requested, :url, :title, :repository]
end

defmodule Ramen.PullRequestReviewComment do
  defstruct [:body, :url, :comment_author, :title, :number, :repository, :organization]
end

defmodule Ramen.ReviewRequest do
  defstruct [:requester, :reviewer, :title, :url, :number, :repository, :organization]
end

defmodule Ramen.BuildStatus do
  defstruct [:author, :success, :url, :branch]
end

defmodule Ramen.IssueComment do
  defstruct [:body, :url, :comment_author, :title, :number, :repository, :organization]
end

defmodule Ramen.Participant do
  defstruct [:username]
end

defmodule Ramen.Config do
  defstruct [:token, :http_client]
end

