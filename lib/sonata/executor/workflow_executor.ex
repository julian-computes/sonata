defmodule Sonata.Executor.WorkflowExecutor do
  @moduledoc """
  Clones and executes a workflow.
  """

  @callback execute(git_url :: String.t(), workflow_path :: String.t(), list()) ::
              {:ok, {map(), String.t()}} | {:error, String.t()}
  def execute(git_url, workflow_path, params \\ []) do
    impl().execute(git_url, workflow_path, params)
  end

  defp impl do
    Process.get(:sonata_executor_workflowexecutor, Sonata.Executor.WorkflowExecutorImpl)
  end
end

defmodule Sonata.Executor.WorkflowExecutorImpl do
  @behaviour Sonata.Executor.WorkflowExecutor

  @impl true
  def execute(git_url, workflow_path, params \\ []) do
    tmp_dir = Temp.mkdir!()

    try do
      with {:ok, abs_workflow_path} <- Sonata.Git.Cloner.clone(git_url, workflow_path, tmp_dir) do
        Sonata.Runtime.DenoRuntime.execute_file(abs_workflow_path, params)
      end
    after
      File.rm_rf!(tmp_dir)
    end
  end
end
