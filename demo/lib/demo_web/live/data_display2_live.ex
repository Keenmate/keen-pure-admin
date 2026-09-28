defmodule DemoWeb.Live.DataDisplay2Live do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Data Display 2")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Fresh approaches to data display. Each section is a completely different pattern.</.paragraph>

    <%!-- ============================================================
         1. ANT DESIGN DESCRIPTIONS TABLE
         ============================================================ --%>

    <.card title_text={gettext("1. Descriptions Table")}>
      <:description>Ant Design style. Label cells get a tinted background. Dense, structured, and very readable.</:description>
      <.desc_table>
        <.desc_label>{gettext("Company")}</.desc_label>
        <.desc_value>Novak &amp; Partners s.r.o.</.desc_value>
        <.desc_label>{gettext("Reg. No.")}</.desc_label>
        <.desc_value>CZ48207497</.desc_value>
        <.desc_label>{gettext("VAT ID")}</.desc_label>
        <.desc_value>CZ48207497</.desc_value>
        <.desc_label>{gettext("Contact")}</.desc_label>
        <.desc_value>Jan Novak</.desc_value>
        <.desc_label>{gettext("Email")}</.desc_label>
        <.desc_value>jan.novak@novakpartners.cz</.desc_value>
        <.desc_label>{gettext("Phone")}</.desc_label>
        <.desc_value>+420 234 111 222</.desc_value>
        <.desc_label>{gettext("Notes")}</.desc_label>
        <.desc_value is_full>Preferred carrier for Central European routes. Framework agreement renewed annually.</.desc_value>
      </.desc_table>
    </.card>

    <%!-- 2-column variant --%>
    <.card title_text={gettext("1b. Descriptions Table (2 columns)")}>
      <.desc_table cols="2">
        <.desc_label>{gettext("First Name")}</.desc_label>
        <.desc_value>Elena</.desc_value>
        <.desc_label>{gettext("Last Name")}</.desc_label>
        <.desc_value>Petrova</.desc_value>
        <.desc_label>{gettext("Date of Birth")}</.desc_label>
        <.desc_value>14 March 1992</.desc_value>
        <.desc_label>{gettext("Role")}</.desc_label>
        <.desc_value>Senior Developer</.desc_value>
        <.desc_label>{gettext("Office")}</.desc_label>
        <.desc_value>Prague, Karlin</.desc_value>
        <.desc_label>{gettext("Start Date")}</.desc_label>
        <.desc_value>1 Sep 2019</.desc_value>
      </.desc_table>
    </.card>

    <%!-- Fixed label width + truncate --%>
    <.grid>
      <.column size="1-2">
        <.card title_text={gettext("1c. Descriptions Table — Fixed + Truncate")}>
          <:description><code>--fixed</code> locks label columns to 14rem. <code>--truncate</code> clips long values with ellipsis.</:description>
          <.desc_table cols="2" is_fixed is_truncate>
            <.desc_label>{gettext("Company")}</.desc_label>
            <.desc_value>Novak &amp; Partners International Consulting Group s.r.o.</.desc_value>
            <.desc_label>{gettext("Reg. No.")}</.desc_label>
            <.desc_value>CZ48207497</.desc_value>
            <.desc_label>{gettext("Address")}</.desc_label>
            <.desc_value>Vinohradska 2468/164, Prague 3, Vinohrady, 130 00, Czech Republic</.desc_value>
            <.desc_label>{gettext("Email")}</.desc_label>
            <.desc_value>jan.novak@novakpartners-international.cz</.desc_value>
          </.desc_table>
        </.card>
      </.column>
      <.column size="1-2">
        <.card title_text={gettext("1d. Descriptions Table — Custom Label Width")}>
          <:description><code>--fixed</code> with <code>--label-width: 20rem</code> via CSS custom property.</:description>
          <.desc_table cols="2" is_fixed label_width="20rem">
            <.desc_label>{gettext("Full Legal Name")}</.desc_label>
            <.desc_value>Elena Petrova</.desc_value>
            <.desc_label>{gettext("Date of Birth")}</.desc_label>
            <.desc_value>14 March 1992</.desc_value>
            <.desc_label>{gettext("Department")}</.desc_label>
            <.desc_value>Engineering</.desc_value>
            <.desc_label>{gettext("Employment Type")}</.desc_label>
            <.desc_value>Full-time permanent</.desc_value>
          </.desc_table>
        </.card>
      </.column>
    </.grid>

    <%!-- ============================================================
         2. DOT LEADERS
         ============================================================ --%>

    <.grid>
      <.column size="1-2">
        <.card title_text={gettext("2. Dot Leaders")}>
          <:description>Restaurant menu / invoice style. Dotted line connects label to value.</:description>
          <.dot_leaders>
            <.dot_leader label={gettext("Contract No.")} value="CTR-2025-00194" />
            <.dot_leader label={gettext("Type")} value="Framework Agreement" />
            <.dot_leader label={gettext("Status")} value="Active" />
            <.dot_leader label={gettext("Renewal Date")} value="1 Jan 2027" />
            <.dot_leader label={gettext("Seats")} value="48 / 50" />
          </.dot_leaders>
        </.card>
      </.column>
      <.column size="1-2">
        <.card title_text={gettext("2b. Dot Leaders — Invoice Totals")}>
          <:description>Perfect for financial summaries.</:description>
          <.dot_leaders>
            <.dot_leader label={gettext("Subtotal")} value="$2,094.00" />
            <.dot_leader label={gettext("Shipping")} value="$24.00" />
            <.dot_leader label="VAT 21%" value="$439.74" />
            <.dot_leader label={gettext("Total")} value="$2,557.74" is_total />
          </.dot_leaders>
        </.card>
      </.column>
    </.grid>

    <%!-- ============================================================
         3. STRIPE PROPERTY CARDS
         ============================================================ --%>

    <.grid>
      <.column size="1-2">
        <.card title_text={gettext("3. Property Card")}>
          <:description>Grouped in bordered card with thin dividers. Clean, professional.</:description>
          <.prop_card header={gettext("Order Details")}>
            <.prop_card_row label={gettext("Order ID")} value="#ORD-2026-00847" />
            <.prop_card_row label={gettext("Date")} value="28 January 2026" />
            <.prop_card_row label={gettext("Status")}><.badge variant="success">Delivered</.badge></.prop_card_row>
            <.prop_card_row label={gettext("Payment")} value="Visa *4242" />
            <.prop_card_row label={gettext("Total")} is_bold>$1,249.00</.prop_card_row>
          </.prop_card>
        </.card>
      </.column>
      <.column size="1-2">
        <.card title_text={gettext("3b. Property Card — Stacked")}>
          <:description>Multiple property groups in sequence.</:description>
          <.prop_card header={gettext("Customer")} class="mb-4">
            <.prop_card_row label={gettext("Name")} value="Elena Petrova" />
            <.prop_card_row label={gettext("Email")} value="elena.petrova@example.com" />
            <.prop_card_row label={gettext("Phone")} value="+420 776 123 456" />
          </.prop_card>
          <.prop_card header={gettext("Shipping")}>
            <.prop_card_row label={gettext("Address")} value="Vinohradska 2468/164, Prague 3" />
            <.prop_card_row label={gettext("Method")} value="Express (2-day)" />
          </.prop_card>
        </.card>
      </.column>
    </.grid>

    <%!-- ============================================================
         4. LINEAR MINIMAL + 5. INLINE CHIPS + 7. BANDED ROWS
         ============================================================ --%>

    <.grid>
      <.column size="1-3">
        <.card title_text={gettext("4. Linear Minimal")}>
          <:description>Ultra-clean. Only weight + color contrast. No decoration.</:description>
          <div class="pa-fields-container">
            <.fields is_linear is_no_border>
              <.field label={gettext("Status")}><.badge variant="success">Active</.badge></.field>
              <.field label={gettext("Priority")}>High</.field>
              <.field label={gettext("Assignee")}>Elena Petrova</.field>
              <.field label={gettext("Created")}>28 Jan 2026</.field>
              <.field label={gettext("Due Date")}>14 Feb 2026</.field>
              <.field label={gettext("Project")}>Platform v2</.field>
              <.field label={gettext("Labels")}>
                <.badge>Frontend</.badge>
                <.badge>UX</.badge>
              </.field>
            </.fields>
          </div>
        </.card>
      </.column>

      <.column size="1-3">
        <.card title_text={gettext("5. Inline Chips")}>
          <:description>Properties as flowing inline pairs. Value in a chip/pill.</:description>
          <div class="pa-fields-container">
            <.fields is_chips is_no_border>
              <.field label={gettext("Status")} value_variant="success">Active</.field>
              <.field label={gettext("Role")}>Senior Dev</.field>
              <.field label={gettext("Team")}>Platform</.field>
              <.field label={gettext("Office")}>Prague</.field>
              <.field label={gettext("Start")}>2019</.field>
              <.field label={gettext("Contract")} value_variant="warning">Renewal</.field>
            </.fields>
          </div>
        </.card>
      </.column>

      <.column size="1-3">
        <.card title_text={gettext("7. Banded Rows")} has_padding={false}>
          <:description>Label gets a fixed-width tinted column. Clear visual anchor.</:description>
          <div class="pa-banded-container">
            <.banded>
              <.banded_row label={gettext("Server")} value="prod-api-01" />
              <.banded_row label={gettext("IP Address")} value="10.0.12.45" />
              <.banded_row label="OS" value="Ubuntu 22.04 LTS" />
              <.banded_row label={gettext("Memory")} value="16 GB DDR5" />
              <.banded_row label={gettext("Uptime")} value="47 days" />
            </.banded>
          </div>
        </.card>
      </.column>
    </.grid>

    <%!-- Banded width variants --%>
    <.grid>
      <.column size="1-3">
        <.card title_text={gettext("7b. Banded — Narrow")} has_padding={false}>
          <:description><code>pa-banded--narrow</code> — 10rem label band.</:description>
          <div class="pa-banded-container">
            <.banded is_narrow>
              <.banded_row label={gettext("Server")} value="prod-api-01" />
              <.banded_row label={gettext("IP Address")} value="10.0.12.45" />
              <.banded_row label="OS" value="Ubuntu 22.04 LTS" />
              <.banded_row label={gettext("Memory")} value="16 GB DDR5" />
            </.banded>
          </div>
        </.card>
      </.column>
      <.column size="1-3">
        <.card title_text={gettext("7c. Banded — Default")} has_padding={false}>
          <:description>No modifier — default 14rem label band.</:description>
          <div class="pa-banded-container">
            <.banded>
              <.banded_row label={gettext("Server")} value="prod-api-01" />
              <.banded_row label={gettext("IP Address")} value="10.0.12.45" />
              <.banded_row label="OS" value="Ubuntu 22.04 LTS" />
              <.banded_row label={gettext("Memory")} value="16 GB DDR5" />
            </.banded>
          </div>
        </.card>
      </.column>
      <.column size="1-3">
        <.card title_text={gettext("7d. Banded — Wide")} has_padding={false}>
          <:description><code>pa-banded--wide</code> — 20rem label band.</:description>
          <div class="pa-banded-container">
            <.banded is_wide>
              <.banded_row label={gettext("Server")} value="prod-api-01" />
              <.banded_row label={gettext("IP Address")} value="10.0.12.45" />
              <.banded_row label="OS" value="Ubuntu 22.04 LTS" />
              <.banded_row label={gettext("Memory")} value="16 GB DDR5" />
            </.banded>
          </div>
        </.card>
      </.column>
    </.grid>

    <%!-- Banded truncate + utility width --%>
    <.grid>
      <.column size="1-2">
        <.card title_text={gettext("7e. Banded — Truncate")} has_padding={false}>
          <:description><code>--truncate</code> clips long values with ellipsis.</:description>
          <div class="pa-banded-container">
            <.banded is_truncate>
              <.banded_row label={gettext("Server")} value="prod-api-gateway-eu-west-01.internal.novakpartners.cz" />
              <.banded_row label={gettext("Path")} value="/var/lib/docker/containers/a1b2c3d4e5f6/config.v2.json" />
              <.banded_row label={gettext("Hash")} value="sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" />
              <.banded_row label={gettext("Cert")}>CN=*.novakpartners.cz, O=Novak &amp; Partners, L=Prague, C=CZ</.banded_row>
            </.banded>
          </div>
        </.card>
      </.column>
      <.column size="1-2">
        <.card title_text={gettext("7f. Banded — wr-* Utility Width")} has_padding={false}>
          <:description>Label width set per-label with <code>wr-8</code> utility class (8rem).</:description>
          <div class="pa-banded-container">
            <div class="pa-banded pa-banded--truncate">
              <div class="pa-banded__row">
                <span class="pa-banded__label wr-8">Server</span>
                <span class="pa-banded__value">prod-api-gateway-eu-west-01.internal.novakpartners.cz</span>
              </div>
              <div class="pa-banded__row">
                <span class="pa-banded__label wr-8">Path</span>
                <span class="pa-banded__value">/var/lib/docker/containers/a1b2c3d4e5f6/config.v2.json</span>
              </div>
              <div class="pa-banded__row">
                <span class="pa-banded__label wr-8">Hash</span>
                <span class="pa-banded__value">sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855</span>
              </div>
              <div class="pa-banded__row">
                <span class="pa-banded__label wr-8">Cert</span>
                <span class="pa-banded__value">CN=*.novakpartners.cz, O=Novak &amp; Partners, L=Prague, C=CZ</span>
              </div>
            </div>
          </div>
        </.card>
      </.column>
    </.grid>

    <%!-- Banded + desc-table multiline wrap --%>
    <.grid>
      <.column size="1-2">
        <.card title_text={gettext("7g. Banded — Multiline (default top)")} has_padding={false}>
          <:description>Labels top-align by default when values wrap to multiple lines.</:description>
          <div class="pa-banded-container">
            <.banded>
              <.banded_row label={gettext("Server")} value="prod-api-01" />
              <.banded_row label={gettext("Description")} value="Primary API gateway for Central European region. Handles authentication, rate limiting, and request routing to downstream microservices." />
              <.banded_row label={gettext("Tags")} value="production, eu-west, api-gateway, load-balanced, auto-scaling, monitored, pci-compliant" />
              <.banded_row label={gettext("Notes")} value="Scheduled for maintenance window on 2026-03-01 02:00 UTC. Failover to prod-api-02 will be active during this period. Contact SRE team before any manual restarts." />
            </.banded>
          </div>
        </.card>
      </.column>
      <.column size="1-2">
        <.card title_text={gettext("7h. Banded — Multiline + --middle")} has_padding={false}>
          <:description><code>pa-banded--middle</code> vertically centers labels against wrapped values.</:description>
          <div class="pa-banded-container">
            <.banded is_middle>
              <.banded_row label={gettext("Server")} value="prod-api-01" />
              <.banded_row label={gettext("Description")}>Primary API gateway for Central European region. Handles authentication, rate limiting, and request routing to downstream microservices.</.banded_row>
              <.banded_row label={gettext("Tags")}>production, eu-west, api-gateway, load-balanced, auto-scaling, monitored, pci-compliant</.banded_row>
              <.banded_row label={gettext("Notes")}>Scheduled for maintenance window on 2026-03-01 02:00 UTC. Failover to prod-api-02 will be active during this period. Contact SRE team before any manual restarts.</.banded_row>
            </.banded>
          </div>
        </.card>
      </.column>
    </.grid>

    <%!-- Desc-table multiline: top (default) vs middle --%>
    <.grid>
      <.column size="1-2">
        <.card title_text={gettext("1e. Desc Table — Multiline (default top)")}>
          <:description>Labels top-align by default in grid cells.</:description>
          <.desc_table cols="2">
            <.desc_label>{gettext("Company")}</.desc_label>
            <.desc_value>Novak &amp; Partners s.r.o.</.desc_value>
            <.desc_label>{gettext("Address")}</.desc_label>
            <.desc_value>Vinohradska 2468/164, Prague 3, Vinohrady, 130 00, Czech Republic</.desc_value>
            <.desc_label>{gettext("Notes")}</.desc_label>
            <.desc_value>Preferred carrier for Central European routes. Framework agreement renewed annually. Contact Jan Novak for any billing disputes or special rate negotiations.</.desc_value>
            <.desc_label>{gettext("Status")}</.desc_label>
            <.desc_value>Active</.desc_value>
          </.desc_table>
        </.card>
      </.column>
      <.column size="1-2">
        <.card title_text={gettext("1f. Desc Table — Multiline + --middle")}>
          <:description>Cells stretch to fill the row, content centered inside. Label backgrounds fill the full row height.</:description>
          <.desc_table cols="2" is_middle>
            <.desc_label>{gettext("Company")}</.desc_label>
            <.desc_value>Novak &amp; Partners s.r.o.</.desc_value>
            <.desc_label>{gettext("Address")}</.desc_label>
            <.desc_value>Vinohradska 2468/164, Prague 3, Vinohrady, 130 00, Czech Republic</.desc_value>
            <.desc_label>{gettext("Notes")}</.desc_label>
            <.desc_value>Preferred carrier for Central European routes. Framework agreement renewed annually. Contact Jan Novak for any billing disputes or special rate negotiations.</.desc_value>
            <.desc_label>{gettext("Status")}</.desc_label>
            <.desc_value>Active</.desc_value>
          </.desc_table>
        </.card>
      </.column>
    </.grid>

    <%!-- Label horizontal alignment --%>
    <.grid>
      <.column size="1-3">
        <.card title_text={gettext("Banded — Label Start (default)")} has_padding={false}>
          <div class="pa-banded-container">
            <.banded>
              <.banded_row label={gettext("Server")} value="prod-api-01" />
              <.banded_row label={gettext("IP Address")} value="10.0.12.45" />
              <.banded_row label={gettext("Memory")} value="16 GB DDR5" />
            </.banded>
          </div>
        </.card>
      </.column>
      <.column size="1-3">
        <.card title_text={gettext("Banded — --label-end")} has_padding={false}>
          <div class="pa-banded-container">
            <.banded is_label_end>
              <.banded_row label={gettext("Server")} value="prod-api-01" />
              <.banded_row label={gettext("IP Address")} value="10.0.12.45" />
              <.banded_row label={gettext("Memory")} value="16 GB DDR5" />
            </.banded>
          </div>
        </.card>
      </.column>
      <.column size="1-3">
        <.card title_text={gettext("Banded — --label-center")} has_padding={false}>
          <div class="pa-banded-container">
            <.banded is_label_center>
              <.banded_row label={gettext("Server")} value="prod-api-01" />
              <.banded_row label={gettext("IP Address")} value="10.0.12.45" />
              <.banded_row label={gettext("Memory")} value="16 GB DDR5" />
            </.banded>
          </div>
        </.card>
      </.column>
    </.grid>

    <.grid>
      <.column size="1-3">
        <.card title_text={gettext("Desc Table — Label Start (default)")}>
          <.desc_table cols="2" is_fixed>
            <.desc_label>{gettext("Server")}</.desc_label>
            <.desc_value>prod-api-01</.desc_value>
            <.desc_label>{gettext("IP Address")}</.desc_label>
            <.desc_value>10.0.12.45</.desc_value>
            <.desc_label>{gettext("Memory")}</.desc_label>
            <.desc_value>16 GB DDR5</.desc_value>
          </.desc_table>
        </.card>
      </.column>
      <.column size="1-3">
        <.card title_text={gettext("Desc Table — --label-end")}>
          <.desc_table cols="2" is_fixed is_label_end>
            <.desc_label>{gettext("Server")}</.desc_label>
            <.desc_value>prod-api-01</.desc_value>
            <.desc_label>{gettext("IP Address")}</.desc_label>
            <.desc_value>10.0.12.45</.desc_value>
            <.desc_label>{gettext("Memory")}</.desc_label>
            <.desc_value>16 GB DDR5</.desc_value>
          </.desc_table>
        </.card>
      </.column>
      <.column size="1-3">
        <.card title_text={gettext("Desc Table — --label-center")}>
          <.desc_table cols="2" is_fixed is_label_center>
            <.desc_label>{gettext("Server")}</.desc_label>
            <.desc_value>prod-api-01</.desc_value>
            <.desc_label>{gettext("IP Address")}</.desc_label>
            <.desc_value>10.0.12.45</.desc_value>
            <.desc_label>{gettext("Memory")}</.desc_label>
            <.desc_value>16 GB DDR5</.desc_value>
          </.desc_table>
        </.card>
      </.column>
    </.grid>

    <%!-- ============================================================
         GHOST CARD DEMO
         ============================================================ --%>

    <.grid>
      <.column size="1-2">
        <.card title_text={gettext("Normal Card + Accent-Bar")}>
          <.accent_grid>
            <.accent_grid_item label={gettext("Order ID")} value="#ORD-2026-00847" />
            <.accent_grid_item label={gettext("Status")} value="Delivered" variant="success" />
            <.accent_grid_item label={gettext("Payment")} value="Visa *4242" variant="info" />
            <.accent_grid_item label={gettext("Customer")} value="Elena Petrova" />
          </.accent_grid>
        </.card>
      </.column>
      <.column size="1-2">
        <.card title_text={gettext("Ghost Card + Accent-Bar")} is_ghost>
          <:description><code>pa-card--ghost</code> — same sizing, no visible container.</:description>
          <.accent_grid>
            <.accent_grid_item label={gettext("Order ID")} value="#ORD-2026-00847" />
            <.accent_grid_item label={gettext("Status")} value="Delivered" variant="success" />
            <.accent_grid_item label={gettext("Payment")} value="Visa *4242" variant="info" />
            <.accent_grid_item label={gettext("Customer")} value="Elena Petrova" />
          </.accent_grid>
        </.card>
      </.column>
    </.grid>

    <%!-- ============================================================
         8. ACCENT-BAR MINI CARDS
         ============================================================ --%>

    <.card title_text={gettext("8. Accent-Bar Grid")} is_ghost>
      <:description>Each property gets a color-coded left border. Good for status-heavy panels.</:description>
      <.accent_grid>
        <.accent_grid_item label={gettext("Order ID")} value="#ORD-2026-00847" />
        <.accent_grid_item label={gettext("Status")} value="Delivered" variant="success" />
        <.accent_grid_item label={gettext("Payment")} value="Visa *4242" variant="info" />
        <.accent_grid_item label={gettext("Customer")} value="Elena Petrova" />
        <.accent_grid_item label={gettext("Renewal")} value="1 Jan 2027" variant="warning" />
        <.accent_grid_item label={gettext("Total")} value="$1,249.00" />
      </.accent_grid>
    </.card>

    <%!-- ============================================================
         COPYABLE FIELDS
         ============================================================ --%>

    <.card title_text={gettext("Copyable Fields")}>
      <:description>Three copy-to-clipboard styles applied to the new data display patterns. Click to test each variant.</:description>
      <.grid>
        <.column size="1-3">
          <.heading level={4}>{gettext("Copy Button (always visible)")}</.heading>
          <p class="text-secondary mb-2"><code>pa-banded__row--copy-btn</code></p>
          <div class="pa-banded">
            <div class="pa-banded__row pa-banded__row--copy-btn">
              <span class="pa-banded__label">IP Address</span>
              <span class="pa-banded__value">
                <span data-copy-value>10.0.12.45</span>
                <button class="pa-banded__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
            </div>
            <div class="pa-banded__row pa-banded__row--copy-btn">
              <span class="pa-banded__label">Hash</span>
              <span class="pa-banded__value">
                <span data-copy-value>sha256:e3b0c44298fc1c</span>
                <button class="pa-banded__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
            </div>
          </div>
        </.column>
        <.column size="1-3">
          <.heading level={4}>{gettext("Click Value to Copy")}</.heading>
          <p class="text-secondary mb-2"><code>pa-banded__row--copy-click</code></p>
          <div class="pa-banded">
            <div class="pa-banded__row pa-banded__row--copy-click">
              <span class="pa-banded__label">Server</span>
              <span class="pa-banded__value" data-pa-copy-on-click data-copy-value="prod-api-01">prod-api-01</span>
            </div>
            <div class="pa-banded__row pa-banded__row--copy-click">
              <span class="pa-banded__label">OS</span>
              <span class="pa-banded__value" data-pa-copy-on-click data-copy-value="Ubuntu 22.04 LTS">Ubuntu 22.04 LTS</span>
            </div>
          </div>
        </.column>
        <.column size="1-3">
          <.heading level={4}>{gettext("Icon on Hover Only")}</.heading>
          <p class="text-secondary mb-2"><code>pa-banded__row--copy-hover</code></p>
          <div class="pa-banded">
            <div class="pa-banded__row pa-banded__row--copy-hover">
              <span class="pa-banded__label">IBAN</span>
              <span class="pa-banded__value">
                <span data-copy-value>CZ65 0800 0000 1920 0014 5399</span>
                <button class="pa-banded__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
            </div>
            <div class="pa-banded__row pa-banded__row--copy-hover">
              <span class="pa-banded__label">BIC/SWIFT</span>
              <span class="pa-banded__value">
                <span data-copy-value>GIBACZPX</span>
                <button class="pa-banded__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
            </div>
          </div>
        </.column>
      </.grid>

      <.grid class="mt-8">
        <.column size="1-2">
          <.heading level={4}>{gettext("Property Card — Hover Copy")}</.heading>
          <p class="text-secondary mb-2"><code>pa-prop-card__row--copy-hover</code></p>
          <div class="pa-prop-card">
            <div class="pa-prop-card__header">Order Details</div>
            <div class="pa-prop-card__row pa-prop-card__row--copy-hover">
              <span class="pa-prop-card__label">Order ID</span>
              <span class="pa-prop-card__value">
                <span data-copy-value>#ORD-2026-00847</span>
                <button class="pa-prop-card__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
            </div>
            <div class="pa-prop-card__row">
              <span class="pa-prop-card__label">Date</span>
              <span class="pa-prop-card__value">28 January 2026</span>
            </div>
            <div class="pa-prop-card__row pa-prop-card__row--copy-hover">
              <span class="pa-prop-card__label">Payment</span>
              <span class="pa-prop-card__value">
                <span data-copy-value>Visa *4242</span>
                <button class="pa-prop-card__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
            </div>
            <div class="pa-prop-card__row">
              <span class="pa-prop-card__label">Total</span>
              <span class="pa-prop-card__value pa-prop-card__value--bold">$1,249.00</span>
            </div>
          </div>
        </.column>
        <.column size="1-2">
          <.heading level={4}>{gettext("Descriptions Table — Copy Button")}</.heading>
          <p class="text-secondary mb-2"><code>pa-desc-table__value--copy-btn</code></p>
          <div class="pa-desc-container">
            <div class="pa-desc-table pa-desc-table--cols-2">
              <span class="pa-desc-table__label">Reg. No.</span>
              <span class="pa-desc-table__value pa-desc-table__value--copy-btn">
                <span data-copy-value>CZ48207497</span>
                <button class="pa-desc-table__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
              <span class="pa-desc-table__label">VAT ID</span>
              <span class="pa-desc-table__value pa-desc-table__value--copy-btn">
                <span data-copy-value>CZ48207497</span>
                <button class="pa-desc-table__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
              <span class="pa-desc-table__label">Email</span>
              <span class="pa-desc-table__value pa-desc-table__value--copy-btn">
                <span data-copy-value>jan.novak@novakpartners.cz</span>
                <button class="pa-desc-table__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
              <span class="pa-desc-table__label">Phone</span>
              <span class="pa-desc-table__value pa-desc-table__value--copy-btn">
                <span data-copy-value>+420 234 111 222</span>
                <button class="pa-desc-table__copy" data-pa-copy title="Copy to clipboard">
                  <i class="fas fa-copy"></i>
                </button>
              </span>
            </div>
          </div>
        </.column>
      </.grid>

      <.heading level={4} class="mt-8">{gettext("Accent Grid — Hover Copy")}</.heading>
      <p class="text-secondary mb-2"><code>pa-accent-grid__item--copy-hover</code></p>
      <div class="pa-accent-grid">
        <div class="pa-accent-grid__item pa-accent-grid__item--copy-hover">
          <div class="pa-accent-grid__label">Order ID</div>
          <div class="pa-accent-grid__value">
            <span data-copy-value>#ORD-2026-00847</span>
            <button class="pa-accent-grid__copy" data-pa-copy title="Copy to clipboard">
              <i class="fas fa-copy"></i>
            </button>
          </div>
        </div>
        <div class="pa-accent-grid__item pa-accent-grid__item--success pa-accent-grid__item--copy-click">
          <div class="pa-accent-grid__label">Status</div>
          <div class="pa-accent-grid__value" data-pa-copy-on-click data-copy-value="Delivered">Delivered</div>
        </div>
        <div class="pa-accent-grid__item pa-accent-grid__item--info pa-accent-grid__item--copy-hover">
          <div class="pa-accent-grid__label">Payment</div>
          <div class="pa-accent-grid__value">
            <span data-copy-value>Visa *4242</span>
            <button class="pa-accent-grid__copy" data-pa-copy title="Copy to clipboard">
              <i class="fas fa-copy"></i>
            </button>
          </div>
        </div>
        <div class="pa-accent-grid__item pa-accent-grid__item--copy-hover">
          <div class="pa-accent-grid__label">Customer</div>
          <div class="pa-accent-grid__value">
            <span data-copy-value>Elena Petrova</span>
            <button class="pa-accent-grid__copy" data-pa-copy title="Copy to clipboard">
              <i class="fas fa-copy"></i>
            </button>
          </div>
        </div>
        <div class="pa-accent-grid__item pa-accent-grid__item--warning pa-accent-grid__item--copy-btn">
          <div class="pa-accent-grid__label">Renewal</div>
          <div class="pa-accent-grid__value">
            <span data-copy-value>1 Jan 2027</span>
            <button class="pa-accent-grid__copy" data-pa-copy title="Copy to clipboard">
              <i class="fas fa-copy"></i>
            </button>
          </div>
        </div>
        <div class="pa-accent-grid__item pa-accent-grid__item--copy-click">
          <div class="pa-accent-grid__label">Total</div>
          <div class="pa-accent-grid__value" data-pa-copy-on-click data-copy-value="$1,249.00">$1,249.00</div>
        </div>
      </div>
    </.card>

    <%!-- Copy behaviour is wired via `initPureAdminEvents()` in app.js — no inline JS required. --%>

    <%!-- ============================================================
         REAL-WORLD: Full Invoice using multiple patterns
         ============================================================ --%>

    <.card title_text={gettext("Real-World: Invoice combining patterns")}>
      <:description>Descriptions table for customer, banded rows for addresses, dot leaders for totals.</:description>

      <%!-- Customer: Ant-style descriptions --%>
      <.heading level={4} class="mb-2">{gettext("Customer")}</.heading>
      <.desc_table class="mb-8">
        <.desc_label>{gettext("Name")}</.desc_label>
        <.desc_value>Novak &amp; Partners s.r.o.</.desc_value>
        <.desc_label>{gettext("Reg. No.")}</.desc_label>
        <.desc_value>CZ48207497</.desc_value>
        <.desc_label>{gettext("VAT ID")}</.desc_label>
        <.desc_value>CZ48207497</.desc_value>
        <.desc_label>{gettext("Contact")}</.desc_label>
        <.desc_value>Jan Novak</.desc_value>
        <.desc_label>{gettext("Email")}</.desc_label>
        <.desc_value>jan.novak@novakpartners.cz</.desc_value>
        <.desc_label>{gettext("Phone")}</.desc_label>
        <.desc_value>+420 234 111 222</.desc_value>
      </.desc_table>

      <%!-- Addresses: Banded rows side-by-side --%>
      <.grid class="mb-8">
        <.column size="1-2">
          <.heading level={4} class="mb-2">{gettext("Receipt Address")}</.heading>
          <.banded>
            <.banded_row label={gettext("Street")} value="Vinohradska 2468/164" />
            <.banded_row label={gettext("City")} value="Prague 3, 130 00" />
            <.banded_row label={gettext("Country")} value="Czech Republic" />
          </.banded>
        </.column>
        <.column size="1-2">
          <.heading level={4} class="mb-2">{gettext("Delivery Address")}</.heading>
          <.banded>
            <.banded_row label={gettext("Street")} value="Prumyslova 1234/5" />
            <.banded_row label={gettext("City")} value="Brno-Slatina, 627 00" />
            <.banded_row label={gettext("Country")} value="Czech Republic" />
          </.banded>
        </.column>
      </.grid>

      <%!-- Items: regular table --%>
      <.heading level={4} class="mb-2">{gettext("Items")}</.heading>
      <.table rows={[
        %{product: "Mechanical Keyboard", sku: "KB-MX-BRN", qty: "2", price: "$149", total: "$298"},
        %{product: "27\" 4K Monitor", sku: "MON-27-4K", qty: "4", price: "$449", total: "$1,796"}
      ]} is_striped class="mb-8">
        <:col :let={row} label={gettext("Product")}>{row.product}</:col>
        <:col :let={row} label="SKU">{row.sku}</:col>
        <:col :let={row} label={gettext("Qty")} align="end">{row.qty}</:col>
        <:col :let={row} label={gettext("Price")} align="end">{row.price}</:col>
        <:col :let={row} label={gettext("Total")} align="end">{row.total}</:col>
      </.table>

      <%!-- Totals: Dot leaders --%>
      <div style="max-width: 28rem; margin-inline-start: auto;">
        <.dot_leaders>
          <.dot_leader label={gettext("Subtotal")} value="$2,094.00" />
          <.dot_leader label={gettext("Shipping")} value="$24.00" />
          <.dot_leader label="VAT 21%" value="$439.74" />
          <.dot_leader label={gettext("Total")} value="$2,557.74" is_total />
        </.dot_leaders>
      </div>
    </.card>

    <%!-- ============================================================
         CSS REFERENCE
         ============================================================ --%>

    <.card title_text={gettext("CSS Reference")} has_padding={false}>
      <table class="pa-table pa-table--striped">
        <thead>
          <tr>
            <th>Class</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr><td colspan="2"><strong>Descriptions Table</strong></td></tr>
          <tr>
            <td><code>.pa-desc-table</code></td>
            <td>CSS Grid with 3 label-value pairs per row (default). Label cells get tinted background.</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table--cols-2</code></td>
            <td>2 label-value pairs per row</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table--fixed</code></td>
            <td>Fixed-width label columns (default 14rem, override with <code>--label-width</code> CSS property)</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table--middle</code></td>
            <td>Vertically center labels and values</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table--label-end</code></td>
            <td>Right-align labels</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table--label-center</code></td>
            <td>Center-align labels</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table--truncate</code></td>
            <td>Single-line ellipsis on labels and values</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table__label</code></td>
            <td>Label cell (tinted background, colon appended via CSS)</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table__value</code></td>
            <td>Value cell</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table__value--full</code></td>
            <td>Value spans all remaining columns</td>
          </tr>
          <tr>
            <td><code>.pa-desc-container</code></td>
            <td>Container query wrapper — desc-tables collapse to single column when parent is narrow</td>
          </tr>

          <tr><td colspan="2"><strong>Dot Leaders</strong></td></tr>
          <tr>
            <td><code>.pa-dot-leaders</code></td>
            <td>Flex column container for leader items</td>
          </tr>
          <tr>
            <td><code>.pa-dot-leaders__item</code></td>
            <td>Single row with label, dotted leader, and value</td>
          </tr>
          <tr>
            <td><code>.pa-dot-leaders__item--total</code></td>
            <td>Total row with top border and bold text</td>
          </tr>
          <tr>
            <td><code>.pa-dot-leaders__label</code></td>
            <td>Left-aligned label text</td>
          </tr>
          <tr>
            <td><code>.pa-dot-leaders__leader</code></td>
            <td>Dotted line filling space between label and value</td>
          </tr>
          <tr>
            <td><code>.pa-dot-leaders__value</code></td>
            <td>Right-aligned value text (tabular-nums)</td>
          </tr>

          <tr><td colspan="2"><strong>Property Card</strong></td></tr>
          <tr>
            <td><code>.pa-prop-card</code></td>
            <td>Bordered card with optional header and label-value rows</td>
          </tr>
          <tr>
            <td><code>.pa-prop-card__header</code></td>
            <td>Uppercase section header with tinted background</td>
          </tr>
          <tr>
            <td><code>.pa-prop-card__row</code></td>
            <td>Flex row with label and value</td>
          </tr>
          <tr>
            <td><code>.pa-prop-card__label</code></td>
            <td>Left-aligned label</td>
          </tr>
          <tr>
            <td><code>.pa-prop-card__value</code></td>
            <td>Right-aligned value</td>
          </tr>
          <tr>
            <td><code>.pa-prop-card__value--bold</code></td>
            <td>Bold value text</td>
          </tr>

          <tr><td colspan="2"><strong>Banded Rows</strong></td></tr>
          <tr>
            <td><code>.pa-banded</code></td>
            <td>Rows with fixed-width tinted label column (default 14rem)</td>
          </tr>
          <tr>
            <td><code>.pa-banded--narrow</code></td>
            <td>Narrow label column (10rem)</td>
          </tr>
          <tr>
            <td><code>.pa-banded--wide</code></td>
            <td>Wide label column (20rem)</td>
          </tr>
          <tr>
            <td><code>.pa-banded--middle</code></td>
            <td>Vertically center labels and values</td>
          </tr>
          <tr>
            <td><code>.pa-banded--label-end</code></td>
            <td>Right-align labels</td>
          </tr>
          <tr>
            <td><code>.pa-banded--label-center</code></td>
            <td>Center-align labels</td>
          </tr>
          <tr>
            <td><code>.pa-banded--truncate</code></td>
            <td>Single-line ellipsis on labels and values</td>
          </tr>
          <tr>
            <td><code>.pa-banded__row</code></td>
            <td>Flex row container</td>
          </tr>
          <tr>
            <td><code>.pa-banded__label</code></td>
            <td>Fixed-width tinted label (use <code>wr-*</code> utilities to override width)</td>
          </tr>
          <tr>
            <td><code>.pa-banded__value</code></td>
            <td>Flexible value area</td>
          </tr>
          <tr>
            <td><code>.pa-banded-container</code></td>
            <td>Container query wrapper — rows stack vertically when parent is narrow</td>
          </tr>

          <tr><td colspan="2"><strong>Fields Modifiers</strong></td></tr>
          <tr>
            <td><code>.pa-fields--linear</code></td>
            <td>Minimal side-by-side layout with fixed-width labels</td>
          </tr>
          <tr>
            <td><code>.pa-fields--chips</code></td>
            <td>Inline flow with pill-styled values</td>
          </tr>
          <tr>
            <td><code>.pa-field__value--success</code></td>
            <td>Green chip color (use with <code>--chips</code>)</td>
          </tr>
          <tr>
            <td><code>.pa-field__value--warning</code></td>
            <td>Orange chip color</td>
          </tr>
          <tr>
            <td><code>.pa-field__value--danger</code></td>
            <td>Red chip color</td>
          </tr>
          <tr>
            <td><code>.pa-fields-container</code></td>
            <td>Container query wrapper for responsive field layouts</td>
          </tr>

          <tr><td colspan="2"><strong>Accent Grid</strong></td></tr>
          <tr>
            <td><code>.pa-accent-grid</code></td>
            <td>Auto-fill grid of items with color-coded left borders</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__item</code></td>
            <td>Grid item with accent border</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__item--success</code></td>
            <td>Green border</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__item--warning</code></td>
            <td>Orange border</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__item--danger</code></td>
            <td>Red border</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__item--info</code></td>
            <td>Blue border</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__label</code></td>
            <td>Small uppercase label</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__value</code></td>
            <td>Prominent value text</td>
          </tr>

          <tr><td colspan="2"><strong>Copyable (Accent Grid)</strong></td></tr>
          <tr>
            <td><code>.pa-accent-grid__item--copy-btn</code></td>
            <td>Always-visible copy button on accent grid item</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__item--copy-hover</code></td>
            <td>Copy button appears on item hover</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__item--copy-click</code></td>
            <td>Click value to copy, shows hint on hover</td>
          </tr>
          <tr>
            <td><code>.pa-accent-grid__copy</code></td>
            <td>Copy button element inside accent grid value</td>
          </tr>

          <tr><td colspan="2"><strong>Copyable (Banded)</strong></td></tr>
          <tr>
            <td><code>.pa-banded__row--copy-btn</code></td>
            <td>Always-visible copy button on banded row</td>
          </tr>
          <tr>
            <td><code>.pa-banded__row--copy-hover</code></td>
            <td>Copy button appears on row hover</td>
          </tr>
          <tr>
            <td><code>.pa-banded__row--copy-click</code></td>
            <td>Click value to copy, shows hint on hover</td>
          </tr>
          <tr>
            <td><code>.pa-banded__copy</code></td>
            <td>Copy button element inside banded value</td>
          </tr>

          <tr><td colspan="2"><strong>Copyable (Prop Card)</strong></td></tr>
          <tr>
            <td><code>.pa-prop-card__row--copy-btn</code></td>
            <td>Always-visible copy button on prop-card row</td>
          </tr>
          <tr>
            <td><code>.pa-prop-card__row--copy-hover</code></td>
            <td>Copy button appears on row hover</td>
          </tr>
          <tr>
            <td><code>.pa-prop-card__row--copy-click</code></td>
            <td>Click value to copy</td>
          </tr>
          <tr>
            <td><code>.pa-prop-card__copy</code></td>
            <td>Copy button element inside prop-card value</td>
          </tr>

          <tr><td colspan="2"><strong>Copyable (Desc Table)</strong></td></tr>
          <tr>
            <td><code>.pa-desc-table__value--copy-btn</code></td>
            <td>Always-visible copy button on desc-table value cell</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table__value--copy-hover</code></td>
            <td>Copy button appears on value hover</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table__value--copy-click</code></td>
            <td>Click value to copy, shows hint on hover</td>
          </tr>
          <tr>
            <td><code>.pa-desc-table__copy</code></td>
            <td>Copy button element inside desc-table value</td>
          </tr>

          <tr><td colspan="2"><strong>Utilities</strong></td></tr>
          <tr>
            <td><code>.pc-cq</code></td>
            <td>General-purpose container query wrapper (<code>container-type: inline-size</code>)</td>
          </tr>
        </tbody>
      </table>
    </.card>
    """
  end
end
