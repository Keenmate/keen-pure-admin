defmodule DemoWeb.Live.TableMultiSelectLive do
  use DemoWeb, :live_view

  @data %{
    "active" => [
      %{id: "u1", name: "John Doe", email: "john@example.com", status: "Active", last_login: "2025-10-13"},
      %{id: "u2", name: "Jane Smith", email: "jane@example.com", status: "Active", last_login: "2025-10-12"},
      %{id: "u3", name: "Mike Johnson", email: "mike@example.com", status: "Active", last_login: "2025-10-11"}
    ],
    "pending" => [
      %{id: "u4", name: "Alice Brown", email: "alice@example.com", status: "Pending", last_login: "2025-09-20"},
      %{id: "u5", name: "Bob Wilson", email: "bob@example.com", status: "Pending", last_login: "2025-09-15"}
    ],
    "archived" => [
      %{id: "u6", name: "Charlie Davis", email: "charlie@example.com", status: "Archived", last_login: "2025-08-05"},
      %{id: "u7", name: "Diana Evans", email: "diana@example.com", status: "Archived", last_login: "2025-07-12"},
      %{id: "u8", name: "Frank Miller", email: "frank@example.com", status: "Archived", last_login: "2025-06-30"}
    ]
  }

  @filter_labels %{
    "active" => "Active Users",
    "pending" => "Pending Users",
    "archived" => "Archived Users"
  }

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Table Multi-Select",
      current_filter: "active",
      selected: %{},
      show_details: false
    )}
  end

  def handle_event("switch-filter", %{"filter" => filter}, socket) do
    {:noreply, assign(socket, current_filter: filter)}
  end

  def handle_event("toggle-row", %{"id" => id}, socket) do
    selected = socket.assigns.selected

    selected =
      if Map.has_key?(selected, id) do
        Map.delete(selected, id)
      else
        item = find_item(id, socket.assigns.current_filter)
        if item, do: Map.put(selected, id, %{item: item, source: @filter_labels[socket.assigns.current_filter]}), else: selected
      end

    {:noreply, assign(socket, selected: selected)}
  end

  def handle_event("select-all-visible", _, socket) do
    rows = @data[socket.assigns.current_filter]
    source = @filter_labels[socket.assigns.current_filter]

    new_selected =
      Enum.reduce(rows, socket.assigns.selected, fn row, acc ->
        Map.put(acc, row.id, %{item: row, source: source})
      end)

    {:noreply, assign(socket, selected: new_selected)}
  end

  def handle_event("deselect-all-visible", _, socket) do
    rows = @data[socket.assigns.current_filter]
    ids = MapSet.new(Enum.map(rows, & &1.id))

    new_selected = Map.reject(socket.assigns.selected, fn {id, _} -> MapSet.member?(ids, id) end)

    {:noreply, assign(socket, selected: new_selected)}
  end

  def handle_event("remove-selected", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected: Map.delete(socket.assigns.selected, id))}
  end

  def handle_event("clear-selection", _, socket) do
    {:noreply, assign(socket, selected: %{}, show_details: false)}
  end

  def handle_event("toggle-details", _, socket) do
    {:noreply, assign(socket, show_details: !socket.assigns.show_details)}
  end

  defp find_item(id, current_filter) do
    Enum.find(@data[current_filter], &(&1.id == id))
  end

  defp visible_rows(filter), do: @data[filter]

  defp filter_count(selected, filter_label) do
    Enum.count(selected, fn {_, %{source: source}} -> source == filter_label end)
  end

  defp all_visible_selected?(selected, filter) do
    rows = @data[filter]
    rows != [] && Enum.all?(rows, &Map.has_key?(selected, &1.id))
  end

  defp some_visible_selected?(selected, filter) do
    rows = @data[filter]
    Enum.any?(rows, &Map.has_key?(selected, &1.id))
  end

  def render(assigns) do
    assigns =
      assigns
      |> assign(:rows, visible_rows(assigns.current_filter))
      |> assign(:filter_labels, @filter_labels)

    ~H"""
    <%!-- Introduction --%>
    <.card>
      <:header>
        <h3>{gettext("Multi-Select Across Different Filters")}</h3>
        <p>Demonstration of maintaining selection state when switching between filters</p>
      </:header>

      <.alert variant="info">
        <:icon>💡</:icon>
        <strong>Use Case:</strong> You need to delete/export multiple items from different filter states.
        <:list>
          <li>Select items from "Active Users" filter</li>
          <li>Switch to "Archived Users" filter</li>
          <li>Select more items from archived list</li>
          <li>Your previous selections are preserved</li>
          <li>View all selected items in the selection panel</li>
        </:list>
      </.alert>

      <.heading level={4} class="mt-4">{gettext("Key Features:")}</.heading>
      <.basic_list>
        <li><strong>Compact Summary Bar:</strong> Shows selection count and actions without pushing content down</li>
        <li><strong>Expandable Details:</strong> Click "Show Details" to see full list of selected items</li>
        <li><strong>Visual Indicators:</strong> Selected rows highlighted in current table view</li>
        <li><strong>Filter Badges:</strong> Shows count of selections per filter tab</li>
        <li><strong>Cross-Filter Selection:</strong> Selections preserved when switching between filters</li>
      </.basic_list>
    </.card>

    <%!-- Filter Tabs --%>
    <.card>
      <:header>
        <.heading level={4}>{gettext("Filter by Status")}</.heading>
      </:header>
      <div class="d-flex gap-5 flex-wrap">
        <.button
          :for={{key, label} <- @filter_labels}
          variant={if @current_filter == key, do: "primary", else: "secondary"}
          phx-click="switch-filter"
          phx-value-filter={key}
        >
          {label} <.badge variant="light">{filter_count(@selected, label)}</.badge>
        </.button>
      </div>
    </.card>

    <%!-- Selection Summary Bar --%>
    <.alert :if={map_size(@selected) > 0} variant="primary" class="d-flex align-items-center">
      <div class="d-flex align-items-center gap-10 flex-1">
        <strong>{map_size(@selected)} items selected</strong>
        <.button size="sm" variant="secondary" phx-click="toggle-details">
          <i class={if @show_details, do: "fas fa-chevron-up", else: "fas fa-chevron-down"} />
          {if @show_details, do: gettext("Hide Details"), else: gettext("Show Details")}
        </.button>
      </div>
      <div class="d-flex gap-5">
        <.button size="sm" variant="primary">
          <i class="fas fa-download" /> {gettext("Export")}
        </.button>
        <.button size="sm" variant="danger">
          <i class="fas fa-trash" /> {gettext("Delete")}
        </.button>
        <.button size="sm" variant="secondary" phx-click="clear-selection">
          <i class="fas fa-times" /> {gettext("Clear All")}
        </.button>
      </div>
    </.alert>

    <%!-- Selection Details (expandable) --%>
    <.card :if={@show_details && map_size(@selected) > 0} has_padding={false}>
      <.table_container>
        <table class="pa-table pa-table--striped">
          <thead>
            <tr>
              <th class="col-auto">{gettext("Actions")}</th>
              <th>{gettext("Name")}</th>
              <th>{gettext("Email")}</th>
              <th>{gettext("Status")}</th>
              <th>{gettext("Source Filter")}</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={{id, %{item: item, source: source}} <- @selected}>
              <td class="col-auto">
                <.button size="xs" variant="danger" is_icon_only title="Remove from selection" phx-click="remove-selected" phx-value-id={id}>
                  <i class="fas fa-times" />
                </.button>
              </td>
              <td>{item.name}</td>
              <td>{item.email}</td>
              <td><.badge variant={status_variant(item.status)} size="sm">{item.status}</.badge></td>
              <td><.badge variant="info" size="sm">{source}</.badge></td>
            </tr>
          </tbody>
        </table>
      </.table_container>
    </.card>

    <%!-- Data Table --%>
    <.card has_padding={false}>
      <:header>
        <h4>
          {@filter_labels[@current_filter]}
          <.badge variant="secondary">{length(@rows)} items</.badge>
        </h4>
        <div class="d-flex gap-5">
          <.button size="sm" variant="secondary" phx-click="select-all-visible">
            <i class="fas fa-check-square" /> {gettext("Select All Visible")}
          </.button>
          <.button size="sm" variant="secondary" phx-click="deselect-all-visible">
            <i class="fas fa-square" /> {gettext("Deselect All Visible")}
          </.button>
        </div>
      </:header>
      <.table_container>
        <table class="pa-table pa-table--striped pa-table--hover">
          <thead>
            <tr>
              <th class="col-auto">
                <.checkbox
                  checked={all_visible_selected?(@selected, @current_filter)}
                  is_indeterminate={some_visible_selected?(@selected, @current_filter) && !all_visible_selected?(@selected, @current_filter)}
                  phx-click={if all_visible_selected?(@selected, @current_filter), do: "deselect-all-visible", else: "select-all-visible"}
                />
              </th>
              <th class="col-auto">{gettext("Actions")}</th>
              <th>{gettext("Name")}</th>
              <th>{gettext("Email")}</th>
              <th>{gettext("Status")}</th>
              <th>{gettext("Last Login")}</th>
            </tr>
          </thead>
          <tbody>
            <tr
              :for={row <- @rows}
              class={if Map.has_key?(@selected, row.id), do: "pa-table__row--selected"}
            >
              <td class="col-auto">
                <.checkbox
                  checked={Map.has_key?(@selected, row.id)}
                  phx-click="toggle-row"
                  phx-value-id={row.id}
                />
              </td>
              <td class="col-auto">
                <.button_group>
                  <.button size="xs" variant="primary" is_icon_only title="View"><i class="fas fa-eye" /></.button>
                  <.button size="xs" variant="secondary" is_icon_only title="Edit"><i class="fas fa-edit" /></.button>
                </.button_group>
              </td>
              <td>{row.name}</td>
              <td>{row.email}</td>
              <td><.badge variant={status_variant(row.status)} size="sm">{row.status}</.badge></td>
              <td>{row.last_login}</td>
            </tr>
          </tbody>
        </table>
      </.table_container>
    </.card>

    <%!-- Implementation Notes --%>
    <.card>
      <:header>
        <.heading level={4}>{gettext("Implementation Notes")}</.heading>
      </:header>

      <.heading level={5}>{gettext("Visual Pattern Components")}</.heading>
      <.ordered_list>
        <li>
          <strong>Selection Summary Bar</strong>
          <.basic_list>
            <li>Appears between filters and data table when items are selected</li>
            <li>Shows selection count and bulk action buttons (Delete, Export, Clear)</li>
            <li>"Show Details" button to expand full list (collapsed by default)</li>
            <li>Uses <.code>pa-alert pa-alert--primary</.code> for visual consistency</li>
          </.basic_list>
        </li>
        <li>
          <strong>Selection Details Table (Expandable)</strong>
          <.basic_list>
            <li>Hidden by default, user can expand via "Show Details" button</li>
            <li>Shows full table of all selected items from all filters</li>
            <li>Includes "Source Filter" column showing where each item was selected</li>
            <li>Individual remove buttons per row for granular control</li>
          </.basic_list>
        </li>
        <li>
          <strong>Filter Tab Badges</strong>
          <.basic_list>
            <li>Each filter tab shows count of selected items from that filter</li>
            <li>Updates in real-time as selections change</li>
          </.basic_list>
        </li>
        <li>
          <strong>Row Highlighting</strong>
          <.basic_list>
            <li>Selected rows have distinct background via <.code>pa-table__row--selected</.code></li>
            <li>Checkboxes remain checked when switching filters</li>
          </.basic_list>
        </li>
        <li>
          <strong>Bulk Selection Controls</strong>
          <.basic_list>
            <li>"Select All Visible" — checks all rows in current filter view</li>
            <li>"Deselect All Visible" — unchecks visible rows (preserves hidden selections)</li>
            <li>Header checkbox with indeterminate state support</li>
          </.basic_list>
        </li>
      </.ordered_list>

      <.heading level={5} class="mt-4">{gettext("LiveView Implementation")}</.heading>
      <.paragraph>This demo uses server-side state management via LiveView assigns:</.paragraph>
      <.basic_list>
        <li>Selection stored as a Map keyed by item ID with item data and source filter</li>
        <li>Filter switching preserves all selections across filter states</li>
        <li>All UI updates happen via standard LiveView event handling</li>
      </.basic_list>

      <.alert variant="warning" class="mt-4">
        <:icon>⚠️</:icon>
        <strong>Note:</strong> For large datasets, consider using LiveView streams and
        paginated selection tracking to avoid loading all items into memory.
      </.alert>
    </.card>
    """
  end

  defp status_variant("Active"), do: "success"
  defp status_variant("Pending"), do: "warning"
  defp status_variant("Archived"), do: "secondary"
  defp status_variant(_), do: nil
end
