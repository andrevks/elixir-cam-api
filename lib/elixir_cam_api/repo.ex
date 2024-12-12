defmodule ElixirCamApi.Repo do
  use Ecto.Repo,
    otp_app: :elixir_cam_api,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 100
end
