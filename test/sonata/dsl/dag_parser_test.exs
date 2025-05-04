defmodule Sonata.Dsl.DagParserTest do
  use ExUnit.Case, async: true

  @valid_workflow """
  ---
  title: Hello Echo Graph
  nodes:
    hello:
      runtime: deno
      git_url: github.com/julian-computes/sonata.git
      workflow_path: example-workflows/hello-world
    echo:
      runtime: deno
      git_url: https://github.com/julian-computes/sonata.git
      workflow_path: example-workflows/echo
  ---

  graph TD
  hello --> echo["labels are okay"] --> echo
  """

  describe "parse/1" do
    test "parses a syntactically correct workflow" do
      assert {:ok,
              %{
                diagram: ["hello", "echo", "echo"],
                metadata: %{
                  "nodes" => %{
                    "echo" => %{
                      "git_url" => "https://github.com/julian-computes/sonata.git",
                      "runtime" => "deno",
                      "workflow_path" => "example-workflows/echo"
                    },
                    "hello" => %{
                      "git_url" => "github.com/julian-computes/sonata.git",
                      "runtime" => "deno",
                      "workflow_path" => "example-workflows/hello-world"
                    }
                  },
                  "title" => "Hello Echo Graph"
                }
              }} = Sonata.DSL.DagParser.parse(@valid_workflow)
    end

    test "fails to parse a syntactically incorrect workflow" do
      invalid_workflow = """
      ---
      title: Hello Echo Graph
      nodes: -
      hello:
          runtime: deno
      """

      assert {:error, _, _} = Sonata.DSL.DagParser.parse(invalid_workflow)
    end
  end
end
