use Mix.Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :phoenix_cms, PhoenixCmsWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# Airtable configuration
config :phoenix_cms, Services.Airtable,
  api_key: System.get_env("AIRTABLE_API_KEY"),
  base_id: System.get_env("AIRTABLE_BASE_ID"),
  api_url: "https://api.airtable.com/v0/"
