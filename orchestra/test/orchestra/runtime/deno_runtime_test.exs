defmodule Orchestra.Runtime.DenoRuntimeTest do
  use ExUnit.Case, async: true
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    # Create a temporary directory for the test
    {:ok, tmp_dir} = Temp.mkdir("deno_runtime_test")
    # Create a main.ts file in the temporary directory
    main_ts_path = Path.join(tmp_dir, "main.ts")
    File.write!(main_ts_path, "// Test workflow")

    on_exit(fn ->
      File.rm_rf!(tmp_dir)
    end)

    {:ok, tmp_dir: tmp_dir}
  end

  describe "execute_file/2" do
    test "executes deno workflow successfully", %{tmp_dir: tmp_dir} do
      params = %{"test" => "value"}

      # Expect the system command to be called with specific arguments
      expect(Orchestra.Runtime.SystemMock, :cmd, fn cmd, args, opts ->
        # Assert we're calling deno
        assert cmd == "deno"
        # Assert we're in the right directory
        assert opts[:cd] == tmp_dir
        # Assert stderr is redirected to stdout
        assert opts[:stderr_to_stdout] == true

        # Validate basic deno arguments
        assert "run" in args
        assert "--allow-read=." in args

        # Find and validate the main.ts path
        main_ts_path = Path.join(tmp_dir, "main.ts")
        assert main_ts_path in args

        # Find and validate params
        params_index = Enum.find_index(args, &(&1 == "--params"))
        assert params_index
        params_json = Enum.at(args, params_index + 1)
        assert Jason.decode!(params_json) == params

        # Find the output path and write a mock result
        output_index = Enum.find_index(args, &(&1 == "--output"))
        output_path = Enum.at(args, output_index + 1)

        # Write a mock result file
        mock_result = %{
          status: "success",
          result: %{
            "message" => "Workflow executed successfully"
          }
        }
        File.write!(output_path, Jason.encode!(mock_result))

        # Return success
        {"Workflow executed successfully", 0}
      end)

      # Execute the workflow
      result = Orchestra.Runtime.DenoRuntime.execute_file(tmp_dir, params)

      # Assert the result
      assert {:ok, %{
        "status" => "success",
        "result" => %{
          "message" => "Workflow executed successfully"
        }
      }} = result
    end

    test "handles deno execution failure", %{tmp_dir: tmp_dir} do
      expect(Orchestra.Runtime.SystemMock, :cmd, fn _cmd, _args, _opts ->
        {"Failed to execute workflow: Runtime error", 1}
      end)

      result = Orchestra.Runtime.DenoRuntime.execute_file(tmp_dir, %{})
      assert {:error, "Failed to execute workflow: Runtime error"} = result
    end

    test "returns error when main.ts is missing", %{tmp_dir: tmp_dir} do
      # Remove main.ts
      File.rm!(Path.join(tmp_dir, "main.ts"))

      result = Orchestra.Runtime.DenoRuntime.execute_file(tmp_dir, %{})
      assert {:error, "main.ts not found in folder: " <> _} = result
    end
  end
end
