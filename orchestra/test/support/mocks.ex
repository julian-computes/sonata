defmodule Orchestra.TestMocks do
  Mox.defmock(Orchestra.Utils.SystemMock, for: Orchestra.Utils.System)
  Mox.defmock(Orchestra.Git.ClonerMock, for: Orchestra.Git.Cloner)
  Mox.defmock(Orchestra.Runtime.DenoRuntimeMock, for: Orchestra.Runtime.DenoRuntime)
  Mox.defmock(Orchestra.Executor.WorkflowExecutorMock, for: Orchestra.Executor.WorkflowExecutor)
end
