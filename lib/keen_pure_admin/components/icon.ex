defmodule PureAdmin.Components.Icon do
  @moduledoc """
  Smart icon dispatcher — routes a string `name` to the right rendering
  strategy by inspecting its prefix.

  This component exists for the legacy `attr :icon, :string` pattern used by
  many of the library's chrome components (sidebar items, buttons, flash,
  profile nav items). Callers pass a single string and the renderer figures
  out whether it's a class-based icon font (Font Awesome, Bootstrap Icons,
  Lucide-font, etc.) or a Heroicon name.

  For direct usage, prefer the specialized components — they give you fuller
  control over per-set attributes (FA variant, heroicon size, etc.):

      <.faicon name="rocket" variant="solid" />
      <.heroicon name="rocket-launch" class="size-4" />

  ## Dispatch rules

  | Name pattern        | Rendered as                                  |
  |---------------------|----------------------------------------------|
  | `nil` / empty       | renders nothing                              |
  | `"hero-X"`          | `<.heroicon name="X">`                       |
  | any other string    | configured `:icon_callback` if set, else `<i class={@name}>` (FA-style) |

  ## Custom icon sets via callback

  Most projects standardize on one icon set (a custom SVG sprite folder,
  a special font, Lucide files in `priv/static`, etc.). Configure
  `:icon_callback` once in `config.exs` and `<.icon>` will route every
  non-`hero-` name through it. See `PureAdmin.Config` for the contract.

  ## Future improvement: compile-time inline icon set

  The current callback pattern serves SVGs as `<img>` per icon — fine for
  most use cases, but every unique name costs an HTTP round trip on cold
  cache, and `stroke="currentColor"` recoloring is lost when the SVG lives
  in a separate document.

  A future enhancement would be a built-in compile-time inliner (same
  approach as `<.heroicon>`): point it at a directory of SVG files and
  generate one function clause per file at compile time.

      Approach:       Compile-time inline (like our Heroicon)
      HTTP requests:  0
      Recolorable:    Yes
      BEAM size:      Larger
      Adding icons:   Recompile

  ## Examples

      <.icon name="fa-solid fa-rocket" />        # → <i class="fa-solid fa-rocket">
      <.icon name="hero-rocket-launch" />        # → <.heroicon name="rocket-launch">
      <.icon name={nil} />                       # → nothing

  ## Renderer-tuning attrs

  Common per-icon options flow through to the underlying element via
  `@rest`. See the allowlist on the `:rest` attr below — extend by adding
  to the `:include` list if you need an attr that isn't there yet.

      <.icon name="hero-rocket-launch" color="red" size="lg" />
  """
  use Phoenix.Component
  import PureAdmin.Components.Heroicon

  attr(:name, :string,
    required: true,
    doc:
      "Icon name. `\"hero-X\"` → Heroicons; anything else → FA-style `<i class>`. May be `nil` or empty at runtime — both render nothing."
  )

  attr(:class, :string,
    default: nil,
    doc: "Additional classes (color, hover state, etc.). For sizing prefer the `size` attr."
  )

  attr(:color, :string,
    default: nil,
    doc: "Color value — CSS color or renderer-specific fragment."
  )

  attr(:size, :string,
    default: nil,
    doc:
      "CSS length (e.g. `\"1.5rem\"`). Sets SVG `width`/`height` for heroicons, inline `font-size` for FA-style. Defaults to `PureAdmin.Config.icon_size/0`."
  )

  attr(:variant, :string,
    default: nil,
    doc: "Renderer-specific variant (e.g. FA `solid`/`regular`/`light`/`brands`)."
  )

  attr(:fill, :string, default: nil, doc: "SVG fill color.")
  attr(:stroke, :string, default: nil, doc: "SVG stroke color.")
  attr(:title, :string, default: nil, doc: "Tooltip title.")

  attr(:aria_label, :string,
    default: nil,
    doc: "Accessibility label — emits as `aria-label` in HTML."
  )

  attr(:is_interactive, :boolean,
    default: false,
    doc:
      "Make a STANDALONE icon its own hover affordance by wrapping it in " <>
        "`<span class=\"pc-icon-hover\">` (the foundation hover context; see pure-css " <>
        "`_icon-hover.scss`). Not needed when the icon sits inside an interactive control " <>
        "(button, nav link, tab): the control is already the hover context, and the marker " <>
        "class this component stamps reacts to it. Mirrors svelte's `isInteractive`."
  )

  def icon(%{name: nil} = assigns), do: ~H""
  def icon(%{name: ""} = assigns), do: ~H""

  # `is_interactive` adds the standalone hover CONTEXT (`.pc-icon-hover`). The CSS
  # uses a descendant selector (`.pc-icon-hover:hover .pc-icon-hover-fill|…`), so
  # the marker must live INSIDE this wrapper — hence the span. The per-set marker
  # itself is stamped by the branch (a "provider") in render_icon/1.
  def icon(assigns) do
    ~H"""
    <%= if @is_interactive do %><span class="pc-icon-hover"><%= render_icon(assigns) %></span><% else %><%= render_icon(assigns) %><% end %>
    """
  end

  # Heroicon (outline SVG) → recolour-on-hover marker (no solid form to fill).
  defp render_icon(%{name: "hero-" <> rest} = assigns) do
    assigns =
      assigns
      |> assign(:hero_name, rest)
      |> assign(:hero_class, join_class(assigns.class, "pc-icon-hover-highlight"))

    ~H"""
    <.heroicon
      name={@hero_name}
      class={@hero_class}
      color={@color}
      size={@size}
      variant={@variant}
      fill={@fill}
      stroke={@stroke}
      title={@title}
      aria_label={@aria_label}
    />
    """
  end

  defp render_icon(%{name: name} = assigns) when is_binary(name) do
    assigns = assign(assigns, :size_value, assigns[:size] || PureAdmin.Config.icon_size())

    case PureAdmin.Config.icon_callback() do
      callback when is_function(callback, 1) -> callback.(assigns)
      _ -> fallback_icon(assigns)
    end
  end

  # FA-style fallback → font-weight regular→solid flip marker (`pc-icon-hover-fill`).
  # This branch IS keen's built-in Font Awesome "provider", so it stamps the FA
  # marker like svelte's `fontAwesome()` does. (A configured `:icon_callback`
  # owns its own markup + markers, exactly like a custom svelte provider.)
  defp fallback_icon(assigns) do
    assigns = assign(assigns, :fa_class, join_class(join_class(assigns.name, assigns.class), "pc-icon-hover-fill"))

    ~H"""
    <i
      class={@fa_class}
      style={"font-size: #{@size_value}"}
      color={@color}
      title={@title}
      aria-label={@aria_label}
    ></i>
    """
  end

  defp join_class(a, b) do
    [a, b] |> Enum.reject(&(is_nil(&1) or &1 == "")) |> Enum.join(" ")
  end
end
