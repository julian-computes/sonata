defmodule Orchestra.Executor.WorkflowExecutor do
  @moduledoc """
  Clones and executes a workflow.
  """

  def execute(git_url, workflow_path, params \\ []) do
    tmp_dir = Temp.mkdir!()
    {:ok, abs_workflow_path} = Orchestra.Git.Cloner.clone(git_url, workflow_path, tmp_dir)
    {:ok, _} = Orchestra.Runtime.DenoRuntime.execute_file(abs_workflow_path, params)
  end
end
