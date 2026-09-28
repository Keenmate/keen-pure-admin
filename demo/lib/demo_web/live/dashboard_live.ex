defmodule DemoWeb.Live.DashboardLive do
  use DemoWeb, :live_view

  # 1:1 with @keenmate/svelte-pure-admin docs/src/routes/+page.svelte (v1.8.0).
  # Uses the new KPI primitives (KpiSparklineList, KpiHeroList) for Top Sales
  # Products and Revenue Trend, with Chart.js-backed sparklines via the
  # PureAdminKpiChart canvas hook.

  def mount(_params, _session, socket) do
    orders = [
      %{id: "#4892", customer: "Alice Johnson", amount: "$234.50", status: "Completed", status_variant: "success"},
      %{id: "#4891", customer: "Bob Williams", amount: "$456.00", status: "Processing", status_variant: "warning"},
      %{id: "#4890", customer: "Carol Davis", amount: "$123.75", status: "Completed", status_variant: "success"},
      %{id: "#4889", customer: "David Miller", amount: "$789.25", status: "Shipped", status_variant: "info"},
      %{id: "#4888", customer: "Emma Wilson", amount: "$345.60", status: "Completed", status_variant: "success"}
    ]

    traffic_sources = [
      %{source: "Organic Search", pct: "42.3%"},
      %{source: "Direct", pct: "28.7%"},
      %{source: "Social Media", pct: "15.8%"},
      %{source: "Referral", pct: "9.4%"},
      %{source: "Email", pct: "3.8%"}
    ]

    top_products = [
      %{name: "Product Alpha", revenue: "$24,532"},
      %{name: "Product Beta", revenue: "$18,940"},
      %{name: "Product Gamma", revenue: "$15,677"},
      %{name: "Product Delta", revenue: "$12,234"}
    ]

    # Top Sales — sentiment-ordered (highest growth first, decline last). Each
    # row carries a series for the Chart.js sparkline. Values are
    # "higher = better" (Chart.js draws bigger y higher).
    top_sales = [
      %{
        id: "epsilon",
        label_text: "Product Epsilon",
        value_text: "9,847",
        delta_text: "+15.2%",
        previous_value_text: "$8,547",
        delta_absolute_text: "+$1,300",
        variant: "up_strong",
        delta_variant: "very_positive",
        points: "[8200, 8400, 8700, 9000, 9200, 9500, 9700, 9847]"
      },
      %{
        id: "alpha",
        label_text: "Product Alpha",
        value_text: "24,532",
        delta_text: "+12.1%",
        previous_value_text: "$21,884",
        delta_absolute_text: "+$2,648",
        variant: "up",
        delta_variant: "positive",
        points: "[21800, 22300, 22700, 22000, 23200, 23500, 24000, 24532]"
      },
      %{
        id: "delta",
        label_text: "Product Delta",
        value_text: "12,234",
        delta_text: "+8.3%",
        previous_value_text: "$11,294",
        delta_absolute_text: "+$940",
        variant: "up",
        delta_variant: "positive",
        points: "[11200, 11400, 11500, 11700, 11800, 11900, 12100, 12234]"
      },
      %{
        id: "beta",
        label_text: "Product Beta",
        value_text: "18,940",
        delta_text: "+5.4%",
        previous_value_text: "$17,970",
        delta_absolute_text: "+$970",
        variant: "up",
        delta_variant: "positive",
        points: "[17900, 18000, 18100, 18200, 18400, 18500, 18700, 18940]"
      },
      %{
        id: "gamma",
        label_text: "Product Gamma",
        value_text: "15,677",
        delta_text: "-3.1%",
        previous_value_text: "$16,178",
        delta_absolute_text: "−$501",
        variant: "down",
        delta_variant: "negative",
        points: "[16400, 16300, 16200, 16100, 16000, 15900, 15800, 15677]"
      }
    ]

    revenue_trend_points =
      "[720, 730, 745, 755, 770, 780, 795, 810, 820, 830, 838, 845, 847]"

    {:ok,
     assign(socket,
       page_title: gettext("Dashboard"),
       orders: orders,
       traffic_sources: traffic_sources,
       top_products: top_products,
       top_sales: top_sales,
       revenue_trend_points: revenue_trend_points
     )}
  end

  def render(assigns) do
    ~H"""
    <p class="pa-text--secondary">{gettext("Real-time overview of key performance metrics")}</p>

    <%!-- KPI Metric Cards --%>
    <.grid>
      <.column size="25">
        <.card>
          <.stat variant="hero" number="$847,392" label_text={gettext("Total Revenue")}
            change_text="▲ 12.5% vs last month" change_direction="positive" />
        </.card>
      </.column>
      <.column size="25">
        <.card>
          <.stat variant="hero" number="24,583" label_text={gettext("Active Users")}
            change_text="▲ 8.3% vs last month" change_direction="positive" />
        </.card>
      </.column>
      <.column size="25">
        <.card>
          <.stat variant="hero" number="3.47%" label_text={gettext("Conversion Rate")}
            change_text="▼ 2.1% vs last month" change_direction="negative" />
        </.card>
      </.column>
      <.column size="25">
        <.card>
          <.stat variant="hero" number="$134.52" label_text={gettext("Avg Order Value")}
            change_text="▲ 5.7% vs last month" change_direction="positive" />
        </.card>
      </.column>
    </.grid>

    <%!-- Top Sales Products + Revenue Trend (LEFT 2/3) — KPI squares + Traffic Sources (RIGHT 1/3) --%>
    <.grid>
      <.column size="2-3">
        <.kpi_sparkline_list title_text={gettext("Top Sales Products")} is_live>
          <.kpi_sparkline_row
            :for={row <- @top_sales}
            id={"top-sales-#{row.id}"}
            variant={row.variant}
            label_text={row.label_text}
            prefix_text="$"
            value_text={row.value_text}
            delta_text={row.delta_text}
            delta_variant={row.delta_variant}
            detail_title_text={"#{row.label_text} · 30D"}
            previous_value_text={row.previous_value_text}
            delta_absolute_text={row.delta_absolute_text}
            delta_absolute_sentiment={row.delta_variant in ["negative", "very_negative", "down_strong"] && :neg || :pos}
          >
            <:chart>
              <canvas
                id={"top-sales-#{row.id}-chart"}
                phx-hook="PureAdminKpiChart"
                data-kpi-chart
                data-kpi-type="line"
                data-kpi-fill="area"
                data-kpi-aspect="6"
                data-kpi-points={row.points}
              />
            </:chart>
          </.kpi_sparkline_row>
        </.kpi_sparkline_list>

        <.kpi_hero_list title_text={gettext("Revenue Trend")} is_live hero_split="2_3">
          <.kpi_hero_main
            id="dashboard-revenue-hero"
            variant="up_strong"
            label_text={gettext("Monthly Revenue")}
            prefix_text="$"
            value_text="847"
            unit_text="K"
            delta_text="+12.5%"
            period_text="vs last month"
            target_text="tgt $900K"
            detail_title_text={gettext("Monthly Revenue · 12MO")}
            previous_value_text="$753K"
            delta_absolute_text="+$94K"
            delta_absolute_sentiment={:pos}
          >
            <:chart>
              <span class="pa-kpi-hero-main__chart-svg">
                <canvas
                  id="dashboard-revenue-chart"
                  phx-hook="PureAdminKpiChart"
                  data-kpi-chart
                  data-kpi-type="line"
                  data-kpi-fill="area"
                  data-kpi-aspect="4"
                  data-kpi-points={@revenue_trend_points}
                />
              </span>
            </:chart>
          </.kpi_hero_main>

          <:rail>
            <.kpi_hero_side
              id="dashboard-rail-ytd"
              variant="positive"
              label_text={gettext("YTD Revenue")}
              prefix_text="$"
              value_text="9.2"
              unit_text="M"
              delta_text="+18.4% vs LY"
              detail_title_text={gettext("YTD Revenue")}
              target_text="$11.1M"
            />
            <.kpi_hero_side
              id="dashboard-rail-q4"
              variant="positive"
              label_text={gettext("Q4 Actual")}
              prefix_text="$"
              value_text="2.4"
              unit_text="M"
              delta_text="+9.1% vs Q3"
              detail_title_text={gettext("Q4 Revenue")}
              target_text="$2.7M"
            />
            <.kpi_hero_side
              id="dashboard-rail-forecast"
              variant="neutral"
              label_text={gettext("Forecast EOY")}
              prefix_text="$"
              value_text="11.1"
              unit_text="M"
              delta_text="on track"
              detail_title_text={gettext("Forecast EOY")}
              target_text="$11.0M"
            />
          </:rail>
        </.kpi_hero_list>
      </.column>

      <.column size="1-3">
        <.card title_text={gettext("Key Performance Indicators")}>
          <.grid class="pa-kpi-grid">
            <.column size="100" xl="50">
              <.stat variant="square" color="primary" number="87" symbol_text="%" label_text={gettext("Completion Rate")} />
            </.column>
            <.column size="100" xl="50">
              <.stat variant="square" color="success" number="94" symbol_text="%" label_text={gettext("Customer Satisfaction")} />
            </.column>
            <.column size="100" xl="50">
              <.stat variant="square" color="info" number="62" symbol_text="%" label_text={gettext("Market Share")} />
            </.column>
            <.column size="100" xl="50">
              <.stat variant="square" color="warning" number="78" symbol_text="%" label_text={gettext("Server Capacity")} />
            </.column>
            <.column size="100" xl="50">
              <.stat variant="square" color="danger" number="23" symbol_text="%" label_text={gettext("Error Rate")} />
            </.column>
            <.column size="100" xl="50">
              <.stat variant="square" color="secondary" number="91" symbol_text="%" label_text={gettext("Uptime")} />
            </.column>
          </.grid>
        </.card>

        <.table_card title_text={gettext("Traffic Sources")}>
          <.table rows={@traffic_sources} size="sm" is_compact>
            <:col :let={row} label={gettext("Source")}>{row.source}</:col>
            <:col :let={row} label={gettext("%")} align="end"><strong>{row.pct}</strong></:col>
          </.table>
        </.table_card>
      </.column>
    </.grid>

    <%!-- Activity Feed & Recent Orders --%>
    <.grid>
      <.column size="50">
        <.card title_text={gettext("Recent Activity")}>
          <.timeline variant="simple">
            <.timeline_item variant="primary" is_filled time_text="2 min ago">
              New user registration: <strong>john.smith@example.com</strong>
            </.timeline_item>
            <.timeline_item variant="success" is_filled time_text="8 min ago">
              Order #4892 completed — <strong>$234.50</strong>
            </.timeline_item>
            <.timeline_item variant="warning" is_filled time_text="15 min ago">
              Low stock alert: <strong>Product A-123</strong>
            </.timeline_item>
            <.timeline_item variant="success" time_text="23 min ago">
              Payment received: <strong>Invoice #2847</strong>
            </.timeline_item>
            <.timeline_item variant="info" time_text="1 hr ago">
              Monthly report generated
            </.timeline_item>
          </.timeline>
          <:footer>
            <.button variant="secondary" size="sm">{gettext("View All Activity")}</.button>
          </:footer>
        </.card>
      </.column>
      <.column size="50">
        <.table_card title_text={gettext("Recent Orders")}>
          <.table rows={@orders} size="sm" is_compact>
            <:col :let={order} label={gettext("Order ID")}>{order.id}</:col>
            <:col :let={order} label={gettext("Customer")}>{order.customer}</:col>
            <:col :let={order} label={gettext("Amount")}>{order.amount}</:col>
            <:col :let={order} label={gettext("Status")}>
              <.badge variant={order.status_variant}>{order.status}</.badge>
            </:col>
          </.table>
          <:footer>
            <.button variant="secondary" size="sm">{gettext("View All Orders")}</.button>
          </:footer>
        </.table_card>
      </.column>
    </.grid>

    <%!-- Bottom Row - Performance Metrics --%>
    <.grid>
      <.column size="1-3">
        <.table_card title_text={gettext("Top Products")}>
          <.table rows={@top_products} size="sm" is_compact>
            <:col :let={row} label={gettext("Product")}>{row.name}</:col>
            <:col :let={row} label={gettext("Revenue")} align="end"><strong>{row.revenue}</strong></:col>
          </.table>
        </.table_card>
      </.column>
      <.column size="1-3">
        <.card has_padding={false} title_text={gettext("System Status")}>
          <.list>
            <.list_item title_text={gettext("API Services")}>
              <:meta><.badge variant="success">{gettext("Operational")}</.badge></:meta>
            </.list_item>
            <.list_item title_text={gettext("Database")}>
              <:meta><.badge variant="success">{gettext("Operational")}</.badge></:meta>
            </.list_item>
            <.list_item title_text={gettext("Payment Gateway")}>
              <:meta><.badge variant="warning">{gettext("Degraded")}</.badge></:meta>
            </.list_item>
            <.list_item title_text={gettext("Email Service")}>
              <:meta><.badge variant="success">{gettext("Operational")}</.badge></:meta>
            </.list_item>
          </.list>
        </.card>
      </.column>
      <.column size="1-3">
        <.card title_text={gettext("Quick Actions")}>
          <.button_group is_vertical>
            <.button variant="primary" is_block>{gettext("New Order")}</.button>
            <.button variant="secondary" is_block>{gettext("Add Customer")}</.button>
            <.button variant="secondary" is_block>{gettext("Generate Report")}</.button>
            <.button variant="secondary" is_block>{gettext("Export Data")}</.button>
          </.button_group>
        </.card>
      </.column>
    </.grid>
    """
  end
end
