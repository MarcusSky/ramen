defmodule Ramen.PullRequest do
  defstruct [:title, :number, :participants]
end

defmodule Ramen.PullRequestReview do
  defstruct [:author, :approved, :changes_requested, :url, :title, :repository]
end

defmodule Ramen.ReviewRequest do
  defstruct [:requester, :reviewer, :title, :url, :number, :repository, :organization]
end

defmodule Ramen.BuildStatus do
  defstruct [:author, :success, :url, :branch]
end

defmodule Ramen.Comment do
  defstruct [:body, :url, :comment_author, :title, :number, :repository, :organization]
end

defmodule Ramen.Participant do
  defstruct [:username]
end

defmodule Ramen.Config do
  defstruct [:token, :http_client]
end
