defmodule DemoWeb.Live.DataDisplayLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Data Display")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>
      Read-only data display components for showing label-value pairs without form inputs. Useful for profile pages, detail views, order summaries, and anywhere you need to present structured data.
    </.paragraph>

    <%!-- ============================================================
         Row 1: Multiple pa-fields Blocks (50%) | Multi-Column Grid (50%)
         ============================================================ --%>

    <.grid>
      <.column size="1-2">
        <.card title_text={gettext("Multiple pa-fields Blocks")}>
          <:description>Consecutive <code>pa-fields</code> blocks get automatic spacing via <code>.pa-fields + .pa-fields</code>.</:description>

          <.fields is_row>
            <.field label={gettext("First Name")}>Elena</.field>
            <.field label={gettext("Last Name")}>Petrova</.field>
          </.fields>
          <.fields cols="2">
            <.field label={gettext("Date of Birth")}>14 March 1992</.field>
            <.field label={gettext("Role")}>Senior Developer</.field>
            <.field label={gettext("Office")}>Prague, Karlin</.field>
            <.field label={gettext("Start Date")}>1 Sep 2019</.field>
          </.fields>
          <.fields>
            <.field label={gettext("Notes")}>Team lead for the frontend platform team. Available for mentoring.</.field>
          </.fields>
        </.card>
      </.column>

      <.column size="1-2">
        <.card title_text={gettext("Multi-Column Grid")}>
          <:description>Uses <code>pa-fields--cols-2/3/4</code>. Use <code>pa-field--full</code> to span all columns.</:description>

          <.fields cols="2">
            <.field label={gettext("Company")}>Acme Logistics</.field>
            <.field label={gettext("Reg. No.")}>CZ27082440</.field>
            <.field label={gettext("Contact")}>Jan Kratochvil</.field>
            <.field label={gettext("Phone")}>+420 234 567 890</.field>
            <.field label={gettext("Notes")} is_full>Preferred carrier for Central European routes.</.field>
          </.fields>
        </.card>
      </.column>
    </.grid>

    <%!-- ============================================================
         Row 2: Field Groups (100%)
         ============================================================ --%>

    <.card title_text={gettext("Field Groups")}>
      <:description>Labeled sections using <code>pa-field-group</code> with <code>pa-field-group__title</code>.</:description>

      <.grid>
        <.column size="1-3">
          <.field_group title={gettext("Personal")}>
            <.fields>
              <.field label={gettext("Full Name")}>Petra Konecna</.field>
              <.field label={gettext("Date of Birth")}>22 June 1990</.field>
            </.fields>
          </.field_group>
        </.column>

        <.column size="1-3">
          <.field_group title={gettext("Employment")}>
            <.fields>
              <.field label={gettext("Position")}>Product Manager</.field>
              <.field label={gettext("Department")}>Product Dev</.field>
            </.fields>
          </.field_group>
        </.column>

        <.column size="1-3">
          <.field_group title={gettext("Emergency Contact")}>
            <.fields>
              <.field label={gettext("Name")}>Martin Konecny</.field>
              <.field label={gettext("Phone")}>+420 777 888 999</.field>
            </.fields>
          </.field_group>
        </.column>
      </.grid>
    </.card>

    <%!-- ============================================================
         Row 3: Horizontal (1/3) | Table-Style Bordered (1/3) | Striped (1/3)
         ============================================================ --%>

    <.grid>
      <.column size="1-3">
        <.card title_text={gettext("Horizontal")}>
          <:description>Uses <code>pa-fields--horizontal</code>.</:description>

          <.fields is_horizontal>
            <.field label={gettext("Company")}>Acme Corp</.field>
            <.field label={gettext("Reg. No.")}>CZ12345678</.field>
            <.field label={gettext("VAT ID")}>CZ12345678</.field>
            <.field label={gettext("Industry")}>Software</.field>
          </.fields>
        </.card>
      </.column>

      <.column size="1-3">
        <.card title_text={gettext("Table-Style Bordered")}>
          <:description>Uses <code>pa-fields--table pa-fields--bordered</code>.</:description>

          <.fields is_table is_bordered>
            <.field label={gettext("Order ID")}>#ORD-00847</.field>
            <.field label={gettext("Status")}><.badge variant="success">Delivered</.badge></.field>
            <.field label={gettext("Payment")}>Visa *4242</.field>
            <.field label={gettext("Total")}><strong>$1,249</strong></.field>
          </.fields>
        </.card>
      </.column>

      <.column size="1-3">
        <.card title_text={gettext("Striped")}>
          <:description>Uses <code>pa-fields--striped</code>.</:description>

          <.fields is_striped>
            <.field label={gettext("Server")}>prod-api-01</.field>
            <.field label="IP">10.0.12.45</.field>
            <.field label="OS">Ubuntu 22.04</.field>
            <.field label={gettext("Memory")}>16 GB</.field>
          </.fields>
        </.card>
      </.column>
    </.grid>

    <%!-- ============================================================
         Row 4: Compact (25%) | Inline (25%) | Row (25%) | Relaxed (25%)
         ============================================================ --%>

    <.grid>
      <.column size="1-4">
        <.card title_text={gettext("Compact")}>
          <:description><code>pa-fields--compact</code></:description>

          <.fields is_compact>
            <.field label={gettext("Name")}>Martin</.field>
            <.field label={gettext("Role")}>DevOps</.field>
            <.field label={gettext("Team")}>Infra</.field>
          </.fields>
        </.card>
      </.column>

      <.column size="1-4">
        <.card title_text={gettext("Inline")}>
          <:description><code>pa-fields--inline</code></:description>

          <.fields is_inline>
            <.field label={gettext("Browser")}>Chrome</.field>
            <.field label="OS">Win 11</.field>
            <.field label="Lang">en-US</.field>
          </.fields>
        </.card>
      </.column>

      <.column size="1-4">
        <.card title_text={gettext("Row")}>
          <:description><code>pa-fields--row</code></:description>

          <.fields is_row>
            <.field label={gettext("Width")}>120cm</.field>
            <.field label={gettext("Height")}>80cm</.field>
            <.field label={gettext("Depth")}>60cm</.field>
          </.fields>
        </.card>
      </.column>

      <.column size="1-4">
        <.card title_text={gettext("Relaxed")}>
          <:description><code>pa-fields--relaxed</code></:description>

          <.fields is_relaxed>
            <.field label={gettext("Name")}>Elena</.field>
            <.field label={gettext("Role")}>Developer</.field>
          </.fields>
        </.card>
      </.column>
    </.grid>

    <%!-- ============================================================
         Row 5: Filled Fields (75%) | Form vs Display (25%)
         ============================================================ --%>

    <.grid>
      <.column size="3-4">
        <.card title_text={gettext("Filled Fields")}>
          <:description>Subtle background to distinguish data blocks. Uses <code>pa-fields--filled</code>.</:description>

          <.grid>
            <.column size="1-2">
              <.fields is_filled>
                <.field label={gettext("Contract No.")}>CTR-2025-00194</.field>
                <.field label={gettext("Type")}>Framework Agreement</.field>
                <.field label={gettext("Status")}><.badge variant="success">Active</.badge></.field>
              </.fields>
            </.column>
            <.column size="1-2">
              <.fields is_filled is_row>
                <.field label={gettext("Plan")}>Enterprise</.field>
                <.field label={gettext("Renewal")}>1 Jan 2027</.field>
                <.field label={gettext("Seats")}>48 / 50</.field>
              </.fields>
            </.column>
          </.grid>
        </.card>
      </.column>

      <.column size="1-4">
        <.card title_text={gettext("Form vs Display")}>
          <.heading level={4}>{gettext("Edit")}</.heading>
          <.form_group>
            <.form_label>{gettext("Name")}</.form_label>
            <.input type="text" value="Tomas" />
          </.form_group>
          <.heading level={4}>{gettext("View")}</.heading>
          <.fields>
            <.field label={gettext("Name")}>Tomas</.field>
          </.fields>
        </.card>
      </.column>
    </.grid>

    <%!-- ============================================================
         Row 6: Color Variants (100%)
         ============================================================ --%>

    <.card title_text={gettext("Color Variants")}>
      <:description>Theme colors for border and filled background. Uses <code>pa-fields--color-{1-9}</code>. Combine with <code>pa-fields--filled</code> for tinted backgrounds. Use <code>pa-fields--no-border</code> to remove the border.</:description>

      <.heading level={4}>{gettext("Border Colors")}</.heading>
      <.grid>
        <.column size="1-3">
          <.fields color="1">
            <.field label={gettext("Color 1")}>Red / Primary</.field>
          </.fields>
        </.column>
        <.column size="1-3">
          <.fields color="4">
            <.field label={gettext("Color 4")}>Green / Success</.field>
          </.fields>
        </.column>
        <.column size="1-3">
          <.fields color="7">
            <.field label={gettext("Color 7")}>Blue / Info</.field>
          </.fields>
        </.column>
      </.grid>

      <.heading level={4} class="mt-4">{gettext("Filled + Color (Tinted Background)")}</.heading>
      <.grid>
        <.column size="1-3">
          <.fields is_filled color="1">
            <.field label={gettext("Status")}><.badge variant="danger">Error</.badge></.field>
            <.field label={gettext("Message")}>Connection failed</.field>
          </.fields>
        </.column>
        <.column size="1-3">
          <.fields is_filled color="4">
            <.field label={gettext("Status")}><.badge variant="success">Success</.badge></.field>
            <.field label={gettext("Message")}>Order completed</.field>
          </.fields>
        </.column>
        <.column size="1-3">
          <.fields is_filled color="3">
            <.field label={gettext("Status")}><.badge variant="warning">Warning</.badge></.field>
            <.field label={gettext("Message")}>Low inventory</.field>
          </.fields>
        </.column>
      </.grid>

      <.heading level={4} class="mt-4">{gettext("No Border")}</.heading>
      <.grid>
        <.column size="1-2">
          <.fields is_no_border>
            <.field label={gettext("Name")}>Elena Petrova</.field>
            <.field label={gettext("Email")}>elena@acme.com</.field>
          </.fields>
        </.column>
        <.column size="1-2">
          <.fields is_filled is_no_border>
            <.field label={gettext("Name")}>Elena Petrova</.field>
            <.field label={gettext("Email")}>elena@acme.com</.field>
          </.fields>
        </.column>
      </.grid>
    </.card>

    <%!-- ============================================================
         Row 7: Copyable Fields (100%)
         ============================================================ --%>

    <.card title_text={gettext("Copyable Fields")}>
      <:description>Three styles for copy-to-clipboard functionality. Click to test each variant.</:description>

      <.grid>
        <.column size="1-3">
          <.heading level={4}>{gettext("Copy Button (always visible)")}</.heading>
          <p class="text-secondary mb-2">Uses <code>pa-field--copy-btn</code></p>
          <.fields is_no_border>
            <.field label={gettext("Email")} is_copy_btn copy_value="elena.petrova@example.com">elena.petrova@example.com</.field>
            <.field label={gettext("API Key")} is_copy_btn copy_value="sk_live_abc123xyz789"><code>sk_live_abc123xyz789</code></.field>
          </.fields>
        </.column>
        <.column size="1-3">
          <.heading level={4}>{gettext("Click Value to Copy")}</.heading>
          <p class="text-secondary mb-2">Uses <code>pa-field--copy-click</code></p>
          <.fields is_no_border>
            <.field label={gettext("Phone")} is_copy_click copy_value="+420 776 123 456">+420 776 123 456</.field>
            <.field label={gettext("Order ID")} is_copy_click copy_value="ORD-2026-00847">#ORD-2026-00847</.field>
          </.fields>
        </.column>
        <.column size="1-3">
          <.heading level={4}>{gettext("Icon on Hover Only")}</.heading>
          <p class="text-secondary mb-2">Uses <code>pa-field--copy-hover</code></p>
          <.fields is_no_border>
            <.field label="IBAN" is_copy_hover copy_value="CZ65 0800 0000 1920 0014 5399">CZ65 0800 0000 1920 0014 5399</.field>
            <.field label="BIC/SWIFT" is_copy_hover copy_value="GIBACZPX">GIBACZPX</.field>
          </.fields>
        </.column>
      </.grid>
    </.card>

    <%!-- Copy behaviour is wired via `initPureAdminEvents()` in app.js — no inline JS required. --%>

    <%!-- ============================================================
         Row 8: Invoice Layout (100%)
         ============================================================ --%>

    <.card title_text={gettext("Real-World: Invoice Layout")}>
      <:description>Customer (full width) + Receipt/Delivery addresses (50/50). Combines <code>pa-field-group</code> with <code>pc-row</code>/<code>pc-col-*</code>.</:description>

      <.field_group title={gettext("Customer")}>
        <.fields cols="3">
          <.field label={gettext("Name")}>Novak &amp; Partners s.r.o.</.field>
          <.field label={gettext("Registration No.")}>CZ48207497</.field>
          <.field label={gettext("VAT ID")}>CZ48207497</.field>
          <.field label={gettext("Contact")}>Jan Novak</.field>
          <.field label={gettext("Email")}>jan.novak@novakpartners.cz</.field>
          <.field label={gettext("Phone")}>+420 234 111 222</.field>
        </.fields>
      </.field_group>

      <.grid style="margin-top: 2.4rem;">
        <.column size="1-2">
          <.field_group title={gettext("Receipt Address")}>
            <.fields is_filled>
              <.field label={gettext("Street")}>Vinohradska 2468/164</.field>
              <.field label={gettext("City")}>Prague 3, 130 00</.field>
              <.field label={gettext("Country")}>Czech Republic</.field>
            </.fields>
          </.field_group>
        </.column>
        <.column size="1-2">
          <.field_group title={gettext("Delivery Address")}>
            <.fields is_filled>
              <.field label={gettext("Street")}>Prumyslova 1234/5</.field>
              <.field label={gettext("City")}>Brno-Slatina, 627 00</.field>
              <.field label={gettext("Country")}>Czech Republic</.field>
            </.fields>
          </.field_group>
        </.column>
      </.grid>

      <.field_group title={gettext("Items")} style="margin-top: 2.4rem;">
        <.table rows={[
          %{product: "Mechanical Keyboard", sku: "KB-MX-BRN", qty: "2", price: "$149", total: "$298"},
          %{product: "27\" 4K Monitor", sku: "MON-27-4K", qty: "4", price: "$449", total: "$1,796"}
        ]} is_striped>
          <:col :let={row} label={gettext("Product")}>{row.product}</:col>
          <:col :let={row} label="SKU">{row.sku}</:col>
          <:col :let={row} label={gettext("Qty")} align="end">{row.qty}</:col>
          <:col :let={row} label={gettext("Price")} align="end">{row.price}</:col>
          <:col :let={row} label={gettext("Total")} align="end">{row.total}</:col>
        </.table>
      </.field_group>

      <.fields is_horizontal style="max-width: 25rem; margin-left: auto; margin-top: 1.2rem;">
        <.field label={gettext("Subtotal")}>$2,094</.field>
        <.field label="VAT 21%">$439.74</.field>
        <.field label={gettext("Total")} class="pa-field--total" style="border-top: 1px solid; padding-top: 0.8rem;"><strong style="font-size: 1.6rem;">$2,533.74</strong></.field>
      </.fields>
    </.card>

    <%!-- ============================================================
         User Profile (1/3) | CSS Reference (2/3)
         ============================================================ --%>

    <.grid>
      <.column size="1-3">
        <.card title_text={gettext("User Profile")}>
          <div style="text-align: center; margin-bottom: 1.6rem;">
            <div style="width: 64px; height: 64px; border-radius: 50%; background: linear-gradient(135deg, #667eea, #764ba2); margin: 0 auto 0.8rem; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 2rem; font-weight: 600;">EP</div>
            <strong>Elena Petrova</strong><br>
            <.badge variant="success">Active</.badge>
          </div>
          <.field_group title={gettext("Contact")}>
            <.fields is_compact>
              <.field label={gettext("Email")}>elena@acme.com</.field>
              <.field label={gettext("Phone")}>+420 776 123 456</.field>
            </.fields>
          </.field_group>
          <.field_group title={gettext("Skills")}>
            <.fields>
              <.field label={gettext("Skills")}>
                <.badge>TypeScript</.badge>
                <.badge>React</.badge>
                <.badge>Node.js</.badge>
              </.field>
            </.fields>
          </.field_group>
        </.card>
      </.column>

      <.column size="2-3">
        <.card title_text={gettext("CSS Classes Reference")}>
          <.grid>
            <.column size="1-2">
              <.heading level={4}>{gettext("Field Elements")}</.heading>
              <.basic_list spacing="compact">
                <li><code>pa-field</code> - Label-value pair</li>
                <li><code>pa-field__label</code> - Label element</li>
                <li><code>pa-field__value</code> - Value element</li>
                <li><code>pa-field--full</code> - Span all grid columns</li>
              </.basic_list>

              <.heading level={4} class="mt-4">{gettext("Container & Groups")}</.heading>
              <.basic_list spacing="compact">
                <li><code>pa-fields</code> - Field container</li>
                <li><code>pa-field-group</code> - Section wrapper</li>
                <li><code>pa-field-group__title</code> - Section title</li>
              </.basic_list>

              <.heading level={4} class="mt-4">{gettext("Grid Columns")}</.heading>
              <.basic_list spacing="compact">
                <li><code>pa-fields--cols-2</code> - 2 columns</li>
                <li><code>pa-fields--cols-3</code> - 3 columns</li>
                <li><code>pa-fields--cols-4</code> - 4 columns</li>
              </.basic_list>
            </.column>
            <.column size="1-2">
              <.heading level={4}>{gettext("Layout Modifiers")}</.heading>
              <.basic_list spacing="compact">
                <li><code>pa-fields--horizontal</code> - Label left, value right</li>
                <li><code>pa-fields--table</code> - Table-like widths</li>
                <li><code>pa-fields--bordered</code> - Row separators</li>
                <li><code>pa-fields--striped</code> - Alternating bg</li>
                <li><code>pa-fields--compact</code> - Tighter spacing</li>
                <li><code>pa-fields--relaxed</code> - Larger spacing</li>
                <li><code>pa-fields--inline</code> - Inline flow</li>
                <li><code>pa-fields--row</code> - Equal-width columns</li>
                <li><code>pa-fields--filled</code> - Background panel</li>
                <li><code>pa-fields--color-{1-9}</code> - Border color</li>
                <li><code>pa-fields--no-border</code> - Remove border</li>
              </.basic_list>

              <.heading level={4} class="mt-4">{gettext("Combining")}</.heading>
              <.basic_list spacing="compact">
                <li><code>--table --bordered</code></li>
                <li><code>--horizontal --compact</code></li>
                <li><code>--filled --cols-2</code></li>
                <li><code>--filled --color-1</code> (tinted bg)</li>
              </.basic_list>
            </.column>
          </.grid>
        </.card>
      </.column>
    </.grid>
    """
  end
end
