defmodule DemoWeb.Live.KpiBentoLive do
  use DemoWeb, :live_view

  # 1:1 port of pure-admin's `demo/views/kpi-bento.mustache`.
  # Default 6-tile hero-left + --hero-right + --5-tile layout modifiers
  # + 1×3 page-grid stress + Chart.js drop-in + Usage Guide + CSS Reference.

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "KPI · Bento layout")}
  end

  defp bento_chart(id, points, dot, area, hook \\ "PureAdminKpiSparkDot") do
    assigns = %{id: id, points: points, dot_x: elem(dot, 0), dot_y: elem(dot, 1), area: area, hook: hook}

    ~H"""
    <span class="pa-kpi-bento-tile__chart-svg">
      <svg id={@id} viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook={@hook}>
        <polygon points={@area} />
        <polyline points={@points} />
        <circle cx={@dot_x} cy={@dot_y} r="2" />
      </svg>
    </span>
    """
  end

  defp tiles_default(prefix) do
    [
      %{id: prefix <> "hero", is_hero: true, variant: "positive", label_text: "Revenue", prefix_text: "$", value_text: "849", unit_text: "K", delta_text: "▲ 13.4%",
        detail_title_text: "Revenue · QTD", previous_value_text: "$749K", target_text: "$900K",
        points: "0,20 12,18 24,17 36,15 48,14 60,12 72,10 84,8 96,6", area: "0,24 0,20 12,18 24,17 36,15 48,14 60,12 72,10 84,8 96,6 96,24", dot: {96, 6}},
      %{id: prefix <> "a", variant: "negative", label_text: "Cloud Spend", prefix_text: "$", value_text: "128", unit_text: "K", delta_text: "▲ 18%",
        points: "0,18 12,17 24,15 36,13 48,11 60,9 72,8 84,7 96,6", area: "0,24 0,18 12,17 24,15 36,13 48,11 60,9 72,8 84,7 96,6 96,24", dot: {96, 6}},
      %{id: prefix <> "b", variant: "up_strong", label_text: "Conversion", value_text: "3.92", unit_text: "%", delta_text: "▲ 12.6%",
        points: "0,18 12,17 24,14 36,13 48,11 60,9 72,7 84,6 96,5", area: "0,24 0,18 12,17 24,14 36,13 48,11 60,9 72,7 84,6 96,5 96,24", dot: {96, 5}},
      %{id: prefix <> "c", variant: "positive", label_text: "Sessions", value_text: "12.3K", delta_text: "▲ 4.1%",
        points: "0,17 12,16 24,15 36,13 48,14 60,12 72,11 84,10 96,9", area: "0,24 0,17 12,16 24,15 36,13 48,14 60,12 72,11 84,10 96,9 96,24", dot: {96, 9}},
      %{id: prefix <> "d", variant: "negative", label_text: "Churn", value_text: "2.4%", delta_text: "▲ 0.3pp",
        points: "0,11 12,12 24,13 36,12 48,14 60,13 72,15 84,14 96,16", area: "0,24 0,11 12,12 24,13 36,12 48,14 60,13 72,15 84,14 96,16 96,24", dot: {96, 16}},
      %{id: prefix <> "e", variant: "neutral", label_text: "NPS", value_text: "64", delta_text: "— 0",
        points: "0,13 12,14 24,13 36,12 48,13 60,14 72,13 84,12 96,13", area: "0,24 0,13 12,14 24,13 36,12 48,13 60,14 72,13 84,12 96,13 96,24", dot: {96, 13}}
    ]
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">
      Magazine-style asymmetric tile sizing with sparklines as soft background fills behind the values.
      Default 6-tile layout (hero left + 2 stacked right + 3 across bottom); <code>bento_layout="hero_right"</code>
      mirrors; <code>bento_layout="5_tile"</code> is hero + 4 supporting. Tile placement is by source order
      via <code>:nth-child</code> so markup stays identical across modifiers.
    </.paragraph>

    <%!-- 1. Default 6-tile layout · hero-left --%>

    <.kpi_bento title_text="Quarterly snapshot · default (hero-left)" is_live>
      <.bento_tile :for={t <- tiles_default("def-")} {t} />
    </.kpi_bento>

    <br />

    <%!-- 2. --hero-right --%>

    <h3><code>bento_layout="hero_right"</code> — mirror of default</h3>

    <.kpi_bento title_text="Quarterly snapshot · hero-right" bento_layout="hero_right">
      <.bento_tile :for={t <- tiles_default("hr-")} {t} />
    </.kpi_bento>

    <br />

    <%!-- 3. --5-tile --%>

    <h3><code>bento_layout="5_tile"</code> — hero + 4 supporting</h3>
    <p>Five tiles in source order: hero, 2 stacked right (rows 1-2), 2 equal halves bottom.</p>

    <.kpi_bento title_text="5-tile dashboard" bento_layout="5_tile">
      <.bento_tile :for={t <- Enum.take(tiles_default("5t-"), 5)} {t} />
    </.kpi_bento>

    <br />

    <%!-- 4. 1×3 page-grid · row_height bump --%>

    <h3>1×3 · <code>row_height="14rem"</code></h3>
    <p>Each card holds a 5-tile bento in its own <code>.pc-col-1-3</code>. <code>row_height</code> bumped to 14rem so the narrow tiles don't compress.</p>

    <div class="pc-row">
      <div :for={i <- 1..3} class="pc-col-100 pc-col-md-1-3">
        <.kpi_bento bento_layout="5_tile" row_height="14rem">
          <.bento_tile :for={t <- Enum.take(tiles_default("c13-#{i}-"), 5)} {t} />
        </.kpi_bento>
      </div>
    </div>

    <br />

    <%!-- 5. Chart.js drop-in --%>

    <h3>Custom chart library · <code>Chart.js</code> in the bento chart slot</h3>
    <p>
      The background chart per tile is a <code>&lt;canvas data-kpi-chart&gt;</code> instead of inline SVG.
      The line/area renders behind the digits at lower opacity (Chart.js <code>backgroundColor</code> alpha
      handled by the hook), inheriting the tile's sentiment <code>currentColor</code>.
    </p>

    <.kpi_bento title_text="Quarterly snapshot · Chart.js" is_live>
      <.kpi_bento_tile is_hero variant="positive" label_text="Revenue" prefix_text="$" value_text="849" unit_text="K" delta_text="▲ 13.4%">
        <:chart>
          <canvas id="bento-cjs-hero" phx-hook="PureAdminKpiChart" data-kpi-chart data-kpi-type="line" data-kpi-fill="area" data-kpi-aspect="3.5"
            data-kpi-points="[612, 638, 660, 685, 705, 728, 750, 772, 798, 818, 832, 849]" />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="negative" label_text="Cloud Spend" prefix_text="$" value_text="128" unit_text="K" delta_text="▲ 18%">
        <:chart>
          <canvas id="bento-cjs-a" phx-hook="PureAdminKpiChart" data-kpi-chart data-kpi-type="line" data-kpi-fill="area" data-kpi-aspect="6"
            data-kpi-points="[88, 92, 98, 102, 108, 112, 116, 120, 122, 124, 126, 128]" />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="up_strong" label_text="Conversion" value_text="3.92" unit_text="%" delta_text="▲ 12.6%">
        <:chart>
          <canvas id="bento-cjs-b" phx-hook="PureAdminKpiChart" data-kpi-chart data-kpi-type="line" data-kpi-fill="area" data-kpi-aspect="6"
            data-kpi-points="[3.32, 3.38, 3.45, 3.51, 3.58, 3.64, 3.72, 3.78, 3.82, 3.86, 3.89, 3.92]" />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="positive" label_text="Sessions" value_text="12.3K" delta_text="▲ 4.1%">
        <:chart>
          <canvas id="bento-cjs-c" phx-hook="PureAdminKpiChart" data-kpi-chart data-kpi-type="line" data-kpi-fill="area" data-kpi-aspect="8"
            data-kpi-points="[10.8, 11.0, 11.2, 11.4, 11.6, 11.8, 12.0, 12.1, 12.2, 12.3]" />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="negative" label_text="Churn" value_text="2.4%" delta_text="▲ 0.3pp">
        <:chart>
          <canvas id="bento-cjs-d" phx-hook="PureAdminKpiChart" data-kpi-chart data-kpi-type="line" data-kpi-fill="area" data-kpi-aspect="8"
            data-kpi-points="[2.0, 2.05, 2.1, 2.12, 2.18, 2.22, 2.28, 2.32, 2.36, 2.4]" />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="neutral" label_text="NPS" value_text="64" delta_text="— 0">
        <:chart>
          <canvas id="bento-cjs-e" phx-hook="PureAdminKpiChart" data-kpi-chart data-kpi-type="line" data-kpi-fill="area" data-kpi-aspect="8"
            data-kpi-points="[63, 64, 63, 65, 64, 63, 64, 64, 63, 64]" />
        </:chart>
      </.kpi_bento_tile>
    </.kpi_bento>

    <br />

    <%!-- Usage Guide --%>

    <.card title_text="Usage Guide">
      <h4>When to use</h4>
      <p>
        Magazine-style asymmetric dashboards where one metric should dominate visually and a few
        supporting metrics need to feel like a curated layout (not a uniform grid). Sparklines as soft
        background fills behind the values. Less data per tile than Terminal grid; more density than
        Hero + supporting.
      </p>

      <h4 class="mt-4">Layout contract</h4>
      <p>
        Tiles are placed by <strong>source order</strong> via <code>:nth-child</code>. The 1st tile is
        the hero (with <code>is_hero</code>), the next 2 are right-column stacked, the next 3 are equal
        bottom-row tiles. Default 6 tiles; layout modifiers (<code>hero_right</code>, <code>5_tile</code>)
        only swap <code>grid-template-areas</code> — tile markup stays unchanged.
      </p>

      <h4 class="mt-4">Sparkline opacity</h4>
      <p>
        The bento sparkline sits <em>behind</em> the value (z-index layering, not column placement).
        Stroke is 55% opacity; fill is 10% — soft enough that the number stays the focal point but the
        chart still reads as a defined shape.
      </p>

      <h4 class="mt-4">Container queries</h4>
      <p>
        At ≤700px the bento collapses to a single column stack, resetting <code>grid-area</code> on
        every tile so the same markup works in narrow page-grid cells. Each tile is also its own
        container query host so the value's <code>cqi</code>-based font-size scales with the tile's
        actual width.
      </p>

      <h4 class="mt-4">--pa-kpi-bento-row-height</h4>
      <p>
        Default row height is <code>12rem</code>. Override per instance via the <code>row_height</code>
        attr (emits inline <code>style="--pa-kpi-bento-row-height: ..."</code>). Useful in narrow page-grid
        cells where the default rows feel cramped.
      </p>
    </.card>

    <br />

    <%!-- CSS Classes Reference --%>

    <.card title_text="CSS Classes Reference">
      <h4>Card structure</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-bento</code> — page-namespace class on <code>.pa-card</code>. Container query host.</li>
        <li><code>pa-kpi-bento__body</code> — card body.</li>
        <li><code>pa-kpi-bento__grid</code> — 6-col × 3-row grid.</li>
        <li><code>pa-kpi-bento__grid--hero-right</code> — mirror of default (hero on right).</li>
        <li><code>pa-kpi-bento__grid--5-tile</code> — hero + 4 supporting.</li>
      </ul>

      <h4 class="mt-4">Layout CSS variables</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>--pa-kpi-bento-row-height</code> — row height (default <code>12rem</code>).</li>
      </ul>

      <h4 class="mt-4">Tile</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-bento-tile</code> — single cell. Carries <code>--pa-kpi-accent</code>.</li>
        <li><code>pa-kpi-bento-tile--hero</code> — larger value + chart for the hero cell.</li>
        <li><code>pa-kpi-bento-tile--positive</code> / <code>--negative</code> / <code>--neutral</code> / <code>--up-strong</code> / <code>--down-strong</code> — sentiment cascade.</li>
        <li><code>pa-kpi-bento-tile__label</code> / <code>__delta</code> / <code>__value</code> / <code>__num</code> / <code>__unit</code>.</li>
        <li><code>pa-kpi-bento-tile__chart</code> / <code>__chart-svg</code> — background sparkline.</li>
      </ul>
    </.card>
    """
  end

  attr(:id, :string, required: true)
  attr(:is_hero, :boolean, default: false)
  attr(:variant, :string, default: nil)
  attr(:label_text, :string, required: true)
  attr(:value_text, :string, required: true)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:detail_title_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:points, :string, required: true)
  attr(:area, :string, required: true)
  attr(:dot, :any, required: true)

  defp bento_tile(assigns) do
    ~H"""
    <.kpi_bento_tile
      id={@id}
      is_hero={@is_hero}
      variant={@variant}
      label_text={@label_text}
      value_text={@value_text}
      unit_text={@unit_text}
      prefix_text={@prefix_text}
      delta_text={@delta_text}
      detail_title_text={@detail_title_text}
      previous_value_text={@previous_value_text}
      target_text={@target_text}
    >
      <:chart>{bento_chart("spark-" <> @id, @points, @dot, @area)}</:chart>
    </.kpi_bento_tile>
    """
  end
end
