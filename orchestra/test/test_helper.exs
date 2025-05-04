ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Orchestra.Repo, :manual)

# Set up mocks
Orchestra.TestMocks.setup()
