ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Orchestra.Repo, :manual)

# Define mocks
Mox.defmock(Orchestra.Runtime.SystemMock, for: Orchestra.Runtime.SystemBehaviour)

Application.put_env(:orchestra, :system, Orchestra.Runtime.SystemMock)
