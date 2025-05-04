defmodule Orchestra.Runtime.DenoRuntimeTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  setup do
    Process.put(:orchestra_utils_system, Orchestra.Utils.SystemMock)
    :ok
  end

  @mock_result %{
    "status" => "success",
    "result" => %{"message" => "Workflow executed successfully"}
  }

  setup do
    {:ok, tmp_dir} = Temp.mkdir("deno_runtime_test")
    File.write!(Path.join(tmp_dir, "main.ts"), "// Test workflow")
    on_exit(fn -> File.rm_rf!(tmp_dir) end)
    {:ok, tmp_dir: tmp_dir}
  end

  describe "execute_file/2" do
    test "executes deno workflow successfully", %{tmp_dir: tmp_dir} do
      params = %{"test" => "value"}

      expect(Orchestra.Utils.SystemMock, :cmd, fn "deno", args, opts ->
        assert_command_opts(opts, tmp_dir)
        assert_deno_args(args, tmp_dir, params)
        write_mock_result(args, @mock_result)
        {"Workflow executed successfully", 0}
      end)

      assert {:ok, {@mock_result, "Workflow executed successfully"}} ==
               Orchestra.Runtime.DenoRuntime.execute_file(tmp_dir, params)
    end

    test "handles deno execution failure", %{tmp_dir: tmp_dir} do
      expect(Orchestra.Utils.SystemMock, :cmd, fn _cmd, _args, _opts ->
        {"Failed to execute workflow: Runtime error", 1}
      end)

      assert {:error, "Failed to execute workflow: Runtime error"} ==
               Orchestra.Runtime.DenoRuntime.execute_file(tmp_dir, %{})
    end

    test "returns error when main.ts is missing", %{tmp_dir: tmp_dir} do
      File.rm!(Path.join(tmp_dir, "main.ts"))
      {:error, message} = Orchestra.Runtime.DenoRuntime.execute_file(tmp_dir, %{})
      assert message == "main.ts not found in workflow folder"
    end
  end

  defp assert_command_opts(opts, cd) do
    assert opts[:stderr_to_stdout]
    assert opts[:cd] == cd
  end

  defp assert_deno_args(args, tmp_dir, params) do
    assert "run" in args
    assert "--allow-read=#{tmp_dir},." in args
    assert Path.join(tmp_dir, "main.ts") in args

    params_index = Enum.find_index(args, &(&1 == "--params"))
    assert params_index
    assert Jason.decode!(Enum.at(args, params_index + 1)) == params
  end

  defp write_mock_result(args, result) do
    output_index = Enum.find_index(args, &(&1 == "--output"))
    output_path = Enum.at(args, output_index + 1)
    File.write!(output_path, Jason.encode!(result))
  end
end
