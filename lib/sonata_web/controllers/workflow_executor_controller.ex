defmodule SonataWeb.WorkflowExecutorController do
  use SonataWeb, :controller

  def execute(conn, %{"git_url" => git_url, "workflow_path" => workflow_path}) do
    case Sonata.Executor.WorkflowExecutor.execute(git_url, workflow_path, []) do
      {:ok, {result, output}} ->
        conn
        |> put_status(:ok)
        |> json(%{result: result, output: output})

      {:error, error} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: error})
    end
  end

  def execute(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing required parameters: git_url, workflow_path"})
  end
end
