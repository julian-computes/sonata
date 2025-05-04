defmodule Sonata.Repo do
  use Ecto.Repo,
    otp_app: :sonata,
    adapter: Ecto.Adapters.Postgres
end
