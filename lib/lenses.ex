defmodule Ramen.Lenses do
  import Focus

  def setup do
    ~w(comment body html_url user login issue title number repository
       name owner pull_request review state requested_reviewer base author
       target_url commit assignee branches repo requested_reviewers)
    |> Enum.reduce(%{}, fn x, acc ->
      Map.put(acc, String.to_atom(x), Lens.make_lens(x))
    end)
  end

  def for(:pull_request) do
    lenses = setup()

    [
      {:author, lenses.user ~> lenses.login},
      {:url, lenses.html_url},
      {:title, lenses.title},
      {:number, lenses.number},
      {:requested_reviewers, lenses.requested_reviewers},
      {:repository, lenses.base ~> lenses.repo ~> lenses.name},
      {:organization, lenses.base ~> lenses.repo ~> lenses.owner ~> lenses.login}
    ]
  end

  def for(:issue) do
    lenses = setup()

    [
      {:url, lenses.issue ~> lenses.html_url},
      {:author, lenses.issue ~> lenses.user ~> lenses.login},
      {:title, lenses.issue ~> lenses.title},
      {:number, lenses.issue ~> lenses.number},
      {:body, lenses.issue ~> lenses.body},
      {:assignee, lenses.issue ~> lenses.assignee ~> lenses.login},
      {:repository, lenses.repository ~> lenses.name},
      {:organization, lenses.repository ~> lenses.owner ~> lenses.login}
    ]
  end

  def for(:comment) do
    lenses = setup()

    [
      {:url, lenses.comment ~> lenses.html_url},
      {:author, lenses.comment ~> lenses.user ~> lenses.login},
      {:title, lenses.issue ~> lenses.title},
      {:number, lenses.issue ~> lenses.number},
      {:body, lenses.comment ~> lenses.body},
      {:repository, lenses.repository ~> lenses.name},
      {:organization, lenses.repository ~> lenses.owner ~> lenses.login}
    ]
  end

  def for(:pull_request_review_comment) do
    lenses = setup()

    [
      {:body, lenses.comment ~> lenses.body},
      {:url, lenses.comment ~> lenses.html_url},
      {:author, lenses.comment ~> lenses.user ~> lenses.login},
      {:title, lenses.pull_request ~> lenses.title},
      {:number, lenses.pull_request ~> lenses.number},
      {:repository, lenses.repository ~> lenses.name},
      {:organization, lenses.repository ~> lenses.owner ~> lenses.login}
    ]
  end

  def for(:pull_request_review) do
    lenses = setup()

    [
      {:state, lenses.review ~> lenses.state},
      {:url, lenses.review ~> lenses.html_url},
      {:author, lenses.review ~> lenses.user ~> lenses.login},
      {:owner, lenses.pull_request ~> lenses.user ~> lenses.login},
      {:title, lenses.pull_request ~> lenses.title},
      {:number, lenses.pull_request ~> lenses.number},
      {:repository, lenses.repository ~> lenses.name},
      {:organization, lenses.repository ~> lenses.owner ~> lenses.login}
    ]
  end

  def for(:review_request) do
    lenses = setup()

    [
      {:reviewer, lenses.requested_reviewer ~> lenses.login},
      {:url, lenses.pull_request ~> lenses.html_url},
      {:title, lenses.pull_request ~> lenses.title},
      {:number, lenses.pull_request ~> lenses.number},
      {:requester, lenses.pull_request ~> lenses.user ~> lenses.login},
      {:repository, lenses.repository ~> lenses.name},
      {:organization, lenses.repository ~> lenses.owner ~> lenses.login}
    ]
  end

  def for(:build_status) do
    lenses = setup()

    [
      {:state, lenses.state},
      {:url, lenses.target_url},
      {:author, lenses.commit ~> lenses.author ~> lenses.login},
      {:branches, lenses.branches}
    ]
  end
  def for(_), do: []

  def apply(lenses, payload) do
    Enum.reduce(lenses, %{}, fn {name, lens}, acc -> 
      value = 
        case Focus.view(lens, payload) do
          {:error, _} -> nil
          value -> value
        end

      Map.put(acc, name, value)
    end)
  end
end
