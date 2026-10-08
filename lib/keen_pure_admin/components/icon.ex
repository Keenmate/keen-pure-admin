defmodule PureAdmin.Components.Icon do
  @moduledoc """
  Smart icon dispatcher — resolves a string `name` to markup in two stages,
  mirroring svelte-pure-admin's `<Icon>`.

  ## Dispatch order

    1. **Framework affordance first (built-in, reserved).** If `name` is one of the
       framework's masked structural affordances (`x`, chevrons, `search`, `check`,
       `success`, `danger`, …) it renders `<span class="pa-icon pa-icon--NAME">` and
       stops. No provider can shadow an affordance — they always resolve, zero-config.
       Qualify external names (`"hero-close"`, a Lucide key) so they don't collide
       with the reserved bare affordance names.
    2. **Provider list, then built-in fallback.** Otherwise `name` is handed to each
       provider configured in `:icon_providers` (see `PureAdmin.Config`), in order;
       the first to return markup (non-`nil`) wins. If none match, a built-in
       fallback handles `"hero-X"` (→ `<.heroicon>`) and any other name as FA-style
       `<i class={name}>`.

  This component exists for the legacy `attr :icon, :string` pattern used by many
  chrome components (sidebar items, buttons, flash, profile nav items): callers
  pass a single string and the renderer figures out how to draw it.

  For direct usage of a specific set, prefer the specialized components:

      <.faicon name="rocket" variant="solid" />
      <.heroicon name="rocket-launch" class="size-4" />

  ## Providers

  A provider lets a project render icons with the set(s) it already has (Font
  Awesome, Lucide SVGs, an Iconify sprite, …) without hand-authoring
  `<fa-icon>` / `<hero-icon>` / raw `<svg>` at each call-site. Configure an
  ordered list once in `config.exs` and `<.icon>` routes every non-affordance
  name through it. See `PureAdmin.Config` for the contract.

  A provider is a 1-arity Phoenix function component receiving the full assigns
  (name + render context: `class`, `color`, `size`, `size_value`, `variant`,
  `fill`, `stroke`, `title`, `aria_label`, `is_interactive`) and returning
  rendered HEEx, or `nil` to pass the name to the next provider. The full
  context flows to every provider so a set can embed its own sizing / hover
  marker.

  ## Examples

      <.icon name="success" />                   # → <span class="pa-icon pa-icon--success">
      <.icon name="hero-rocket-launch" />        # → <.heroicon name="rocket-launch">
      <.icon name="fa-solid fa-rocket" />        # → <i class="fa-solid fa-rocket">
      <.icon name={nil} />                       # → nothing

  ## Renderer-tuning attrs

  Common per-icon options flow through to the underlying element / provider via
  the assigns. See the allowlist on the `:rest` attr below.
  """
  use Phoenix.Component
  import PureAdmin.Components.Heroicon

  # Framework masked structural affordances — kept in sync with core `_icons.scss`
  # and svelte's `AFFORDANCE_ICON_NAMES`. Reserved: resolve before any provider.
  @affordances ~w(x chevron chevron-right chevron-down chevron-left chevron-up
    caret caret-down caret-up clear remove expand collapse add edit delete search
    refresh filter check copy ellipsis ellipsis-vertical save settings bell user
    lock help logout download link external-link favorites info success warning danger)

  @doc "True if `name` is one of the framework's reserved masked affordances."
  @spec affordance?(term()) :: boolean()
  def affordance?(name) when is_binary(name), do: name in @affordances
  def affordance?(_), do: false

  attr(:name, :string,
    required: true,
    doc:
      "Icon name. A framework affordance (`\"success\"`, `\"chevron-down\"`, …) → masked `pa-icon--*` span; `\"hero-X\"` → Heroicons; anything else → the configured provider list, else FA-style `<i class>`. May be `nil` or empty at runtime — both render nothing."
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
      "CSS length (e.g. `\"1.5rem\"`). Sets SVG `width`/`height` for heroicons, inline `font-size` for FA-style, `font-size` + `--pa-icon-size` for masked affordances. Defaults to `PureAdmin.Config.icon_size/0` for sized renderers."
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
        "(button, nav link, tab): the control is already the hover context. Mirrors " <>
        "svelte's `isInteractive`."
  )

  def icon(%{name: nil} = assigns), do: ~H""
  def icon(%{name: ""} = assigns), do: ~H""

  # `is_interactive` adds the standalone hover CONTEXT (`.pc-icon-hover`). The CSS
  # uses a descendant selector (`.pc-icon-hover:hover .pc-icon-hover-fill|…`), so the
  # marker must live INSIDE this wrapper — hence the span.
  def icon(assigns) do
    assigns = assign(assigns, :size_value, assigns[:size] || PureAdmin.Config.icon_size())

    ~H"""
    <%= if @is_interactive do %><span class="pc-icon-hover"><%= render_icon(assigns) %></span><% else %><%= render_icon(assigns) %><% end %>
    """
  end

  # 1. Framework affordance — reserved, built-in, resolved first.
  defp render_icon(%{name: name} = assigns) when is_binary(name) do
    if affordance?(name) do
      render_affordance(assigns)
    else
      render_from_providers(assigns)
    end
  end

  defp render_affordance(assigns) do
    ~H"""
    <span
      class={["pa-icon", "pa-icon--#{@name}", @class]}
      style={@size && "font-size: #{@size}; --pa-icon-size: #{@size}"}
      role={@aria_label && "img"}
      aria-label={@aria_label}
      aria-hidden={if @aria_label, do: nil, else: "true"}
    ></span>
    """
  end

  # 2. Configured provider list (first non-nil wins), then the built-in fallback.
  defp render_from_providers(assigns) do
    case Enum.find_value(PureAdmin.Config.icon_providers(), fn provider -> provider.(assigns) end) do
      nil -> render_builtin(assigns)
      rendered -> rendered
    end
  end

  # Built-in heroicon provider (outline SVG) → recolour-on-hover marker.
  defp render_builtin(%{name: "hero-" <> rest} = assigns) do
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

  # Built-in FA-style fallback → font-weight regular→solid flip marker (`pc-icon-hover-fill`).
  defp render_builtin(assigns) do
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
