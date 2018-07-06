defmodule Ramen.LensesTest do
  use ExUnit.Case, async: true

  alias Ramen.Lenses

  test "setup/0" do
    result = Lenses.setup()

    assert is_map(result)
    assert %{comment: _, body: _} = result
  end

  describe "for/1" do
    test "returns a list of lenses for issue" do
      result = Lenses.for(:issue)

      assert is_list(result)

      assert [
               url: %Lens{get: _, put: _},
               author: %Lens{get: _, put: _},
               title: %Lens{get: _, put: _},
               number: %Lens{get: _, put: _},
               body: %Lens{get: _, put: _},
               assignee: %Lens{get: _, put: _},
               repository: %Lens{get: _, put: _},
               organization: %Lens{get: _, put: _}
             ] = result
    end

    test "returns a list of lenses for comment" do
      result = Lenses.for(:comment)

      assert is_list(result)

      assert [
               url: %Lens{get: _, put: _},
               author: %Lens{get: _, put: _},
               title: %Lens{get: _, put: _},
               number: %Lens{get: _, put: _},
               body: %Lens{get: _, put: _},
               repository: %Lens{get: _, put: _},
               organization: %Lens{get: _, put: _}
             ] = result
    end

    test "returns a list of lenses for pull_request_review_comment" do
      result = Lenses.for(:pull_request_review_comment)

      assert is_list(result)

      assert [
               body: %Lens{get: _, put: _},
               url: %Lens{get: _, put: _},
               author: %Lens{get: _, put: _},
               title: %Lens{get: _, put: _},
               number: %Lens{get: _, put: _},
               repository: %Lens{get: _, put: _},
               organization: %Lens{get: _, put: _}
             ] = result
    end

    test "returns a list of lenses for pull_request_review" do
      result = Lenses.for(:pull_request_review)

      assert is_list(result)

      assert [
               state: %Lens{get: _, put: _},
               url: %Lens{get: _, put: _},
               author: %Lens{get: _, put: _},
               owner: %Lens{get: _, put: _},
               title: %Lens{get: _, put: _},
               number: %Lens{get: _, put: _},
               repository: %Lens{get: _, put: _},
               organization: %Lens{get: _, put: _}
             ] = result
    end

    test "returns a list of lenses for pull_request" do
      result = Lenses.for(:pull_request)

      assert is_list(result)

      assert [
               reviewer: %Lens{get: _, put: _},
               url: %Lens{get: _, put: _},
               title: %Lens{get: _, put: _},
               number: %Lens{get: _, put: _},
               requester: %Lens{get: _, put: _},
               repository: %Lens{get: _, put: _},
               organization: %Lens{get: _, put: _}
             ] = result
    end

    test "returns a list of lenses for build_status" do
      result = Lenses.for(:build_status)

      assert is_list(result)

      assert [
               state: %Lens{get: _, put: _},
               url: %Lens{get: _, put: _},
               author: %Lens{get: _, put: _},
               branches: %Lens{get: _, put: _}
             ] = result
    end

    test "returns an empty list when not supported" do
      result = Lenses.for(:not_supported)

      assert is_list(result)
      assert [] = result
    end
  end

  describe "apply/2" do
    test "uses comment lens to transform payload into map" do
      payload =
        File.read!("payloads/issue_comment.json")
        |> Poison.decode!()

      result =
        Lenses.for(:comment)
        |> Lenses.apply(payload)

      assert is_map(result)

      assert %{
               author: "baxterthehacker",
               body: "You are totally right! I'll get this fixed right away.",
               number: 2,
               organization: "baxterthehacker",
               repository: "public-repo",
               title: "Spelling error in the README file",
               url:
                 "https://github.com/baxterthehacker/public-repo/issues/2#issuecomment-99262140"
             } = result
    end

    test "uses pull_request_review_comment lens to transform payload into map" do
      payload =
        File.read!("payloads/pull_request_review_comment.json")
        |> Poison.decode!()

      result =
        Lenses.for(:pull_request_review_comment)
        |> Lenses.apply(payload)

      assert is_map(result)

      assert %{
               author: "Codertocat",
               body: "Maybe you should use more emojji on this line.",
               number: 1,
               organization: "Codertocat",
               repository: "Hello-World",
               title: "Update the README with new information",
               url: "https://github.com/Codertocat/Hello-World/pull/1#discussion_r191908831"
             } = result
    end

    test "uses pull_request_review lens to transform payload into map" do
      payload =
        File.read!("payloads/pull_request_review_approved.json")
        |> Poison.decode!()

      result =
        Lenses.for(:pull_request_review)
        |> Lenses.apply(payload)

      assert is_map(result)

      assert %{
               author: "Codertocat",
               number: 1,
               organization: "Codertocat",
               repository: "Hello-World",
               state: "approved",
               title: "Update the README with new information",
               url: "https://github.com/Codertocat/Hello-World/pull/1#pullrequestreview-124575911"
             } = result
    end

    test "uses pull_request lens to transform payload into map" do
      payload =
        File.read!("payloads/review_requested.json")
        |> Poison.decode!()

      result =
        Lenses.for(:pull_request)
        |> Lenses.apply(payload)

      assert is_map(result)

      assert %{
               number: 59,
               organization: "jaya",
               repository: "jaya_bot_lab",
               requester: "MarcusSky",
               reviewer: "roehst",
               title: "Issue Comment ",
               url: "https://github.com/jaya/jaya_bot_lab/pull/59"
             } = result
    end

    test "uses build_status lens to transform payload into map" do
      payload =
        File.read!("payloads/build_status_success.json")
        |> Poison.decode!()

      result =
        Lenses.for(:build_status)
        |> Lenses.apply(payload)

      assert is_map(result)

      assert %{
               author: "web-flow",
               branches: _,
               state: "success",
               url: "google.com"
             } = result
    end

    test "uses issue lens to transform payload into map" do
      payload =
        File.read!("payloads/issue_created.json")
        |> Poison.decode!()

      result =
        Lenses.for(:issue)
        |> Lenses.apply(payload)

      assert is_map(result)

      assert %{
               assignee: nil,
               author: "Codertocat",
               body: "It looks like you accidently spelled 'commit' with two 't's.",
               number: 2,
               organization: "Codertocat",
               repository: "Hello-World",
               title: "Spelling error in the README file",
               url: "https://github.com/Codertocat/Hello-World/issues/2"
             } = result
    end

    test "does not decode when given incorrect lenses" do
      payload =
        File.read!("payloads/issue_created.json")
        |> Poison.decode!()

      result =
        Lenses.for(:not_supported)
        |> Lenses.apply(payload)

      assert is_map(result)
      assert %{} == result
    end
  end
end
