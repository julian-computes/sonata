ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Orchestra.Repo, :manual)

# Define mocks
Mox.defmock(Orchestra.Utils.SystemMock, for: Orchestra.Utils.SystemBehaviour)

Application.put_env(:orchestra, :system, Orchestra.Utils.SystemMock)
