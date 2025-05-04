defmodule Orchestra.Executor.WorkflowExecutorTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  @repo_url "https://github.com/julian-computes/sonata.git"
  @workflow_path "example-workflows/hello-world"

  describe "execute/3" do
    test "successfully executes workflow" do
      expect(Orchestra.Git.ClonerMock, :clone, fn @repo_url, @workflow_path, tmp_dir ->
        workflow_abs_path = Path.join(tmp_dir, @workflow_path)
        {:ok, workflow_abs_path}
      end)

      expect(Orchestra.Runtime.DenoRuntimeMock, :execute_file, fn workflow_path, [] ->
        assert String.ends_with?(workflow_path, @workflow_path)
        {:ok, %{result: "success"}}
      end)

      assert {:ok, %{result: "success"}} ==
               Orchestra.Executor.WorkflowExecutor.execute(
                 @repo_url,
                 @workflow_path,
                 []
               )
    end
  end
end
