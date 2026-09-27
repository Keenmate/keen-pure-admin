defmodule DemoWeb.Live.DataVisualizationLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Data Visualization")}
  end

  def render(assigns) do
    ~H"""
    <p>CSS-only data visualization components for admin dashboards. Progress bars, rings, gauges, heatmaps, sparklines, and more.</p>

    <%!-- ============================================================
         1. PROGRESS BARS
         ============================================================ --%>

    <.card title_text="1. Progress Bars" subtitle_text="Horizontal progress indicators with size, color, striped, and animated variants.">

      <%!-- Basic progress bars --%>
      <.heading level={4} class="mb-sm">Default (with labels)</.heading>
      <.grid>
        <.column size="50">
          <.progress_group label="Storage Used" value={65} />
        </.column>
        <.column size="50">
          <.progress_group label="Upload Progress" value={89} variant="success" />
        </.column>
      </.grid>

      <%!-- Color variants --%>
      <.heading level={4} class="mt-lg mb-sm">Color Variants</.heading>
      <div class="d-flex flex-column gap-sm">
        <.progress value={70} />
        <.progress value={55} variant="success" />
        <.progress value={45} variant="warning" />
        <.progress value={30} variant="danger" />
        <.progress value={82} variant="info" />
      </div>

      <%!-- Sizes --%>
      <.heading level={4} class="mt-lg mb-sm">Sizes</.heading>
      <div class="d-flex flex-column gap-sm">
        <div>
          <span class="pa-text--secondary font-xs">XS</span>
          <.progress value={60} size="xs" />
        </div>
        <div>
          <span class="pa-text--secondary font-xs">SM</span>
          <.progress value={60} size="sm" />
        </div>
        <div>
          <span class="pa-text--secondary font-xs">Default</span>
          <.progress value={60} />
        </div>
        <div>
          <span class="pa-text--secondary font-xs">LG</span>
          <.progress value={60} size="lg" />
        </div>
      </div>

      <%!-- Striped & Animated --%>
      <.heading level={4} class="mt-lg mb-sm">Striped &amp; Animated</.heading>
      <div class="d-flex flex-column gap-sm">
        <.progress value={72} size="lg" is_striped />
        <.progress value={58} size="lg" variant="success" is_striped is_animated />
        <.progress value={40} size="lg" variant="warning" is_striped is_animated />
      </div>

      <%!-- Rounded --%>
      <.heading level={4} class="mt-lg mb-sm">Rounded (Pill)</.heading>
      <div class="d-flex flex-column gap-sm">
        <.progress value={75} size="lg" is_rounded />
        <.progress value={50} size="lg" variant="info" is_rounded is_striped is_animated />
      </div>
    </.card>

    <%!-- ============================================================
         2. STACKED BARS
         ============================================================ --%>

    <.card title_text="2. Stacked Bars" subtitle_text="Multiple colored segments in one bar showing breakdowns and distributions.">

      <%!-- Disk usage --%>
      <.heading level={4} class="mb-sm">Disk Usage (256 GB)</.heading>
      <.stacked_bar>
        <.stacked_segment value={35} />
        <.stacked_segment value={25} variant="success" />
        <.stacked_segment value={15} variant="warning" />
        <.stacked_segment value={10} variant="secondary" />
      </.stacked_bar>
      <.stacked_bar_legend>
        <.stacked_legend_item label="Apps (89 GB)" variant="primary" />
        <.stacked_legend_item label="Documents (64 GB)" variant="success" />
        <.stacked_legend_item label="Media (38 GB)" variant="warning" />
        <.stacked_legend_item label="System (26 GB)" variant="secondary" />
      </.stacked_bar_legend>

      <%!-- Browser share --%>
      <.heading level={4} class="mt-xl mb-sm">Browser Market Share</.heading>
      <.stacked_bar is_rounded size="lg">
        <.stacked_segment value={65} variant="info" />
        <.stacked_segment value={18} variant="danger" />
        <.stacked_segment value={10} variant="warning" />
        <.stacked_segment value={7} variant="secondary" />
      </.stacked_bar>
      <.stacked_bar_legend>
        <.stacked_legend_item label="Chrome (65%)" variant="info" />
        <.stacked_legend_item label="Firefox (18%)" variant="danger" />
        <.stacked_legend_item label="Safari (10%)" variant="warning" />
        <.stacked_legend_item label="Other (7%)" variant="secondary" />
      </.stacked_bar_legend>
    </.card>

    <%!-- ============================================================
         3. PROGRESS RINGS
         ============================================================ --%>

    <.card title_text="3. Progress Rings" subtitle_text={"Circular progress indicators using CSS conic-gradient. Set value via style=\"--value: 72\" (0-100)."}>

      <%!-- Default rings --%>
      <.heading level={4} class="mb-sm">Color Variants</.heading>
      <div class="d-flex gap-xl flex-wrap align-items-center">
        <.progress_ring value={72} label="CPU" />
        <.progress_ring value={94} label="Uptime" variant="success" />
        <.progress_ring value={58} label="Memory" variant="warning" />
        <.progress_ring value={87} label="Disk" variant="danger" />
        <.progress_ring value={43} label="Network" variant="info" />
      </div>

      <%!-- Sizes --%>
      <.heading level={4} class="mt-xl mb-sm">Sizes</.heading>
      <div class="d-flex gap-xl flex-wrap align-items-center">
        <.progress_ring value={65} size="sm" />
        <.progress_ring value={65} label="Default" />
        <.progress_ring value={65} label="Large" variant="success" size="lg" />
      </div>
    </.card>

    <%!-- ============================================================
         4. DASHBOARD GAUGES
         ============================================================ --%>

    <.card title_text="4. Dashboard Gauges" subtitle_text={"Semi-circle gauge indicators. Set value via style=\"--value: 72\" (0-100). v2.7.0 rebuilt the gauge as a true transparent ring — label moved out of the donut, sits below alongside __min and __max."}>

      <div class="d-flex gap-xl flex-wrap align-items-end">
        <%!-- CPU gauge --%>
        <.gauge value={72} label="CPU" />

        <%!-- Memory gauge (success) --%>
        <.gauge value={45} label="Memory" variant="success" min="0" max="32 GB" />

        <%!-- Temperature gauge (danger) --%>
        <.gauge value={85} label="Temp" variant="danger" value_text="85°" min="0°C" max="100°C" />

        <%!-- Zone gauge --%>
        <.gauge value={62} label="Speed" is_zones value_text="62" />
      </div>

      <.heading level={4} class="mt-6">Size override · v2.7.0 :size attr</.heading>
      <p class="pa-text--secondary mb-2">
        New <code>:size</code> attr emits <code>--pa-gauge-size</code> inline (default upstream <code>12rem</code>). Width and height (always half the width) both derive from this token. Text inside the donut doesn't auto-scale — set <code>font-size</code> on <code>.pa-gauge__value</code> in your stylesheet for proportional resizing.
      </p>

      <div class="d-flex gap-xl flex-wrap align-items-end">
        <.gauge value={68} label="8rem" variant="info" size="8rem" />
        <.gauge value={68} label="12rem (default)" variant="info" />
        <.gauge value={68} label="16rem" variant="info" size="16rem" />
        <.gauge value={68} label="20rem" variant="info" size="20rem" />
      </div>
    </.card>

    <%!-- ============================================================
         5. DATA BARS IN TABLES
         ============================================================ --%>

    <.card title_text="5. Data Bars in Tables" subtitle_text="Inline bar visualization inside table cells for quick comparison." has_padding={false}>

      <table class="pa-table pa-table--striped pa-table--hover">
        <thead>
          <tr>
            <th style="width: 5%">#</th>
            <th style="width: 25%">Sales Rep</th>
            <th style="width: 15%">Revenue</th>
            <th style="width: 35%">Performance</th>
            <th style="width: 10%">Target</th>
            <th style="width: 10%">Status</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>1</td>
            <td><strong>Sarah Chen</strong></td>
            <td>$142,500</td>
            <td><.data_bar value={95} variant="success" /></td>
            <td>95%</td>
            <td><.badge variant="success" size="xs">On Track</.badge></td>
          </tr>
          <tr>
            <td>2</td>
            <td><strong>James Wilson</strong></td>
            <td>$128,300</td>
            <td><.data_bar value={85} /></td>
            <td>85%</td>
            <td><.badge variant="success" size="xs">On Track</.badge></td>
          </tr>
          <tr>
            <td>3</td>
            <td><strong>Maria Garcia</strong></td>
            <td>$98,700</td>
            <td><.data_bar value={66} variant="warning" /></td>
            <td>66%</td>
            <td><.badge variant="warning" size="xs">At Risk</.badge></td>
          </tr>
          <tr>
            <td>4</td>
            <td><strong>Tom Baker</strong></td>
            <td>$76,200</td>
            <td><.data_bar value={51} variant="danger" /></td>
            <td>51%</td>
            <td><.badge variant="danger" size="xs">Behind</.badge></td>
          </tr>
          <tr>
            <td>5</td>
            <td><strong>Lisa Park</strong></td>
            <td>$112,900</td>
            <td><.data_bar value={75} variant="info" /></td>
            <td>75%</td>
            <td><.badge variant="info" size="xs">Steady</.badge></td>
          </tr>
        </tbody>
      </table>
    </.card>

    <%!-- ============================================================
         6. HEATMAP
         ============================================================ --%>

    <.card title_text="6. Activity Heatmap" subtitle_text={"GitHub contribution-style activity grid. Each cell uses data-level=\"0-4\" for intensity."}>

      <.heading level={4} class="mb-sm">Contribution Activity (12 weeks)</.heading>
      <.heatmap columns={12} levels={[0,1,2,0,3,1,0, 1,2,4,3,2,1,0, 0,0,1,2,3,4,2, 3,4,4,3,2,1,0, 1,0,2,3,1,2,0, 2,3,1,0,4,3,2, 0,1,3,4,2,1,3, 2,0,1,2,4,3,1, 1,2,0,3,1,0,2, 4,3,2,4,3,2,1, 0,1,2,3,4,2,1, 1,0,2,1,3,4,2]} />
      <.heatmap_legend />

      <%!-- Success color variant --%>
      <.heading level={4} class="mt-xl mb-sm">Color Variant (Success)</.heading>
      <.heatmap columns={7} variant="success" levels={[0,1,2,3,4,2,0, 1,3,4,2,1,3,4, 2,0,1,4,3,2,1]} />
    </.card>

    <%!-- ============================================================
         7. SPARKLINES
         ============================================================ --%>

    <.card title_text="7. Sparkline Bars" subtitle_text="Compact mini bar charts for inline data visualization inside cards or table cells.">

      <div class="d-flex gap-xl flex-wrap align-items-end">
        <%!-- Default --%>
        <div>
          <span class="pa-text--secondary font-xs d-block mb-xs">Revenue (7d)</span>
          <.sparkline values={[40, 65, 55, 80, 70, 90, 85]} />
        </div>

        <%!-- Success --%>
        <div>
          <span class="pa-text--secondary font-xs d-block mb-xs">Orders (7d)</span>
          <.sparkline values={[30, 45, 60, 50, 75, 85, 95]} variant="success" />
        </div>

        <%!-- Warning --%>
        <div>
          <span class="pa-text--secondary font-xs d-block mb-xs">Errors (7d)</span>
          <.sparkline values={[90, 70, 50, 60, 40, 25, 15]} variant="warning" />
        </div>

        <%!-- Large --%>
        <div>
          <span class="pa-text--secondary font-xs d-block mb-xs">Traffic (14d)</span>
          <.sparkline values={[50, 60, 45, 70, 80, 65, 75, 90, 85, 60, 55, 70, 95, 80]} variant="info" size="lg" />
        </div>
      </div>
    </.card>

    <%!-- ============================================================
         8. COMBINED: KPI DASHBOARD
         ============================================================ --%>

    <.card title_text="8. Combined: KPI Dashboard" subtitle_text="Real-world example combining stat cards, progress rings, sparklines, and data bars.">

      <%!-- KPI Row: Stat cards with sparklines --%>
      <.grid>
        <.column size="1-3">
          <.card>
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <div class="pa-text--secondary font-xs text-upper mb-xs">Total Revenue</div>
                <div class="font-2xl font-bold">$284,520</div>
                <div class="font-xs mt-xs" style="color: #28a745">+12.5% vs last month</div>
              </div>
              <.sparkline values={[40, 55, 50, 65, 75, 85, 90]} variant="success" />
            </div>
          </.card>
        </.column>
        <.column size="1-3">
          <.card>
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <div class="pa-text--secondary font-xs text-upper mb-xs">Active Users</div>
                <div class="font-2xl font-bold">8,429</div>
                <div class="font-xs mt-xs" style="color: #28a745">+3.2% vs last week</div>
              </div>
              <.sparkline values={[60, 65, 70, 68, 75, 80, 85]} variant="info" />
            </div>
          </.card>
        </.column>
        <.column size="1-3">
          <.card>
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <div class="pa-text--secondary font-xs text-upper mb-xs">Error Rate</div>
                <div class="font-2xl font-bold">0.24%</div>
                <div class="font-xs mt-xs" style="color: #dc3545">+0.02% vs yesterday</div>
              </div>
              <.sparkline values={[20, 15, 25, 18, 22, 30, 28]} variant="danger" />
            </div>
          </.card>
        </.column>
      </.grid>

      <%!-- System Health: Progress rings row --%>
      <.heading level={4} class="mt-xl mb-base">System Health</.heading>
      <div class="d-flex gap-xl flex-wrap justify-content-center">
        <div class="text-center">
          <.progress_ring value={72} size="sm" />
          <div class="font-xs pa-text--secondary mt-sm">CPU</div>
        </div>
        <div class="text-center">
          <.progress_ring value={58} size="sm" variant="warning" />
          <div class="font-xs pa-text--secondary mt-sm">Memory</div>
        </div>
        <div class="text-center">
          <.progress_ring value={87} size="sm" variant="danger" />
          <div class="font-xs pa-text--secondary mt-sm">Disk</div>
        </div>
        <div class="text-center">
          <.progress_ring value={99} size="sm" variant="success" />
          <div class="font-xs pa-text--secondary mt-sm">Uptime</div>
        </div>
      </div>

      <%!-- Storage breakdown --%>
      <.heading level={4} class="mt-xl mb-sm">Storage Breakdown</.heading>
      <div class="pa-progress-group">
        <div class="pa-progress__label">
          <span>Server Cluster Storage</span>
          <span class="pa-progress__label-value">845 GB / 1 TB</span>
        </div>
        <.stacked_bar is_rounded>
          <.stacked_segment value={40} />
          <.stacked_segment value={25} variant="success" />
          <.stacked_segment value={12} variant="warning" />
          <.stacked_segment value={8} variant="secondary" />
        </.stacked_bar>
      </div>
      <.stacked_bar_legend>
        <.stacked_legend_item label="Databases (400 GB)" variant="primary" />
        <.stacked_legend_item label="Logs (250 GB)" variant="success" />
        <.stacked_legend_item label="Backups (120 GB)" variant="warning" />
        <.stacked_legend_item label="Cache (75 GB)" variant="secondary" />
      </.stacked_bar_legend>
    </.card>
    """
  end
end
