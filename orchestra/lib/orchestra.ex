defmodule Orchestra do
  @moduledoc """
  Orchestra keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
  Returns the system module for executing system commands.
  Defaults to Orchestra.Utils.System if not configured.
  """
  @spec system() :: Orchestra.Utils.SystemBehaviour.t()
  def system do
    Application.get_env(:orchestra, :system, Orchestra.Utils.System)
  end

  @doc """
  Returns the Git Cloner module for cloning repositories.
  Defaults to Orchestra.Git.Cloner if not configured.
  """
  @spec cloner() :: Orchestra.Git.Cloner.t()
  def cloner do
    Application.get_env(:orchestra, :git_cloner, Orchestra.Git.Cloner)
  end

  @doc """
  Returns the Deno runtime module for executing workflows.
  Defaults to Orchestra.Runtime.DenoRuntime if not configured.
  """
  @spec deno_runtime() :: Orchestra.Runtime.DenoRuntime.t()
  def deno_runtime do
    Application.get_env(:orchestra, :deno_runtime, Orchestra.Runtime.DenoRuntime)
  end

  @doc """
  Returns the workflow executor module for managing workflow execution.
  Defaults to Orchestra.Executor.WorkflowExecutor if not configured.
  """
  @spec workflow_executor() :: Orchestra.Executor.WorkflowExecutorBehaviour.t()
  def workflow_executor do
    Application.get_env(:orchestra, :workflow_executor, Orchestra.Executor.WorkflowExecutor)
  end
end
