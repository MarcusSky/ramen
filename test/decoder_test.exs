defmodule Ramen.DecoderTest do
  use ExUnit.Case, async: true

  alias Ramen.Decoder
  alias Ramen.{PullRequest, Participant, Comment}

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

      assert {:issue_comment, :created, %Comment{}} = Decoder.decode(payload, "issue_comment")
    end
  end
end
