defmodule DemoWeb.Live.KpiSparklineListLive do
  use DemoWeb, :live_view

  # 1:1 port of pure-admin's `demo/views/kpi-sparkline-list.mustache`.
  # Canonical card + 1×3 page-grid stress test + 25/45/30 asymmetric +
  # --no-delta variant + Chart.js drop-in + Usage Guide + CSS Reference.

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "KPI · Sparkline list")}
  end

  defp rows do
    [
      %{
        id: "revenue",
        label_text: "Revenue",
        prefix_text: "$",
        value_text: "848",
        unit_text: "K",
        variant: "up",
        delta_text: "▲ 12.4%",
        delta_variant: "positive",
        detail_title_text: "Revenue · 24h",
        previous_value_text: "$754K",
        target_text: "$900K",
        points: "0,18 12,16 24,14 36,15 48,13 60,11 72,10 84,9 96,8",
        area: "0,24 0,18 12,16 24,14 36,15 48,13 60,11 72,10 84,9 96,8 96,24",
        dot: {96, 8}
      },
      %{
        id: "sessions",
        label_text: "Sessions",
        value_text: "12.3",
        unit_text: "K",
        variant: "up_strong",
        delta_text: "▲ 28.7%",
        delta_variant: "very_positive",
        detail_title_text: "Sessions · 24h",
        previous_value_text: "9.5K",
        target_text: "10K",
        points: "0,20 12,18 24,15 36,12 48,11 60,9 72,7 84,5 96,4",
        area: "0,24 0,20 12,18 24,15 36,12 48,11 60,9 72,7 84,5 96,4 96,24",
        dot: {96, 4}
      },
      %{
        id: "conversion",
        label_text: "Conversion",
        value_text: "3.92",
        unit_text: "%",
        variant: "up",
        delta_text: "▲ 4.3%",
        delta_variant: "positive",
        detail_title_text: "Conversion · 24h",
        previous_value_text: "3.76%",
        target_text: "4.0%",
        points: "0,15 12,14 24,15 36,13 48,12 60,13 72,11 84,12 96,10",
        area: "0,24 0,15 12,14 24,15 36,13 48,12 60,13 72,11 84,12 96,10 96,24",
        dot: {96, 10}
      },
      %{
        id: "bounce",
        label_text: "Bounce Rate",
        value_text: "42.1",
        unit_text: "%",
        variant: "down",
        delta_text: "▲ 5.8%",
        delta_variant: "negative",
        detail_title_text: "Bounce Rate · 24h",
        previous_value_text: "39.8%",
        target_text: "≤ 40%",
        points: "0,10 12,11 24,13 36,12 48,14 60,15 72,16 84,17 96,18",
        area: "0,24 0,10 12,11 24,13 36,12 48,14 60,15 72,16 84,17 96,18 96,24",
        dot: {96, 18}
      },
      %{
        id: "errors",
        label_text: "Error Rate",
        value_text: "0.18",
        unit_text: "%",
        variant: "up_strong",
        delta_text: "▼ 38.0%",
        delta_variant: "very_positive",
        detail_title_text: "Error Rate · 24h",
        previous_value_text: "0.29%",
        target_text: "≤ 0.30%",
        points: "0,8 12,9 24,11 36,12 48,13 60,14 72,15 84,16 96,17",
        area: "0,24 0,8 12,9 24,11 36,12 48,13 60,14 72,15 84,16 96,17 96,24",
        dot: {96, 17}
      },
      %{
        id: "latency",
        label_text: "Latency p95",
        value_text: "148",
        unit_text: "ms",
        variant: "flat",
        delta_text: "▲ 0.7%",
        delta_variant: "neutral",
        detail_title_text: "Latency p95 · 24h",
        previous_value_text: "147 ms",
        target_text: "≤ 200ms",
        points: "0,14 12,13 24,14 36,13 48,14 60,13 72,14 84,13 96,14",
        area: "0,24 0,14 12,13 24,14 36,13 48,14 60,13 72,14 84,13 96,14 96,24",
        dot: {96, 14}
      }
    ]
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">
      Each KPI is one row: label · sparkline · value · Δ%. Built for fast vertical scanning rather than
      per-tile depth. The sparkline gets a filled area underneath the line for stronger visual weight.
      Container queries on the card collapse the row template from 4-col → 2-row → 3-row as the card
      narrows.
    </.paragraph>

    <%!-- 1. Canonical card --%>

    <.kpi_sparkline_list title_text="Live KPIs · 24h" is_live footer_text="Sparkline list — Fast scan · Hover any row for detail">
      <.row :for={r <- rows()} {row_assigns(r)} />
    </.kpi_sparkline_list>

    <br />

    <%!-- 2. 1×3 page-grid --%>

    <h3>1×3 · <code>.pc-col-1-3</code> columns</h3>
    <p>
      Each card holds two rows in its own <code>.pc-col-1-3</code>. Container queries collapse the row
      template to a 2-row stack at mid-narrow widths — same markup, different layout per card.
    </p>

    <div class="pc-row">
      <div :for={pair <- rows() |> Enum.chunk_every(2) |> Enum.take(3)} class="pc-col-100 pc-col-md-1-3">
        <.kpi_sparkline_list>
          <.row :for={r <- pair} {row_assigns(r, "c13-")} />
        </.kpi_sparkline_list>
      </div>
    </div>

    <br />

    <%!-- 3. 25 / 45 / 25 asymmetric (third uses --chart-first) --%>

    <h3>Asymmetric · <code>25 + 45 + 25</code>, third card uses <code>--chart-first</code></h3>
    <p>
      The very-narrow third card opts into <code>is_chart_first</code> — rotates the canonical L→R order
      90°: label on top, chart in the middle, value+delta side-by-side at the bottom. Compare the second
      and third cards side-by-side.
    </p>

    <div class="pc-row">
      <div class="pc-col-100 pc-col-md-25">
        <.kpi_sparkline_list>
          <.row :for={r <- Enum.take(rows(), 2)} {row_assigns(r, "asym1-")} />
        </.kpi_sparkline_list>
      </div>
      <div class="pc-col-100 pc-col-md-45">
        <.kpi_sparkline_list>
          <.row :for={r <- rows() |> Enum.drop(2) |> Enum.take(2)} {row_assigns(r, "asym2-")} />
        </.kpi_sparkline_list>
      </div>
      <div class="pc-col-100 pc-col-md-25">
        <.kpi_sparkline_list is_chart_first>
          <.row :for={r <- Enum.take(rows(), 2)} {row_assigns(r, "asym3-")} />
        </.kpi_sparkline_list>
      </div>
    </div>

    <br />

    <%!-- 4. --no-delta variant --%>

    <h3><code>is_no_delta</code>: drop the rightmost Δ% column</h3>
    <p>Useful when the chart slope already conveys direction.</p>

    <.kpi_sparkline_list title_text="Compact KPIs" is_no_delta>
      <.row :for={r <- Enum.take(rows(), 3)} {row_assigns(r, "nd-")} />
    </.kpi_sparkline_list>

    <br />

    <%!-- 5. Chart.js drop-in --%>

    <h3>Custom chart library · <code>Chart.js</code> in the chart slot</h3>
    <p>
      Each row's chart is a <code>&lt;canvas data-kpi-chart&gt;</code> instead of the inline SVG. The
      <code>PureAdminKpiChart</code> hook renders a Chart.js line/area chart in the same cell, picking
      up the row's sentiment <code>currentColor</code>.
    </p>

    <.kpi_sparkline_list title_text="Live KPIs · Chart.js" is_live>
      <.kpi_sparkline_row
        label_text="Revenue"
        prefix_text="$"
        value_text="848"
        unit_text="K"
        variant="up"
        delta_text="▲ 12.4%"
        delta_variant="positive"
      >
        <:chart>
          <canvas
            id="spark-cjs-revenue"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="line"
            data-kpi-aspect="6"
            data-kpi-fill="area"
            data-kpi-points="[640, 668, 690, 712, 730, 748, 760, 772, 790, 810, 832, 848]"
          />
        </:chart>
      </.kpi_sparkline_row>

      <.kpi_sparkline_row
        label_text="Sessions"
        value_text="12.3"
        unit_text="K"
        variant="up_strong"
        delta_text="▲ 28.7%"
        delta_variant="very_positive"
      >
        <:chart>
          <canvas
            id="spark-cjs-sessions"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="line"
            data-kpi-aspect="6"
            data-kpi-fill="area"
            data-kpi-points="[7.8, 8.2, 8.9, 9.5, 9.8, 10.2, 10.6, 11.1, 11.5, 11.8, 12.0, 12.3]"
          />
        </:chart>
      </.kpi_sparkline_row>
    </.kpi_sparkline_list>

    <br />

    <%!-- Usage Guide --%>

    <.card title_text="Usage Guide">
      <h4>When to use</h4>
      <p>
        Side-by-side comparison of many metrics in one panel, with the sparkline shape giving fast visual
        confirmation of the delta direction. Best for executive overviews, "live KPI strip" pages, observability
        dashboards. If you need per-tile depth (status pill, detail tabs) use Terminal grid; if you want huge
        focal numbers with light supporting visuals use Editorial minimal.
      </p>

      <h4 class="mt-4">Row contract</h4>
      <p>
        Each row is <code>label · chart · value · Δ%</code> in a 4-column grid. The chart cell uses
        <code>preserveAspectRatio="none"</code>; the trailing dot is converted by the
        <code>PureAdminKpiSparkDot</code> hook to a CSS-pixel span so it stays round.
      </p>

      <h4 class="mt-4">--no-delta + --chart-first modifiers</h4>
      <p>
        <code>is_no_delta</code> drops the rightmost Δ% column — the row template shrinks to 3 cols at wide
        widths, the delta cell is hidden via <code>display: none</code>. Compose with <code>is_chart_first</code>
        for a clean 3-row stack at mid-narrow widths.
      </p>

      <h4 class="mt-4">Container queries</h4>
      <p>
        The card sets <code>container-type: inline-size</code> on <code>.pa-kpi-spark-list</code>, so rows
        react to <em>card</em> width, not viewport. At ≤640px each row stacks into a 2-row layout (label/value/delta
        on top, full-width chart below); at ≤360px it becomes 3 rows. The same markup adapts to every cell width.
      </p>

      <h4 class="mt-4">Hover detail popover</h4>
      <p>
        Same recipe as the Terminal grid: each row is the hover host; the row's <code>pa-kpi-detail</code>
        moves to <code>&lt;body&gt;</code> on mount, then follows the cursor via a virtual reference
        element. Auto-built rows from typed props (Current / Previous / Δ absolute / Δ percent / Target).
      </p>
    </.card>

    <br />

    <%!-- CSS Classes Reference --%>

    <.card title_text="CSS Classes Reference">
      <h4>Card structure</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-spark-list</code> — page-namespace class on <code>.pa-card</code>. Container query host.</li>
        <li><code>pa-kpi-spark-list--no-delta</code> — drops the rightmost Δ% column.</li>
        <li><code>pa-kpi-spark-list--chart-first</code> — rotates the L→R order 90° at narrow widths.</li>
        <li><code>pa-kpi-spark-list__body</code> — card body, zero padding.</li>
      </ul>

      <h4 class="mt-4">Row + cells</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-spark-row</code> — single data row.</li>
        <li><code>pa-kpi-spark-row--up-strong</code> / <code>--up</code> / <code>--flat</code> / <code>--down</code> / <code>--down-strong</code> — chart sentiment.</li>
        <li><code>pa-kpi-spark-row__label</code> / <code>__chart</code> / <code>__value</code> / <code>__delta</code> — cell elements.</li>
        <li><code>pa-kpi-spark-row__num</code> / <code>__unit</code> — value spans.</li>
        <li><code>pa-kpi-spark-row__delta--positive</code> / <code>--negative</code> / etc. — delta sentiment.</li>
      </ul>

      <h4 class="mt-4">Sparkline</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-spark-wrap</code> / <code>pa-kpi-spark-dot</code> — JS-injected wrapper + dot.</li>
        <li><code>pa-kpi-detail</code> + <code>__title</code> — popover element.</li>
      </ul>

      <h4 class="mt-4">Framework tokens used by this showcase</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>--pc-positive</code> / <code>--pc-negative</code> / etc. — sentiment palette.</li>
        <li><code>--pa-chart-trendline-height</code> (3rem) / <code>--pa-chart-trendline-stroke</code> (2.1) — sparkline geometry.</li>
        <li><code>--pc-detail-*</code> — popover chrome.</li>
      </ul>
    </.card>
    """
  end

  defp row_assigns(r, id_prefix \\ ""), do: Map.merge(r, %{id: id_prefix <> r.id})

  attr(:id, :string, required: true)
  attr(:label_text, :string, required: true)
  attr(:value_text, :string, default: nil)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:variant, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:delta_variant, :string, default: nil)
  attr(:detail_title_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:points, :string, required: true)
  attr(:area, :string, required: true)
  attr(:dot, :any, required: true)

  defp row(assigns) do
    {dot_x, dot_y} = assigns.dot
    assigns = assign(assigns, %{dot_x: dot_x, dot_y: dot_y})

    ~H"""
    <.kpi_sparkline_row
      label_text={@label_text}
      prefix_text={@prefix_text}
      value_text={@value_text}
      unit_text={@unit_text}
      variant={@variant}
      delta_text={@delta_text}
      delta_variant={@delta_variant}
      detail_title_text={@detail_title_text}
      previous_value_text={@previous_value_text}
      target_text={@target_text}
    >
      <:chart>
        <svg
          id={"spark-" <> @id}
          viewBox="0 0 100 24"
          preserveAspectRatio="none"
          phx-hook="PureAdminKpiSparkDot"
        >
          <polygon points={@area} />
          <polyline points={@points} />
          <circle cx={@dot_x} cy={@dot_y} r="2" />
        </svg>
      </:chart>
    </.kpi_sparkline_row>
    """
  end
end
