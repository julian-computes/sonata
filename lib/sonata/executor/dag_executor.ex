defmodule Sonata.Executor.DAGExecutor do
  def execute(dag_string) do
    {:ok, %{metadata: metadata, diagram: diagram}} =
      Sonata.DSL.DagParser.parse(dag_string)

    result =
      diagram
      |> Enum.reduce("", fn node, acc ->
        {:ok, {execution_result, _output}} = execute_node(node, metadata, acc)

        IO.inspect(_output)

        execution_result
      end)

    {:ok, result}
  end

  defp execute_node(node, metadata, args) do
    node_metadata = lookup_node(metadata, node)

    Sonata.Executor.WorkflowExecutor.execute(
      git_url(node_metadata),
      workflow_path(node_metadata),
      args
    )
  end

  defp lookup_node(metadata, node) do
    Map.get(metadata, "nodes", %{})
    |> Map.get(node)
  end

  defp git_url(node_metadata) do
    Map.get(node_metadata, "git_url")
  end

  defp workflow_path(node_metadata) do
    Map.get(node_metadata, "workflow_path")
  end
end
