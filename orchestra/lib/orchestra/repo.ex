defmodule Orchestra.Repo do
  use Ecto.Repo,
    otp_app: :orchestra,
    adapter: Ecto.Adapters.Postgres
end
