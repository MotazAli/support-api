# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """


    # config :support_service, SupportService.Repo,
    # username: "doadmin",
    # password: "929G89DVkXkadMe6",
    # database: "SenderSupportDB",
    # hostname: "db-postgresql-ams3-do-user-8500484-0.b.db.ondigitalocean.com",
    # port: 25060,
    # show_sensitive_data_on_connection_error: true,
    # pool_size: 10,
    # # after_connect: {Postgrex, :query!, query_args},
    # ssl: true


config :support_service, SupportService.Repo,
  ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :support_service, SupportServiceWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :support_service, SupportServiceWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
