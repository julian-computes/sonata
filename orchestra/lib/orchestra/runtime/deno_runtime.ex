defmodule Orchestra.Runtime.DenoRuntime do
  @moduledoc """
  Runtime for executing JavaScript/TypeScript workflows using Deno.
  """

  @callback execute_file(String.t(), list()) :: {:ok, {map(), String.t()}} | {:error, String.t()}
  def execute_file(folder_path, params \\ []) do
    impl().execute_file(folder_path, params)
  end

  defp impl do
    Process.get(:orchestra_runtime_denoruntime, Orchestra.Runtime.DenoRuntimeImpl)
  end
end

defmodule Orchestra.Runtime.DenoRuntimeImpl do
  @workflow_runner_path Application.app_dir(:orchestra, "priv/deno/workflow-runner.ts")

  @callback execute_file(String.t(), list()) :: {:ok, {map(), String.t()}} | {:error, String.t()}
  def execute_file(folder_path, params \\ []) do
    with {:ok, main_file_path} <- validate_main_file(folder_path),
         {:ok, temp_path} <- create_temp_file(),
         {:ok, result, output} <-
           run_deno_workflow(folder_path, main_file_path, temp_path, params),
         {:ok, parsed_result} <- parse_output(result) do
      {:ok, {parsed_result, output}}
    end
  end

  defp validate_main_file(folder_path) do
    main_file_path = Path.join(folder_path, "main.ts")

    if File.exists?(main_file_path) do
      {:ok, main_file_path}
    else
      {:error, "main.ts not found in workflow folder"}
    end
  end

  defp create_temp_file do
    Temp.path(%{suffix: ".json"})
  end

  defp build_deno_args(runner_path, folder_path, main_file_path, temp_path, params) do
    params_json = Jason.encode!(params)

    [
      "run",
      "--allow-read=#{folder_path},.",
      "--allow-write=#{temp_path}",
      runner_path,
      main_file_path,
      "--params",
      params_json,
      "--output",
      temp_path
    ]
  end

  defp run_deno_workflow(folder_path, main_file_path, temp_path, params) do
    try do
      deno_args =
        build_deno_args(@workflow_runner_path, folder_path, main_file_path, temp_path, params)

      case Orchestra.Utils.System.cmd("deno", deno_args,
             stderr_to_stdout: true,
             cd: folder_path
           ) do
        {output, 0} ->
          case File.read(temp_path) do
            {:ok, result} -> {:ok, result, output}
            {:error, reason} -> {:error, "Failed to read output file: #{reason}"}
          end

        {error, _exit_code} ->
          {:error, error}
      end
    after
      File.rm(temp_path)
    end
  end

  defp parse_output(output) do
    case Jason.decode(output) do
      {:ok, result} -> {:ok, result}
      {:error, _} -> {:error, "Invalid JSON response: #{output}"}
    end
  end
end
