defmodule PureAdmin.Config do
  @moduledoc """
  Application-level configuration for PureAdmin.

  Set in `config/config.exs`:

      config :keen_pure_admin,
        app_name: "My App",
        app_logo: "/images/logo.svg",
        app_version: "1.0.0",
        copyright: "© 2026 My Company",
        font_class: "pa-font-responsive",
        default_variant: "primary",
        default_icon_size: "1.25rem",
        toast_position: "top-right"

  Components like `app_header/1` and `footer/1` read from this config
  automatically when no explicit content is provided.

  ## Available Keys

  | Key | Default | Used by |
  |-----|---------|---------|
  | `:app_name` | `"PureAdmin"` | `app_header/1` |
  | `:app_logo` | `nil` | `app_header/1` |
  | `:app_version` | `nil` | `footer/1` |
  | `:copyright` | `nil` | `footer/1` |
  | `:font_class` | `nil` | `root_html_attrs/0` |
  | `:default_variant` | `"primary"` | various components |
  | `:default_icon_size` | `"1.25rem"` | `heroicon/1`, `faicon/1`, `icon/1` |
  | `:icon_providers` | `[]` | `icon/1` |
  | `:toast_position` | `"top-right"` | `toast_container/1` |

  ## Icon providers

  An ordered LIST of providers that `<.icon>` consults for any name that
  isn't a framework affordance (`pa-icon--*`, resolved first and built-in).
  Each provider is a Phoenix function component — it receives the full
  assigns map (with `name`, `class`, `color`, `size`, `size_value`,
  `variant`, `fill`, `stroke`, `title`, `aria_label`, `is_interactive`) and
  returns rendered HEEx, or `nil` to pass the name to the next provider.
  After the list, a built-in fallback handles `"hero-X"` (→ `<.heroicon>`)
  and otherwise FA-style `<i class={name}>`. Mirrors svelte's provider list.

      # config/config.exs
      config :keen_pure_admin, icon_providers: [{MyAppWeb.Icons, :render}]

      # lib/my_app_web/icons.ex
      defmodule MyAppWeb.Icons do
        use Phoenix.Component

        # Handle this set; return nil for anything else so the next
        # provider (or the built-in fallback) gets a turn.
        def render(%{name: "lucide-" <> name} = assigns) do
          assigns = assign(assigns, :file, name)
          ~H\"""
          <img src={"/assets/icons/lucide/\#{@file}.svg"} width={@size_value} height={@size_value} />
          \"""
        end

        def render(_assigns), do: nil
      end

  Each entry is either a `{module, function}` tuple or a function capture
  (`&MyAppWeb.Icons.render/1`). The tuple form is safer in `config.exs`
  because it doesn't require the module to be compiled before the config
  is evaluated.
  """

  @defaults %{
    app_name: "PureAdmin",
    app_logo: nil,
    app_version: nil,
    copyright: nil,
    font_class: nil,
    default_variant: "primary",
    default_icon_size: "1.25rem",
    icon_providers: [],
    toast_position: "top-right"
  }

  @doc "Get a single config value with fallback to default."
  @spec get(atom(), any()) :: any()
  def get(key, default \\ nil) do
    app_default = Map.get(@defaults, key, default)
    Application.get_env(:keen_pure_admin, key, app_default)
  end

  @doc "Get the full merged config as a map."
  @spec all() :: map()
  def all do
    app_config = Application.get_all_env(:keen_pure_admin)
    Map.merge(@defaults, Map.new(app_config))
  end

  @doc "Get the app name."
  @spec app_name() :: String.t()
  def app_name, do: get(:app_name)

  @doc "Get the app logo URL."
  @spec app_logo() :: String.t() | nil
  def app_logo, do: get(:app_logo)

  @doc "Get the app version."
  @spec app_version() :: String.t() | nil
  def app_version, do: get(:app_version)

  @doc "Get the copyright text."
  @spec copyright() :: String.t() | nil
  def copyright, do: get(:copyright)

  @doc "Get the font class for the `<html>` element (e.g. `\"pa-font-responsive\"`)."
  @spec font_class() :: String.t() | nil
  def font_class, do: get(:font_class)

  @doc "Get the default component variant."
  @spec default_variant() :: String.t()
  def default_variant, do: get(:default_variant)

  @doc """
  Get the default icon size — a CSS length applied to `<.heroicon>` (SVG
  `width`/`height` attrs) and `<.faicon>` / `<.icon>` (inline `font-size`).
  """
  @spec icon_size() :: String.t()
  def icon_size, do: get(:default_icon_size)

  @doc """
  Get the configured icon providers as a list of 1-arity function components.

  Each `:icon_providers` entry is either a function capture (`&Mod.fun/1`)
  or a `{module, function}` tuple; the tuple form is preferred since it
  doesn't require the target module to be loaded when `config.exs` is
  evaluated. Each provider receives the full assigns map (name + render
  context) and returns rendered HEEx, or `nil` to pass the name to the next
  provider. Framework affordances (`pa-icon--*`) resolve before this list.
  """
  @spec icon_providers() :: [(map() -> Phoenix.LiveView.Rendered.t() | nil)]
  def icon_providers do
    get(:icon_providers, [])
    |> List.wrap()
    |> Enum.map(&normalize_provider/1)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_provider(fun) when is_function(fun, 1), do: fun
  defp normalize_provider({mod, fun}) when is_atom(mod) and is_atom(fun), do: Function.capture(mod, fun, 1)
  defp normalize_provider({mod, fun, _arity}) when is_atom(mod) and is_atom(fun), do: Function.capture(mod, fun, 1)
  defp normalize_provider(_), do: nil

  @doc """
  Returns HTML attributes for the `<html>` element.

  Includes the `font_class` if configured. Use in your root layout:

      <html lang="en" {PureAdmin.Config.root_html_attrs()}>
  """
  @spec root_html_attrs() :: map()
  def root_html_attrs do
    case font_class() do
      nil -> %{}
      fc -> %{class: fc}
    end
  end
end
