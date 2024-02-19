defmodule ShowmakerBackend.Repo do
  use Ecto.Repo,
    otp_app: :showmaker_backend,
    adapter: Ecto.Adapters.Postgres
end
