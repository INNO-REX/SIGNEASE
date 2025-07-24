defmodule Signease.Repo do
  use Ecto.Repo,
    otp_app: :signease,
    adapter: Ecto.Adapters.Postgres
end
