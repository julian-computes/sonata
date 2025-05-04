defmodule Orchestra.Executor.WorkflowExecutor do
  @moduledoc """
  Clones and executes a workflow.
  """

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
