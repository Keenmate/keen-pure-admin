# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :demo,
  generators: [timestamp_type: :utc_datetime]

# Gettext — demo i18n. `default` domain holds the demo's own content;
# `pure_admin` domain bridges library chrome (see DemoWeb.PaTranslate).
config :demo, DemoWeb.Gettext, default_locale: "en", locales: ~w(en es)

# Configure the endpoint
config :demo, DemoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DemoWeb.ErrorHTML, json: DemoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Demo.PubSub,
  live_view: [signing_salt: "DIsTgwrS"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  demo: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# PureAdmin configuration
config :keen_pure_admin,
  app_name: "Pure Admin",
  app_version: "1.0.0",
  copyright: "© 2026 Keenmate s.r.o.",
  font_class: "pa-font-responsive",
  icon_providers: [{DemoWeb.Icons, :render}],
  # Bridge library chrome (PureAdmin.Translations.t/2) into the demo's Gettext.
  translate: &DemoWeb.PaTranslate.translate/2,
  page_context_providers: [
    &DemoWeb.PageContext.theme_manifests/1
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
