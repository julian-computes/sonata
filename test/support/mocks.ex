defmodule Sonata.TestMocks do
  Mox.defmock(Sonata.Utils.SystemMock, for: Sonata.Utils.System)
  Mox.defmock(Sonata.Git.ClonerMock, for: Sonata.Git.Cloner)
  Mox.defmock(Sonata.Runtime.DenoRuntimeMock, for: Sonata.Runtime.DenoRuntime)
  Mox.defmock(Sonata.Executor.WorkflowExecutorMock, for: Sonata.Executor.WorkflowExecutor)
end
