defmodule Orchestra.Git.Cloner do
  @moduledoc """
  Provides functionality for efficiently cloning specific paths from Git repositories.

  This module implements a sparse checkout strategy to clone only the required
  workflow directory from a Git repository, avoiding the download of unnecessary files.
  It uses Git's sparse-checkout feature to:

  1. Initialize an empty repository
  2. Add the remote repository as origin
  3. Configure sparse-checkout to only download the specified workflow path
  4. Pull the minimal set of files needed

  Example:
      Orchestra.Git.Cloner.clone(
        "https://github.com/julian-computes/sonata.git",
        "example-workflows/hello-world",
        "/tmp/destination"
      )
  """

  @doc """
  Efficiently clones a specific path from a Git repository.

  Uses Git's sparse-checkout feature to clone only the specified workflow path,
  minimizing network bandwidth and disk usage.

  ## Parameters

    * `git_url` - The URL of the Git repository to clone from
    * `workflow_path` - The specific directory path within the repository to clone
    * `dest_path` - The local destination path where the repository will be cloned

  ## Returns

    * `{:ok, path}` - On success, returns the absolute path to the cloned workflow directory
    * `{:error, reason}` - On failure, returns an error tuple with the failure reason

  ## Examples

      iex> Orchestra.Git.Cloner.clone(
      ...>   "https://github.com/julian-computes/sonata.git",
      ...>   "example-workflows/hello-world",
      ...>   "/tmp/sonata"
      ...> )
      {:ok, "/tmp/sonata/example-workflows/hello-world"}

  """
  @callback clone(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def clone(git_url, workflow_path, dest_path) do
    impl().clone(git_url, workflow_path, dest_path)
  end

  defp impl do
    Process.get(:orchestra_git_cloner, Orchestra.Git.ClonerImpl)
  end
end

defmodule Orchestra.Git.ClonerImpl do
  @behaviour Orchestra.Git.Cloner

  @impl true
  def clone(git_url, workflow_path, dest_path) do
    with :ok <- init_repo(dest_path),
         :ok <- add_remote(git_url, dest_path),
         :ok <- enable_sparse_checkout(workflow_path, dest_path),
         :ok <- pull(dest_path) do
      {:ok, Path.join(dest_path, workflow_path)}
    end
  end

  defp init_repo(dest_path) do
    run_git_command(["init", dest_path], "initialize repository")
  end

  defp add_remote(git_url, dest_path) do
    run_git_command(["remote", "add", "-f", "origin", git_url], "add remote", cd: dest_path)
  end

  defp enable_sparse_checkout(workflow_path, dest_path) do
    with :ok <-
           run_git_command(["config", "core.sparseCheckout", "true"], "enable sparse-checkout",
             cd: dest_path
           ) do
      write_sparse_checkout_config(workflow_path, dest_path)
    end
  end

  defp write_sparse_checkout_config(workflow_path, dest_path) do
    sparse_checkout_file = Path.join([dest_path, ".git", "info", "sparse-checkout"])
    sparse_checkout_dir = Path.dirname(sparse_checkout_file)

    with :ok <- File.mkdir_p(sparse_checkout_dir),
         :ok <- File.write(sparse_checkout_file, workflow_path <> "/\n") do
      :ok
    else
      {:error, reason} -> {:error, "Failed to write sparse-checkout config: #{reason}"}
    end
  end

  defp pull(dest_path) do
    run_git_command(["pull", "origin", "main"], "pull repository", cd: dest_path)
  end

  defp run_git_command(args, operation, opts \\ []) do
    opts = Keyword.merge([into: "", stderr_to_stdout: true], opts)

    case Orchestra.Utils.System.cmd("git", args, opts) do
      {_, 0} -> :ok
      {error, _} -> {:error, "Failed to #{operation}: #{error}"}
    end
  end
end
