defmodule DemoWeb.Live.KpiDashboardLive do
  use DemoWeb, :live_view

  # Combined KPI dashboard — exercises the 7 new pa-kpi-* showcase
  # components together in one page so integration / spacing / theming can
  # be verified end-to-end. Not a 1:1 port of upstream's kpi-dashboard.mustache
  # (which is a Geckoboard-style page using older pa-stat components).

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "KPI · Combined dashboard")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">
      Combined dashboard exercising all seven KPI showcases on one page. Useful for testing how the
      designs sit next to each other, how spacing reads at viewport width, and how hover popovers
      / sparklines / Chart.js examples behave in a busy LiveView. Each component has its own dedicated
      page in the sidebar.
    </.paragraph>

    <%!-- Row 1: Hero + supporting (full-width) --%>

    <.kpi_hero_list title_text={gettext("Q4 Revenue Overview")} is_live hero_split="2_3">
      <.kpi_hero_main
        id="cd-hero"
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
            <svg id="cd-hero-spark" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
              <polygon points="0,24 0,20 12,19 24,17 36,18 48,15 60,14 72,12 84,10 96,8 96,24" />
              <polyline points="0,20 12,19 24,17 36,18 48,15 60,14 72,12 84,10 96,8" />
              <circle cx="96" cy="8" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_hero_main>
      <:rail>
        <.kpi_hero_side id="cd-side-arpu" variant="positive" label_text={gettext("ARPU")} prefix_text="$" value_text="34.20" delta_text="▲ 7.5%" />
        <.kpi_hero_side id="cd-side-users" variant="positive" label_text={gettext("Active users")} value_text="12.3" unit_text="K" delta_text="▲ 4.1%" />
        <.kpi_hero_side id="cd-side-conv" variant="up_strong" label_text={gettext("Conversion")} value_text="3.92" unit_text="%" delta_text="▲ 12.6%" />
        <.kpi_hero_side id="cd-side-churn" variant="negative" label_text={gettext("Churn")} value_text="2.4" unit_text="%" delta_text="▲ 0.3pp" />
      </:rail>
    </.kpi_hero_list>

    <br />

    <%!-- Row 2: Terminal grid + Editorial minimal side by side --%>

    <div class="pc-row">
      <div class="pc-col-100 pc-col-md-50">
        <.kpi_terminal title_text={gettext("Operations")} is_live>
          <.kpi_tile id="cd-t1" id_text="OPS.01" status_text="GOOD" status_variant="good" label_text={gettext("Uptime")} value_text="99.97" unit_text="%" variant="up" delta_text="▲ 0.04pp" delta_variant="positive">
            <:chart>
              <.kpi_sparkline id="cd-t1-spark" points="0,15 12,14 24,13 36,12 48,11 60,10 72,9 84,8 96,7" dot_at={{96, 7}} />
            </:chart>
          </.kpi_tile>
          <.kpi_tile id="cd-t2" id_text="OPS.02" status_text="WARN" status_variant="warn" label_text={gettext("Latency p95")} value_text="148" unit_text="ms" variant="flat" delta_text="▲ 0.7%" delta_variant="neutral">
            <:chart>
              <.kpi_sparkline id="cd-t2-spark" points="0,14 12,13 24,14 36,13 48,14 60,13 72,14 84,13 96,14" dot_at={{96, 14}} />
            </:chart>
          </.kpi_tile>
          <.kpi_tile id="cd-t3" id_text="OPS.03" status_text="GOOD" status_variant="good" label_text={gettext("Error Rate")} value_text="0.18" unit_text="%" variant="up_strong" delta_text="▼ 56%" delta_variant="very_positive">
            <:chart>
              <.kpi_sparkline id="cd-t3-spark" points="0,8 12,9 24,11 36,12 48,13 60,14 72,15 84,16 96,17" dot_at={{96, 17}} />
            </:chart>
          </.kpi_tile>
          <.kpi_tile id="cd-t4" id_text="OPS.04" status_text="NEUTRAL" status_variant="neutral" label_text={gettext("Deploys / day")} value_text="14" variant="up" delta_text="▲ 27%" delta_variant="positive">
            <:chart>
              <.kpi_sparkline id="cd-t4-spark" points="0,18 12,16 24,15 36,13 48,12 60,11 72,10 84,9 96,8" dot_at={{96, 8}} />
            </:chart>
          </.kpi_tile>
        </.kpi_terminal>
      </div>

      <div class="pc-col-100 pc-col-md-50">
        <.kpi_editorial title_text={gettext("Executive Summary")} is_2_columns>
          <.kpi_editorial_tile label_text={gettext("REVENUE")} prefix_text="$" value_text="847" unit_text="K" delta_text="+13.3%" delta_variant="positive" target_text="$900K" />
          <.kpi_editorial_tile label_text={gettext("ARPU")} prefix_text="$" value_text="34.20" delta_text="+7.5%" delta_variant="positive" target_text="$36" />
          <.kpi_editorial_tile label_text={gettext("USERS")} value_text="12.3" unit_text="K" delta_text="+4.1%" delta_variant="positive" target_text="11K" />
          <.kpi_editorial_tile label_text={gettext("CHURN")} value_text="2.4" unit_text="%" delta_text="+14%" delta_variant="negative" target_text="≤ 2%" />
        </.kpi_editorial>
      </div>
    </div>

    <br />

    <%!-- Row 3: Sparkline list (full-width) --%>

    <.kpi_sparkline_list title_text={gettext("Live KPIs · 24h")} is_live>
      <.kpi_sparkline_row label_text={gettext("Revenue")} prefix_text="$" value_text="848" unit_text="K" variant="up" delta_text="▲ 12.4%" delta_variant="positive">
        <:chart>
          <svg id="cd-sl-1" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
            <polygon points="0,24 0,18 12,16 24,14 36,15 48,13 60,11 72,10 84,9 96,8 96,24" />
            <polyline points="0,18 12,16 24,14 36,15 48,13 60,11 72,10 84,9 96,8" />
            <circle cx="96" cy="8" r="2" />
          </svg>
        </:chart>
      </.kpi_sparkline_row>
      <.kpi_sparkline_row label_text={gettext("Sessions")} value_text="12.3" unit_text="K" variant="up_strong" delta_text="▲ 28.7%" delta_variant="very_positive">
        <:chart>
          <svg id="cd-sl-2" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
            <polygon points="0,24 0,20 12,18 24,15 36,12 48,11 60,9 72,7 84,5 96,4 96,24" />
            <polyline points="0,20 12,18 24,15 36,12 48,11 60,9 72,7 84,5 96,4" />
            <circle cx="96" cy="4" r="2" />
          </svg>
        </:chart>
      </.kpi_sparkline_row>
      <.kpi_sparkline_row label_text={gettext("Conversion")} value_text="3.92" unit_text="%" variant="up" delta_text="▲ 4.3%" delta_variant="positive">
        <:chart>
          <svg id="cd-sl-3" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
            <polygon points="0,24 0,15 12,14 24,15 36,13 48,12 60,13 72,11 84,12 96,10 96,24" />
            <polyline points="0,15 12,14 24,15 36,13 48,12 60,13 72,11 84,12 96,10" />
            <circle cx="96" cy="10" r="2" />
          </svg>
        </:chart>
      </.kpi_sparkline_row>
    </.kpi_sparkline_list>

    <br />

    <%!-- Row 4: Gauges (full-width) --%>

    <.kpi_gauge_list title_text={gettext("Quarterly targets")} grid_layout="max_3">
      <.kpi_gauge label_text={gettext("Completion")} value_text="88.6" unit_text="%" variant="positive" bar_percent={98} scale_end_text="tgt 90.0%" />
      <.kpi_gauge label_text={gettext("Revenue")} prefix_text="$" value_text="835" unit_text="K" variant="positive" bar_percent={93} scale_end_text="tgt $900K" />
      <.kpi_gauge label_text={gettext("Capacity")} value_text="84.5" unit_text="%" variant="warning" bar_percent={100} tick_position="80%" scale_end_text="tgt 80%" />
      <.kpi_gauge label_text={gettext("Error rate")} value_text="0.27" unit_text="%" variant="positive" bar_percent={54} scale_end_text="tgt 0.5%" />
      <.kpi_gauge label_text={gettext("NPS")} value_text="64" variant="neutral" bar_percent={71} scale_end_text="tgt 90" />
      <.kpi_gauge label_text={gettext("Latency p95")} value_text="148" unit_text="ms" variant="positive" bar_percent={74} scale_end_text="≤ 200ms" />
    </.kpi_gauge_list>

    <br />

    <%!-- Row 5: Numeric strip (full-width) --%>

    <.kpi_strip title_text={gettext("Weekly review")} is_live no_target_bar>
      <.kpi_strip_row metric_text={gettext("REVENUE")} prefix_text="$" value_text="847K" previous_value_text="$748K" delta_text="▲ 13.3%" delta_variant="positive" />
      <.kpi_strip_row metric_text={gettext("ARPU")} prefix_text="$" value_text="34.20" previous_value_text="$31.80" delta_text="▲ 7.5%" delta_variant="positive" />
      <.kpi_strip_row metric_text={gettext("ACTIVE USERS")} value_text="12.3K" previous_value_text="11.8K" delta_text="▲ 4.1%" delta_variant="positive" />
      <.kpi_strip_row metric_text={gettext("CHURN")} value_text="2.4%" previous_value_text="2.1%" delta_text="▲ 14%" delta_variant="negative" />
    </.kpi_strip>

    <br />

    <%!-- Row 6: Bento (full-width) --%>

    <.kpi_bento title_text={gettext("Magazine snapshot")}>
      <.kpi_bento_tile is_hero variant="positive" label_text={gettext("Revenue")} prefix_text="$" value_text="849" unit_text="K" delta_text="▲ 13.4%">
        <:chart>
          <span class="pa-kpi-bento-tile__chart-svg">
            <svg id="cd-bn-hero" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
              <polygon points="0,24 0,20 12,18 24,17 36,15 48,14 60,12 72,10 84,8 96,6 96,24" />
              <polyline points="0,20 12,18 24,17 36,15 48,14 60,12 72,10 84,8 96,6" />
              <circle cx="96" cy="6" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_bento_tile>
      <.kpi_bento_tile variant="negative" label_text={gettext("Cloud Spend")} prefix_text="$" value_text="128" unit_text="K" delta_text="▲ 18%">
        <:chart>
          <span class="pa-kpi-bento-tile__chart-svg">
            <svg id="cd-bn-a" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
              <polygon points="0,24 0,18 12,17 24,15 36,13 48,11 60,9 72,8 84,7 96,6 96,24" />
              <polyline points="0,18 12,17 24,15 36,13 48,11 60,9 72,8 84,7 96,6" />
              <circle cx="96" cy="6" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_bento_tile>
      <.kpi_bento_tile variant="up_strong" label_text={gettext("Conversion")} value_text="3.92" unit_text="%" delta_text="▲ 12.6%">
        <:chart>
          <span class="pa-kpi-bento-tile__chart-svg">
            <svg id="cd-bn-b" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
              <polygon points="0,24 0,18 12,17 24,14 36,13 48,11 60,9 72,7 84,6 96,5 96,24" />
              <polyline points="0,18 12,17 24,14 36,13 48,11 60,9 72,7 84,6 96,5" />
              <circle cx="96" cy="5" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_bento_tile>
      <.kpi_bento_tile variant="positive" label_text={gettext("Sessions")} value_text="12.3K" delta_text="▲ 4.1%">
        <:chart>
          <span class="pa-kpi-bento-tile__chart-svg">
            <svg id="cd-bn-c" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
              <polygon points="0,24 0,17 12,16 24,15 36,13 48,14 60,12 72,11 84,10 96,9 96,24" />
              <polyline points="0,17 12,16 24,15 36,13 48,14 60,12 72,11 84,10 96,9" />
              <circle cx="96" cy="9" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_bento_tile>
      <.kpi_bento_tile variant="negative" label_text={gettext("Churn")} value_text="2.4%" delta_text="▲ 0.3pp">
        <:chart>
          <span class="pa-kpi-bento-tile__chart-svg">
            <svg id="cd-bn-d" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
              <polygon points="0,24 0,11 12,12 24,13 36,12 48,14 60,13 72,15 84,14 96,16 96,24" />
              <polyline points="0,11 12,12 24,13 36,12 48,14 60,13 72,15 84,14 96,16" />
              <circle cx="96" cy="16" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_bento_tile>
      <.kpi_bento_tile variant="neutral" label_text={gettext("NPS")} value_text="64" delta_text="— 0">
        <:chart>
          <span class="pa-kpi-bento-tile__chart-svg">
            <svg id="cd-bn-e" viewBox="0 0 100 24" preserveAspectRatio="none" phx-hook="PureAdminKpiSparkDot">
              <polygon points="0,24 0,13 12,14 24,13 36,12 48,13 60,14 72,13 84,12 96,13 96,24" />
              <polyline points="0,13 12,14 24,13 36,12 48,13 60,14 72,13 84,12 96,13" />
              <circle cx="96" cy="13" r="2" />
            </svg>
          </span>
        </:chart>
      </.kpi_bento_tile>
    </.kpi_bento>

    <br />

    <%!-- Chart.js exercise · stacked bars + doughnut --%>

    <h3>Chart.js · stacked bars + doughnut</h3>
    <p>
      Exercises the <code>PureAdminKpiChart</code> hook with
      <code>data-kpi-type="stacked-bar"</code> (multi-series via array-of-arrays in
      <code>data-kpi-points</code>) and <code>data-kpi-type="doughnut"</code>. Series colour
      via decreasing-opacity <code>currentColor</code> — flip the theme/mode toggle in the
      settings panel and every chart below re-colours in place via the
      <code>pa:theme-change</code> event.
    </p>

    <.kpi_sparkline_list title_text={gettext("Revenue by Segment · Q1–Q4 weekly")} is_live>
      <.kpi_sparkline_row
        id="seg-enterprise"
        variant="up"
        label_text={gettext("Enterprise")}
        prefix_text="$"
        value_text="590"
        unit_text="K"
        delta_text="+10.0%"
        delta_variant="positive"
        detail_title_text="Enterprise · Q4"
        previous_value_text="$536K"
        delta_absolute_text="+$54K"
        delta_absolute_sentiment={:pos}
        target_text="$600K"
      >
        <:chart>
          <canvas
            id="seg-enterprise-chart"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="stacked-bar"
            data-kpi-aspect="6"
            data-kpi-labels='["Q1","Q2","Q3","Q4"]'
            data-kpi-points="[[120,140,160,180],[280,290,300,320],[60,70,80,90]]"
          />
        </:chart>
      </.kpi_sparkline_row>

      <.kpi_sparkline_row
        id="seg-smb"
        variant="up"
        label_text={gettext("SMB")}
        prefix_text="$"
        value_text="325"
        unit_text="K"
        delta_text="+5.5%"
        delta_variant="positive"
        detail_title_text="SMB · Q4"
        previous_value_text="$308K"
        delta_absolute_text="+$17K"
        delta_absolute_sentiment={:pos}
        target_text="$340K"
      >
        <:chart>
          <canvas
            id="seg-smb-chart"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="stacked-bar"
            data-kpi-aspect="6"
            data-kpi-labels='["Q1","Q2","Q3","Q4"]'
            data-kpi-points="[[80,90,100,110],[140,150,160,170],[30,35,40,45]]"
          />
        </:chart>
      </.kpi_sparkline_row>

      <.kpi_sparkline_row
        id="seg-consumer"
        variant="up_strong"
        label_text={gettext("Consumer")}
        prefix_text="$"
        value_text="410"
        unit_text="K"
        delta_text="+18.2%"
        delta_variant="very_positive"
        detail_title_text="Consumer · Q4"
        previous_value_text="$347K"
        delta_absolute_text="+$63K"
        delta_absolute_sentiment={:pos}
        target_text="$400K"
      >
        <:chart>
          <canvas
            id="seg-consumer-chart"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="stacked-bar"
            data-kpi-aspect="6"
            data-kpi-labels='["Q1","Q2","Q3","Q4"]'
            data-kpi-points="[[200,220,240,260],[80,85,90,95],[40,45,50,55]]"
          />
        </:chart>
      </.kpi_sparkline_row>

      <.kpi_sparkline_row
        id="seg-marketplace"
        variant="down"
        label_text={gettext("Marketplace")}
        prefix_text="$"
        value_text="180"
        unit_text="K"
        delta_text="-3.8%"
        delta_variant="negative"
        detail_title_text="Marketplace · Q4"
        previous_value_text="$187K"
        delta_absolute_text="−$7K"
        delta_absolute_sentiment={:neg}
        target_text="$220K"
      >
        <:chart>
          <canvas
            id="seg-marketplace-chart"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="stacked-bar"
            data-kpi-aspect="6"
            data-kpi-labels='["Q1","Q2","Q3","Q4"]'
            data-kpi-points="[[60,70,80,90],[40,45,50,55],[20,25,30,35]]"
          />
        </:chart>
      </.kpi_sparkline_row>
    </.kpi_sparkline_list>

    <br />

    <.kpi_bento title_text={gettext("Pipeline & Distribution · Chart.js mix")}>
      <.kpi_bento_tile is_hero variant="positive" label_text={gettext("Pipeline by Stage")} prefix_text="$" value_text="2.84" unit_text="M" delta_text="▲ 14.2%">
        <:chart>
          <canvas
            id="cjs-bento-hero"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="stacked-bar"
            data-kpi-aspect="3"
            data-kpi-labels='["W1","W2","W3","W4","W5","W6","W7","W8"]'
            data-kpi-points="[[420,450,480,520,560,610,650,700],[280,300,320,340,360,380,410,440],[180,200,220,240,260,290,320,360]]"
          />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="up_strong" label_text={gettext("Customer Mix")} value_text="4" unit_text="segments" delta_text="▲ 2.1%">
        <:chart>
          <canvas
            id="cjs-bento-a"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="doughnut"
            data-kpi-aspect="2.5"
            data-kpi-points="[42, 28, 18, 12]"
          />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="positive" label_text={gettext("Top Channels")} value_text="5" unit_text="active" delta_text="▲ 8.7%">
        <:chart>
          <canvas
            id="cjs-bento-b"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="doughnut"
            data-kpi-aspect="2.5"
            data-kpi-points="[38, 24, 18, 12, 8]"
          />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="positive" label_text={gettext("Deals by Region")} value_text="6" unit_text="regions" delta_text="▲ 5.0%">
        <:chart>
          <canvas
            id="cjs-bento-c"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="stacked-bar"
            data-kpi-aspect="3.5"
            data-kpi-labels='["NA","EU","APAC","LATAM","ME","AF"]'
            data-kpi-points="[[14,11,9,5,3,2],[8,7,6,4,2,1]]"
          />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="negative" label_text={gettext("Stalled %")} value_text="11.4" unit_text="%" delta_text="▲ 1.8pp">
        <:chart>
          <canvas
            id="cjs-bento-d"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="stacked-bar"
            data-kpi-aspect="3.5"
            data-kpi-labels='["W1","W2","W3","W4","W5","W6"]'
            data-kpi-points="[[6,7,8,9,10,11],[4,5,5,6,6,7]]"
          />
        </:chart>
      </.kpi_bento_tile>

      <.kpi_bento_tile variant="neutral" label_text={gettext("Forecast Confidence")} value_text="78" unit_text="%" delta_text="— 0">
        <:chart>
          <canvas
            id="cjs-bento-e"
            phx-hook="PureAdminKpiChart"
            data-kpi-chart
            data-kpi-type="doughnut"
            data-kpi-aspect="2.5"
            data-kpi-points="[78, 22]"
          />
        </:chart>
      </.kpi_bento_tile>
    </.kpi_bento>
    """
  end
end
