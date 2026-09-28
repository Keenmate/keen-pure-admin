defmodule DemoWeb.Live.TablesLive do
  use DemoWeb, :live_view

  # -- Basic table data (matches pure-admin reference) --
  @users [
    %{id: 1, name: "John Doe", email: "john.doe@example.com", role: "Admin", status: "Active"},
    %{id: 2, name: "Jane Smith", email: "jane.smith@example.com", role: "User", status: "Pending"},
    %{id: 3, name: "Bob Johnson", email: "bob.johnson@example.com", role: "User", status: "Active"},
    %{id: 4, name: "Alice Brown", email: "alice.brown@example.com", role: "Moderator", status: "Inactive"},
    %{id: 5, name: "Charlie Wilson", email: "charlie.wilson@example.com", role: "User", status: "Active"}
  ]

  @products [
    %{name: "Laptop Pro", category: "Electronics", price: "$1,299.99", stock: 15, status: "In Stock"},
    %{name: "Wireless Mouse", category: "Accessories", price: "$29.99", stock: 0, status: "Out of Stock"},
    %{name: "Office Chair", category: "Furniture", price: "$249.99", stock: 8, status: "In Stock"},
    %{name: "USB Cable", category: "Accessories", price: "$12.99", stock: 3, status: "Low Stock"}
  ]

  @transactions [
    %{date: "2024-01-15", transaction: "Purchase at Store ABC", amount: "-$45.67", amount_class: "text-danger", balance: "$1,234.56"},
    %{date: "2024-01-14", transaction: "Salary Deposit", amount: "+$2,500.00", amount_class: "text-success", balance: "$1,280.23"},
    %{date: "2024-01-13", transaction: "ATM Withdrawal", amount: "-$100.00", amount_class: "text-danger", balance: "-$1,219.77"},
    %{date: "2024-01-12", transaction: "Online Transfer", amount: "-$200.00", amount_class: "text-danger", balance: "-$1,119.77"}
  ]

  # Load more tables data
  @lm_products [
    %{name: "MacBook Pro", price: "$2,399", stock: 12, status: "Available"},
    %{name: "iPhone 15", price: "$999", stock: 0, status: "Out of Stock"},
    %{name: "iPad Air", price: "$599", stock: 8, status: "Available"}
  ]

  @lm_customers [
    %{name: "John Smith", email: "john@example.com", orders: 23, total: "$4,567.89"},
    %{name: "Sarah Johnson", email: "sarah@example.com", orders: 18, total: "$3,245.12"},
    %{name: "Mike Davis", email: "mike@example.com", orders: 31, total: "$6,789.45"}
  ]

  @lm_invoices [
    %{id: "#INV-001", date: "2024-01-15", amount: "$234.56", status: "Paid"},
    %{id: "#INV-002", date: "2024-01-14", amount: "$567.89", status: "Pending"},
    %{id: "#INV-003", date: "2024-01-13", amount: "$123.45", status: "Paid"}
  ]

  # Panel table data
  @panel_products [
    %{name: "Wireless Keyboard", sku: "WK-2024", price: "$79.99", stock: 45},
    %{name: "USB-C Hub", sku: "HUB-7P", price: "$49.99", stock: 120},
    %{name: "Monitor Stand", sku: "MS-ADJ", price: "$129.99", stock: 28}
  ]

  @panel_orders [
    %{id: "#ORD-1001", customer: "Alice Johnson", date: "2024-01-28", total: "$234.50", status: "Shipped"},
    %{id: "#ORD-1002", customer: "Bob Williams", date: "2024-01-27", total: "$89.00", status: "Processing"},
    %{id: "#ORD-1003", customer: "Carol Davis", date: "2024-01-27", total: "$567.25", status: "Delivered"},
    %{id: "#ORD-1004", customer: "David Miller", date: "2024-01-26", total: "$145.00", status: "Cancelled"}
  ]

  @activity_log [
    %{time: "10:45 AM", user: "admin", action: "Updated product pricing"},
    %{time: "10:32 AM", user: "john.doe", action: "Created new order #1005"},
    %{time: "10:15 AM", user: "admin", action: "Approved refund request"}
  ]

  @stats_data [
    %{metric: "Orders", value: "156"},
    %{metric: "Revenue", value: "$12.4k"},
    %{metric: "Refunds", value: "3"}
  ]

  # Table card data
  @card_orders [
    %{id: "#1001", customer: "John Smith", date: "2024-01-28", amount: "$250.00", status: "Completed"},
    %{id: "#1002", customer: "Jane Doe", date: "2024-01-27", amount: "$180.00", status: "Pending"},
    %{id: "#1003", customer: "Bob Wilson", date: "2024-01-26", amount: "$320.00", status: "Completed"}
  ]

  @card_primary [
    %{user: "Alice", role: "Admin", status: "Active"},
    %{user: "Bob", role: "Editor", status: "Active"}
  ]

  @card_success [
    %{task: "Database backup", completed: "10:00 AM"},
    %{task: "Cache cleared", completed: "10:15 AM"}
  ]

  @card_warning [
    %{alert: "High CPU usage", time: "2 min ago"},
    %{alert: "Low disk space", time: "5 min ago"}
  ]

  @card_danger [
    %{error: "Connection timeout", count: 23},
    %{error: "Auth failure", count: 7}
  ]

  @sales_by_region [
    %{region: "North", q1: "$45,000", q2: "$52,000", q3: "$48,000"},
    %{region: "South", q1: "$38,000", q2: "$41,000", q3: "$44,000"},
    %{region: "East", q1: "$62,000", q2: "$58,000", q3: "$65,000"}
  ]

  @top_products [
    %{product: "Widget Pro", units: "1,245", revenue: "$124,500"},
    %{product: "Gadget Plus", units: "892", revenue: "$89,200"},
    %{product: "Tool Master", units: "567", revenue: "$56,700"}
  ]

  @bordered_items [
    %{item: "Widget A", qty: 10, price: "$25.00", total: "$250.00"},
    %{item: "Widget B", qty: 5, price: "$45.00", total: "$225.00"},
    %{item: "Widget C", qty: 8, price: "$30.00", total: "$240.00"}
  ]

  @dept_data [
    %{department: "Engineering", employees: 45, budget: "$2.5M"},
    %{department: "Marketing", employees: 22, budget: "$1.2M"},
    %{department: "Sales", employees: 38, budget: "$1.8M"},
    %{department: "HR", employees: 12, budget: "$0.6M"}
  ]

  @plain_pager_orders [
    %{id: "#1001", customer: "John Smith", date: "2026-01-15", status: "Completed", total: "$245.00"},
    %{id: "#1002", customer: "Jane Doe", date: "2026-01-16", status: "Pending", total: "$189.50"},
    %{id: "#1003", customer: "Bob Wilson", date: "2026-01-17", status: "Completed", total: "$312.75"},
    %{id: "#1004", customer: "Alice Brown", date: "2026-01-18", status: "Cancelled", total: "$78.00"},
    %{id: "#1005", customer: "Charlie Davis", date: "2026-01-19", status: "Completed", total: "$456.25"}
  ]

  # Order detail data
  @order_items [
    %{product: "Wireless Bluetooth Headphones", sku: "WBH-PRO-BK", qty: 1, unit_price: "$149.99", total: "$149.99"},
    %{product: "USB-C Charging Cable (2m)", sku: "USB-C-2M", qty: 2, unit_price: "$19.99", total: "$39.98"},
    %{product: "Carrying Case", sku: "CASE-HP-01", qty: 1, unit_price: "$29.99", total: "$29.99"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Tables",
      users: @users,
      products: @products,
      transactions: @transactions,
      lm_products: @lm_products,
      lm_customers: @lm_customers,
      lm_invoices: @lm_invoices,
      panel_products: @panel_products,
      panel_orders: @panel_orders,
      activity_log: @activity_log,
      stats_data: @stats_data,
      card_orders: @card_orders,
      card_primary: @card_primary,
      card_success: @card_success,
      card_warning: @card_warning,
      card_danger: @card_danger,
      sales_by_region: @sales_by_region,
      top_products: @top_products,
      bordered_items: @bordered_items,
      dept_data: @dept_data,
      plain_pager_orders: @plain_pager_orders,
      order_items: @order_items,
      page: 1,
      total_pages: 10
    )}
  end

  def handle_event("prev-page", _, socket) do
    {:noreply, assign(socket, page: max(1, socket.assigns.page - 1))}
  end

  def handle_event("next-page", _, socket) do
    {:noreply, assign(socket, page: min(socket.assigns.total_pages, socket.assigns.page + 1))}
  end

  def handle_event("first-page", _, socket) do
    {:noreply, assign(socket, page: 1)}
  end

  def handle_event("last-page", _, socket) do
    {:noreply, assign(socket, page: socket.assigns.total_pages)}
  end

  def handle_event("load_more", _, socket), do: {:noreply, socket}

  defp status_variant("Active"), do: "success"
  defp status_variant("Pending"), do: "warning"
  defp status_variant("Inactive"), do: "danger"
  defp status_variant(_), do: nil

  defp stock_variant("In Stock"), do: "success"
  defp stock_variant("Available"), do: "success"
  defp stock_variant("Low Stock"), do: "warning"
  defp stock_variant("Out of Stock"), do: "danger"
  defp stock_variant(_), do: nil

  defp order_variant("Completed"), do: "success"
  defp order_variant("Shipped"), do: "success"
  defp order_variant("Delivered"), do: "success"
  defp order_variant("Processing"), do: "warning"
  defp order_variant("Pending"), do: "warning"
  defp order_variant("Cancelled"), do: "danger"
  defp order_variant("Paid"), do: "success"
  defp order_variant(_), do: nil

  def render(assigns) do
    ~H"""
    <p>Data tables with sorting, pagination, and various styling options.</p>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- Basic Table with Pagination                               --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("Basic Table with Pagination")}>
      <%!-- Pager Above Table (Center) --%>
      <.pager page={@page} total_pages={@total_pages} align="center"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page" />

      <.table_container>
        <.table rows={@users}>
          <:action :let={user}>
            <.button variant="primary" size="xs" is_icon_only title={"View #{user.name}"}>
              <i class="fa-solid fa-eye"></i>
            </.button>
            <.button variant="secondary" size="xs" is_icon_only title={"Edit #{user.name}"}>
              <i class="fa-solid fa-pen"></i>
            </.button>
            <.button variant="danger" size="xs" is_icon_only title={"Delete #{user.name}"}>
              <i class="fa-solid fa-trash"></i>
            </.button>
          </:action>
          <:col :let={user} label={gettext("ID")}>{user.id}</:col>
          <:col :let={user} label={gettext("Name")}>{user.name}</:col>
          <:col :let={user} label={gettext("Email")}>{user.email}</:col>
          <:col :let={user} label={gettext("Role")}>{user.role}</:col>
          <:col :let={user} label={gettext("Status")}>
            <.badge variant={status_variant(user.status)} size="sm">{user.status}</.badge>
          </:col>
        </.table>
      </.table_container>

      <%!-- Pager Below Table (Right) --%>
      <.pager page={@page} total_pages={@total_pages} align="end"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page" />
    </.card>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- Striped Table                                             --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("Striped Table")}>
      <.table_container>
        <.table rows={@products} is_striped>
          <:col :let={p} label={gettext("Product")}>{p.name}</:col>
          <:col :let={p} label={gettext("Category")}>{p.category}</:col>
          <:col :let={p} label={gettext("Price")}>{p.price}</:col>
          <:col :let={p} label={gettext("Stock")}>{p.stock}</:col>
          <:col :let={p} label={gettext("Status")}>
            <.badge variant={stock_variant(p.status)} size="sm">{p.status}</.badge>
          </:col>
        </.table>
      </.table_container>
    </.card>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- 2x Spacing Table                                          --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("2x Spacing Table")}>
      <%!-- Start-aligned pager --%>
      <.pager page={2} total_pages={5} align="start"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page" />

      <.table_container>
        <.table rows={@transactions}>
          <:action :let={t}>
            <.button variant="primary" size="xs" is_icon_only title={"View #{t.transaction}"}>
              <i class="fa-solid fa-eye"></i>
            </.button>
            <.button variant="secondary" size="xs" is_icon_only title={"Edit #{t.transaction}"}>
              <i class="fa-solid fa-pen"></i>
            </.button>
            <.button variant="danger" size="xs" is_icon_only title={"Delete #{t.transaction}"}>
              <i class="fa-solid fa-trash"></i>
            </.button>
          </:action>
          <:col :let={t} label={gettext("Date")}>{t.date}</:col>
          <:col :let={t} label={gettext("Transaction")}>{t.transaction}</:col>
          <:col :let={t} label={gettext("Amount")}><span class={t.amount_class}>{t.amount}</span></:col>
          <:col :let={t} label={gettext("Balance")}>{t.balance}</:col>
        </.table>
      </.table_container>
    </.card>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- Load More Positioning                                     --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("Load More Positioning")}>
      <.heading level={4}>{gettext("Table with Start-aligned Load More")}</.heading>
      <.table_container>
        <.table rows={@lm_products}>
          <:col :let={p} label={gettext("Product")}>{p.name}</:col>
          <:col :let={p} label={gettext("Price")}>{p.price}</:col>
          <:col :let={p} label={gettext("Stock")}>{p.stock}</:col>
          <:col :let={p} label={gettext("Status")}>
            <.badge variant={stock_variant(p.status)} size="sm">{p.status}</.badge>
          </:col>
        </.table>
      </.table_container>
      <.load_more align="start" phx-click="load_more" count="showing 3 of 150">{gettext("Load more products")}</.load_more>

      <.heading level={4} class="mt-4">{gettext("Table with Center Load More")}</.heading>
      <.table_container>
        <.table rows={@lm_customers}>
          <:col :let={c} label={gettext("Customer")}>{c.name}</:col>
          <:col :let={c} label={gettext("Email")}>{c.email}</:col>
          <:col :let={c} label={gettext("Orders")}>{c.orders}</:col>
          <:col :let={c} label={gettext("Total")}>{c.total}</:col>
        </.table>
      </.table_container>
      <.load_more align="center" phx-click="load_more" count="3 of 1,247">{gettext("Load more customers")}</.load_more>

      <.heading level={4} class="mt-4">{gettext("Table with Right Load More (Loading State)")}</.heading>
      <.table_container>
        <.table rows={@lm_invoices}>
          <:col :let={i} label={gettext("Invoice")}>{i.id}</:col>
          <:col :let={i} label={gettext("Date")}>{i.date}</:col>
          <:col :let={i} label={gettext("Amount")}>{i.amount}</:col>
          <:col :let={i} label={gettext("Status")}>
            <.badge variant={order_variant(i.status)} size="sm">{i.status}</.badge>
          </:col>
        </.table>
      </.table_container>
      <.load_more align="end" is_loading phx-click="load_more">{gettext("Loading...")}</.load_more>
    </.card>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- Pager Positioning Examples                                --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("Pager Positioning Examples")}>
      <.heading level={4}>{gettext("Start-aligned Pager")}</.heading>
      <.pager page={1} total_pages={10} align="start"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page" />

      <.heading level={4}>{gettext("Center-aligned Pager (Default)")}</.heading>
      <.pager page={5} total_pages={10} align="center"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page" />

      <.heading level={4}>{gettext("End-aligned Pager")}</.heading>
      <.pager page={10} total_pages={10} align="end"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page" />
    </.card>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- Alternative Pager Icon Sets                               --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("Alternative Pager Icon Sets")}>
      <.heading level={4}>{gettext("Double/Single Angles (Current)")}</.heading>
      <.pager page={1} total_pages={10} align="center"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page" />

      <.heading level={4}>{gettext("Triangular Arrows")}</.heading>
      <.pager page={1} total_pages={10} align="center"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page"
        icon_first="&#x23EE;" icon_previous="&#x25C0;" icon_next="&#x25B6;" icon_last="&#x23ED;" />

      <.heading level={4}>{gettext("Simple Arrows")}</.heading>
      <.pager page={1} total_pages={10} align="center"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page"
        icon_first="&#x21E4;" icon_previous="&#x2190;" icon_next="&#x2192;" icon_last="&#x21E5;" />

      <.heading level={4}>{gettext("Mathematical Double Arrows")}</.heading>
      <.pager page={1} total_pages={10} align="center"
        on_first="first-page" on_last="last-page" on_previous="prev-page" on_next="next-page"
        icon_first="&#x21C7;" icon_previous="&#x21E6;" icon_next="&#x21E8;" icon_last="&#x21C9;" />
    </.card>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- Panel Tables                                              --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("Panel Tables")}>
      <.callout variant="warning" class="mb-4">
        The <.code>--panel</.code> shape (<.code>&lt;.table_container is_panel&gt;</.code>) was
        deprecated in pure-admin-core 2.9.0-rc10 as a near-duplicate of the table card. Use
        <.code>&lt;.table_card&gt;</.code> for any table that needs a header, actions, or footer —
        the examples below now use it.
      </.callout>

      <.heading level={4}>{gettext("Basic Table Card (no header)")}</.heading>
      <.table_card>
        <.table rows={@panel_products}>
          <:col :let={p} label={gettext("Product")}>{p.name}</:col>
          <:col :let={p} label={gettext("SKU")}>{p.sku}</:col>
          <:col :let={p} label={gettext("Price")}>{p.price}</:col>
          <:col :let={p} label={gettext("Stock")}>{p.stock}</:col>
        </.table>
      </.table_card>

      <.heading level={4}>{gettext("Table Card with Header")}</.heading>
      <.table_card title_text={gettext("Recent Orders")}>
        <:actions>
          <.button variant="secondary" size="sm">{gettext("Export")}</.button>
          <.button variant="primary" size="sm">{gettext("Add Order")}</.button>
        </:actions>
        <.table rows={@panel_orders} is_striped>
          <:col :let={o} label={gettext("Order ID")}>{o.id}</:col>
          <:col :let={o} label={gettext("Customer")}>{o.customer}</:col>
          <:col :let={o} label={gettext("Date")}>{o.date}</:col>
          <:col :let={o} label={gettext("Total")}>{o.total}</:col>
          <:col :let={o} label={gettext("Status")}>
            <.badge variant={order_variant(o.status)} size="sm">{o.status}</.badge>
          </:col>
        </.table>
      </.table_card>

      <.heading level={4}>{gettext("Table Cards in Grid (75/25 split)")}</.heading>
      <.paragraph class="mb-4">Table cards work inside grid just like cards.</.paragraph>
    </.card>

    <.grid>
      <.column size="75">
        <.table_card title_text={gettext("Activity Log (75%)")}>
          <.table rows={@activity_log} size="sm">
            <:col :let={row} label={gettext("Time")}>{row.time}</:col>
            <:col :let={row} label={gettext("User")}>{row.user}</:col>
            <:col :let={row} label={gettext("Action")}>{row.action}</:col>
          </.table>
        </.table_card>
      </.column>
      <.column size="25">
        <.table_card title_text={gettext("Stats (25%)")}>
          <.table rows={@stats_data} size="sm">
            <:col :let={row} label={gettext("Metric")}>{row.metric}</:col>
            <:col :let={row} label={gettext("Value")}>{row.value}</:col>
          </.table>
        </.table_card>
      </.column>
    </.grid>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- Table Cards                                               --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("Table Cards")}>
      <.paragraph class="mb-4">The <.code>pa-table-card</.code> component is a card specifically designed for tables. It includes header, body (for the table), footer, and color variants like regular cards.</.paragraph>
      <.heading level={4}>{gettext("Basic Table Card with Actions")}</.heading>
    </.card>

    <.table_card title_text={gettext("Recent Orders")}>
      <:actions>
        <.button variant="secondary" size="sm">{gettext("Export")}</.button>
        <.button variant="primary" size="sm">{gettext("Add Order")}</.button>
      </:actions>
      <.table rows={@card_orders} is_striped>
        <:col :let={o} label={gettext("Order ID")}>{o.id}</:col>
        <:col :let={o} label={gettext("Customer")}>{o.customer}</:col>
        <:col :let={o} label={gettext("Date")}>{o.date}</:col>
        <:col :let={o} label={gettext("Amount")}>{o.amount}</:col>
        <:col :let={o} label={gettext("Status")}>
          <.badge variant={order_variant(o.status)} size="sm">{o.status}</.badge>
        </:col>
      </.table>
      <:footer>
        <span>Showing 3 of 156 orders</span>
        <.button variant="secondary" size="sm">{gettext("View All")}</.button>
      </:footer>
    </.table_card>

    <.card>
      <.heading level={4}>{gettext("Color Variants")}</.heading>
      <.paragraph class="mb-4">Table cards support the same color variants as regular cards: <.code>--primary</.code>, <.code>--success</.code>, <.code>--warning</.code>, <.code>--danger</.code>, and theme colors <.code>--color-1</.code> through <.code>--color-9</.code>.</.paragraph>
    </.card>

    <.grid>
      <.column size="50">
        <.table_card title_text={gettext("Primary Table Card")} variant="primary">
          <:actions><.button variant="light" size="sm">{gettext("Refresh")}</.button></:actions>
          <.table rows={@card_primary} size="sm">
            <:col :let={row} label={gettext("User")}>{row.user}</:col>
            <:col :let={row} label={gettext("Role")}>{row.role}</:col>
            <:col :let={row} label={gettext("Status")}>{row.status}</:col>
          </.table>
        </.table_card>
      </.column>
      <.column size="50">
        <.table_card title_text={gettext("Success Table Card")} variant="success">
          <:actions><.button variant="light" size="sm">{gettext("Export")}</.button></:actions>
          <.table rows={@card_success} size="sm">
            <:col :let={row} label={gettext("Task")}>{row.task}</:col>
            <:col :let={row} label={gettext("Completed")}>{row.completed}</:col>
          </.table>
        </.table_card>
      </.column>
    </.grid>

    <.grid>
      <.column size="50">
        <.table_card title_text={gettext("Warning Table Card")} variant="warning">
          <.table rows={@card_warning} size="sm">
            <:col :let={row} label={gettext("Alert")}>{row.alert}</:col>
            <:col :let={row} label={gettext("Time")}>{row.time}</:col>
          </.table>
        </.table_card>
      </.column>
      <.column size="50">
        <.table_card title_text={gettext("Danger Table Card")} variant="danger">
          <.table rows={@card_danger} size="sm">
            <:col :let={row} label={gettext("Error")}>{row.error}</:col>
            <:col :let={row} label={gettext("Count")}>{row.count}</:col>
          </.table>
        </.table_card>
      </.column>
    </.grid>

    <%!-- Plain Table Cards --%>
    <.card>
      <.heading level={4}>{gettext("Plain Table Cards")}</.heading>
      <.paragraph class="mb-4">Use <.code>pa-table-card--plain</.code> to remove the card visual styling (border, shadow, background) while keeping grid behavior. Tables work side by side with proper gaps.</.paragraph>
    </.card>

    <.grid>
      <.column size="50">
        <.table_card title_text={gettext("Sales by Region")} is_plain>
          <.table rows={@sales_by_region} is_striped>
            <:col :let={row} label={gettext("Region")}>{row.region}</:col>
            <:col :let={row} label={gettext("Q1")}>{row.q1}</:col>
            <:col :let={row} label={gettext("Q2")}>{row.q2}</:col>
            <:col :let={row} label={gettext("Q3")}>{row.q3}</:col>
          </.table>
        </.table_card>
      </.column>
      <.column size="50">
        <.table_card title_text={gettext("Top Products")} is_plain>
          <.table rows={@top_products} is_striped>
            <:col :let={row} label={gettext("Product")}>{row.product}</:col>
            <:col :let={row} label={gettext("Units")}>{row.units}</:col>
            <:col :let={row} label={gettext("Revenue")}>{row.revenue}</:col>
          </.table>
        </.table_card>
      </.column>
    </.grid>

    <.grid>
      <.column size="50">
        <.table_card title_text={gettext("Bordered Table")} is_plain>
          <.table rows={@bordered_items} is_bordered>
            <:col :let={row} label={gettext("Item")}>{row.item}</:col>
            <:col :let={row} label={gettext("Quantity")}>{row.qty}</:col>
            <:col :let={row} label={gettext("Price")}>{row.price}</:col>
            <:col :let={row} label={gettext("Total")}>{row.total}</:col>
          </.table>
        </.table_card>
      </.column>
      <.column size="50">
        <.table_card title_text={gettext("Bordered + Striped")} is_plain>
          <.table rows={@dept_data} is_bordered is_striped>
            <:col :let={row} label={gettext("Department")}>{row.department}</:col>
            <:col :let={row} label={gettext("Employees")}>{row.employees}</:col>
            <:col :let={row} label={gettext("Budget")}>{row.budget}</:col>
          </.table>
        </.table_card>
      </.column>
    </.grid>

    <%!-- Plain Table with Pagers --%>
    <.table_card title_text={gettext("Plain Table with Pagers")} is_plain>
      <:actions>
        <.pager page={1} total_pages={16} align="end" show_page_input={false}
          info_text="Showing 1-10 of 156" on_previous="prev-page" on_next="next-page" />
      </:actions>
      <.table rows={@plain_pager_orders} is_bordered is_striped>
        <:col :let={o} label={gettext("ID")}>{o.id}</:col>
        <:col :let={o} label={gettext("Customer")}>{o.customer}</:col>
        <:col :let={o} label={gettext("Order Date")}>{o.date}</:col>
        <:col :let={o} label={gettext("Status")}>
          <.badge variant={order_variant(o.status)} size="sm">{o.status}</.badge>
        </:col>
        <:col :let={o} label={gettext("Total")}>{o.total}</:col>
      </.table>
      <:footer>
        <.pager page={1} total_pages={16} on_previous="prev-page" on_next="next-page" />
      </:footer>
    </.table_card>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- Real-World Example: Order Detail Layout                   --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("Real-World Example: Order Detail Layout")}>
      <.paragraph class="mb-4">Cards and panel tables side by side — all with consistent visual treatment.</.paragraph>
    </.card>

    <.grid>
      <.column size="50">
        <.card title_text={gettext("Customer Information")}>
          <.fields is_horizontal>
            <.field label={gettext("Name")}>John Smith</.field>
            <.field label={gettext("Email")}>john.smith@example.com</.field>
            <.field label={gettext("Phone")}>+1 (555) 123-4567</.field>
            <.field label={gettext("Customer Since")}>March 2021</.field>
          </.fields>
        </.card>
      </.column>
      <.column size="50">
        <.card title_text={gettext("Delivery Details")}>
          <.fields is_horizontal>
            <.field label={gettext("Address")}>123 Main Street, Apt 4B</.field>
            <.field label={gettext("City")}>New York, NY 10001</.field>
            <.field label={gettext("Delivery Method")}>Express Shipping</.field>
            <.field label={gettext("Est. Delivery")}>Jan 30, 2024</.field>
          </.fields>
        </.card>
      </.column>
    </.grid>

    <.table_card title_text={gettext("Order Items")}>
      <.table rows={@order_items}>
        <:col :let={item} label={gettext("Product")}>{item.product}</:col>
        <:col :let={item} label={gettext("SKU")}>{item.sku}</:col>
        <:col :let={item} label={gettext("Qty")} align="end">{item.qty}</:col>
        <:col :let={item} label={gettext("Unit Price")} align="end">{item.unit_price}</:col>
        <:col :let={item} label={gettext("Total")} align="end">{item.total}</:col>
        <:foot>
          <tr>
            <td colspan="4" class="text-end"><strong>{gettext("Subtotal")}</strong></td>
            <td class="text-end">$219.96</td>
          </tr>
          <tr>
            <td colspan="4" class="text-end"><strong>{gettext("Shipping")}</strong></td>
            <td class="text-end">$12.99</td>
          </tr>
          <tr>
            <td colspan="4" class="text-end"><strong>{gettext("Tax")}</strong></td>
            <td class="text-end">$18.70</td>
          </tr>
          <tr>
            <td colspan="4" class="text-end"><strong>{gettext("Total")}</strong></td>
            <td class="text-end"><strong>$251.65</strong></td>
          </tr>
        </:foot>
      </.table>
    </.table_card>

    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <%!-- CSS Classes Reference                                     --%>
    <%!-- ═══════════════════════════════════════════════════════════ --%>
    <.card title_text={gettext("CSS Classes Reference")}>
      <.heading level={4}>{gettext("Tables")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-table-container</.code> — Bare framed + scrollable wrapper (no header)</li>
        <li><.code>pa-table-card</.code> — Full card with header/body/footer/actions (blessed shape for tables with chrome)</li>
        <li><.code>pa-table-card__body--scrollable</.code> — Horizontal scroll for wide tables inside the card</li>
        <li><.code>pa-table-card--plain</.code> — Table card without the card chrome</li>
        <li><del><.code>pa-table-container--panel</.code></del> — Deprecated (rc10); use <.code>pa-table-card</.code></li>
        <li><.code>pa-table</.code> — Base table class</li>
        <li><.code>pa-table--striped</.code> — Zebra striping on rows</li>
        <li><.code>pa-table--xs</.code> — Extra small padding</li>
        <li><.code>pa-table--sm</.code> — Small padding</li>
        <li><.code>pa-table--lg</.code> — Large padding</li>
        <li><.code>pa-table--xl</.code> — Extra large padding</li>
        <li><.code>pa-table--responsive</.code> — Stacks into cards on mobile</li>
        <li><.code>pa-table--responsive-grid</.code> — CSS grid layout on mobile</li>
        <li><.code>.col-auto</.code> — Auto-width column (shrinks to content)</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Table Cards")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-table-card</.code> — Card wrapper for tables</li>
        <li><.code>pa-table-card--primary / success / warning / danger</.code> — Color variants</li>
        <li><.code>pa-table-card--color-1</.code> through <.code>--color-9</.code> — Theme colors</li>
        <li><.code>pa-table-card--plain</.code> — Remove card styling</li>
        <li><.code>pa-table-card__header</.code> — Card header</li>
        <li><.code>pa-table-card__title</.code> — Title wrapper</li>
        <li><.code>pa-table-card__actions</.code> — Header actions</li>
        <li><.code>pa-table-card__body</.code> — Table body wrapper</li>
        <li><.code>pa-table-card__body--scrollable</.code> — Horizontal scroll</li>
        <li><.code>pa-table-card__footer</.code> — Footer for pagination</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Pager")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-pager</.code> — Pagination container (default: centered)</li>
        <li><.code>pa-pager--start</.code> — Start-aligned</li>
        <li><.code>pa-pager--center</.code> — Center-aligned</li>
        <li><.code>pa-pager--end</.code> — End-aligned</li>
        <li><.code>pa-pager__container</.code> — Inner wrapper (flex)</li>
        <li><.code>pa-pager__controls</.code> — Navigation buttons</li>
        <li><.code>pa-pager__info</.code> — Page input and text</li>
        <li><.code>pa-pager__input</.code> — Page number input</li>
        <li><.code>pa-pager__text</.code> — "/ X pages" text</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Load More")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-load-more</.code> — Load more container (default: centered)</li>
        <li><.code>pa-load-more--start</.code> — Start-aligned</li>
        <li><.code>pa-load-more--center</.code> — Center-aligned</li>
        <li><.code>pa-load-more--end</.code> — End-aligned</li>
        <li><.code>pa-load-more__button</.code> — The button element</li>
        <li><.code>pa-load-more__button--loading</.code> — Loading state</li>
        <li><.code>pa-load-more__spinner</.code> — Spinner element</li>
        <li><.code>pa-load-more__text</.code> — Button text</li>
        <li><.code>pa-load-more__count</.code> — Count display (e.g., "3 of 150")</li>
      </.basic_list>
    </.card>
    """
  end
end
