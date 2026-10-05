defmodule DemoWeb.Live.CheckboxListsLive do
  use DemoWeb, :live_view

  @initial_tasks [
    %{id: "task1", label: "Complete project proposal", checked: false},
    %{id: "task2", label: "Review design mockups", checked: true},
    %{id: "task3", label: "Update documentation", checked: false}
  ]

  @table_data [
    %{id: 1, name: "John Doe", email: "john@example.com", status: "Active", status_variant: "success", checked: false},
    %{id: 2, name: "Jane Smith", email: "jane@example.com", status: "Active", status_variant: "success", checked: true},
    %{id: 3, name: "Bob Johnson", email: "bob@example.com", status: "Pending", status_variant: "warning", checked: false},
    %{id: 4, name: "Alice Williams", email: "alice@example.com", status: "Active", status_variant: "success", checked: true},
    %{id: 5, name: "Charlie Brown", email: "charlie@example.com", status: "Inactive", status_variant: "danger", checked: false}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Checkbox Lists",
      # Card 1: Tri-state
      cb_unchecked: false, cb_checked: true,
      size_xs: true, size_sm: true, size_default: true, size_lg: true, size_xl: true,
      xmark_xs: true, xmark_sm: true, xmark_default: true, xmark_lg: true, xmark_xl: true,
      # Card 2: Select all
      fruit_apple: true, fruit_banana: false, fruit_orange: true, fruit_grape: false,
      # Card 4: Basic lists
      basic_opt1: false, basic_opt2: true, basic_opt3: false, basic_opt4: false,
      feat_email: false, feat_sms: true, feat_push: false,
      # Card 5: States
      state_normal: false, state_disabled: false, state_locked1: false, state_locked2: false, state_normal_selected: true,
      # Card 6: Variants
      compact1: false, compact2: false, compact3: false,
      bordered1: false, bordered2: false, bordered3: false,
      striped1: false, striped2: false, striped3: false, striped4: false,
      # Card 7: Tasks
      tasks: @initial_tasks,
      # Card 8: Layouts
      inline_a: false, inline_b: false, inline_c: false, inline_d: false,
      grid1: false, grid2: false, grid3: false, grid4: false,
      col2_1: false, col2_2: false, col2_3: false, col2_4: false,
      col3_1: false, col3_2: false, col3_3: false, col3_4: false, col3_5: false, col3_6: false,
      # Card 9/10: Table
      table_data: @table_data
    )}
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    key = String.to_existing_atom(id)
    {:noreply, assign(socket, key, !socket.assigns[key])}
  end

  def handle_event("select_all_fruits", _params, socket) do
    all_checked = socket.assigns.fruit_apple && socket.assigns.fruit_banana && socket.assigns.fruit_orange && socket.assigns.fruit_grape
    val = !all_checked
    {:noreply, assign(socket, fruit_apple: val, fruit_banana: val, fruit_orange: val, fruit_grape: val)}
  end

  def handle_event("toggle_task", %{"id" => id}, socket) do
    tasks = Enum.map(socket.assigns.tasks, fn t ->
      if t.id == id, do: %{t | checked: !t.checked}, else: t
    end)
    {:noreply, assign(socket, :tasks, tasks)}
  end

  def handle_event("delete_task", %{"id" => id}, socket) do
    tasks = Enum.reject(socket.assigns.tasks, &(&1.id == id))
    {:noreply, assign(socket, :tasks, tasks)}
  end

  def handle_event("toggle_table_row", %{"id" => id}, socket) do
    id = String.to_integer(id)
    table_data = Enum.map(socket.assigns.table_data, fn row ->
      if row.id == id, do: %{row | checked: !row.checked}, else: row
    end)
    {:noreply, assign(socket, :table_data, table_data)}
  end

  def handle_event("select_all_table", _params, socket) do
    all_checked = Enum.all?(socket.assigns.table_data, & &1.checked)
    table_data = Enum.map(socket.assigns.table_data, &%{&1 | checked: !all_checked})
    {:noreply, assign(socket, :table_data, table_data)}
  end

  defp fruits_checked(assigns) do
    [assigns.fruit_apple, assigns.fruit_banana, assigns.fruit_orange, assigns.fruit_grape]
    |> Enum.count(& &1)
  end

  def render(assigns) do
    assigns = assign(assigns, :fruit_count, fruits_checked(assigns))
    assigns = assign(assigns, :table_selected, Enum.count(assigns.table_data, & &1.checked))

    ~H"""
    <.paragraph>Checkbox lists, tri-state checkboxes, select-all patterns, and table row selection.</.paragraph>

    <%!-- Card 1: Custom Tri-State Checkbox --%>
    <.card title_text={gettext("Custom Tri-State Checkbox")} subtitle_text={gettext("Fully styled custom checkboxes with 3 states: unchecked, checked, and indeterminate")}>
      <.grid>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("Three States")}</.heading>
          <div class="d-flex flex-column gap-12">
            <.checkbox id="unchecked-demo" label_text={gettext("Unchecked")} checked={@cb_unchecked} phx-click="toggle" phx-value-id="cb_unchecked" />
            <.checkbox id="checked-demo" label_text={gettext("Checked")} checked={@cb_checked} phx-click="toggle" phx-value-id="cb_checked" />
            <.checkbox id="indeterminate-demo" label_text={gettext("Indeterminate")} is_indeterminate />
          </div>
        </.column>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("X Mark Modifier")}</.heading>
          <div class="d-flex flex-column gap-12">
            <.checkbox id="xmark-xs" label_text={gettext("Extra Small with X")} size="xs" is_x_mark checked={@xmark_xs} phx-click="toggle" phx-value-id="xmark_xs" />
            <.checkbox id="xmark-sm" label_text={gettext("Small with X")} size="sm" is_x_mark checked={@xmark_sm} phx-click="toggle" phx-value-id="xmark_sm" />
            <.checkbox id="xmark-default" label_text={gettext("Default with X")} is_x_mark checked={@xmark_default} phx-click="toggle" phx-value-id="xmark_default" />
            <.checkbox id="xmark-lg" label_text={gettext("Large with X")} size="lg" is_x_mark checked={@xmark_lg} phx-click="toggle" phx-value-id="xmark_lg" />
            <.checkbox id="xmark-xl" label_text={gettext("Extra Large with X")} size="xl" is_x_mark checked={@xmark_xl} phx-click="toggle" phx-value-id="xmark_xl" />
          </div>
        </.column>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("Size Variants")}</.heading>
          <div class="d-flex flex-column gap-12">
            <.checkbox id="size-xs" label_text={gettext("Extra Small (xs)")} size="xs" checked={@size_xs} phx-click="toggle" phx-value-id="size_xs" />
            <.checkbox id="size-sm" label_text={gettext("Small (sm)")} size="sm" checked={@size_sm} phx-click="toggle" phx-value-id="size_sm" />
            <.checkbox id="size-default" label_text={gettext("Default")} checked={@size_default} phx-click="toggle" phx-value-id="size_default" />
            <.checkbox id="size-lg" label_text={gettext("Large (lg)")} size="lg" checked={@size_lg} phx-click="toggle" phx-value-id="size_lg" />
            <.checkbox id="size-xl" label_text={gettext("Extra Large (xl)")} size="xl" checked={@size_xl} phx-click="toggle" phx-value-id="size_xl" />
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- Card 2: Select All Pattern --%>
    <.card title_text={gettext("Select All Pattern")} subtitle_text={gettext("Interactive demo showing indeterminate state for partial selection")}>
      <.grid>
        <.column size="100" md="50">
          <div class="d-flex flex-column gap-12">
            <.checkbox
              id="select-all-fruits"
              label_text={gettext("Select All Fruits (%{count}/4)", count: @fruit_count)}
              checked={@fruit_count == 4}
              is_indeterminate={@fruit_count > 0 && @fruit_count < 4}
              phx-click="select_all_fruits"
              class="font-weight-500"
            />
            <div class="d-flex flex-column gap-8 ml-10">
              <.checkbox id="fruit-apple" checked={@fruit_apple} phx-click="toggle" phx-value-id="fruit_apple">
                <:label_content>🍎 {gettext("Apple")}</:label_content>
              </.checkbox>
              <.checkbox id="fruit-banana" checked={@fruit_banana} phx-click="toggle" phx-value-id="fruit_banana">
                <:label_content>🍌 {gettext("Banana")}</:label_content>
              </.checkbox>
              <.checkbox id="fruit-orange" checked={@fruit_orange} phx-click="toggle" phx-value-id="fruit_orange">
                <:label_content>🍊 {gettext("Orange")}</:label_content>
              </.checkbox>
              <.checkbox id="fruit-grape" checked={@fruit_grape} phx-click="toggle" phx-value-id="fruit_grape">
                <:label_content>🍇 {gettext("Grape")}</:label_content>
              </.checkbox>
            </div>
          </div>
        </.column>
        <.column size="100" md="50">
          <.alert variant="info">
            <strong>How it works:</strong>
            <.basic_list class="mt-3 mb-0">
              <li>When <strong>none</strong> are selected → "Select All" is unchecked</li>
              <li>When <strong>some</strong> are selected → count shows partial state</li>
              <li>When <strong>all</strong> are selected → "Select All" is checked</li>
            </.basic_list>
          </.alert>
        </.column>
      </.grid>
    </.card>

    <%!-- Card 3: Disabled Checkboxes --%>
    <.card title_text={gettext("Disabled Checkboxes")} subtitle_text={gettext("Disabled state with reduced opacity")}>
      <div class="d-flex flex-wrap gap-2xl">
        <.checkbox id="disabled-unchecked" label_text={gettext("Disabled unchecked")} disabled />
        <.checkbox id="disabled-checked" label_text={gettext("Disabled checked")} disabled checked />
        <.checkbox id="disabled-indeterminate" label_text={gettext("Disabled indeterminate")} disabled is_indeterminate />
      </div>
    </.card>

    <hr class="my-8" />
    <.heading level={2} class="mb-6">{gettext("Checkbox Lists")}</.heading>

    <%!-- Card 4: Basic Checkbox Lists --%>
    <.card title_text={gettext("Basic Checkbox Lists")} subtitle_text={gettext("Simple vertical checkbox lists with hover effects - full item area is clickable")}>
      <.grid>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("Default List")}</.heading>
          <.checkbox_list>
            <.checkbox_list_item id="check1" label_text={gettext("Option 1")} checked={@basic_opt1} phx-click="toggle" phx-value-id="basic_opt1" />
            <.checkbox_list_item id="check2" label_text={gettext("Option 2 (Selected)")} checked={@basic_opt2} phx-click="toggle" phx-value-id="basic_opt2" />
            <.checkbox_list_item id="check3" label_text={gettext("Option 3")} checked={@basic_opt3} phx-click="toggle" phx-value-id="basic_opt3" />
            <.checkbox_list_item id="check4" label_text={gettext("Option 4 (Disabled)")} state="disabled" checked={@basic_opt4} />
          </.checkbox_list>
        </.column>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("With Descriptions")}</.heading>
          <.checkbox_list>
            <.checkbox_list_item id="feature1" label_text={gettext("Email Notifications")} description_text={gettext("Receive updates via email")} checked={@feat_email} phx-click="toggle" phx-value-id="feat_email" />
            <.checkbox_list_item id="feature2" label_text={gettext("SMS Alerts")} description_text={gettext("Get urgent alerts via SMS")} checked={@feat_sms} phx-click="toggle" phx-value-id="feat_sms" />
            <.checkbox_list_item id="feature3" label_text={gettext("Push Notifications")} description_text={gettext("Browser push notifications")} checked={@feat_push} phx-click="toggle" phx-value-id="feat_push" />
          </.checkbox_list>
        </.column>
      </.grid>
    </.card>

    <%!-- Card 5: Item States --%>
    <.card title_text={gettext("Item States")} subtitle_text={gettext("Clickable, disabled, and locked states with different visual feedback")}>
      <.heading level={4}>{gettext("State Comparison")}</.heading>
      <.checkbox_list variant="bordered">
        <.checkbox_list_item id="state1" label_text={gettext("Normal clickable option")} checked={@state_normal} phx-click="toggle" phx-value-id="state_normal" />
        <.checkbox_list_item id="state2" label_text={gettext("Disabled - feature not available")} state="disabled" checked={@state_disabled} />
        <.checkbox_list_item id="state3" label_text={gettext("Requires admin permission")} state="locked" checked={@state_locked1} />
        <.checkbox_list_item id="state4" label_text={gettext("Pro feature - upgrade required")} state="locked" checked={@state_locked2} />
        <.checkbox_list_item id="state5" label_text={gettext("Normal selected option")} checked={@state_normal_selected} phx-click="toggle" phx-value-id="state_normal_selected" />
      </.checkbox_list>

      <.alert variant="info" class="mt-4">
        <small>
          <strong>State differences:</strong><br />
          • <strong>Normal</strong> - Full opacity, pointer cursor, default text color<br />
          • <strong>Disabled</strong> - 50% opacity on entire item, not-allowed cursor<br />
          • <strong>Locked</strong> - 50% opacity on checkbox only, warning color text with 🔒 icon
        </small>
      </.alert>
    </.card>

    <%!-- Card 6: List Variants --%>
    <.card title_text={gettext("List Variants")} subtitle_text={gettext("Different styles for checkbox lists")}>
      <.grid>
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Compact")}</.heading>
          <.checkbox_list variant="compact">
            <.checkbox_list_item id="compact1" label_text={gettext("Compact Option 1")} checked={@compact1} phx-click="toggle" phx-value-id="compact1" />
            <.checkbox_list_item id="compact2" label_text={gettext("Compact Option 2")} checked={@compact2} phx-click="toggle" phx-value-id="compact2" />
            <.checkbox_list_item id="compact3" label_text={gettext("Compact Option 3")} checked={@compact3} phx-click="toggle" phx-value-id="compact3" />
          </.checkbox_list>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Bordered")}</.heading>
          <.checkbox_list variant="bordered">
            <.checkbox_list_item id="bordered1" label_text={gettext("Bordered Option 1")} checked={@bordered1} phx-click="toggle" phx-value-id="bordered1" />
            <.checkbox_list_item id="bordered2" label_text={gettext("Bordered Option 2")} checked={@bordered2} phx-click="toggle" phx-value-id="bordered2" />
            <.checkbox_list_item id="bordered3" label_text={gettext("Bordered Option 3")} checked={@bordered3} phx-click="toggle" phx-value-id="bordered3" />
          </.checkbox_list>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Striped")}</.heading>
          <.checkbox_list variant="striped">
            <.checkbox_list_item id="striped1" label_text={gettext("Striped Option 1")} checked={@striped1} phx-click="toggle" phx-value-id="striped1" />
            <.checkbox_list_item id="striped2" label_text={gettext("Striped Option 2")} checked={@striped2} phx-click="toggle" phx-value-id="striped2" />
            <.checkbox_list_item id="striped3" label_text={gettext("Striped Option 3")} checked={@striped3} phx-click="toggle" phx-value-id="striped3" />
            <.checkbox_list_item id="striped4" label_text={gettext("Striped Option 4")} checked={@striped4} phx-click="toggle" phx-value-id="striped4" />
          </.checkbox_list>
        </.column>
      </.grid>
    </.card>

    <%!-- Card 7: Checkbox Lists with Actions --%>
    <.card title_text={gettext("Checkbox Lists with Actions")} subtitle_text={gettext("Lists with action buttons for each item")}>
      <.heading level={4}>{gettext("Task List")}</.heading>
      <.checkbox_list variant="bordered">
        <.checkbox_list_item
          :for={task <- @tasks}
          id={task.id}
          label_text={task.label}
          checked={task.checked}
          phx-click="toggle_task"
          phx-value-id={task.id}
        >
          <:actions>
            <.button size="xs" variant="secondary" is_icon_only>✏️</.button>
            <.button size="xs" variant="danger" is_icon_only phx-click="delete_task" phx-value-id={task.id}>🗑️</.button>
          </:actions>
        </.checkbox_list_item>
      </.checkbox_list>
    </.card>

    <%!-- Card 8: Alternative Layouts --%>
    <.card title_text={gettext("Alternative Layouts")} subtitle_text={gettext("Inline, grid, and multi-column layouts")}>
      <.heading level={4}>{gettext("Inline Layout")}</.heading>
      <.checkbox_list layout="inline">
        <.checkbox_list_item id="inline1" label_text={gettext("Option A")} checked={@inline_a} phx-click="toggle" phx-value-id="inline_a" />
        <.checkbox_list_item id="inline2" label_text={gettext("Option B")} checked={@inline_b} phx-click="toggle" phx-value-id="inline_b" />
        <.checkbox_list_item id="inline3" label_text={gettext("Option C")} checked={@inline_c} phx-click="toggle" phx-value-id="inline_c" />
        <.checkbox_list_item id="inline4" label_text={gettext("Option D")} checked={@inline_d} phx-click="toggle" phx-value-id="inline_d" />
      </.checkbox_list>

      <.heading level={4} class="mt-6">{gettext("Grid Layout")}</.heading>
      <.checkbox_list layout="grid">
        <.checkbox_list_item id="grid1" label_text={gettext("Grid Item 1")} checked={@grid1} phx-click="toggle" phx-value-id="grid1" />
        <.checkbox_list_item id="grid2" label_text={gettext("Grid Item 2")} checked={@grid2} phx-click="toggle" phx-value-id="grid2" />
        <.checkbox_list_item id="grid3" label_text={gettext("Grid Item 3")} checked={@grid3} phx-click="toggle" phx-value-id="grid3" />
        <.checkbox_list_item id="grid4" label_text={gettext("Grid Item 4")} checked={@grid4} phx-click="toggle" phx-value-id="grid4" />
      </.checkbox_list>

      <.heading level={4} class="mt-6">{gettext("Two-Column Layout")}</.heading>
      <.checkbox_list layout="2col" variant="bordered">
        <.checkbox_list_item id="col2-1" label_text={gettext("Column 1 - Item 1")} checked={@col2_1} phx-click="toggle" phx-value-id="col2_1" />
        <.checkbox_list_item id="col2-2" label_text={gettext("Column 2 - Item 1")} checked={@col2_2} phx-click="toggle" phx-value-id="col2_2" />
        <.checkbox_list_item id="col2-3" label_text={gettext("Column 1 - Item 2")} checked={@col2_3} phx-click="toggle" phx-value-id="col2_3" />
        <.checkbox_list_item id="col2-4" label_text={gettext("Column 2 - Item 2")} checked={@col2_4} phx-click="toggle" phx-value-id="col2_4" />
      </.checkbox_list>

      <.heading level={4} class="mt-6">{gettext("Three-Column Layout")}</.heading>
      <.checkbox_list layout="3col" variant="bordered">
        <.checkbox_list_item id="col3-1" label_text={gettext("Col 1 - Item 1")} checked={@col3_1} phx-click="toggle" phx-value-id="col3_1" />
        <.checkbox_list_item id="col3-2" label_text={gettext("Col 2 - Item 1")} checked={@col3_2} phx-click="toggle" phx-value-id="col3_2" />
        <.checkbox_list_item id="col3-3" label_text={gettext("Col 3 - Item 1")} checked={@col3_3} phx-click="toggle" phx-value-id="col3_3" />
        <.checkbox_list_item id="col3-4" label_text={gettext("Col 1 - Item 2")} checked={@col3_4} phx-click="toggle" phx-value-id="col3_4" />
        <.checkbox_list_item id="col3-5" label_text={gettext("Col 2 - Item 2")} checked={@col3_5} phx-click="toggle" phx-value-id="col3_5" />
        <.checkbox_list_item id="col3-6" label_text={gettext("Col 3 - Item 2")} checked={@col3_6} phx-click="toggle" phx-value-id="col3_6" />
      </.checkbox_list>
    </.card>

    <%!-- Card 9: Tables with Checkboxes --%>
    <.card title_text={gettext("Interactive Table with Checkboxes")} subtitle_text={gettext("Select-all functionality and row selection")}>
      <table class="pa-table pa-table--striped">
        <thead>
          <tr>
            <th class="pa-table__checkbox-col">
              <.checkbox_box id="select-all" checked={@table_selected == length(@table_data)} phx-click="select_all_table" />
            </th>
            <th>Name</th>
            <th>Email</th>
            <th>Status</th>
            <th class="col-auto">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={row <- @table_data} class={if row.checked, do: "pa-table__row--selected"}>
            <td class="pa-table__checkbox-col">
              <.checkbox_box checked={row.checked} phx-click="toggle_table_row" phx-value-id={to_string(row.id)} />
            </td>
            <td><%= row.name %></td>
            <td><%= row.email %></td>
            <td><.badge variant={row.status_variant}><%= row.status %></.badge></td>
            <td class="col-auto">
              <.button_group>
                <.button size="xs" variant="primary" is_icon_only>👁️</.button>
                <.button size="xs" variant="secondary" is_icon_only>✏️</.button>
                <.button size="xs" variant="danger" is_icon_only>🗑️</.button>
              </.button_group>
            </td>
          </tr>
        </tbody>
      </table>
      <:footer>
        <span class="text-sm text-secondary">
          <%= @table_selected %> item<%= if @table_selected != 1, do: "s" %> selected
        </span>
      </:footer>
    </.card>
    """
  end
end
