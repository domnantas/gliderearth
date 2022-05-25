defmodule Gliderearth.Repo do
  use Ecto.Repo,
    otp_app: :gliderearth,
    adapter: Ecto.Adapters.Postgres
end
