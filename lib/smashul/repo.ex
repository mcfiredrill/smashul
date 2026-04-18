defmodule Smashul.Repo do
  use Ecto.Repo,
    otp_app: :smashul,
    adapter: Ecto.Adapters.Postgres
end
