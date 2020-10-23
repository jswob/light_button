defmodule LightButton.Repo do
  use Ecto.Repo,
    otp_app: :light_button,
    adapter: Ecto.Adapters.Postgres
end
