defmodule PureAdmin.MixProject do
  use Mix.Project

  @version "2.0.0-rc.1"
  @source_url "https://github.com/KeenMate/keen-pure-admin"

  def project do
    [
      app: :keen_pure_admin,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "PureAdmin",
      description:
        "Phoenix LiveView components for business admin apps. " <>
          "35+ components, 14 hooks, command palette, flash, i18n, themes. " <>
          "Built on pureadmin.io — standalone BEM CSS, no Tailwind needed.",
      package: package(),
      docs: docs(),
      source_url: @source_url,
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:nimble_options, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:floki, "~> 0.36", only: :test}
    ]
  end

  defp package do
    [
      name: "keen_pure_admin",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Pure Admin" => "https://pureadmin.io",
        "Live Demo" => "https://elixir.demo.pureadmin.io"
      },
      files:
        ~w(lib docs .formatter.exs mix.exs package.json README.md LICENSE CHANGELOG.md security-audit.md component-audit.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      logo: nil,
      extras: [
        "README.md",
        "docs/getting-started.md",
        "docs/js-hooks.md",
        "docs/theming.md",
        "CHANGELOG.md",
        "security-audit.md",
        "component-audit.md",
        "LICENSE"
      ],
      groups_for_extras: [
        Guides: [
          "docs/getting-started.md",
          "docs/js-hooks.md",
          "docs/theming.md"
        ]
      ],
      groups_for_modules: [
        "Layout & Navigation": [
          PureAdmin.Components.Layout,
          PureAdmin.Components.Navigation,
          PureAdmin.Components.CommandPalette,
          PureAdmin.Components.Profile,
          PureAdmin.Components.SettingsPanel,
          PureAdmin.Components.Grid,
          PureAdmin.Components.Splitter
        ],
        "UI Components": [
          PureAdmin.Components.Button,
          PureAdmin.Components.Badge,
          PureAdmin.Components.Alert,
          PureAdmin.Components.Callout,
          PureAdmin.Components.Card,
          PureAdmin.Components.Flash,
          PureAdmin.Components.Modal,
          PureAdmin.Components.Popconfirm,
          PureAdmin.Components.Toast,
          PureAdmin.Components.Tooltip,
          PureAdmin.Components.Loader,
          PureAdmin.Components.Stat,
          PureAdmin.Components.Code,
          PureAdmin.Components.Typography
        ],
        Icons: [
          PureAdmin.Components.Icon,
          PureAdmin.Components.Faicon,
          PureAdmin.Components.Heroicon
        ],
        "Data & Tables": [
          PureAdmin.Components.Table,
          PureAdmin.Components.Comparison,
          PureAdmin.Components.DataDisplay,
          PureAdmin.Components.DataViz,
          PureAdmin.Components.FilterCard,
          PureAdmin.Components.Pager
        ],
        "Forms & Inputs": [
          PureAdmin.Components.Form,
          PureAdmin.Components.CheckboxList,
          PureAdmin.Components.RangeGroup
        ],
        "Lists & Timeline": [
          PureAdmin.Components.List,
          PureAdmin.Components.Timeline
        ],
        "KPI Showcases": [
          PureAdmin.Components.Kpi,
          PureAdmin.Components.KpiDetail,
          PureAdmin.Components.KpiTerminal,
          PureAdmin.Components.KpiSparklineList,
          PureAdmin.Components.KpiGaugeList,
          PureAdmin.Components.KpiHero,
          PureAdmin.Components.KpiBento,
          PureAdmin.Components.KpiStrip,
          PureAdmin.Components.KpiEditorial
        ],
        "Live Components": ~r/PureAdmin\.Live\./,
        "Helpers & Config": [
          PureAdmin.Components,
          PureAdmin.Helpers,
          PureAdmin.Config,
          PureAdmin.Types,
          PureAdmin.Translations,
          PureAdmin.DateTime,
          PureAdmin.PageContext
        ]
      ]
    ]
  end

  defp aliases do
    [
      quality: ["format --check-formatted", "credo --strict", "dialyzer"]
    ]
  end
end
