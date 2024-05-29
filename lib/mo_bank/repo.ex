defmodule MoBank.Repo do
  use Ecto.Repo,
    otp_app: :mo_bank,
    adapter: Ecto.Adapters.Postgres
end
