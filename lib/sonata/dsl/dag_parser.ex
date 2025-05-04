defmodule Sonata.DSL.DagParser do
  def parse(content) do
    content = String.trim(content, "\n")
    split = Regex.split(~r/---\n/, content, parts: 3)

    case split do
      [_, metadata_yaml | [mermaid_string]] ->
        create_graph(metadata_yaml, mermaid_string)

      parts ->
        {:error, "Failed to parse DAG", parts}
    end
  end

  defp create_graph(metadata_yaml, mermaid_string) do
    metadata = parse_yaml(metadata_yaml)
    diagram = parse_diagram(mermaid_string)
    {:ok, %{metadata: metadata, diagram: diagram}}
  end

  defp parse_yaml(yaml) do
    YamlElixir.read_from_string!(yaml)
  end

  defp parse_diagram(mermaid_string) do
    mermaid_string
    |> String.split("\n")
    |> Enum.filter(fn line -> String.contains?(line, "-->") end)
    |> Enum.flat_map(fn line ->
      # Extract node names from connection lines
      Regex.scan(~r/([a-zA-Z0-9_]+)(?:\[[^\]]*\])?(?:\s*-->|\s*$)/, line)
      |> Enum.map(fn [_, node] -> node end)
    end)
  end
end
