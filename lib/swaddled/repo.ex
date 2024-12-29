defmodule Swaddled.Repo do
  use Ecto.Repo,
    otp_app: :swaddled,
    adapter: Ecto.Adapters.Postgres
end
