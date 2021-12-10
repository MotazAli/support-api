defmodule SupportService.Repo do
  use Ecto.Repo,
    otp_app: :support_service,
    adapter: Ecto.Adapters.Postgres
end
