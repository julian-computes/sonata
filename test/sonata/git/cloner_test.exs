defmodule Sonata.Git.ClonerTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  @repo_url "https://github.com/julian-computes/sonata.git"
  @workflow_path "example-workflows/hello-world"

  # Set up mock expectations for the test process
  setup do
    Process.put(:sonata_utils_system, Sonata.Utils.SystemMock)

    {:ok, dest_path} = Temp.mkdir("cloner_test")
    on_exit(fn -> File.rm_rf!(dest_path) end)

    {:ok, git_url: @repo_url, workflow_path: @workflow_path, dest_path: dest_path}
  end

  describe "clone/3" do
    test "successfully clones specific workflow path", %{
      git_url: url,
      workflow_path: path,
      dest_path: dest
    } do
      # Mock commands in sequence
      expect(Sonata.Utils.SystemMock, :cmd, fn "git", ["init", ^dest], opts ->
        assert_command_opts(opts)
        {"", 0}
      end)

      expect(Sonata.Utils.SystemMock, :cmd, fn "git",
                                                  ["remote", "add", "-f", "origin", ^url],
                                                  opts ->
        assert_command_opts(opts, dest)
        {"", 0}
      end)

      expect(Sonata.Utils.SystemMock, :cmd, fn "git",
                                                  ["config", "core.sparseCheckout", "true"],
                                                  opts ->
        assert_command_opts(opts, dest)
        {"", 0}
      end)

      expect(Sonata.Utils.SystemMock, :cmd, fn "git", ["pull", "origin", "main"], opts ->
        assert_command_opts(opts, dest)
        {"", 0}
      end)

      assert {:ok, Path.join(dest, path)} == Sonata.Git.Cloner.clone(url, path, dest)
    end

    test "handles git command failure", %{git_url: url, workflow_path: path, dest_path: dest} do
      # Only expect the init command since it will fail
      expect(Sonata.Utils.SystemMock, :cmd, fn "git", ["init", ^dest], opts ->
        assert_command_opts(opts)
        {"Repository initialization failed", 1}
      end)

      assert {:error, "Failed to initialize repository: Repository initialization failed"} ==
               Sonata.Git.Cloner.clone(url, path, dest)
    end
  end

  defp assert_command_opts(opts, cd \\ nil) do
    assert opts[:stderr_to_stdout]
    assert opts[:into] == ""
    if cd, do: assert(opts[:cd] == cd)
  end
end
