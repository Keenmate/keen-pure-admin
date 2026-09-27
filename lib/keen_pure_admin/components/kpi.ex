defmodule PureAdmin.Components.Kpi do
  @moduledoc """
  Shared substrate for the Pure Admin KPI showcase family.

  Tracks `@keenmate/pure-admin-core` v2.7.1+ where the seven KPI showcase
  designs (Terminal grid, Sparkline list, Comparison gauges, Hero+supporting,
  Bento, Numeric strip, Editorial minimal) were promoted from inline demo
  styles into permanent `pa-kpi-*` core components. This module provides the
  parts every showcase reuses:

  - `kpi_tile/1` — the canonical tile (head · label · value · prev row ·
    sparkline slot · optional hover detail) used by Terminal grid and as a
    standalone primitive.
  - `kpi_detail/1` — hover detail popover with auto-built rows from typed
    props or a raw `:inner_block` override. The host tile / row carries the
    `phx-hook="PureAdminKpiTile"` attribute; this component just emits the
    popover element that the hook finds and moves to `<body>`.
  - `kpi_sparkline/1` — convenience SVG sparkline matching upstream defaults.
    Optional — the chart slot accepts any renderer.

  Showcase-specific wrappers (terminal-grid chrome, hero+supporting layout,
  bento grid, gauge list, etc.) build on top of these primitives in dedicated
  modules — see `PureAdmin.Components.Kpi.*` siblings.

  ## Design principles

  1. **Pluggable chart rendering.** The `:chart` slot accepts any markup —
     inline SVG, a hook-mounted container for Chart.js / D3 / ApexCharts /
     Contex / etc. The framework does not pick a chart library.
  2. **Labels are fully customisable.** Every textual element is an attribute
     or slot. No English strings are hardcoded; consumers control all i18n
     at the call site.

  ## Auto-built detail popover

  Set `detail_title_text` on `kpi_tile/1` (plus any combination of
  `target_text` / `delta_absolute_text` / `previous_value_text` / etc.) and
  the popover body is built for you. The row order is Current → Previous →
  Δ absolute → Δ percent → Target — rows without data are skipped. For raw
  control, pass a `:detail` slot instead.

  ## Floating UI requirement

  The popover hook (`PureAdminKpiTile`) expects Floating UI loaded globally
  as `window.FloatingUIDOM` — same convention as Tooltip / Popconfirm.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  alias PureAdmin.Components.KpiDetail

  @sentiments [nil, "very_positive", "positive", "neutral", "negative", "very_negative"]
  @trend_directions [nil, "up_strong", "up", "flat", "down", "down_strong"]

  # ----------------------------------------------------------------------
  # kpi_tile/1
  # ----------------------------------------------------------------------

  @doc """
  Renders a single KPI tile.

  Used by the Terminal grid showcase and as a standalone primitive when
  `is_standalone` is set. The tile is the hover host for the detail popover
  when either `detail_title_text` is set OR a `:detail` slot is provided —
  in those cases the component sets `phx-hook="PureAdminKpiTile"` (an
  `id` is required for the hook).

  ## Examples

      <.kpi_tile
        id="completion-rate-30d"
        id_text="KPI.01 · 30d"
        status_text="WARN"
        status_variant="warn"
        label_text="Completion Rate"
        value_text="88.6"
        unit_text="%"
        variant="up"
        previous_value_text="84.2%"
        delta_text="▲ 5.2%"
        delta_variant="positive"
        detail_title_text="Completion Rate · 30D"
        delta_absolute_text="+4.4pp"
        target_text="90.0%"
      >
        <:chart>
          <.kpi_sparkline points="0,18 12,16 24,17 36,12 48,15 60,9 72,11 84,7 96,5" dot_at={{96, 5}} />
        </:chart>
      </.kpi_tile>

  Standalone (outside a `pa-kpi-terminal__grid`):

      <.kpi_tile id_text="KPI.07" label_text="Custom" value_text="42" is_standalone>
        <:chart><!-- consumer-provided D3 / Apex / etc. --></:chart>
      </.kpi_tile>

  ## Sentiment axes

  - `variant` colours the entire tile's spark-direction cascade
    (`up_strong` / `up` / `flat` / `down` / `down_strong`). Named by
    *sentiment of the change*, not by line shape — error-rate dropping is
    `"up"`, server-temp climbing is `"down"`.
  - `value_variant` colours the focal number itself (rare — usually the
    delta carries the colour).
  - `delta_variant` colours the bottom-row delta text.
  """
  attr(:id, :string,
    default: nil,
    doc: "Required when the popover hook is engaged (detail_title_text set OR :detail slot present)"
  )

  attr(:variant, :string,
    default: nil,
    values: @trend_directions,
    doc: "Spark-direction sentiment cascade — colours the sparkline via `currentColor`"
  )

  attr(:is_standalone, :boolean,
    default: false,
    doc:
      "Adds `pa-kpi-tile--standalone` (full border + card bg + bottom margin) for tiles outside `pa-kpi-terminal__grid`"
  )

  attr(:id_text, :string, default: nil, doc: "Identifier shown in tile head (e.g. \"KPI.01 · 30d\")")

  attr(:status_text, :string,
    default: nil,
    doc: "Status pill text (e.g. \"WARN\", \"GOOD\", \"NEUTRAL\")"
  )

  attr(:status_variant, :string,
    default: nil,
    doc: "Status pill variant — built-ins: \"warn\" / \"good\" / \"neutral\""
  )

  attr(:label_text, :string, default: nil, doc: "Uppercase mono tile label")

  attr(:value_text, :string, default: nil, doc: "Focal numeric value")
  attr(:unit_text, :string, default: nil, doc: "Unit suffix (\"%\", \"°C\", \"K\")")
  attr(:prefix_text, :string, default: nil, doc: "Currency / scale prefix (\"$\", \"¥\")")

  attr(:value_variant, :string,
    default: nil,
    values: @sentiments,
    doc: "Sentiment colour applied to the focal number"
  )

  attr(:previous_value_text, :string,
    default: nil,
    doc: "Bare previous value (e.g. \"84.2%\"); rendered as `prev <value>` in the bottom row"
  )

  attr(:delta_text, :string,
    default: nil,
    doc: "Bottom-row Δ% (e.g. \"▲ 5.2%\") — caller provides the arrow"
  )

  attr(:delta_variant, :string,
    default: nil,
    values: @sentiments,
    doc: "Sentiment colour for the bottom-row delta"
  )

  # Auto-built detail popover props
  attr(:detail_title_text, :string,
    default: nil,
    doc: "Setting this (or providing `:detail`) enables the popover"
  )

  attr(:delta_absolute_text, :string, default: nil, doc: "Absolute delta shown only in the popover")

  attr(:delta_absolute_sentiment, :atom,
    default: nil,
    values: [nil, :pos, :neg, :warn],
    doc: "Sentiment override for the Δ absolute popover row"
  )

  attr(:target_text, :string, default: nil, doc: "Target value shown only in the popover")

  attr(:detail_rows, :list,
    default: nil,
    doc: "Override the auto-built popover rows with a typed list — see `PureAdmin.Components.KpiDetail`"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:head, doc: "Override the head row (id + status) with custom markup")
  slot(:label, doc: "Override the label cell with custom markup")
  slot(:value, doc: "Override the focal value cell with custom markup")
  slot(:previous_value, doc: "Override the prev/delta row with custom markup")
  slot(:chart, doc: "Chart cell — pass any SVG / hook-mounted chart container")
  slot(:detail, doc: "Raw popover content — overrides the auto-built popover")

  def kpi_tile(assigns) do
    has_detail? = assigns.detail != [] or assigns.detail_title_text != nil

    assigns = assign(assigns, :has_detail?, has_detail?)

    ~H"""
    <div
      id={@id}
      class={tile_classes(@variant, @is_standalone, @class)}
      phx-hook={if @has_detail?, do: "PureAdminKpiTile"}
      {@rest}
    >
      <%= if @head != [] do %>
        <div class="pa-kpi-tile__head">
          {render_slot(@head)}
        </div>
      <% else %>
        <div :if={@id_text || @status_text} class="pa-kpi-tile__head">
          <span :if={@id_text} class="pa-kpi-tile__id">{@id_text}</span>
          <span :if={@status_text} class={status_classes(@status_variant)}>{@status_text}</span>
        </div>
      <% end %>

      <%= if @label != [] do %>
        <div class="pa-kpi-tile__label">{render_slot(@label)}</div>
      <% else %>
        <div :if={@label_text} class="pa-kpi-tile__label">{@label_text}</div>
      <% end %>

      <div :if={@value != [] || @value_text || @prefix_text || @unit_text} class="pa-kpi-tile__values">
        <span class={value_classes(@value_variant)}>
          <%= if @value != [] do %>
            {render_slot(@value)}
          <% else %>
            <span :if={@prefix_text} class="pa-kpi-tile__unit">{@prefix_text}</span>
            <span :if={@value_text} class="pa-kpi-tile__num">{@value_text}</span>
            <span :if={@unit_text} class="pa-kpi-tile__unit">{@unit_text}</span>
          <% end %>
        </span>
      </div>

      <%= if @previous_value != [] do %>
        <div class="pa-kpi-tile__prev">{render_slot(@previous_value)}</div>
      <% else %>
        <div :if={@previous_value_text || @delta_text} class="pa-kpi-tile__prev">
          <span :if={@previous_value_text}>prev {@previous_value_text}</span>
          <span :if={@delta_text} class={delta_classes(@delta_variant)}>{@delta_text}</span>
        </div>
      <% end %>

      <%= for c <- @chart do %>
        {render_slot(c)}
      <% end %>

      <%= if @detail != [] do %>
        <.kpi_detail :if={@has_detail?}>
          <%= for d <- @detail do %>
            {render_slot(d)}
          <% end %>
        </.kpi_detail>
      <% else %>
        <.kpi_detail
          :if={@has_detail?}
          title_text={@detail_title_text}
          rows={@detail_rows || auto_detail_rows(assigns)}
        />
      <% end %>
    </div>
    """
  end

  defp auto_detail_rows(assigns) do
    KpiDetail.build_auto_rows(
      prefix_text: assigns.prefix_text,
      value_text: assigns.value_text,
      unit_text: assigns.unit_text,
      previous_value_text: assigns.previous_value_text,
      delta_absolute_text: assigns.delta_absolute_text,
      delta_absolute_sentiment: assigns.delta_absolute_sentiment,
      delta_text: assigns.delta_text,
      delta_sentiment: KpiDetail.delta_to_sentiment(assigns.delta_variant),
      target_text: assigns.target_text
    )
  end

  defp tile_classes(variant, is_standalone, extra) do
    dir = KpiDetail.dasherize(variant)

    build_classes(
      "pa-kpi-tile",
      [
        {"pa-kpi-tile--#{dir}", dir != nil},
        {"pa-kpi-tile--standalone", is_standalone}
      ],
      extra
    )
  end

  defp status_classes(variant) do
    v = KpiDetail.dasherize(variant)

    build_classes("pa-kpi-tile__status", [
      {"pa-kpi-tile__status--#{v}", v != nil}
    ])
  end

  defp value_classes(variant) do
    v = KpiDetail.dasherize(variant)

    build_classes("pa-kpi-tile__value", [
      {"pa-kpi-tile__value--#{v}", v != nil}
    ])
  end

  defp delta_classes(variant) do
    v = KpiDetail.dasherize(variant)

    build_classes("pa-kpi-tile__delta", [
      {"pa-kpi-tile__delta--#{v}", v != nil}
    ])
  end

  # ----------------------------------------------------------------------
  # kpi_detail/1
  # ----------------------------------------------------------------------

  @doc """
  Renders the KPI hover detail popover.

  Two ways to author content:

  - **Auto-built rows**: pass `title_text` and a `rows` list (typically
    produced by `PureAdmin.Components.KpiDetail.build_auto_rows/1`). Each
    row is `%{label_text: ..., value_text: ..., sentiment: ...}`.
  - **Raw override**: include any markup as `inner_block`. The component
    just provides the `<div class="pa-kpi-detail" role="tooltip">` wrapper;
    write your own `__title` + `<dl>` inside.

  The popover element is opt-in: it renders nothing when there's no title,
  no rows, and no inner_block. Place it as a direct child of the host tile
  / row that carries `phx-hook="PureAdminKpiTile"` — the hook moves the
  popover to `<body>` on mount and follows the cursor inside the host.

  ## Examples

      <.kpi_detail
        title_text="Completion Rate · 30D"
        rows={[
          %{label_text: "Current", value_text: "88.6%"},
          %{label_text: "Previous", value_text: "84.2%"},
          %{label_text: "Δ absolute", value_text: "+4.4pp", sentiment: :pos},
          %{label_text: "Target", value_text: "90.0%"}
        ]}
      />

      <.kpi_detail>
        <div class="pa-kpi-detail__title">Custom</div>
        <p>Whatever markup you want.</p>
      </.kpi_detail>
  """
  attr(:title_text, :string, default: nil)
  attr(:rows, :list, default: [])
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, doc: "Raw popover content — overrides title + rows")

  def kpi_detail(assigns) do
    has_inner? = assigns.inner_block != []
    has_data? = assigns.title_text != nil or assigns.rows != []
    assigns = assigns |> assign(:has_inner?, has_inner?) |> assign(:has_data?, has_data?)

    ~H"""
    <div
      :if={@has_inner? || @has_data?}
      class={build_classes("pa-kpi-detail", [], @class)}
      role="tooltip"
      {@rest}
    >
      <%= if @has_inner? do %>
        {render_slot(@inner_block)}
      <% else %>
        <div :if={@title_text} class="pa-kpi-detail__title">{@title_text}</div>
        <dl :if={@rows != []}>
          <%= for row <- @rows do %>
            <dt>{row.label_text}</dt>
            <dd class={KpiDetail.sentiment_class(Map.get(row, :sentiment))}>{row.value_text}</dd>
          <% end %>
        </dl>
      <% end %>
    </div>
    """
  end

  # ----------------------------------------------------------------------
  # kpi_sparkline/1 (convenience)
  # ----------------------------------------------------------------------

  @doc """
  Convenience SVG sparkline matching upstream's default look.

  This is **one option** for the `:chart` slot — consumers who already have
  a chart library should put that in the slot instead. The sparkline renders
  a `<polyline>` inside an SVG with `preserveAspectRatio="none"` so the
  line stretches to fill the container width. The framework's
  `--pa-chart-trendline-height` and `--pa-chart-trendline-stroke` tokens
  control height and stroke width.

  When `dot_at` is given, the SVG emits a `<circle>` at that point — at
  mount time `PureAdminKpiSparkDot` swaps it for a CSS-pixel-sized
  `<span class="pa-kpi-spark-dot">` so the dot stays circular regardless of
  chart aspect ratio. Set `id` to engage the hook.

  ## Examples

      <.kpi_sparkline points="0,18 12,16 24,17 36,12 48,15" />

      <.kpi_sparkline
        id="spark-completion"
        points="0,18 12,16 24,17 36,12 48,15 60,9 72,11 84,7 96,5"
        dot_at={{96, 5}}
      />
  """
  attr(:id, :string, default: nil)
  attr(:points, :string, required: true, doc: "SVG polyline points (e.g. \"0,18 12,16 24,17\")")
  attr(:view_box, :string, default: "0 0 100 24")
  attr(:dot_at, :any, default: nil, doc: "`{cx, cy}` tuple for the trailing dot")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def kpi_sparkline(assigns) do
    {cx, cy} =
      case assigns.dot_at do
        {x, y} -> {x, y}
        _ -> {nil, nil}
      end

    assigns = assigns |> assign(:cx, cx) |> assign(:cy, cy)

    ~H"""
    <svg
      id={@id}
      class={build_classes("pa-kpi-tile__spark", [], @class)}
      viewBox={@view_box}
      preserveAspectRatio="none"
      phx-hook={if @cx, do: "PureAdminKpiSparkDot"}
      {@rest}
    >
      <polyline points={@points} />
      <circle :if={@cx} cx={@cx} cy={@cy} r="2" />
    </svg>
    """
  end
end
