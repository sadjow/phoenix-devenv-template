defmodule PhoenixDevenv.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_devenv,
    adapter: Ecto.Adapters.Postgres
end
