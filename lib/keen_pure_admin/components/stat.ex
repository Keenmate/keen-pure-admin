defmodule PureAdmin.Components.Stat do
  @moduledoc """
  Stat and metric display components for Pure Admin.

  Supports multiple variants: default (with optional icon), hero, hero-compact, and square.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  @doc """
  Renders a stat display.

  ## Variants

  - default: Simple number + label (optionally with icon)
  - `"hero"`: Large prominent stat with change indicator
  - `"hero-compact"`: Compact hero variant
  - `"square"`: Colored square stat with optional symbol

  ## Examples

      <.stat number="1,234" label_text="Total Users" />

      <.stat variant="hero" number="$12,345" label_text="Revenue"
        change_text="+12.5%" change_direction="positive" />

      <.stat variant="square" color="primary" number="42" label_text="Tasks" />

      <.stat number="99.9%" label_text="Uptime" icon_variant="success">
        <:icon><i class="fa-solid fa-check-circle"></i></:icon>
      </.stat>

      <%!-- Fit + progressive-disclosure square (v2.9.0-rc04). Needs a height
           source (explicit height / aspect-ratio / sized grid cell). --%>
      <.stat
        variant="square"
        color="info"
        is_fit
        number="847K"
        symbol_text="$"
        is_prefix_symbol
        label_text="Monthly Revenue"
        change_text="12.5% vs last month"
        change_direction="positive"
        context_text="Updated 2 min ago"
        style="height: 16rem;"
      />
  """
  attr(:variant, :string, default: nil, values: [nil, "hero", "hero-compact", "square"], doc: "Stat display variant")

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "success", "info", "warning", "danger"],
    doc: "Color for square variant"
  )

  attr(:icon_variant, :string,
    default: "primary",
    values: ["primary", "success", "info", "warning", "danger"],
    doc: "Icon color variant — `danger` added in v2.7.0. (No `--secondary`: core defines only these five.)"
  )

  attr(:number, :string, default: nil, doc: "Value to display")
  attr(:label_text, :string, default: nil, doc: "Label text")
  attr(:change_text, :string, default: nil, doc: "Change text (e.g. '+12.5%') for hero variant")

  attr(:change_direction, :string,
    default: nil,
    values: [nil, "very_positive", "positive", "neutral", "negative", "very_negative"],
    doc:
      "Sentiment direction colouring the hero __change. v2.7.0 extended the previous 3-step scale " <>
        "to 5 by adding `very_positive` / `very_negative` for outlier deltas. Neutral colour shifted " <>
        "from `--pc-text-color-2` to `--pc-neutral`."
  )

  attr(:symbol_text, :string, default: nil, doc: "Symbol text for square variant (e.g. `%`, `°C`, `$`, `¥`)")

  attr(:is_prefix_symbol, :boolean,
    default: false,
    doc:
      "Square variant only. When true, renders `__symbol` BEFORE `__number` for prefix currencies " <>
        "(`$847K`, `¥12.4M`). Default false renders `__number` first for suffix units (`87%`, `23°C`). " <>
        "v2.6.0 contract: markup order drives visual order — no CSS modifier needed."
  )

  attr(:is_fit, :boolean,
    default: false,
    doc:
      "Square variant only. Opt into fit-to-box + progressive-disclosure mode (v2.9.0-rc04). " <>
        "Emits `data-pa-stat-fit` and wires the `PureAdminStatFit` hook (`pa-stat-fit.js`): the " <>
        "`__number` is sized to fill the tile at the largest font that still fits (never overflows, " <>
        "any character count), and a priority ladder reveals rows as the tile earns BOTH width and " <>
        "height — `__number` (P0) → `__symbol` (P1) → `__label` (P2) → `__change` (P3) → `__context` " <>
        "(P4). Once the tile is ≥ 32rem wide it flips to a horizontal banner (`pa-stat--fit-wide`, " <>
        "toggled by the JS). REQUIRES a height source on the tile (explicit height / aspect-ratio / " <>
        "sized grid cell) because `container-type: size` sizes the box independently of its content. " <>
        "An `id` is auto-derived if not supplied via `:rest`."
  )

  attr(:context_text, :string,
    default: nil,
    doc:
      "Square fit-mode only. Lowest-priority (P4) caption row — e.g. `\"Updated 2 min ago\"` — " <>
        "rendered as `.pa-stat__context`. Revealed last, only when the tile is largest. Mirror of the " <>
        "`:context` slot (pass one or the other)."
  )

  # Legacy aliases
  attr(:value, :string, default: nil, doc: "Legacy alias for number")
  attr(:label, :string, default: nil, doc: "Legacy alias for label_text")
  attr(:trend, :string, default: nil, doc: "Legacy alias for change_text")
  attr(:trend_direction, :string, default: nil, doc: "Legacy alias for change_direction (up/down)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon, doc: "Icon content")

  slot(:context,
    doc:
      "Square fit-mode only. Rich (P4) `.pa-stat__context` caption row — the named-slot half of the " <>
        "`context_text` dual pair. Use when the caption needs markup; use `context_text` for a plain string."
  )

  slot(:inner_block, doc: "Custom layout content (overrides default rendering)")

  def stat(assigns) do
    # Resolve legacy aliases
    number = assigns.number || assigns.value
    label_text = assigns.label_text || assigns.label
    change_text = assigns.change_text || assigns.trend

    change_direction =
      assigns.change_direction ||
        case assigns.trend_direction do
          "up" -> "positive"
          "down" -> "negative"
          other -> other
        end

    # Fit mode is square-only. When on, emit `data-pa-stat-fit`, wire the
    # PureAdminStatFit hook, and auto-derive an id if the caller didn't pass
    # one via `:rest` (the hook needs a stable id, and LiveView requires an id
    # on any phx-hook element).
    is_fit = assigns.is_fit && assigns.variant == "square"

    # `inner_block` is the "custom layout" override, but a WHITESPACE-only
    # inner_block — the newlines HEEX captures around a named `<:icon>` slot —
    # must not count as custom content, or passing an icon silently blanks the
    # stat (it renders the whitespace and skips the number/label/icon cond).
    # Treat inner_block as an override only when the caller supplied no
    # structured inputs (number/value or an icon slot).
    custom_layout? = assigns.inner_block != [] and number == nil and assigns.icon == []

    assigns =
      assigns
      |> assign(:resolved_number, number)
      |> assign(:resolved_label, label_text)
      |> assign(:resolved_change, change_text)
      |> assign(:resolved_direction, change_direction)
      |> assign(:custom_layout?, custom_layout?)
      |> assign(:fit?, is_fit)
      # Only auto-derive an id when fit mode is on AND the caller didn't already
      # supply one via `:rest` — otherwise `{@rest}` renders the id and we'd emit
      # a duplicate attribute.
      |> assign(:fit_id, (is_fit && !Map.has_key?(assigns.rest, :id) && stat_auto_id()) || nil)

    ~H"""
    <div
      class={stat_classes(assigns)}
      data-pa-stat-fit={(@fit? && "") || nil}
      id={@fit_id}
      phx-hook={(@fit? && "PureAdminStatFit") || nil}
      {@rest}
    >
      <%!-- Custom content via inner_block (only when it's real content, not the
           whitespace HEEX captures around a named slot — see custom_layout?). --%>
      <%= if @custom_layout? do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= cond do %>
          <% @variant in ["hero", "hero-compact"] -> %>
            <div class="pa-stat__label"><%= @resolved_label %></div>
            <div class="pa-stat__value"><%= @resolved_number %></div>
            <div :if={@resolved_change} class={change_classes(@resolved_direction)}>
              <%= @resolved_change %>
            </div>

          <% @variant == "square" and @fit? -> %>
            <%!-- Fit mode: pa-stat-fit.js wraps __number + __symbol into
                 __slot > __group and the __label / __change / __context rows
                 into a __meta column at runtime. The canonical snippet emits
                 __number + __symbol as <span> in fit mode (inline flow inside
                 the JS-built __group) — matches core snippets/statistics.html. --%>
            <span :if={@symbol_text && @is_prefix_symbol} class="pa-stat__symbol"><%= @symbol_text %></span>
            <span class="pa-stat__number"><%= @resolved_number %></span>
            <span :if={@symbol_text && !@is_prefix_symbol} class="pa-stat__symbol"><%= @symbol_text %></span>
            <div class="pa-stat__label"><%= @resolved_label %></div>
            <%!-- Fit-mode disclosure rows (P3 change, P4 context). Rendered
                 flat; the JS moves them into the __meta column. --%>
            <div :if={@resolved_change} class={change_classes(@resolved_direction)}>
              <%= @resolved_change %>
            </div>
            <div :if={@context_text || @context != []} class="pa-stat__context">
              <%= if @context != [], do: render_slot(@context), else: @context_text %>
            </div>

          <% @variant == "square" -> %>
            <%!-- Non-fit square: static coloured tile. __number + __symbol as
                 <div> per the canonical snippet's classic square shape. No
                 disclosure rows (change/context are fit-mode only). --%>
            <div :if={@symbol_text && @is_prefix_symbol} class="pa-stat__symbol"><%= @symbol_text %></div>
            <div class="pa-stat__number"><%= @resolved_number %></div>
            <div :if={@symbol_text && !@is_prefix_symbol} class="pa-stat__symbol"><%= @symbol_text %></div>
            <div class="pa-stat__label"><%= @resolved_label %></div>

          <% @icon != [] -> %>
            <div class={"pa-stat__icon pa-stat__icon--#{@icon_variant}"}>
              <%= for icon <- @icon do %>
                <%= render_slot(icon) %>
              <% end %>
            </div>
            <div class="pa-stat__content">
              <div class="pa-stat__number"><%= @resolved_number %></div>
              <div class="pa-stat__label"><%= @resolved_label %></div>
            </div>

          <% true -> %>
            <div class="pa-stat__number"><%= @resolved_number %></div>
            <div class="pa-stat__label"><%= @resolved_label %></div>
            <div :if={@resolved_change} class={change_classes(@resolved_direction)}>
              <%= @resolved_change %>
            </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp stat_classes(assigns) do
    variant_class =
      case assigns.variant do
        "hero" -> "pa-stat--hero"
        # Core defines `pa-stat--hero-compact` as a standalone modifier (single
        # dash; shares base with `--hero` via a comma selector). The old
        # `pa-stat--hero--compact` was an invalid double-dash class that matched
        # nothing, and pairing it with `--hero` was redundant.
        "hero-compact" -> "pa-stat--hero-compact"
        "square" -> "pa-stat--square"
        _ -> nil
      end

    # Core only defines the colour variants COMPOUNDED with `--square`
    # (`.pa-stat--square.pa-stat--{color}`); a standalone `.pa-stat--{color}` on
    # a default/hero stat matches nothing. Gate the colour class on the square
    # variant so we never emit a dead modifier.
    color = assigns.color != nil and assigns.variant == "square"

    build_classes(
      "pa-stat",
      [
        {variant_class, variant_class != nil},
        {"pa-stat--#{assigns.color}", color}
      ],
      assigns.class
    )
  end

  defp stat_auto_id, do: "pa-stat-fit-#{System.unique_integer([:positive])}"

  defp change_classes(direction) do
    dir = if is_binary(direction), do: String.replace(direction, "_", "-")

    build_classes("pa-stat__change", [
      {"pa-stat__change--#{dir}", dir != nil}
    ])
  end
end
