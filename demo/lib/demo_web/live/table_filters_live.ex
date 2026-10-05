defmodule DemoWeb.Live.TableFiltersLive do
  use DemoWeb, :live_view

  @users [
    %{name: "John Doe", email: "john@example.com", status: "Active"},
    %{name: "Jane Smith", email: "jane@example.com", status: "Active"},
    %{name: "Bob Johnson", email: "bob@example.com", status: "Pending"}
  ]

  @products [
    %{name: "Laptop Pro 15\"", category: "Electronics", price: "$1,299", stock: "In Stock"},
    %{name: "Wireless Mouse", category: "Electronics", price: "$29", stock: "In Stock"},
    %{name: "Office Chair", category: "Furniture", price: "$199", stock: "Out of Stock"}
  ]

  @orders [
    %{id: "#ORD-001", customer: "John Doe", date: "2025-10-10", total: "$150.00", status: "Completed"},
    %{id: "#ORD-002", customer: "Jane Smith", date: "2025-10-09", total: "$75.50", status: "Processing"},
    %{id: "#ORD-003", customer: "Bob Johnson", date: "2025-10-08", total: "$299.99", status: "Completed"}
  ]

  @filtered_products [
    %{name: "Wireless Headphones", category: "Electronics", price: "$79.99", status: "Active"},
    %{name: "Bluetooth Speaker", category: "Electronics", price: "$59.99", status: "Active"},
    %{name: "USB-C Cable", category: "Electronics", price: "$12.99", status: "Active"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Table Filters",
      users: @users,
      products: @products,
      orders: @orders,
      filtered_products: @filtered_products,
      filters_expanded: false
    )}
  end

  def handle_event("toggle-filters", _, socket) do
    {:noreply, assign(socket, filters_expanded: !socket.assigns.filters_expanded)}
  end

  def render(assigns) do
    ~H"""
    <%!-- Basic Search Filter --%>
    <.card>
      <:header>
        <h3>{gettext("Basic Search Filter")}</h3>
      </:header>
      <.grid>
        <.column size="100">
          <.input_wrapper>
            <.input type="text" placeholder={gettext("Search users...")} />
          </.input_wrapper>
        </.column>
      </.grid>
    </.card>

    <.card has_padding={false}>
      <.table rows={@users} is_striped>
        <:action :let={_u}>
          <.button_group>
            <.button size="xs" variant="primary" is_icon_only title="View">👁️</.button>
            <.button size="xs" variant="secondary" is_icon_only title="Edit">✏️</.button>
          </.button_group>
        </:action>
        <:col :let={u} label={gettext("Name")}>{u.name}</:col>
        <:col :let={u} label={gettext("Email")}>{u.email}</:col>
        <:col :let={u} label={gettext("Status")}>
          <.badge variant={status_variant(u.status)} size="sm">{u.status}</.badge>
        </:col>
      </.table>
    </.card>

    <%!-- Expandable Filters --%>
    <.filter_card is_expanded={@filters_expanded} on_toggle="toggle-filters">
      <:filters>
        <.input_group>
          <:prepend>🔍</:prepend>
          <.input type="text" placeholder={gettext("Search by rule")} />
        </.input_group>

        <.input_group>
          <:prepend>🌐</:prepend>
          <.input type="text" placeholder={gettext("Filter by data source")} />
        </.input_group>

        <.input_group>
          <:prepend>🌐</:prepend>
          <.input type="text" placeholder={gettext("Filter by Organization tree")} />
        </.input_group>
      </:filters>

      <:advanced_filters>
        <.grid>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label>{gettext("Category")}</.form_label>
              <.input_wrapper>
                <.select prompt="All Categories" options={["Electronics", "Clothing", "Books"]} />
              </.input_wrapper>
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label>{gettext("Price Range")}</.form_label>
              <.input_wrapper>
                <.select prompt="Any Price" options={["Under $50", "$50 - $100", "$100 - $500", "Over $500"]} />
              </.input_wrapper>
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label>{gettext("Status")}</.form_label>
              <.input_wrapper>
                <.select prompt="All Statuses" options={["In Stock", "Out of Stock", "Pre-order"]} />
              </.input_wrapper>
            </.form_group>
          </.column>
        </.grid>

        <.grid>
          <.column size="100" md="50">
            <.form_group>
              <.form_label>{gettext("Date Range")}</.form_label>
              <.grid>
                <.column size="100" md="50">
                  <.input_wrapper>
                    <.date_input type="date" />
                  </.input_wrapper>
                </.column>
                <.column size="100" md="50">
                  <.input_wrapper>
                    <.date_input type="date" />
                  </.input_wrapper>
                </.column>
              </.grid>
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group>
              <.form_label>{gettext("Supplier")}</.form_label>
              <.input_wrapper>
                <.select prompt="All Suppliers" options={["Supplier A", "Supplier B", "Supplier C"]} />
              </.input_wrapper>
            </.form_group>
          </.column>
        </.grid>
      </:advanced_filters>
    </.filter_card>

    <.card has_padding={false}>
      <.table rows={@products} is_striped>
        <:action :let={_p}>
          <.button_group>
            <.button size="xs" variant="primary" is_icon_only title="View">👁️</.button>
            <.button size="xs" variant="secondary" is_icon_only title="Edit">✏️</.button>
          </.button_group>
        </:action>
        <:col :let={p} label={gettext("Product")}>{p.name}</:col>
        <:col :let={p} label={gettext("Category")}>{p.category}</:col>
        <:col :let={p} label={gettext("Price")}>{p.price}</:col>
        <:col :let={p} label={gettext("Stock")}>
          <.badge variant={stock_variant(p.stock)} size="sm">{p.stock}</.badge>
        </:col>
      </.table>
    </.card>

    <%!-- Inline Horizontal Filters --%>
    <.card>
      <h3>{gettext("Inline Horizontal Filters")}</h3>
      <.paragraph class="text-secondary mb-4">All filters visible in a single row</.paragraph>

      <.grid>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Search")}</.form_label>
            <.input_wrapper>
              <.input type="text" placeholder={gettext("Search...")} />
            </.input_wrapper>
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Status")}</.form_label>
            <.input_wrapper>
              <.select prompt="All" options={["Active", "Inactive"]} />
            </.input_wrapper>
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Type")}</.form_label>
            <.input_wrapper>
              <.select prompt="All Types" options={["Type A", "Type B"]} />
            </.input_wrapper>
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Date")}</.form_label>
            <.input_wrapper>
              <.date_input type="date" />
            </.input_wrapper>
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>&nbsp;</.form_label>
            <.button variant="primary" is_block>{gettext("Filter")}</.button>
          </.form_group>
        </.column>
      </.grid>
    </.card>

    <.card has_padding={false}>
      <.table rows={@orders} is_striped>
        <:col :let={o} label={gettext("Order ID")}>{o.id}</:col>
        <:col :let={o} label={gettext("Customer")}>{o.customer}</:col>
        <:col :let={o} label={gettext("Date")}>{o.date}</:col>
        <:col :let={o} label={gettext("Total")}>{o.total}</:col>
        <:col :let={o} label={gettext("Status")}>
          <.badge variant={order_variant(o.status)} size="sm">{o.status}</.badge>
        </:col>
      </.table>
    </.card>

    <%!-- Filter Tags/Pills --%>
    <.card>
      <:header>
        <h3>{gettext("Active Filter Tags")}</h3>
        <.button_group>
          <.button size="sm" variant="secondary" is_icon_only title="Refresh"><i class="fas fa-sync-alt" /></.button>
          <.button size="sm" variant="secondary" is_icon_only title="Download"><i class="fas fa-download" /></.button>
        </.button_group>
      </:header>

      <.callout variant="info" class="mb-4">Visual representation of applied filters with remove buttons</.callout>

      <.input_wrapper>
        <.input type="text" placeholder={gettext("Search...")} />
      </.input_wrapper>

      <div class="mt-3">
        <strong class="text-sm" style="color: var(--base-text-color-3);">Active Filters:</strong>
        <div class="d-flex gap-5 mt-2 flex-wrap">
          <.composite_badge variant="info" label="Category: Electronics" button_text="×" is_interactive>
            <:icon_content>📁</:icon_content>
          </.composite_badge>
          <.composite_badge variant="success" label="Status: Active" button_text="×" is_interactive>
            <:icon_content>✓</:icon_content>
          </.composite_badge>
          <.composite_badge variant="warning" label="Price: $50-$100" button_text="×" is_interactive>
            <:icon_content>💰</:icon_content>
          </.composite_badge>
          <.button size="xs" variant="secondary">{gettext("Clear All")}</.button>
        </div>
      </div>
    </.card>

    <.card has_padding={false}>
      <.table rows={@filtered_products} is_striped>
        <:col :let={p} label={gettext("Product")}>{p.name}</:col>
        <:col :let={p} label={gettext("Category")}>{p.category}</:col>
        <:col :let={p} label={gettext("Price")}>{p.price}</:col>
        <:col :let={p} label={gettext("Status")}>
          <.badge variant={status_variant(p.status)} size="sm">{p.status}</.badge>
        </:col>
      </.table>
    </.card>
    """
  end

  defp status_variant("Active"), do: "success"
  defp status_variant("Pending"), do: "warning"
  defp status_variant(_), do: nil

  defp stock_variant("In Stock"), do: "success"
  defp stock_variant("Out of Stock"), do: "danger"
  defp stock_variant(_), do: nil

  defp order_variant("Completed"), do: "success"
  defp order_variant("Processing"), do: "warning"
  defp order_variant(_), do: nil
end
