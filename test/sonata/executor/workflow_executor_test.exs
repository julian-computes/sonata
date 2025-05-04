defmodule Sonata.Executor.WorkflowExecutorTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  @repo_url "https://github.com/julian-computes/sonata.git"
  @workflow_path "example-workflows/hello-world"

  setup do
    Process.put(:sonata_utils_system, Sonata.Utils.SystemMock)
    Process.put(:sonata_git_cloner, Sonata.Git.ClonerMock)
    Process.put(:sonata_runtime_denoruntime, Sonata.Runtime.DenoRuntimeMock)
    :ok
  end

  describe "execute/3" do
    test "successfully executes workflow" do
      expect(Sonata.Git.ClonerMock, :clone, fn @repo_url, @workflow_path, tmp_dir ->
        workflow_abs_path = Path.join(tmp_dir, @workflow_path)
        {:ok, workflow_abs_path}
      end)

      expect(Sonata.Runtime.DenoRuntimeMock, :execute_file, fn workflow_path, [] ->
        assert String.ends_with?(workflow_path, @workflow_path)
        {:ok, %{result: "success"}}
      end)

      assert {:ok, %{result: "success"}} ==
               Sonata.Executor.WorkflowExecutor.execute(
                 @repo_url,
                 @workflow_path,
                 []
               )
    end
  end
end
