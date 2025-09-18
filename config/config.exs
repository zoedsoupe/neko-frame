# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :neko_frame,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :neko_frame, NekoFrameWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: NekoFrameWeb.ErrorHTML, json: NekoFrameWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: NekoFrame.PubSub,
  live_view: [signing_salt: "OfvKd7IU"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  neko_frame: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

{:ok, cwd} = File.cwd()

config :neko_frame, upload_path: System.get_env("UPLOAD_PATH", Path.join(cwd, "uploads"))

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
