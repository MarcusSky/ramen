defmodule Ramen.DecoderTest do
  use ExUnit.Case, async: true

  alias Ramen.Decoder
  alias Ramen.{PullRequest, Participant, Comment, BuildStatus, PullRequestReview, ReviewRequest}

  describe "decode/2 - non-webhook" do
    test "decodes into a Pull Request" do
      payload = %{"title" => "Title", "number" => 1}

      assert %PullRequest{title: "Title", number: 1} =
               Decoder.decode(payload, into: [PullRequest])
    end

    test "decodes into a Participant" do
      payload = %{
        "data" => %{
          "repository" => %{
            "pullRequest" => %{
              "participants" => %{"edges" => [%{"node" => %{"login" => "MarcusSky"}}]}
            }
          }
        }
      }

      assert [%Participant{username: "MarcusSky"}] = Decoder.decode(payload, into: [Participant])
    end
  end

  describe "decode/2" do
    test "decodes into a Comment" do
      payload =
        File.read!("payloads/issue_comment.json")
        |> Poison.decode!()

      assert {:comment, :created, %Comment{}} = Decoder.decode(payload, "issue_comment")
    end

    test "decodes into a Comment from a PullRequest - submitted" do
      payload =
        File.read!("payloads/pull_request_review_comment.json")
        |> Poison.decode!()

      assert {:comment, :created, %Comment{}} =
               Decoder.decode(payload, "pull_request_review_comment")
    end

    test "does not decode an edited comment" do
      payload =
        File.read!("payloads/pull_request_review_edited.json")
        |> Poison.decode!()

      assert_raise RuntimeError, ~r/for pull_request_review_comment with action edited/, fn ->
        Decoder.decode(payload, "pull_request_review_comment")
      end
    end

    test "decodes into a PullRequestReview - approved" do
      payload =
        File.read!("payloads/pull_request_review_approved.json")
        |> Poison.decode!()

      assert {:pull_request_review, :approved, %PullRequestReview{}} =
               Decoder.decode(payload, "pull_request_review")
    end

    test "decodes into a PullRequestReview - changes_requested" do
      payload =
        File.read!("payloads/pull_request_review_changes.json")
        |> Poison.decode!()

      assert {:pull_request_review, :changes_requested, %PullRequestReview{}} =
               Decoder.decode(payload, "pull_request_review")
    end

    test "decodes into a ReviewRequest" do
      payload =
        File.read!("payloads/review_requested.json")
        |> Poison.decode!()

      assert {:review_request, :created, %ReviewRequest{}} =
               Decoder.decode(payload, "pull_request")
    end

    test "decodes into a BuildStatus - success" do
      payload =
        File.read!("payloads/build_status_success.json")
        |> Poison.decode!()

      assert {:build_status, :success, %BuildStatus{}} = Decoder.decode(payload, "status")
    end

    test "decodes into a BuildStatus - failure" do
      payload =
        File.read!("payloads/build_status_failure.json")
        |> Poison.decode!()

      assert {:build_status, :failure, %BuildStatus{}} = Decoder.decode(payload, "status")
    end

    test "raises when decoder is not implemented for an event" do
      event_name = "blergh"
      resource = %{}

      assert_raise RuntimeError, ~r/not implemented/, fn ->
        Decoder.decode(resource, event_name)
      end
    end
  end
end
