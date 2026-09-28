defmodule DemoWeb.Live.KpiTerminalGridLive do
  use DemoWeb, :live_view

  # 1:1 port of pure-admin's `demo/views/kpi-terminal-grid.mustache`.
  # Canonical card (3 tabs · 6/2/4 tiles) + 1×3 page-grid stress test +
  # 25%/45% asymmetric stress test + Chart.js drop-in + Usage Guide + CSS
  # Classes Reference card.

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "KPI · Terminal grid")}
  end

  defp tiles_overview do
    [
      %{
        id: "ovw-1",
        id_text: "KPI.01 · 30d",
        status_text: "WARN",
        status_variant: "warn",
        label_text: gettext("Completion Rate"),
        value_text: "88.6",
        unit_text: "%",
        variant: "up",
        previous_value_text: "84.2%",
        delta_text: "▲ 5.2%",
        delta_variant: "positive",
        detail_title_text: "Completion Rate · 30D",
        delta_absolute_text: "+4.4pp",
        delta_absolute_sentiment: :pos,
        target_text: "90.0%",
        points: "0,18 12,16 24,17 36,12 48,15 60,9 72,11 84,7 96,5",
        dot: {96, 5}
      },
      %{
        id: "ovw-2",
        id_text: "KPI.02 · 12mo",
        status_text: "GOOD",
        status_variant: "good",
        label_text: gettext("Monthly Revenue"),
        prefix_text: "$",
        value_text: "835",
        unit_text: "K",
        variant: "up",
        previous_value_text: "$752K",
        delta_text: "▲ 11.0%",
        delta_variant: "positive",
        detail_title_text: "Monthly Revenue · 12MO",
        delta_absolute_text: "+$83K",
        delta_absolute_sentiment: :pos,
        target_text: "$900K",
        points: "0,16 12,15 24,14 36,15 48,13 60,14 72,12 84,13 96,11",
        dot: {96, 11}
      },
      %{
        id: "ovw-3",
        id_text: "KPI.03 · 24h",
        status_text: "GOOD",
        status_variant: "good",
        label_text: gettext("Server Temp"),
        value_text: "22.9",
        unit_text: "°C",
        variant: "down",
        previous_value_text: "24.5°C",
        delta_text: "▼ 6.5%",
        delta_variant: "negative",
        detail_title_text: "Server Temp · 24H",
        delta_absolute_text: "−1.6°C",
        delta_absolute_sentiment: :neg,
        target_text: "≤ 23°C",
        points: "0,18 12,17 24,15 36,14 48,12 60,11 72,10 84,9 96,11",
        dot: {96, 11}
      },
      %{
        id: "ovw-4",
        id_text: "KPI.04 · 7d",
        status_text: "WARN",
        status_variant: "warn",
        label_text: gettext("Server Capacity"),
        value_text: "81.6",
        unit_text: "%",
        variant: "up",
        previous_value_text: "71.0%",
        delta_text: "▲ 14.9%",
        delta_variant: "positive",
        detail_title_text: "Server Capacity · 7D",
        delta_absolute_text: "+10.6pp",
        delta_absolute_sentiment: :pos,
        target_text: "≤ 75%",
        points: "0,17 12,15 24,12 36,10 48,8 60,9 72,11 84,13 96,12",
        dot: {96, 12}
      },
      %{
        id: "ovw-5",
        id_text: "KPI.05 · 24h",
        status_text: "GOOD",
        status_variant: "good",
        label_text: gettext("Error Rate"),
        value_text: "0.24",
        unit_text: "%",
        variant: "up_strong",
        previous_value_text: "0.41%",
        delta_text: "▼ 41.0%",
        delta_variant: "very_positive",
        detail_title_text: "Error Rate · 24H",
        delta_absolute_text: "−0.17pp",
        delta_absolute_sentiment: :pos,
        target_text: "≤ 0.50%",
        points: "0,8 12,10 24,9 36,12 48,11 60,14 72,12 84,15 96,17",
        dot: {96, 17}
      },
      %{
        id: "ovw-6",
        id_text: "KPI.06 · 12mo",
        status_text: "NEUTRAL",
        status_variant: "neutral",
        label_text: gettext("Tokyo Office"),
        prefix_text: "¥",
        value_text: "11.6",
        unit_text: "M",
        variant: "up",
        previous_value_text: "¥11.2M",
        delta_text: "▲ 3.5%",
        delta_variant: "positive",
        detail_title_text: "Tokyo Office · 12MO",
        delta_absolute_text: "+0.39M",
        delta_absolute_sentiment: :pos,
        target_text: "¥13.0M",
        points: "0,15 12,16 24,14 36,13 48,15 60,12 72,13 84,11 96,10",
        dot: {96, 10}
      }
    ]
  end

  defp tiles_finance, do: Enum.filter(tiles_overview(), &(&1.id in ["ovw-2", "ovw-6"]))

  defp tiles_ops do
    base = tiles_overview()
    Enum.filter(base, &(&1.id in ["ovw-1", "ovw-3", "ovw-4", "ovw-5"]))
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">
      Bloomberg-y "terminal grid" KPI panel — mono numbers, status tags, sparklines, ▲▼ deltas. The header
      strip is a <strong>tab control</strong>: each tab swaps in a separate pane with its own tile set and
      grid layout (different tile counts allowed). Hover any tile for the detail breakdown.
    </.paragraph>

    <%!-- 1. Terminal grid · canonical card with three tabs --%>

    <.kpi_terminal id="exec-kpis" title_text={gettext("Key Performance Indicators")} is_live footer_text="Bloomberg-y dense — Hover any KPI for detail · Click a tab to swap the pane">
      <:pane id="overview" label_text={gettext("OVERVIEW")} is_active>
        <.tile :for={t <- tiles_overview()} {tile_assigns(t)} />
      </:pane>
      <:pane id="finance" label_text={gettext("FINANCE")}>
        <.tile :for={t <- tiles_finance()} {tile_assigns(t, "fin-")} />
      </:pane>
      <:pane id="ops" label_text={gettext("OPERATIONS")}>
        <.tile :for={t <- tiles_ops()} {tile_assigns(t, "ops-")} />
      </:pane>
    </.kpi_terminal>

    <br />

    <%!-- 2. Layout test — 1×3 page-grid columns --%>

    <h3>1×3 · <code>.pc-col-1-3</code> columns</h3>
    <p>
      Each tile in its own <code>.pc-col-1-3</code> (33% page-grid column) as a <em>standalone</em> mini-card
      — no shared terminal-grid chrome, no tabs. Tests how a single tile renders at one-third of the viewport
      width, the typical "stat strip" placement.
    </p>

    <div class="pc-row">
      <div :for={t <- tiles_overview() |> Enum.take(3) |> Enum.with_index()} class="pc-col-100 pc-col-md-1-3">
        <.tile {tile_assigns(elem(t, 0), "col13-")} is_standalone />
      </div>
    </div>

    <br />

    <%!-- 3. Layout test — 25 / 45 asymmetric --%>

    <h3>Asymmetric · <code>.pc-col-25</code> + <code>.pc-col-45</code> + <code>.pc-col-30</code></h3>
    <p>
      Mixed-width page-grid: a narrow <code>.pc-col-25</code> (25%), a mid <code>.pc-col-45</code> (45%),
      and a <code>.pc-col-30</code> (30%) all carrying standalone tiles. Surfaces how the typography + layout
      handles narrow vs wide cells in the same row.
    </p>

    <div class="pc-row">
      <div class="pc-col-100 pc-col-md-25">
        <.tile {tile_assigns(Enum.at(tiles_overview(), 0), "asym-")} is_standalone />
      </div>
      <div class="pc-col-100 pc-col-md-45">
        <.tile {tile_assigns(Enum.at(tiles_overview(), 1), "asym-")} is_standalone />
      </div>
      <div class="pc-col-100 pc-col-md-30">
        <.tile {tile_assigns(Enum.at(tiles_overview(), 4), "asym-")} is_standalone />
      </div>
    </div>

    <br />

    <%!-- 4. Custom chart library — Chart.js drop-in --%>

    <h3>Custom chart library · <code>Chart.js</code> in the chart slot</h3>
    <p>
      The terminal sparkline is just a <code>&lt;svg class="pa-kpi-tile__spark"&gt;</code> — swap it for a
      <code>&lt;canvas class="pa-kpi-tile__spark" data-kpi-chart&gt;</code> and a real charting library renders
      into the same place, here a Chart.js <strong>bar chart</strong> so it's clearly not the default line
      sparkline. The <code>pa-kpi-tile__spark</code> class still carries the tile's sentiment
      <code>color</code>, so the bars read <code>currentColor</code> and track the sentiment scale + theme.
    </p>

    <.kpi_terminal title_text={gettext("Key Performance Indicators")} is_live footer_text="Chart.js bar charts library-rendered into the pa-kpi-tile__spark slot · Switch theme to see the bars re-colour">
      <.kpi_tile
        id="cjs-completion"
        id_text="KPI.01 · 30d"
        status_text="WARN"
        status_variant="warn"
        label_text={gettext("Completion Rate")}
        value_text="88.6"
        unit_text="%"
        variant="up"
        previous_value_text="84.2%"
        delta_text="▲ 5.2%"
        delta_variant="positive"
        detail_title_text="Completion Rate · 30D"
        target_text="90.0%"
      >
        <:chart>
          <canvas
            id="cjs-completion-chart"
            class="pa-kpi-tile__spark"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="bar"
            data-kpi-aspect="6"
            data-kpi-points="[84.2, 84.8, 84.5, 85.6, 85.2, 86.4, 86.0, 87.3, 87.0, 88.0, 88.6]"
          />
        </:chart>
      </.kpi_tile>

      <.kpi_tile
        id="cjs-error"
        id_text="KPI.02 · 24h"
        status_text="GOOD"
        status_variant="good"
        label_text={gettext("Error Rate")}
        value_text="0.28"
        unit_text="%"
        variant="up_strong"
        previous_value_text="0.42%"
        delta_text="▼ 33.3%"
        delta_variant="very_positive"
        detail_title_text="Error Rate · 24H"
        target_text="≤ 0.50%"
      >
        <:chart>
          <canvas
            id="cjs-error-chart"
            class="pa-kpi-tile__spark"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="bar"
            data-kpi-aspect="6"
            data-kpi-points="[0.42, 0.41, 0.40, 0.38, 0.37, 0.35, 0.34, 0.32, 0.31, 0.29, 0.28]"
          />
        </:chart>
      </.kpi_tile>
    </.kpi_terminal>

    <br />

    <%!-- Usage Guide --%>

    <.card title_text={gettext("Usage Guide")}>
      <h4>When to use</h4>
      <p>
        Bloomberg-style dense KPI panels: per-tile depth (id, status pill, label, focal value, prev row,
        sparkline) with an optional tab strip on top that swaps in a different pane (different tile set,
        different grid layout) per tab. Best for trading floor / NOC / operations dashboards where a single
        panel must carry several distinct views. If you want even-weight grids with less per-tile chrome,
        pick Sparkline list or Editorial minimal.
      </p>

      <h4 class="mt-4">Tab strip (optional)</h4>
      <p>
        Each <code>kpi_terminal/1</code> can hold one or more <code>:pane</code> slots, each carrying an
        <code>id</code> + <code>label_text</code>. The header auto-renders a tab strip; the
        <code>PureAdminKpiTerminalTabs</code> hook toggles <code>.is-active</code> on the clicked tab and
        matching pane. Panes are independent — different tile counts in this demo: OVERVIEW has 6, FINANCE
        has 2, OPERATIONS has 4.
      </p>
      <p>
        Sections without tabs simply omit the <code>:pane</code> slots and place tiles as <code>inner_block</code>
        — the wrapper supplies a <code>pa-kpi-terminal__grid--2col</code> automatically. The 1×3 / asymmetric
        stress tests and the Chart.js demo do this.
      </p>

      <h4 class="mt-4">Status pills (different axis from sentiment)</h4>
      <p>
        Three pill styles for tile-level status: <code>WARN</code> (filled orange — needs attention),
        <code>GOOD</code> (text-only — passing, no chrome by design), <code>NEUTRAL</code> (filled grey —
        informational).
      </p>
      <p>
        The pill is on a <strong>different axis</strong> from the 5-step sentiment scale
        (<code>very_positive</code> / <code>positive</code> / <code>neutral</code> / <code>negative</code> /
        <code>very_negative</code>) used on <code>value_variant</code> and <code>delta_variant</code>.
        Sentiment is <em>direction of change</em>; the pill is <em>action urgency</em>. A tile can be
        <code>very_negative</code> numerically AND <code>good</code> pill-wise if the drop is on target.
      </p>

      <h4 class="mt-4">is_standalone modifier</h4>
      <p>
        Tiles inside a <code>kpi_terminal</code> share grid-bookkeeping borders. A tile placed directly
        inside a <code>.pc-col-*</code> outside a grid needs <code>is_standalone</code> to draw its own
        full border + card-bg + bottom margin so it doesn't look orphaned.
      </p>

      <h4 class="mt-4">Sparkline trailing dot</h4>
      <p>
        SVG <code>preserveAspectRatio="none"</code> stretches a <code>&lt;circle&gt;</code> into an oval, so
        the <code>PureAdminKpiSparkDot</code> hook converts each circle to an HTML <code>&lt;span&gt;</code>
        inside a <code>.pa-kpi-spark-wrap</code> on mount. The dot is sized in CSS pixels so it stays a
        true circle regardless of chart aspect ratio.
      </p>

      <h4 class="mt-4">Hover detail popover</h4>
      <p>
        Cursor-anchored via Floating UI's <code>computePosition</code> + virtual reference element. Each
        tile's detail is appended to <code>&lt;body&gt;</code> on init to escape ancestor
        <code>overflow: hidden</code>. Set <code>detail_title_text</code> (plus any combination of
        <code>previous_value_text</code> / <code>delta_absolute_text</code> / <code>target_text</code>) and
        the popover body is auto-built; pass a <code>:detail</code> slot for fully-custom markup.
      </p>
    </.card>

    <br />

    <%!-- CSS Classes Reference --%>

    <.card title_text={gettext("CSS Classes Reference")}>
      <h4>Card structure</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-terminal</code> — page-namespace class on <code>.pa-card</code>. Scopes the tab/pane DOM contract.</li>
        <li><code>pa-kpi-header</code> — flex header with title + controls + LIVE indicator.</li>
        <li><code>pa-kpi-terminal__controls</code> — controls group (tabs + LIVE side by side).</li>
        <li><code>pa-kpi-live</code> / <code>pa-kpi-live__dot</code> — LIVE pill + animated dot.</li>
        <li><code>pa-kpi-terminal__body</code> — card body with internal padding.</li>
        <li><code>pa-kpi-terminal__grid</code> — internal tile grid.</li>
        <li><code>pa-kpi-terminal__grid--2col</code> — 2-col layout modifier (canonical dense grid).</li>
      </ul>

      <h4 class="mt-4">Tab strip</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-terminal__tabs</code> — segmented tab container (<code>role="tablist"</code>).</li>
        <li><code>pa-kpi-terminal__tab</code> — tab button. <code>data-tab="slug"</code> matches a pane; add <code>is-active</code> for the selected one.</li>
        <li><code>pa-kpi-terminal__pane</code> — pane container. <code>data-tab="slug"</code> matches a tab; add <code>is-active</code> for the visible one.</li>
      </ul>

      <h4 class="mt-4">Tile structure</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-tile</code> — single tile.</li>
        <li><code>pa-kpi-tile--standalone</code> — for tiles directly in a <code>.pc-col-*</code> outside a grid.</li>
        <li><code>pa-kpi-tile--up-strong</code> / <code>--up</code> / <code>--flat</code> / <code>--down</code> / <code>--down-strong</code> — sparkline-direction sentiment.</li>
      </ul>

      <h4 class="mt-4">Tile head</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-tile__head</code> — top row (id + status pill).</li>
        <li><code>pa-kpi-tile__id</code> — tile id (e.g. "KPI.01").</li>
        <li><code>pa-kpi-tile__status</code> + <code>--warn</code> / <code>--good</code> / <code>--neutral</code>.</li>
        <li><code>pa-kpi-tile__label</code> — uppercase mono caption below the head.</li>
      </ul>

      <h4 class="mt-4">Tile value</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-tile__values</code> — wrapper.</li>
        <li><code>pa-kpi-tile__value</code> — focal value element.</li>
        <li><code>pa-kpi-tile__num</code> / <code>pa-kpi-tile__unit</code> — numeric + unit spans.</li>
        <li><code>pa-kpi-tile__value--very-positive</code> / <code>--positive</code> / <code>--neutral</code> / <code>--negative</code> / <code>--very-negative</code> — coloured-number sentiment.</li>
      </ul>

      <h4 class="mt-4">Prev row + delta</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-tile__prev</code> — previous-period row.</li>
        <li><code>pa-kpi-tile__delta--very-positive</code> / <code>--positive</code> / <code>--neutral</code> / <code>--negative</code> / <code>--very-negative</code> — delta sentiment.</li>
      </ul>

      <h4 class="mt-4">Sparkline</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-tile__spark</code> — chart SVG (or <code>&lt;canvas data-kpi-chart&gt;</code> for library-rendered charts).</li>
        <li><code>pa-kpi-spark-wrap</code> — JS-inserted wrapper around the SVG.</li>
        <li><code>pa-kpi-spark-dot</code> — HTML span replacing the SVG circle.</li>
      </ul>

      <h4 class="mt-4">Hover detail popover</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-detail</code> — popover root (moved to <code>&lt;body&gt;</code> on init).</li>
        <li><code>pa-kpi-detail__title</code> — uppercase mono header.</li>
        <li><code>pa-kpi-detail .pos / .neg / .warn</code> — sentiment-coloured <code>&lt;dd&gt;</code> text.</li>
      </ul>

      <h4 class="mt-4">Framework tokens used by this showcase</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>--pc-very-positive</code> / <code>--pc-positive</code> / <code>--pc-neutral</code> / <code>--pc-negative</code> / <code>--pc-very-negative</code> — 5-step sentiment.</li>
        <li><code>--pc-warning</code> — orange "off-target / approaching limit" signal.</li>
        <li><code>--pc-detail-bg</code> / <code>-text</code> / <code>-row-label</code> / <code>-title</code> / <code>-shadow</code> — popover chrome.</li>
      </ul>
    </.card>
    """
  end

  defp tile_assigns(t, id_prefix \\ "") do
    Map.merge(t, %{id: id_prefix <> t.id})
  end

  # Private function component to keep the JSX-ish render terse.
  attr(:id, :string, default: nil)
  attr(:id_text, :string, default: nil)
  attr(:status_text, :string, default: nil)
  attr(:status_variant, :string, default: nil)
  attr(:label_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:value_text, :string, default: nil)
  attr(:unit_text, :string, default: nil)
  attr(:variant, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:delta_variant, :string, default: nil)
  attr(:detail_title_text, :string, default: nil)
  attr(:delta_absolute_text, :string, default: nil)
  attr(:delta_absolute_sentiment, :atom, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:points, :string, required: true)
  attr(:dot, :any, required: true)
  attr(:is_standalone, :boolean, default: false)

  defp tile(assigns) do
    ~H"""
    <.kpi_tile
      id={@id}
      id_text={@id_text}
      status_text={@status_text}
      status_variant={@status_variant}
      label_text={@label_text}
      prefix_text={@prefix_text}
      value_text={@value_text}
      unit_text={@unit_text}
      variant={@variant}
      previous_value_text={@previous_value_text}
      delta_text={@delta_text}
      delta_variant={@delta_variant}
      detail_title_text={@detail_title_text}
      delta_absolute_text={@delta_absolute_text}
      delta_absolute_sentiment={@delta_absolute_sentiment}
      target_text={@target_text}
      is_standalone={@is_standalone}
    >
      <:chart>
        <.kpi_sparkline id={"spark-" <> @id} points={@points} dot_at={@dot} />
      </:chart>
    </.kpi_tile>
    """
  end
end
