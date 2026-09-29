defmodule DemoWeb.Live.TablesResponsiveLive do
  use DemoWeb, :live_view

  @users [
    %{id: "#1001", name: "John Doe", email: "john.doe@example.com", role: "Admin", status: "Active"},
    %{id: "#1002", name: "Jane Smith", email: "jane.smith@example.com", role: "Editor", status: "Pending"},
    %{id: "#1003", name: "Bob Johnson", email: "bob.johnson@example.com", role: "Viewer", status: "Active"},
    %{id: "#1004", name: "Alice Williams", email: "alice.w@example.com", role: "Editor", status: "Inactive"}
  ]

  @products [
    %{name: "MacBook Pro 16\"", category: "Laptops", price: "$2,499.00", stock: "In Stock", rating: "4.8"},
    %{name: "iPhone 15 Pro", category: "Smartphones", price: "$999.00", stock: "Low Stock", rating: "4.9"},
    %{name: "AirPods Pro (2nd gen)", category: "Audio", price: "$249.00", stock: "In Stock", rating: "4.6"},
    %{name: "iPad Air M2", category: "Tablets", price: "$599.00", stock: "Out of Stock", rating: "4.7"}
  ]

  @orders [
    %{id: "#ORD-2501", date: "Oct 23, 2025", customer: "Sarah Connor", items: "3 items", total: "$3,247.00", status: "Delivered"},
    %{id: "#ORD-2502", date: "Oct 22, 2025", customer: "John Matrix", items: "1 item", total: "$999.00", status: "Shipped"},
    %{id: "#ORD-2503", date: "Oct 21, 2025", customer: "Ellen Ripley", items: "5 items", total: "$1,847.00", status: "Processing"},
    %{id: "#ORD-2504", date: "Oct 20, 2025", customer: "Martin Riggs", items: "2 items", total: "$548.00", status: "Cancelled"}
  ]

  @code_add_class ~S"""
  <table class="pa-table pa-table--responsive">
    <!-- table content -->
  </table>
  """

  @code_data_label ~S"""
  <table class="pa-table pa-table--responsive">
    <thead>
      <tr>
        <th>Name</th>
        <th>Email</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td data-label="Name">John Doe</td>
        <td data-label="Email">john@example.com</td>
        <td data-label="Status">
          <span class="pa-badge pa-badge--success">Active</span>
        </td>
      </tr>
    </tbody>
  </table>
  """

  @code_component ~S"""
  <.table rows={@users} is_responsive is_striped>
    <:col :let={row} label="Name">{row.name}</:col>
    <:col :let={row} label="Email">{row.email}</:col>
    <:col :let={row} label="Status">
      <.badge variant="success">{row.status}</.badge>
    </:col>
  </.table>
  """

  @code_in_card ~S"""
  <.table_card title_text="Users">
    <.table rows={@users} is_responsive>
      <:col :let={row} label="Name">{row.name}</:col>
      <:col :let={row} label="Email">{row.email}</:col>
      <:col :let={row} label="Status">
        <.badge variant="success">{row.status}</.badge>
      </:col>
    </.table>
  </.table_card>
  """

  @code_key_points ~S"""
  <%!-- The is_responsive attribute handles data-label automatically --%>
  <.table rows={@data} is_responsive>
    <:col :let={row} label="Column Name">{row.value}</:col>
  </.table>

  <%!-- Combine with table variants --%>
  <.table rows={@data} is_responsive is_striped />
  <.table rows={@data} is_responsive />

  <%!-- Actions column with button groups --%>
  <:action :let={row}>
    <.button_group>
      <.button size="xs">View</.button>
      <.button size="xs">Edit</.button>
    </.button_group>
  </:action>
  """

  @grid_contacts [
    %{first: "Sarah", last: "Johnson", email: "sarah.johnson@company.com", phone: "+1 (555) 123-4567", department: "Engineering", status: "Active"},
    %{first: "Michael", last: "Chen", email: "michael.chen@company.com", phone: "+1 (555) 234-5678", department: "Marketing", status: "Pending"},
    %{first: "Emma", last: "Rodriguez", email: "emma.rodriguez@company.com", phone: "+1 (555) 345-6789", department: "Sales", status: "Active"}
  ]

  @grid_attrs [
    %{attribute: ~S'data-grid="2"', description: "2-column grid on mobile (applies to <tr>)", example: "Name fields side-by-side"},
    %{attribute: ~S'data-grid="3"', description: "3-column grid on mobile (applies to <tr>)", example: "Compact data display"},
    %{attribute: ~S'data-span="2"', description: "Span 2 columns (applies to <td>)", example: "Wider fields"},
    %{attribute: ~S'data-span="3"', description: "Span 3 columns (applies to <td>)", example: "Extra wide fields"},
    %{attribute: ~S'data-span="full"', description: "Span all columns (applies to <td>)", example: "Email, description, status"}
  ]

  @code_grid ~S"""
  <table class="pa-table pa-table--responsive-grid">
    <thead>
      <tr>
        <th>First Name</th>
        <th>Last Name</th>
        <th>Email</th>
        <th>Phone</th>
      </tr>
    </thead>
    <tbody>
      <tr data-grid="2">
        <td data-label="First Name">John</td>
        <td data-label="Last Name">Doe</td>
        <td data-label="Email" data-span="full">john@example.com</td>
        <td data-label="Phone">555-1234</td>
      </tr>
    </tbody>
  </table>
  """

  @scss_vars [
    %{variable: "$table-responsive-breakpoint", default: "768px", description: "Screen width where tables switch to stacked layout"},
    %{variable: "$table-responsive-card-margin", default: "1rem", description: "Space between stacked row cards"},
    %{variable: "$table-responsive-card-padding", default: "0.75rem", description: "Inner padding for each card cell"},
    %{variable: "$table-responsive-label-width", default: "40%", description: "Width allocated for labels in mobile view"},
    %{variable: "$table-responsive-label-font-weight", default: "$font-weight-semibold", description: "Font weight for labels (default: 600)"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Responsive Tables",
      users: @users,
      products: @products,
      orders: @orders,
      scss_vars: @scss_vars,
      grid_contacts: @grid_contacts,
      grid_attrs: @grid_attrs,
      code_add_class: @code_add_class,
      code_data_label: @code_data_label,
      code_component: @code_component,
      code_in_card: @code_in_card,
      code_key_points: @code_key_points,
      code_grid: @code_grid
    )}
  end

  def render(assigns) do
    ~H"""
    <%!-- How It Works --%>
    <.card title_text={gettext("How It Works")}>
      <.grid>
        <.column size="100" md="1-3">
          <.heading level={4} class="mb-2">{gettext("Desktop (>1024px)")}</.heading>
          <.basic_list>
            <li>Standard table layout with columns</li>
            <li>Headers visible at top</li>
            <li>Data in rows and columns</li>
            <li>Full table width displayed</li>
          </.basic_list>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4} class="mb-2">{gettext("Tablet (769px - 1024px)")}</.heading>
          <.basic_list>
            <li>Table becomes horizontally scrollable</li>
            <li>Maintains desktop structure</li>
            <li>Prevents cramped columns</li>
            <li>Smooth scrolling on touch devices</li>
          </.basic_list>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4} class="mb-2">{gettext("Mobile (≤768px)")}</.heading>
          <.basic_list>
            <li>Each row becomes a card</li>
            <li>Headers hidden</li>
            <li>Labels from <.code>data-label</.code></li>
            <li>Label: Value pattern</li>
            <li>Stacked vertically</li>
          </.basic_list>
        </.column>
      </.grid>
      <.alert variant="info" class="mt-4">
        <:heading>Try it:</:heading>
        Resize your browser window to see the responsive behavior:
        <:list>
          <li><strong>1024px → 769px:</strong> Table becomes scrollable (prevents cramping)</li>
          <li><strong>768px and below:</strong> Transforms into stacked cards</li>
        </:list>
      </.alert>
    </.card>

    <%!-- Basic Responsive Table --%>
    <.table_card title_text={gettext("Basic Responsive Table")}>
      <:subtitle>Simple user data table with automatic mobile transformation</:subtitle>
      <.table rows={@users} is_responsive>
        <:col :let={row} label={gettext("ID")}>{row.id}</:col>
        <:col :let={row} label={gettext("Name")}>{row.name}</:col>
        <:col :let={row} label={gettext("Email")}>{row.email}</:col>
        <:col :let={row} label={gettext("Role")}>{row.role}</:col>
        <:col :let={row} label={gettext("Status")}>
          <.badge variant={user_status_variant(row.status)} size="sm">{row.status}</.badge>
        </:col>
      </.table>
    </.table_card>

    <%!-- Product Catalog --%>
    <.table_card title_text={gettext("Product Catalog")}>
      <:subtitle>E-commerce product table with prices and stock status</:subtitle>
      <.table rows={@products} is_responsive is_striped>
        <:action :let={_p}>
          <.button_group>
            <.button size="xs" variant="primary" title="View">👁️</.button>
            <.button size="xs" variant="secondary" title="Edit">✏️</.button>
          </.button_group>
        </:action>
        <:col :let={p} label={gettext("Product")}><strong>{p.name}</strong></:col>
        <:col :let={p} label={gettext("Category")}>{p.category}</:col>
        <:col :let={p} label={gettext("Price")}>{p.price}</:col>
        <:col :let={p} label={gettext("Stock")}>
          <.badge variant={stock_variant(p.stock)} size="sm">{p.stock}</.badge>
        </:col>
        <:col :let={p} label={gettext("Rating")}>{"⭐⭐⭐⭐⭐ (#{p.rating})"}</:col>
      </.table>
    </.table_card>

    <%!-- Recent Orders --%>
    <.table_card title_text={gettext("Recent Orders")}>
      <:subtitle>Order management table with dates, customers, and amounts</:subtitle>
      <.table rows={@orders} is_responsive>
        <:action :let={_o}>
          <.button size="xs" variant="secondary">{gettext("View")}</.button>
        </:action>
        <:col :let={o} label={gettext("Order #")}>{o.id}</:col>
        <:col :let={o} label={gettext("Date")}>{o.date}</:col>
        <:col :let={o} label={gettext("Customer")}>{o.customer}</:col>
        <:col :let={o} label={gettext("Items")}>{o.items}</:col>
        <:col :let={o} label={gettext("Total")}>{o.total}</:col>
        <:col :let={o} label={gettext("Status")}>
          <.badge variant={order_status_variant(o.status)} size="sm">{o.status}</.badge>
        </:col>
      </.table>
    </.table_card>

    <%!-- CSS Grid Custom Layouts --%>
    <.table_card title_text={gettext("CSS Grid Custom Layouts")}>
      <:subtitle>Use <.code>.pa-table--responsive-grid</.code> for custom multi-column mobile layouts</:subtitle>
      <.table rows={@grid_contacts} is_responsive_grid responsive_grid_cols="2" is_striped>
        <:action label={gettext("Actions")}>
          <.button size="xs" variant="primary" title="View">👁️</.button>
          <.button size="xs" variant="secondary" title="Edit">✏️</.button>
        </:action>
        <:col :let={c} label={gettext("First Name")}>{c.first}</:col>
        <:col :let={c} label={gettext("Last Name")}>{c.last}</:col>
        <:col :let={c} label={gettext("Email")} span="full">{c.email}</:col>
        <:col :let={c} label={gettext("Phone")}>{c.phone}</:col>
        <:col :let={c} label={gettext("Department")}>{c.department}</:col>
        <:col :let={c} label={gettext("Status")} span="full">
          <.badge variant={user_status_variant(c.status)} size="sm">{c.status}</.badge>
        </:col>
      </.table>
      <:footer>
        <.alert variant="info">
          <:heading>On mobile:</:heading>
          First name and last name appear side-by-side, email and status span full width, phone and department are on the same row.
        </.alert>
      </:footer>
    </.table_card>

    <%!-- HTML Implementation --%>
    <.card title_text={gettext("HTML Implementation")}>
      <:subtitle>How to make your tables responsive</:subtitle>
      <.heading level={4} class="mb-2">{gettext("1. Add the class modifier")}</.heading>
      <.paragraph class="mb-3">Add <.code>.pa-table--responsive</.code> to your table element:</.paragraph>
      <.code_block language="html" class="mb-4">{@code_add_class}</.code_block>

      <.heading level={4} class="mb-2">{gettext("2. Add data-label attributes")}</.heading>
      <.paragraph class="mb-3">Each <.code>&lt;td&gt;</.code> needs a <.code>data-label</.code> attribute matching its column header:</.paragraph>
      <.code_block language="html" class="mb-4">{@code_data_label}</.code_block>

      <.heading level={4} class="mb-2">{gettext("3. That's it!")}</.heading>
      <.paragraph>The table will automatically transform on screens smaller than 768px. No JavaScript required!</.paragraph>

      <.alert variant="success" class="mt-4">
        <:heading>Pro tip:</:heading>
        Combine with <.code>.pa-table--striped</.code> for better readability on desktop. The striping is automatically disabled on mobile.
      </.alert>

      <hr class="mt-4 mb-4" />

      <.heading level={3} class="mb-3">{gettext("CSS Grid Layout (Advanced)")}</.heading>
      <.paragraph class="mb-3">For more control over mobile layouts, use <.code>.pa-table--responsive-grid</.code> instead:</.paragraph>
      <.code_block language="html" class="mb-4">{@code_grid}</.code_block>

      <.heading level={4} class="mb-2">{gettext("Grid Attributes:")}</.heading>
      <.table rows={@grid_attrs}>
        <:col :let={a} label={gettext("Attribute")}><.code>{a.attribute}</.code></:col>
        <:col :let={a} label={gettext("Description")}>{a.description}</:col>
        <:col :let={a} label={gettext("Example")}>{a.example}</:col>
      </.table>

      <.alert variant="warning" class="mt-4">
        <:heading>Grid vs Simple:</:heading>
        Use <.code>--responsive-grid</.code> when you need custom layouts. Use plain <.code>--responsive</.code> for simple label:value stacking.
      </.alert>
    </.card>

    <%!-- SCSS Variables Reference --%>
    <.card title_text={gettext("Customization Variables")}>
      <:subtitle>SCSS variables for responsive table styling</:subtitle>
      <.table rows={@scss_vars}>
        <:col :let={v} label={gettext("Variable")}><.code>{v.variable}</.code></:col>
        <:col :let={v} label={gettext("Default Value")}><.code>{v.default}</.code></:col>
        <:col :let={v} label={gettext("Description")}>{v.description}</:col>
      </.table>

      <.alert variant="info" class="mt-4">
        <:heading>Customize in your theme:</:heading>
        Override these variables in your theme file to adjust the responsive behavior and styling.
      </.alert>
    </.card>

    <%!-- Testing Tips --%>
    <.card title_text={gettext("Testing Tips")}>
      <.grid>
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Desktop Browser")}</.heading>
          <.basic_list>
            <li>Resize browser window</li>
            <li>Use DevTools device toolbar</li>
            <li>Press F12 → Toggle device toolbar</li>
          </.basic_list>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Real Device")}</.heading>
          <.basic_list>
            <li>Test on actual phones/tablets</li>
            <li>Check both orientations</li>
            <li>Verify touch interactions</li>
          </.basic_list>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Common Breakpoints")}</.heading>
          <.basic_list>
            <li>Mobile: 320px - 767px</li>
            <li>Tablet: 768px - 1023px</li>
            <li>Desktop: 1024px+</li>
          </.basic_list>
        </.column>
      </.grid>
    </.card>

    <%!-- LiveView Component Code Examples --%>
    <.card title_text={gettext("LiveView Component Code Examples")}>
      <.grid>
        <.column size="100" md="50">
          <.heading level={4} class="mb-2">{gettext("Using Table Component")}</.heading>
          <.code_block language="heex">{@code_component}</.code_block>
        </.column>
        <.column size="100" md="50">
          <.heading level={4} class="mb-2">{gettext("Inside a Card")}</.heading>
          <.code_block language="heex">{@code_in_card}</.code_block>
        </.column>
      </.grid>

      <.heading level={4} class="mb-2 mt-4">{gettext("Key Points")}</.heading>
      <.code_block language="heex">{@code_key_points}</.code_block>
    </.card>
    """
  end

  defp user_status_variant("Active"), do: "success"
  defp user_status_variant("Pending"), do: "warning"
  defp user_status_variant("Inactive"), do: "danger"
  defp user_status_variant(_), do: nil

  defp stock_variant("In Stock"), do: "success"
  defp stock_variant("Low Stock"), do: "warning"
  defp stock_variant("Out of Stock"), do: "danger"
  defp stock_variant(_), do: nil

  defp order_status_variant("Delivered"), do: "success"
  defp order_status_variant("Shipped"), do: "primary"
  defp order_status_variant("Processing"), do: "warning"
  defp order_status_variant("Cancelled"), do: "danger"
  defp order_status_variant(_), do: nil
end
