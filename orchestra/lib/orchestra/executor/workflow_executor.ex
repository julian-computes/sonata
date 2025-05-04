defmodule Orchestra.Executor.WorkflowExecutorBehaviour do
  @moduledoc """
  Behaviour for workflow execution.
  """

  @type t :: module()
  @type params :: list()
  @type workflow_result :: map()
  @type execution_output :: String.t()

  @callback execute(git_url :: String.t(), workflow_path :: String.t(), params()) ::
              {:ok, {workflow_result(), execution_output()}} | {:error, String.t()}
end

defmodule Orchestra.Executor.WorkflowExecutor do
  @moduledoc """
  Clones and executes a workflow.
  """

  @behaviour Orchestra.Executor.WorkflowExecutorBehaviour

  @impl true
  def execute(git_url, workflow_path, params \\ []) do
    cloner = Orchestra.cloner()
    runtime = Orchestra.deno_runtime()
    tmp_dir = Temp.mkdir!()

    try do
      with {:ok, abs_workflow_path} <- cloner.clone(git_url, workflow_path, tmp_dir) do
        runtime.execute_file(abs_workflow_path, params)
      end
    after
      File.rm_rf!(tmp_dir)
    end
  end
end
