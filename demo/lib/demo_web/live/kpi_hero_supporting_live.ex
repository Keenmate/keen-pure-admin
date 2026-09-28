defmodule DemoWeb.Live.KpiHeroSupportingLive do
  use DemoWeb, :live_view

  # 1:1 port of pure-admin's `demo/views/kpi-hero-supporting.mustache`.
  # Canonical card + --hero-2-3 + --hero-3-4 split modifiers + 25/45/30
  # asymmetric stress + Chart.js drop-in + Usage Guide + CSS Reference.

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "KPI · Hero + supporting")}
  end

  defp side_tiles do
    [
      %{label_text: gettext("ARPU"), prefix_text: "$", value_text: "34.20", delta_text: "▲ 7.5%", variant: "positive"},
      %{label_text: gettext("Active users"), value_text: "12.3", unit_text: "K", delta_text: "▲ 4.1%", variant: "positive"},
      %{label_text: gettext("Conversion"), value_text: "3.92", unit_text: "%", delta_text: "▲ 12.6%", variant: "up_strong"},
      %{label_text: gettext("Churn"), value_text: "2.4", unit_text: "%", delta_text: "▲ 0.3pp", variant: "negative"},
      %{label_text: gettext("NPS"), value_text: "64", delta_text: "— 0", variant: "neutral"}
    ]
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">
      Marketing/exec dashboard pattern — one headline metric on the left, a vertical rail of compact
      supporting metrics on the right. Container query collapses to single column on narrow cards.
      Split-ratio modifiers shift weight onto the hero.
    </.paragraph>

    <%!-- 1. Canonical card · default 1:1 split --%>

    <.kpi_hero_list title_text={gettext("Q4 Revenue Dashboard · Default 1:1 split")} is_live footer_text="Default 1:1 — Hero + 5 supporting · Hover hero or any side tile for detail">
      <.kpi_hero_main
        id="hero-default"
        variant="positive"
        label_text={gettext("Monthly Revenue")}
        prefix_text="$"
        value_text="847"
        unit_text="K"
        delta_text="▲ 13.3%"
        period_text="vs last month"
        target_text="tgt $900K"
        detail_title_text="Monthly Revenue · 12MO"
        previous_value_text="$748K"
        delta_absolute_text="+$99K"
        delta_absolute_sentiment={:pos}
      >
        <:chart>
          <span class="pa-kpi-hero-main__chart-svg">
            <svg
              id="hero-default-spark"
              viewBox="0 0 100 24"
              preserveAspectRatio="none"
              phx-hook="PureAdminKpiSparkDot"
            >
              <polygon points="0,24 0,20 12,19 24,17 36,18 48,15 60,14 72,12 84,10 96,8 96,24" />
              <polyline points="0,20 12,19 24,17 36,18 48,15 60,14 72,12 84,10 96,8" />
              <circle cx="96" cy="8" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_hero_main>

      <:rail>
        <.kpi_hero_side
          :for={{t, i} <- Enum.with_index(side_tiles())}
          id={"hero-default-side-#{i}"}
          variant={t.variant}
          label_text={t.label_text}
          prefix_text={Map.get(t, :prefix_text)}
          value_text={t.value_text}
          unit_text={Map.get(t, :unit_text)}
          delta_text={t.delta_text}
        />
      </:rail>
    </.kpi_hero_list>

    <br />

    <%!-- 2. --hero-2-3 split --%>

    <h3><code>hero_split="2_3"</code> — hero 2/3, rail 1/3</h3>
    <p>Shifts weight onto the hero. Same markup as above, just one prop change.</p>

    <.kpi_hero_list title_text={gettext("Q4 Revenue · 2:3 split")} is_live hero_split="2_3">
      <.kpi_hero_main
        id="hero-23"
        variant="positive"
        label_text={gettext("Monthly Revenue")}
        prefix_text="$"
        value_text="847"
        unit_text="K"
        delta_text="▲ 13.3%"
        period_text="vs last month"
        target_text="tgt $900K"
      >
        <:chart>
          <span class="pa-kpi-hero-main__chart-svg">
            <svg id="hero-23-spark" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
              <polygon points="0,24 0,20 12,19 24,17 36,18 48,15 60,14 72,12 84,10 96,8 96,24" />
              <polyline points="0,20 12,19 24,17 36,18 48,15 60,14 72,12 84,10 96,8" />
              <circle cx="96" cy="8" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_hero_main>
      <:rail>
        <.kpi_hero_side :for={{t, i} <- Enum.with_index(Enum.take(side_tiles(), 3))} id={"hero-23-side-#{i}"} variant={t.variant} label_text={t.label_text} prefix_text={Map.get(t, :prefix_text)} value_text={t.value_text} unit_text={Map.get(t, :unit_text)} delta_text={t.delta_text} />
      </:rail>
    </.kpi_hero_list>

    <br />

    <%!-- 3. --hero-3-4 split --%>

    <h3><code>hero_split="3_4"</code> — hero dominant, rail thin sidebar</h3>

    <.kpi_hero_list title_text={gettext("Q4 Revenue · 3:4 split")} is_live hero_split="3_4">
      <.kpi_hero_main
        id="hero-34"
        variant="up_strong"
        label_text={gettext("Annual Recurring Revenue")}
        prefix_text="$"
        value_text="9.4"
        unit_text="M"
        delta_text="▲ 28.1%"
        period_text="vs last year"
        target_text="tgt $10M"
      >
        <:chart>
          <span class="pa-kpi-hero-main__chart-svg">
            <svg id="hero-34-spark" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
              <polygon points="0,24 0,21 12,20 24,18 36,17 48,15 60,12 72,10 84,7 96,5 96,24" />
              <polyline points="0,21 12,20 24,18 36,17 48,15 60,12 72,10 84,7 96,5" />
              <circle cx="96" cy="5" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_hero_main>
      <:rail>
        <.kpi_hero_side :for={{t, i} <- Enum.with_index(side_tiles())} id={"hero-34-side-#{i}"} variant={t.variant} label_text={t.label_text} prefix_text={Map.get(t, :prefix_text)} value_text={t.value_text} unit_text={Map.get(t, :unit_text)} delta_text={t.delta_text} />
      </:rail>
    </.kpi_hero_list>

    <br />

    <%!-- 4. Chart.js drop-in --%>

    <h3>Custom chart library · <code>Chart.js</code> in the hero chart slot</h3>
    <p>
      The hero's <code>:chart</code> slot accepts any renderer — here a Chart.js <strong>line/area</strong>
      chart instead of the inline SVG. The slot's <code>currentColor</code> is set by the hero's variant
      so Chart.js picks up the sentiment colour automatically and re-colours on theme change.
    </p>

    <.kpi_hero_list title_text={gettext("Q4 Revenue · Chart.js")} is_live>
      <.kpi_hero_main
        id="hero-cjs"
        variant="positive"
        label_text={gettext("Monthly Revenue")}
        prefix_text="$"
        value_text="847"
        unit_text="K"
        delta_text="▲ 13.3%"
        period_text="vs last month"
        target_text="tgt $900K"
      >
        <:chart>
          <canvas
            id="hero-cjs-chart"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="line"
            data-kpi-fill="area"
            data-kpi-aspect="4"
            data-kpi-points="[612, 638, 660, 685, 705, 728, 750, 772, 798, 818, 832, 847]"
          />
        </:chart>
      </.kpi_hero_main>
      <:rail>
        <.kpi_hero_side :for={{t, i} <- Enum.with_index(Enum.take(side_tiles(), 4))} id={"hero-cjs-side-#{i}"} variant={t.variant} label_text={t.label_text} prefix_text={Map.get(t, :prefix_text)} value_text={t.value_text} unit_text={Map.get(t, :unit_text)} delta_text={t.delta_text} />
      </:rail>
    </.kpi_hero_list>

    <br />

    <%!-- Usage Guide --%>

    <.card title_text={gettext("Usage Guide")}>
      <h4>When to use</h4>
      <p>
        Marketing or exec dashboards where one headline metric needs to dominate while supporting metrics
        provide context. Best for "north star" pages, KPI hero sections, single-purpose dashboards. If
        you want even-weight tiles, see Sparkline list or Editorial minimal.
      </p>

      <h4 class="mt-4">Hero / rail split</h4>
      <p>
        Default is 1:1. <code>hero_split="2_3"</code> gives the hero 2/3 (rail 1/3); <code>"3_4"</code>
        gives the hero 3/4 (rail = thin sidebar). Container query at ≤700px stacks the layout into a
        single column regardless of split.
      </p>

      <h4 class="mt-4">Hero meta row</h4>
      <p>
        The inline meta row underneath the hero value carries three optional bits: <code>delta_text</code>
        (colour from <code>variant</code>), <code>period_text</code> (e.g. "vs last month"), and
        <code>target_text</code> (e.g. "tgt $900K"). All three are independently optional. Pass a
        <code>:meta</code> snippet for fully-custom markup.
      </p>

      <h4 class="mt-4">Side tile layout</h4>
      <p>
        Each <code>kpi_hero_side</code> is a 2×2 grid: label top-left, delta bottom-left, value spans both
        rows on the right. Looks balanced when the label is one line and still reads cleanly when it
        wraps to two.
      </p>

      <h4 class="mt-4">Hero chart slot</h4>
      <p>
        Any renderer goes here. The chart container has <code>flex: 1 1 10rem</code> so it grows to fill
        extra vertical space when the rail is taller than the hero's natural content. For inline SVG,
        wrap in <code>&lt;span class="pa-kpi-hero-main__chart-svg"&gt;</code> so the SVG stays at fixed
        pixel height regardless of how tall the parent gets. For Chart.js, just drop a
        <code>&lt;canvas data-kpi-chart&gt;</code>.
      </p>
    </.card>

    <br />

    <%!-- CSS Classes Reference --%>

    <.card title_text={gettext("CSS Classes Reference")}>
      <h4>Card structure</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-hero-list</code> — page-namespace class on <code>.pa-card</code>. Container query host.</li>
        <li><code>pa-kpi-hero-list__layout</code> — 2-col grid (hero left, rail right).</li>
        <li><code>pa-kpi-hero-list__layout--hero-2-3</code> / <code>--hero-3-4</code> — split-ratio modifiers.</li>
        <li><code>pa-kpi-hero-list__rail</code> — flex column for side tiles.</li>
      </ul>

      <h4 class="mt-4">Hero main panel</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-hero-main</code> — headline metric panel.</li>
        <li><code>pa-kpi-hero-main--positive</code> / <code>--negative</code> / <code>--neutral</code> / <code>--up-strong</code> — sentiment cascade.</li>
        <li><code>pa-kpi-hero-main__label</code> / <code>__value</code> / <code>__num</code> / <code>__unit</code> — text elements.</li>
        <li><code>pa-kpi-hero-main__meta</code> — inline meta row.</li>
        <li><code>pa-kpi-hero-main__delta</code> / <code>__period</code> / <code>__target</code> — meta row cells.</li>
        <li><code>pa-kpi-hero-main__chart</code> — chart container.</li>
        <li><code>pa-kpi-hero-main__chart-svg</code> — fixed-height SVG wrapper (for inline SVG sparklines).</li>
      </ul>

      <h4 class="mt-4">Side rail tile</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-hero-side</code> — compact supporting tile.</li>
        <li><code>pa-kpi-hero-side--positive</code> / etc. — sentiment cascade.</li>
        <li><code>pa-kpi-hero-side__label</code> / <code>__value</code> / <code>__num</code> / <code>__unit</code> / <code>__delta</code>.</li>
      </ul>
    </.card>
    """
  end
end
