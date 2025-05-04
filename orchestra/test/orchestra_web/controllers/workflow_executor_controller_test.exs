defmodule OrchestraWeb.WorkflowExecutorControllerTest do
  use OrchestraWeb.ConnCase, async: true
  import Mox

  setup :verify_on_exit!

  @repo_url "https://github.com/julian-computes/sonata.git"
  @workflow_path "example-workflows/hello-world"

  setup do
    Process.put(:orchestra_executor_workflowexecutor, Orchestra.Executor.WorkflowExecutorMock)
    :ok
  end

  describe "execute/2" do
    test "successfully executes workflow", %{conn: conn} do
      mock_result = %{"status" => "success", "message" => "Hello, World!"}
      mock_output = "Workflow executed successfully"

      expect(Orchestra.Executor.WorkflowExecutorMock, :execute, fn @repo_url,
                                                                   @workflow_path,
                                                                   [] ->
        {:ok, {mock_result, mock_output}}
      end)

      conn =
        post(conn, ~p"/api/workflows/execute", %{
          "git_url" => @repo_url,
          "workflow_path" => @workflow_path
        })

      assert %{
               "result" => %{"status" => "success", "message" => "Hello, World!"},
               "output" => "Workflow executed successfully"
             } = json_response(conn, 200)
    end

    test "handles workflow execution failure", %{conn: conn} do
      expect(Orchestra.Executor.WorkflowExecutorMock, :execute, fn @repo_url,
                                                                   @workflow_path,
                                                                   [] ->
        {:error, "Failed to execute workflow"}
      end)

      conn =
        post(conn, ~p"/api/workflows/execute", %{
          "git_url" => @repo_url,
          "workflow_path" => @workflow_path
        })

      assert %{"error" => "Failed to execute workflow"} = json_response(conn, 400)
    end

    test "returns 400 when required parameters are missing", %{conn: conn} do
      conn = post(conn, ~p"/api/workflows/execute", %{})
      assert %{"error" => _} = json_response(conn, 400)
    end
  end
end
