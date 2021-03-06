defmodule Ramen.PullRequest do
  defstruct [:author, :url, :title, :number, :participants, :requested_reviewers, :repository, :organization]
end

defmodule Ramen.Issue do
  defstruct [:body, :url, :author, :assignee, :title, :number, :repository, :organization]
end

defmodule Ramen.PullRequestReview do
  defstruct [:author, :owner, :url, :title, :number, :repository, :organization]
end

defmodule Ramen.ReviewRequest do
  defstruct [:requester, :reviewer, :title, :url, :number, :repository, :organization]
end

defmodule Ramen.BuildStatus do
  defstruct [:author, :url, :branch]
end

defmodule Ramen.Comment do
  defstruct [:body, :url, :author, :title, :number, :repository, :organization]
end

defmodule Ramen.Participant do
  defstruct [:username]
end

defmodule Ramen.Config do
  defstruct [:token, :http_client]
end
