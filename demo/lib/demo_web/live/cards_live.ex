defmodule DemoWeb.Live.CardsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Cards", active_tab: "tab1")}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Flexible content containers for organizing and displaying information.</.paragraph>

    <%!-- Same Height Cards --%>
    <.section title_text={gettext("Same Height Cards")}>
      <.paragraph class="mb-2">
        Use <code>sameHeight</code> on Grid to make all cards in a row match the height of the tallest card.
      </.paragraph>
      <.grid is_same_height>
        <.column size="100" md="1-3">
          <.card title_text={gettext("Short Card")}>
            <.paragraph>This card has minimal content.</.paragraph>
          </.card>
        </.column>
        <.column size="100" md="1-3">
          <.card title_text={gettext("Tall Card")}>
            <.paragraph>This card has much more content than the others, making it naturally taller.</.paragraph>
            <.paragraph>
              All sibling cards will stretch to match this height thanks to the <code>sameHeight</code> prop on Grid.
            </.paragraph>
            <.paragraph>This is useful for dashboard layouts where visual consistency matters.</.paragraph>
          </.card>
        </.column>
        <.column size="100" md="1-3">
          <.card title_text={gettext("Medium Card")}>
            <.paragraph>This card also stretches to match the tallest card in the row.</.paragraph>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Basic Cards --%>
    <.section title_text={gettext("Basic Cards")}>
      <.grid>
        <%!-- Simple Card --%>
        <.column size="100" md="1-2">
          <.card>
            <.heading level={4}>{gettext("Simple Card")}</.heading>
            <.paragraph>This is a basic card with just a body. Perfect for simple content display.</.paragraph>
          </.card>
        </.column>

        <%!-- Card with Header --%>
        <.column size="100" md="1-2">
          <.card>
            <:header>
              <.heading level={4}>{gettext("Card with Header")}</.heading>
            </:header>
            <.paragraph>This card includes a header section for titles and actions.</.paragraph>
          </.card>
        </.column>

        <%!-- Card with Footer --%>
        <.column size="100" md="1-2">
          <.card>
            <.heading level={4}>{gettext("Card with Footer")}</.heading>
            <.paragraph>This card includes a footer section for actions or meta information.</.paragraph>
            <:footer>
              <.button variant="primary" size="sm">{gettext("Action")}</.button>
            </:footer>
          </.card>
        </.column>

        <%!-- Complete Card --%>
        <.column size="100" md="1-2">
          <.card title_text={gettext("Complete Card")}>
            <:tools>
              <.button variant="secondary" size="xs">⚙</.button>
            </:tools>
            <.paragraph>A complete card with header, body, and footer sections.</.paragraph>
            <:footer>
              <span class="pa-card__meta">Updated 2 hours ago</span>
              <div class="pa-card__actions">
                <.button variant="secondary" size="sm">{gettext("Cancel")}</.button>
                <.button variant="primary" size="sm">{gettext("Save")}</.button>
              </div>
            </:footer>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Card Header Three-Part Layout --%>
    <.section title_text={gettext("Card Header Three-Part Layout")}>
      <.paragraph class="mb-2">
        Card headers support a flexible three-part layout: <strong>Title</strong> (fixed), <strong>Description</strong>
        (flexible, truncates), and <strong>Actions</strong> (fixed). Elements are separated by automatic gaps.
      </.paragraph>

      <.grid>
        <%!-- Full three-part layout --%>
        <.column size="100" lg="1-2">
          <.card
            title_text={gettext("User Management")}
            description_text="Manage user accounts, permissions, and access controls for your organization"
          >
            <:tools>
              <.button variant="primary" size="sm">{gettext("Add User")}</.button>
            </:tools>
            <.paragraph>
              Full three-part layout: title stays fixed, description fills available space and truncates with ellipsis, action button stays fixed on the right.
            </.paragraph>
          </.card>
        </.column>

        <%!-- Multiple action buttons --%>
        <.column size="100" lg="1-2">
          <.card
            title_text={gettext("Reports")}
            description_text="Generate and download analytics reports for your dashboard metrics"
          >
            <:tools>
              <.button_group>
                <.button variant="secondary" size="sm">{gettext("Export")}</.button>
                <.button variant="primary" size="sm">{gettext("Generate")}</.button>
              </.button_group>
            </:tools>
            <.paragraph>
              Multiple buttons can be grouped with <code>ButtonGroup</code>. The group stays fixed and won't shrink.
            </.paragraph>
          </.card>
        </.column>

        <%!-- Title + Description only --%>
        <.column size="100" lg="1-2">
          <.card
            title_text={gettext("Settings")}
            description_text="Configure application preferences and system settings"
          >
            <.paragraph>Title + description without actions. The description expands to fill the remaining space.</.paragraph>
          </.card>
        </.column>

        <%!-- Title + Actions only --%>
        <.column size="100" lg="1-2">
          <.card title_text={gettext("Notifications")}>
            <:tools>
              <.button_group>
                <.button variant="secondary" size="sm">{gettext("Mark All Read")}</.button>
                <.button variant="danger" size="sm" is_outline>{gettext("Clear")}</.button>
              </.button_group>
            </:tools>
            <.paragraph>
              Title + actions without description. The gap keeps them separated, and <code>justify-content: space-between</code> pushes actions to the right.
            </.paragraph>
          </.card>
        </.column>
      </.grid>

      <.heading level={4} class="mt-4">{gettext("Long Description Truncation")}</.heading>
      <.paragraph class="mb-2">
        When descriptions are too long, they automatically truncate with ellipsis (...) to maintain a single-line header.
      </.paragraph>

      <.grid>
        <.column size="100" lg="1-2">
          <.card
            title_text={gettext("Analytics")}
            description_text="This is a very long description that explains the analytics dashboard features including real-time metrics, historical data analysis, custom reports, and export functionality for enterprise users"
          >
            <:tools>
              <.button variant="primary" size="sm">{gettext("View")}</.button>
            </:tools>
            <.paragraph>
              The description truncates with ellipsis when it exceeds the available space. Hover or resize to see the effect.
            </.paragraph>
          </.card>
        </.column>

        <.column size="100" lg="1-2">
          <.card
            title_text={gettext("Inventory")}
            description_text="Track stock levels, manage suppliers, process purchase orders, and monitor warehouse capacity across multiple locations"
          >
            <:tools>
              <.button_group>
                <.button variant="secondary" size="sm">{gettext("Import")}</.button>
                <.button variant="secondary" size="sm">{gettext("Export")}</.button>
                <.button variant="primary" size="sm">{gettext("Add Item")}</.button>
              </.button_group>
            </:tools>
            <.paragraph>
              Even with multiple action buttons, the description gracefully truncates to prevent overflow.
            </.paragraph>
          </.card>
        </.column>
      </.grid>

      <.heading level={4} class="mt-4">{gettext("With Tooltip for Full Description")}</.heading>
      <.paragraph class="mb-2">
        Add <code>pa-tooltip pa-tooltip--multiline</code> to the description paragraph to show the full text on hover.
      </.paragraph>

      <.grid>
        <.column size="100" lg="1-2">
          <.card>
            <:header>
              <.heading level={4}>{gettext("Dashboard")}</.heading>
              <.tooltip text="View real-time metrics, KPIs, and performance indicators for your organization. Includes customizable widgets, drill-down reports, and automated alerts." position="bottom" multiline>
                <p>View real-time metrics, KPIs, and performance indicators for your organization. Includes customizable widgets, drill-down reports, and automated alerts.</p>
              </.tooltip>
              <.button variant="primary" size="sm">{gettext("Open")}</.button>
            </:header>
            <.paragraph>Hover over the truncated description to see the full text in a multiline tooltip.</.paragraph>
          </.card>
        </.column>

        <.column size="100" lg="1-2">
          <.card>
            <:header>
              <.heading level={4}>{gettext("Audit Log")}</.heading>
              <.tooltip text="Complete history of system changes, user actions, and security events. Filter by date, user, action type, or resource. Export to CSV for compliance reporting." position="bottom" multiline>
                <p>Complete history of system changes, user actions, and security events. Filter by date, user, action type, or resource. Export to CSV for compliance reporting.</p>
              </.tooltip>
              <.button_group>
                <.button variant="secondary" size="sm">{gettext("Export")}</.button>
                <.button variant="primary" size="sm">{gettext("View")}</.button>
              </.button_group>
            </:header>
            <.paragraph>The tooltip provides full context while keeping the header compact and consistent.</.paragraph>
          </.card>
        </.column>
      </.grid>

      <.heading level={4} class="mt-4">{gettext("Wrap Modifier")}</.heading>
      <.paragraph class="mb-2">
        Use <code>headerWrap</code> when you need the description to wrap onto its own line (useful for mobile or when full description visibility is important).
      </.paragraph>

      <.grid>
        <.column size="100" lg="1-2">
          <.card
            header_wrap
            title_text={gettext("Project Overview")}
            description_text="This card uses the wrap modifier so the description appears on its own line below the title and actions. This is useful when the full description text needs to be visible."
          >
            <:tools>
              <.button_group>
                <.button variant="secondary" size="sm">{gettext("Edit")}</.button>
                <.button variant="primary" size="sm">{gettext("View")}</.button>
              </.button_group>
            </:tools>
            <.paragraph>
              With <code>headerWrap</code>, the description moves to a new line (via <code>flex-basis: 100%</code> and <code>order: 1</code>) and can display multiple lines.
            </.paragraph>
          </.card>
        </.column>

        <.column size="100" lg="1-2">
          <.card
            header_wrap
            title_text={gettext("Documentation")}
            description_text="Complete API reference and integration guides for developers. Includes code samples, authentication flows, and best practices for building with our platform."
          >
            <:tools>
              <.button variant="primary" size="sm">{gettext("Open Docs")}</.button>
            </:tools>
            <.paragraph>
              The wrap modifier is ideal for mobile layouts or when description content is essential to display in full.
            </.paragraph>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Colored Cards --%>
    <.section title_text={gettext("Colored Cards")}>
      <.grid>
        <.column size="100" md="1-2">
          <.card variant="primary">
            <:header><.heading level={4}>{gettext("Primary Card")}</.heading></:header>
            <.paragraph>Card with primary color theme.</.paragraph>
          </.card>
        </.column>
        <.column size="100" md="1-2">
          <.card variant="success">
            <:header><.heading level={4}>{gettext("Success Card")}</.heading></:header>
            <.paragraph>Card with success color theme.</.paragraph>
          </.card>
        </.column>
        <.column size="100" md="1-2">
          <.card variant="warning">
            <:header><.heading level={4}>{gettext("Warning Card")}</.heading></:header>
            <.paragraph>Card with warning color theme.</.paragraph>
          </.card>
        </.column>
        <.column size="100" md="1-2">
          <.card variant="danger">
            <:header><.heading level={4}>{gettext("Danger Card")}</.heading></:header>
            <.paragraph>Card with danger color theme.</.paragraph>
          </.card>
        </.column>
        <%!-- Core has no `pa-card--info` fill variant (only primary/success/
             warning/danger). For a blue-accented card use a theme colour slot
             (see "Theme Color Cards" below) or a header underline. --%>
      </.grid>
    </.section>

    <%!-- Theme Color Cards --%>
    <.section title_text={gettext("Theme Color Cards")}>
      <.paragraph class="mb-2">
        Cards can use theme color slots (color-1 through color-9) for custom color schemes defined by your theme.
      </.paragraph>
      <.grid>
        <.column :for={i <- 1..9} size="100" md="1-3">
          <% card_variant = "color-#{i}" %>
          <.card variant={card_variant}>
            <:header><.heading level={4}>Color <%= i %></.heading></:header>
            <.paragraph>Theme color slot <%= i %></.paragraph>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Bordered Cards --%>
    <.section title_text={gettext("Bordered Cards")}>
      <.paragraph class="mb-2">
        Cards can have visible borders using the <code>pa-card--bordered</code> class.
      </.paragraph>
      <.grid>
        <.column size="100" md="1-2">
          <.card is_bordered title_text={gettext("Bordered Card")}>
            <.paragraph>Card with visible border styling.</.paragraph>
          </.card>
        </.column>
        <.column size="100" md="1-2">
          <.card is_bordered variant="primary" title_text={gettext("Bordered Primary")}>
            <.paragraph>Bordered card with color variant.</.paragraph>
          </.card>
        </.column>
        <.column size="100" md="1-2">
          <.card is_bordered variant="success" title_text={gettext("Bordered Success")}>
            <.paragraph>Bordered card with success variant.</.paragraph>
          </.card>
        </.column>
        <.column size="100" md="1-2">
          <.card is_bordered variant="danger" title_text={gettext("Bordered Danger")}>
            <.paragraph>Bordered card with danger variant.</.paragraph>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Ghost Card --%>
    <.section title_text={gettext("Ghost Card")}>
      <.paragraph class="mb-4">
        Invisible container with no background, border, or shadow. Useful as a layout wrapper that maintains card spacing without visual chrome.
      </.paragraph>
      <.grid>
        <.column size="1-3">
          <.card is_ghost title_text={gettext("Ghost Card")}>
            <.paragraph>No background, no border, no shadow. Just layout structure.</.paragraph>
            <:footer>
              <span class="pa-card__meta">Footer is also transparent</span>
            </:footer>
          </.card>
        </.column>
        <.column size="1-3">
          <.card title_text={gettext("Normal Card")}>
            <.paragraph>Standard card for comparison.</.paragraph>
          </.card>
        </.column>
        <.column size="1-3">
          <.card is_ghost>
            <.paragraph>Ghost card with body only — no header or footer needed.</.paragraph>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Underlined Headers --%>
    <.section title_text={gettext("Underlined Headers")}>
      <.paragraph class="mb-4">
        Add <code>isHeaderUnderlined</code> for an accent border under the heading. Combine with <code>headerUnderlineColor</code>
        for semantic colors or <code>headerUnderlineThemeColor</code> for theme color slots.
      </.paragraph>
      <.grid>
        <.column size="100" sm="50" lg="1-4">
          <.card is_header_underlined title_text={gettext("Default Accent")}>
            <.paragraph>Uses the theme's accent color.</.paragraph>
          </.card>
        </.column>
        <.column size="100" sm="50" lg="1-4">
          <.card is_header_underlined header_underline_color="success" title_text={gettext("Success")}>
            <.paragraph>Green underline for positive context.</.paragraph>
          </.card>
        </.column>
        <.column size="100" sm="50" lg="1-4">
          <.card is_header_underlined header_underline_color="warning" title_text={gettext("Warning")}>
            <.paragraph>Yellow underline for caution.</.paragraph>
          </.card>
        </.column>
        <.column size="100" sm="50" lg="1-4">
          <.card is_header_underlined header_underline_color="danger" title_text={gettext("Danger")}>
            <.paragraph>Red underline for critical items.</.paragraph>
          </.card>
        </.column>
      </.grid>
      <.grid>
        <.column size="100" sm="50" lg="1-4">
          <.card is_header_underlined header_underline_color="info" title_text={gettext("Info")}>
            <.paragraph>Blue underline for informational.</.paragraph>
          </.card>
        </.column>
        <.column size="100" sm="50" lg="1-4">
          <.card is_header_underlined header_class="pa-card__header--underline-color-1" title_text={gettext("Color 1")}>
            <.paragraph>Theme color slot 1.</.paragraph>
          </.card>
        </.column>
        <.column size="100" sm="50" lg="1-4">
          <.card is_header_underlined header_class="pa-card__header--underline-color-3" title_text={gettext("Color 3")}>
            <.paragraph>Theme color slot 3.</.paragraph>
          </.card>
        </.column>
        <.column size="100" sm="50" lg="1-4">
          <.card is_ghost is_header_underlined title_text={gettext("Ghost + Underlined")}>
            <.paragraph>Works with ghost cards too.</.paragraph>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Statistics Cards --%>
    <.section title_text={gettext("Statistics Cards")}>
      <.grid>
        <.column size="100" sm="1-2" lg="1-4">
          <.card variant="stat">
            <.stat number="1,234" label_text={gettext("Total Users")} icon_variant="primary">
              <:icon>👥</:icon>
            </.stat>
          </.card>
        </.column>
        <.column size="100" sm="1-2" lg="1-4">
          <.card variant="stat">
            <.stat number="$45,678" label_text={gettext("Revenue")} icon_variant="success">
              <:icon>📊</:icon>
            </.stat>
          </.card>
        </.column>
        <.column size="100" sm="1-2" lg="1-4">
          <.card variant="stat">
            <.stat number="567" label_text={gettext("Orders")} icon_variant="warning">
              <:icon>📦</:icon>
            </.stat>
          </.card>
        </.column>
        <.column size="100" sm="1-2" lg="1-4">
          <.card variant="stat">
            <.stat number="+12%" label_text={gettext("Growth")} icon_variant="info">
              <:icon>📈</:icon>
            </.stat>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Statistics with Trends --%>
    <.section title_text={gettext("Statistics with Trends")}>
      <.paragraph class="mb-2">
        Stats can display change indicators showing positive, negative, or neutral trends. Note: Change indicators only display when NOT using the icon layout.
      </.paragraph>
      <.grid>
        <.column size="100" sm="1-2" lg="1-3">
          <.card variant="stat">
            <.stat number="1,234" label_text={gettext("Total Users")} change_text="+12.5%" change_direction="positive" />
          </.card>
        </.column>
        <.column size="100" sm="1-2" lg="1-3">
          <.card variant="stat">
            <.stat number="567" label_text={gettext("Orders")} change_text="-5.2%" change_direction="negative" />
          </.card>
        </.column>
        <.column size="100" sm="1-2" lg="1-3">
          <.card variant="stat">
            <.stat number="$89.50" label_text={gettext("Avg Order")} change_text="0%" change_direction="neutral" />
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Interactive Cards --%>
    <.section title_text={gettext("Interactive Cards")}>
      <.grid>
        <%!-- Collapsible Card --%>
        <.column size="100" md="1-2">
          <.card title_text={gettext("Collapsible Card")}>
            <:tools>
              <.button variant="secondary" size="xs">−</.button>
            </:tools>
            <.paragraph>
              This card can be collapsed and expanded. Click the minus/plus button in the header.
            </.paragraph>
            <.paragraph>Content that can be hidden to save space when not needed.</.paragraph>
          </.card>
        </.column>

        <%!-- Card with Tabs --%>
        <.column size="100" md="1-2">
          <.card>
            <:header>
              <.heading level={4}>{gettext("Card with Tabs")}</.heading>
            </:header>
            <:tabs>
              <.card_tab is_active={@active_tab == "tab1"} phx-click="switch_tab" phx-value-tab="tab1">
                {gettext("Overview")}
              </.card_tab>
              <.card_tab is_active={@active_tab == "tab2"} phx-click="switch_tab" phx-value-tab="tab2">
                {gettext("Details")}
              </.card_tab>
              <.card_tab is_active={@active_tab == "tab3"} phx-click="switch_tab" phx-value-tab="tab3">
                {gettext("Settings")}
              </.card_tab>
            </:tabs>
            <.paragraph :if={@active_tab == "tab1"}>Overview content goes here. This is the default active tab.</.paragraph>
            <.paragraph :if={@active_tab == "tab2"}>Detailed information is displayed in this tab.</.paragraph>
            <.paragraph :if={@active_tab == "tab3"}>Settings and configuration options would be shown here.</.paragraph>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Advanced Card Features --%>
    <.section title_text={gettext("Advanced Card Features")}>
      <.grid>
        <%!-- Card with Icon and Tools --%>
        <.column size="100" md="1-2">
          <.card title_text={gettext("Analytics Dashboard Overview")}>
            <:title_icon>📊</:title_icon>
            <:tools>
              <.button variant="secondary" size="xs" title="Refresh">↻</.button>
              <.button variant="secondary" size="xs" title="Settings">⚙</.button>
              <.button variant="secondary" size="xs" title="More options">⋯</.button>
            </:tools>
            <.paragraph>
              This card demonstrates icon in title with tool buttons. The title will truncate with ellipsis when it's too long.
            </.paragraph>
          </.card>
        </.column>

        <%!-- Card with Very Long Title --%>
        <.column size="100" md="1-2">
          <.card title_text="This is a Very Long Card Title That Should Be Truncated With Ellipsis When It Exceeds Available Space">
            <:title_icon>🔒</:title_icon>
            <:tools>
              <.button variant="secondary" size="xs" title="Edit">✏️</.button>
              <.button variant="secondary" size="xs" title="Delete">🗑️</.button>
              <.button variant="secondary" size="xs" title="Export">⬇️</.button>
              <.button variant="secondary" size="xs" title="Share">📤</.button>
            </:tools>
            <.paragraph>
              Notice how the title truncates with ellipsis (...) when there's not enough space due to the tool buttons.
            </.paragraph>
          </.card>
        </.column>

        <%!-- Card with Different Icon Styles --%>
        <.column size="100" md="1-2">
          <.card title_text={gettext("Project Management")}>
            <:title_icon>💼</:title_icon>
            <:tools>
              <.button variant="primary" size="xs">{gettext("+ Add")}</.button>
              <.button variant="secondary" size="xs" title="Filter">🔍</.button>
            </:tools>
            <.paragraph>Different combinations of icons and tool button styles work well together.</.paragraph>
          </.card>
        </.column>

        <%!-- Card with Minimal Tools --%>
        <.column size="100" md="1-2">
          <.card title_text="Revenue Metrics and KPI Tracking System">
            <:title_icon>📈</:title_icon>
            <:tools>
              <.button variant="secondary" size="xs" title="Maximize">⛶</.button>
            </:tools>
            <.paragraph>Even with fewer tools, the title still truncates appropriately to maintain layout.</.paragraph>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- Data Display Cards --%>
    <.section title_text={gettext("Data Display Cards")}>
      <.grid>
        <%!-- Table Card --%>
        <.column size="100" lg="1-2">
          <.card title_text={gettext("Recent Orders")} has_padding={false}>
            <:tools>
              <.button variant="secondary" size="sm">{gettext("View All")}</.button>
            </:tools>
            <.table rows={[
              %{id: "#1234", customer: "John Doe", amount: "$299.99", status: "Completed", status_variant: "success"},
              %{id: "#1235", customer: "Jane Smith", amount: "$149.50", status: "Pending", status_variant: "warning"},
              %{id: "#1236", customer: "Bob Johnson", amount: "$89.99", status: "Processing", status_variant: "info"}
            ]}>
              <:col :let={row} label={gettext("Order ID")}>{row.id}</:col>
              <:col :let={row} label={gettext("Customer")}>{row.customer}</:col>
              <:col :let={row} label={gettext("Amount")}>{row.amount}</:col>
              <:col :let={row} label={gettext("Status")}><.badge variant={row.status_variant}>{row.status}</.badge></:col>
            </.table>
          </.card>
        </.column>

        <%!-- List Card --%>
        <.column size="100" lg="1-2">
          <.card title_text={gettext("Activity Feed")} has_padding={false}>
            <.list>
              <.list_item
                title_text={gettext("User Registration")}
                subtitle_text="New user John Doe registered"
                meta_text="2 minutes ago"
              >
                <:avatar>👤</:avatar>
              </.list_item>
              <.list_item
                title_text={gettext("Payment Received")}
                subtitle_text="$299.99 from Order #1234"
                meta_text="5 minutes ago"
              >
                <:avatar>💰</:avatar>
              </.list_item>
              <.list_item
                title_text={gettext("Order Shipped")}
                subtitle_text="Order #1233 has been shipped"
                meta_text="10 minutes ago"
              >
                <:avatar>📦</:avatar>
              </.list_item>
            </.list>
          </.card>
        </.column>
      </.grid>
    </.section>

    <%!-- CSS Classes Reference --%>
    <.card title_text={gettext("CSS Classes Reference")}>
      <.heading level={4}>Card Base & Sections</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-card</code> - Base card container</li>
        <li><code>pa-card__header</code> - Card header with title/tools</li>
        <li><code>pa-card__body</code> - Card body content area</li>
        <li><code>pa-card__body--no-padding</code> - Remove body padding (for tables)</li>
        <li><code>pa-card__footer</code> - Card footer with actions/meta</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Header Elements</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-card__header</code> - Flexbox header with gap between children</li>
        <li><code>pa-card__header--wrap</code> - Allow description to wrap to new line</li>
        <li><code>h1-h6</code> (direct child) - Title, fixed width, won't shrink</li>
        <li><code>p</code> (direct child) - Description, flexible, truncates with ellipsis</li>
        <li><code>pa-card__title</code> - Title container with icon support</li>
        <li><code>pa-card__title-icon</code> - Icon before title</li>
        <li><code>pa-card__title-text</code> - Title text (auto-truncates)</li>
        <li><code>pa-card__actions</code> - Button/control container (right side, gap + align-center); emitted from the <code>:tools</code> slot</li>
        <li><code>pa-btn-group</code> - Button group in header, fixed width</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Footer Elements</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-card__actions</code> - Action buttons container</li>
        <li><code>pa-card__meta</code> - Meta text (timestamps, etc.)</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Color Variants</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-card--primary</code> - Primary color header</li>
        <li><code>pa-card--success</code> - Success color header</li>
        <li><code>pa-card--warning</code> - Warning color header</li>
        <li><code>pa-card--danger</code> - Danger color header</li>
        <li><code>pa-card--color-1</code> through <code>pa-card--color-9</code> - Theme color slots with automatic contrast text</li>
        <li><code>pa-card--stat</code> - Compact padding for stat cards</li>
        <li><code>pa-card--ghost</code> - Invisible container (no background, border, or shadow)</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Card Tabs</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-card__tabs</code> - Tab navigation container</li>
        <li><code>pa-card__tabs--inline</code> - Inline tabs in header (same height as regular header)</li>
        <li><code>pa-card__tab</code> - Individual tab button</li>
        <li><code>pa-card__tab--active</code> - Active tab state</li>
        <li><code>pa-card__tab-content</code> - Tab content panel</li>
        <li><code>pa-card__tab-content--active</code> - Active content panel</li>
      </.basic_list>

      <.heading level={4} class="mt-4">Section Helpers</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-section</code> - Page section with margin</li>
        <li><code>pa-section-title</code> - Standalone section title with accent border</li>
      </.basic_list>
    </.card>

    <.card title_text="Live-data direction · live_state">
      <:description>
        <code>live_state="up"</code> / <code>"down"</code> tint the card background to reflect the latest tick direction. v2.7.0 migrated the internal SCSS from <code>rgba(--pc-success-bg, X)</code> to <code>color-mix()</code> over the 5-step sentiment scale — wrapper API unchanged. Direction-of-change indicators, distinct from status (<code>--success</code> / etc.).
      </:description>
      <.grid>
        <.column size="1-3">
          <.card live_state="up">
            <.stat variant="hero-compact" number="$847K" label_text={gettext("MRR")} change_text="▲ 12.5%" change_direction="positive" />
          </.card>
        </.column>
        <.column size="1-3">
          <.card live_state="neutral">
            <.stat variant="hero-compact" number="148 ms" label_text={gettext("Latency p95")} change_text="±0.7%" change_direction="neutral" />
          </.card>
        </.column>
        <.column size="1-3">
          <.card live_state="down">
            <.stat variant="hero-compact" number="2.4%" label_text={gettext("Churn")} change_text="▲ 14%" change_direction="negative" />
          </.card>
        </.column>
      </.grid>
    </.card>
    """
  end
end
