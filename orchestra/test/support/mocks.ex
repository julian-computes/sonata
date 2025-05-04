defmodule Orchestra.TestMocks do
  Mox.defmock(Orchestra.Utils.SystemMock, for: Orchestra.Utils.SystemBehaviour)
  Mox.defmock(Orchestra.Git.ClonerMock, for: Orchestra.Git.Cloner)
  Mox.defmock(Orchestra.Runtime.DenoRuntimeMock, for: Orchestra.Runtime.DenoRuntime)

  Mox.defmock(Orchestra.Executor.WorkflowExecutorMock,
    for: Orchestra.Executor.WorkflowExecutorBehaviour
  )

  def setup do
    Application.put_env(:orchestra, :system, Orchestra.Utils.SystemMock)
    Application.put_env(:orchestra, :git_cloner, Orchestra.Git.ClonerMock)
    Application.put_env(:orchestra, :deno_runtime, Orchestra.Runtime.DenoRuntimeMock)
    Application.put_env(:orchestra, :workflow_executor, Orchestra.Executor.WorkflowExecutorMock)
  end
end
