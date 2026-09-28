defmodule DemoWeb.Live.KpiComparisonGaugesLive do
  use DemoWeb, :live_view

  # 1:1 port of pure-admin's `demo/views/kpi-comparison-gauges.mustache`.
  # Canonical card (--max-3) + 1×3 page-grid stress + 25/45/30 asymmetric
  # + Usage Guide + CSS Classes Reference.

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "KPI · Comparison gauges")}
  end

  defp gauges do
    [
      %{
        id: "completion",
        variant: "positive",
        label_text: gettext("Completion Rate"),
        value_text: "88.6",
        unit_text: "%",
        bar_percent: 98,
        scale_end_text: "tgt 90.0%",
        detail_title_text: "Completion Rate · 30D",
        target_text: "90.0%",
        previous_value_text: "84.2%",
        delta_text: "+5.2%"
      },
      %{
        id: "monthly-revenue",
        variant: "positive",
        label_text: gettext("Monthly Revenue"),
        prefix_text: "$",
        value_text: "835",
        unit_text: "K",
        bar_percent: 93,
        scale_end_text: "tgt $900K",
        detail_title_text: "Monthly Revenue · 12MO",
        target_text: "$900K",
        previous_value_text: "$752K",
        delta_text: "+11.0%"
      },
      %{
        id: "server-temp",
        variant: "positive",
        label_text: gettext("Server Temp"),
        value_text: "23.8",
        unit_text: "°C",
        bar_percent: 95,
        scale_end_text: "tgt 25.0°C",
        detail_title_text: "Server Temp · 24H",
        target_text: "25.0°C"
      },
      %{
        id: "server-capacity",
        variant: "warning",
        label_text: gettext("Server Capacity"),
        value_text: "84.5",
        unit_text: "%",
        bar_percent: 100,
        tick_position: "80%",
        scale_end_text: "tgt 80.0% / max 100%",
        detail_title_text: "Server Capacity · 7D",
        target_text: "≤ 80%"
      },
      %{
        id: "error-rate",
        variant: "positive",
        label_text: gettext("Error Rate"),
        value_text: "0.27",
        unit_text: "%",
        bar_percent: 54,
        scale_end_text: "tgt 0.50%",
        detail_title_text: "Error Rate · 24H",
        target_text: "≤ 0.50%"
      },
      %{
        id: "tokyo",
        variant: "neutral",
        label_text: gettext("Tokyo Office"),
        prefix_text: "¥",
        value_text: "11.7",
        unit_text: "M",
        bar_percent: 90,
        scale_end_text: "tgt ¥13.0M",
        detail_title_text: "Tokyo Office · 12MO",
        target_text: "¥13.0M"
      }
    ]
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">
      Goal-oriented progress bars: each KPI shows label · value on top, a bar with target tick in the
      middle, and a 0 · tgt scale below. Bar fill is <code>value / target × 100%</code> — colour
      signals overshoot/undershoot. Grid is a cell-min-driven <code>auto-fit</code> layout (no media
      queries).
    </.paragraph>

    <%!-- 1. Canonical card with --max-3 cap --%>

    <.kpi_gauge_list title_text={gettext("Quarterly targets")} is_live grid_layout="max_3" footer_text="3-column cap · cell-min driven · hover any bar for detail">
      <.gauge_tile :for={g <- gauges()} {gauge_assigns(g)} />
    </.kpi_gauge_list>

    <br />

    <%!-- 2. 1×3 page-grid (each card with --2col) --%>

    <h3>1×3 · <code>.pc-col-1-3</code> columns, each card <code>--2col</code></h3>
    <p>
      Each card carries two gauges in a deterministic 2-col grid. Useful at moderate viewport widths where
      auto-fit would still pack only 1 col per card.
    </p>

    <div class="pc-row">
      <div :for={pair <- gauges() |> Enum.chunk_every(2) |> Enum.take(3)} class="pc-col-100 pc-col-md-1-3">
        <.kpi_gauge_list grid_layout="2col">
          <.gauge_tile :for={g <- pair} {gauge_assigns(g, "c13-")} />
        </.kpi_gauge_list>
      </div>
    </div>

    <br />

    <%!-- 3. Asymmetric 25/45/30 --%>

    <h3>Asymmetric · <code>.pc-col-25</code> + <code>.pc-col-45</code> + <code>.pc-col-30</code></h3>
    <p>
      Mixed-width cells: narrow 25% uses <code>cell_min_width="16rem"</code> to keep 1 col; the mid 45%
      auto-fits 2 cols; the 30% caps at 2 columns via <code>--max-2</code>.
    </p>

    <div class="pc-row">
      <div class="pc-col-100 pc-col-md-25">
        <.kpi_gauge_list cell_min_width="16rem">
          <.gauge_tile :for={g <- Enum.take(gauges(), 3)} {gauge_assigns(g, "asym1-")} />
        </.kpi_gauge_list>
      </div>
      <div class="pc-col-100 pc-col-md-45">
        <.kpi_gauge_list>
          <.gauge_tile :for={g <- Enum.take(gauges(), 4)} {gauge_assigns(g, "asym2-")} />
        </.kpi_gauge_list>
      </div>
      <div class="pc-col-100 pc-col-md-30">
        <.kpi_gauge_list grid_layout="max_2">
          <.gauge_tile :for={g <- Enum.take(gauges(), 2)} {gauge_assigns(g, "asym3-")} />
        </.kpi_gauge_list>
      </div>
    </div>

    <br />

    <%!-- Usage Guide --%>

    <.card title_text={gettext("Usage Guide")}>
      <h4>When to use</h4>
      <p>
        Goal-oriented dashboards — each KPI is shown as a progress bar against a target. Best when the
        operator's mental model is "are we on track?" rather than "what's the trend?". For trend-first
        reads, see Sparkline list or Terminal grid; for purely textual scanning, see Numeric strip.
      </p>

      <h4 class="mt-4">Bar semantics — two modes</h4>
      <p>
        <strong>Default mode (0 → target scale):</strong> the bar's full width represents the target.
        Fill width = <code>value / target</code>, capped at 100%. Tick sits at the right edge. Overshoots
        are signalled by the warning colour rather than overflow.
      </p>
      <p>
        <strong>0 → max scale</strong> (override <code>tick_position</code>): bar's full width represents
        some wider scale (e.g. 0–100% capacity). Tick slides inside the bar to mark the target. Overshoots
        become visible as fill extending past the tick. See "Server Capacity" in the canonical card.
      </p>

      <h4 class="mt-4">Sentiment colours</h4>
      <ul>
        <li><strong>positive</strong> (green) — on track / approaching target.</li>
        <li><strong>warning</strong> (orange) — off-target or approaching a limit.</li>
        <li><strong>negative</strong> (red) — actively bad / failing target.</li>
        <li><strong>neutral</strong> (grey) — informational, no strong sentiment.</li>
      </ul>

      <h4 class="mt-4">Layout</h4>
      <p>
        Default <code>kpi_gauge_list</code> is a cell-min-driven <code>auto-fit</code> grid: cells stay
        at least <code>cell_min_width</code> wide (default upstream <code>20rem</code>), the grid fits as
        many columns as the container allows. <code>grid_layout="max_N"</code> caps the column count;
        <code>grid_layout="2col"</code> forces exactly 2.
      </p>

      <h4 class="mt-4">Hairline dividers</h4>
      <p>
        Dividers are <code>gap: 1px</code> over <code>background: var(--pc-border-color)</code>; each
        tile paints <code>background: var(--pc-card-bg)</code> on top. The gap shows through, giving
        single-pixel hairlines on every interior boundary regardless of column count.
      </p>
    </.card>

    <br />

    <%!-- CSS Classes Reference --%>

    <.card title_text={gettext("CSS Classes Reference")}>
      <h4>Card structure</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-gauge-list</code> — page-namespace class on <code>.pa-card</code>.</li>
        <li><code>pa-kpi-gauge-list__body</code> — <code>padding: 0</code> so hairlines reach the card edges.</li>
        <li><code>pa-kpi-gauge-list__grid</code> — cell-min auto-fit grid.</li>
      </ul>

      <h4 class="mt-4">Grid layout modifiers</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-gauge-list__grid--2col</code> — force exactly 2 columns.</li>
        <li><code>pa-kpi-gauge-list__grid--max-2</code> / <code>--max-3</code> / <code>--max-4</code> / <code>--max-5</code> / <code>--max-6</code> — cap column count.</li>
      </ul>

      <h4 class="mt-4">Layout CSS variables</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>--pa-kpi-gauge-cell-min</code> — min cell width for auto-fit (default <code>20rem</code>).</li>
      </ul>

      <h4 class="mt-4">Gauge tile</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-gauge</code> — single gauge cell. Carries <code>--pa-kpi-bar-color</code>.</li>
        <li><code>pa-kpi-gauge--positive</code> / <code>--warning</code> / <code>--negative</code> / <code>--neutral</code>.</li>
        <li><code>pa-kpi-gauge__head</code> / <code>__label</code> / <code>__value</code> / <code>__num</code> / <code>__unit</code> / <code>__scale</code>.</li>
        <li><code>pa-kpi-gauge__bar</code> / <code>__fill</code> — track + fill (width inline).</li>
      </ul>

      <h4 class="mt-4">Bar tick CSS variables</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>--pa-kpi-gauge-tick-pos</code> — target tick position (default <code>100%</code>).</li>
        <li><code>--pa-kpi-gauge-tick-color</code> — tick colour (default <code>var(--pc-text-color-1)</code>).</li>
      </ul>
    </.card>
    """
  end

  defp gauge_assigns(g, id_prefix \\ ""), do: Map.merge(g, %{id: id_prefix <> g.id})

  attr(:id, :string, required: true)
  attr(:variant, :string, required: true)
  attr(:label_text, :string, required: true)
  attr(:value_text, :string, required: true)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:bar_percent, :integer, required: true)
  attr(:tick_position, :string, default: nil)
  attr(:scale_end_text, :string, default: nil)
  attr(:detail_title_text, :string, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)

  defp gauge_tile(assigns) do
    ~H"""
    <.kpi_gauge
      id={@id}
      variant={@variant}
      label_text={@label_text}
      value_text={@value_text}
      unit_text={@unit_text}
      prefix_text={@prefix_text}
      bar_percent={@bar_percent}
      tick_position={@tick_position}
      scale_end_text={@scale_end_text}
      detail_title_text={@detail_title_text}
      target_text={@target_text}
      previous_value_text={@previous_value_text}
      delta_text={@delta_text}
    />
    """
  end
end
