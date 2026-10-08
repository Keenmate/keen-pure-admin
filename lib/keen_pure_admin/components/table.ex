defmodule PureAdmin.Components.Table do
  @moduledoc """
  Table components for Pure Admin.

  Provides `table/1`, `table_container/1`, and `table_card/1`.
  """
  use Phoenix.Component

  import PureAdmin.Helpers
  # Header select-all checkbox reuses the canonical checkbox (indeterminate needs
  # its PureAdminCheckbox hook). Row checkboxes are hand-written (they need
  # phx-value-id, which checkbox/1's :rest allowlist doesn't pass through).
  import PureAdmin.Components.Form, only: [checkbox: 1]

  @doc """
  Renders a data table with Pure Admin BEM classes.

  Accepts rows and column definitions via slots, following Phoenix conventions.

  ## Examples

      <.table rows={@users} is_striped>
        <:col :let={user} label="Name"><%= user.name %></:col>
        <:col :let={user} label="Email"><%= user.email %></:col>
        <:action :let={user}>
          <.button variant="primary" size="xs">Edit</.button>
        </:action>
      </.table>
  """
  attr(:id, :string, default: nil)

  attr(:rows, :list,
    default: [],
    doc:
      "List of row data. Omit (with no `:col` slots) to use the container-only shape — " <>
        "a bare `<table class=\"pa-table\">` whose `<thead>`/`<tbody>` you hand-author in " <>
        "`inner_block`, exactly as core's `snippets/tables.html` blesses."
  )
  attr(:row_id, :any, default: nil, doc: "Function to generate row id from row data")
  attr(:row_click, :any, default: nil, doc: "JS command for row click")
  attr(:is_striped, :boolean, default: false, doc: "Alternating row colors")
  # Note: former `is_hover` / `is_borderless` attrs emitted `pa-table--hover` /
  # `pa-table--borderless`, neither of which exists in core. Row hover is ON by
  # DEFAULT (`.pa-table tbody tr:hover`), and the default table is already
  # borderless (`pa-table--bordered` is the opt-in). Both attrs were no-ops and
  # were dropped.
  attr(:is_bordered, :boolean, default: false, doc: "Full cell borders on all sides")

  attr(:is_plain, :boolean,
    default: false,
    doc:
      "Neutral ruled table (`pa-table--plain`): strips the themed header fill and body/stripe backgrounds so the table reads as a plain ruled grid (paper forms, printouts, embedded sheet grids). Combine with `is_bordered` for cell rules."
  )

  attr(:is_compact, :boolean, default: false, doc: "Compact table (reduced padding)")

  attr(:is_responsive, :boolean,
    default: false,
    doc:
      "Mobile row→card transform (`pa-table--responsive`). Each value cell auto-emits " <>
        "`data-label` from its `:col` `label`, so the mobile card labels render — no hand-authoring."
  )

  attr(:is_responsive_grid, :boolean,
    default: false,
    doc:
      "Mobile CSS-Grid collapse (`pa-table--responsive-grid`). Each `<tr>` gets `data-grid` " <>
        "(see `responsive_grid_cols`); cells auto-emit `data-label`, and a `:col` `span` emits `data-span`."
  )

  attr(:responsive_grid_cols, :string,
    default: nil,
    values: [nil, "2", "3"],
    doc:
      "With `is_responsive_grid`: the mobile grid column count, emitted as `data-grid` on each `<tr>` " <>
        "(nil = auto-fit bare `data-grid`; \"2\"/\"3\" = preset column counts)."
  )

  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])

  attr(:selectable, :boolean,
    default: false,
    doc:
      "Render a leading checkbox column (`pa-table__checkbox-col`): a select-all box in the header " <>
        "and a per-row box. Wire `on_row_select` / `on_select_all` + `row_selected` / `select_id`."
  )

  attr(:row_selected, :any,
    default: nil,
    doc: "Fn `(row -> boolean)` — marks a row `pa-table__row--selected` and checks its box."
  )

  attr(:select_id, :any,
    default: nil,
    doc:
      "Fn `(row -> value)` for the row checkbox's `phx-value-id` (sent with `on_row_select`). " <>
        "Falls back to `row_id` when unset."
  )

  attr(:on_row_select, :string, default: nil, doc: "`phx-click` event on a row checkbox (sends `phx-value-id`).")
  attr(:on_select_all, :string, default: nil, doc: "`phx-click` event on the header select-all checkbox.")
  attr(:all_selected, :boolean, default: false, doc: "Header checkbox checked state (all rows selected).")

  attr(:some_selected, :boolean,
    default: false,
    doc: "Header checkbox indeterminate state (some — but not all — rows selected)."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block,
    doc:
      "Container-only body: hand-authored `<thead>`/`<tbody>` markup. Used ONLY when no " <>
        "`:col` slots are given — then `table/1` renders a bare `<table class=\"pa-table\">` " <>
        "around this slot (the core-blessed shape where the consumer writes the rows). When " <>
        "`:col` slots ARE present, the data-driven thead/tbody is generated and this is ignored."
  )

  slot :col, doc: "Column definitions" do
    attr(:label, :string, required: true)
    attr(:class, :string)
    attr(:col_class, :string, doc: "Class for th/td (e.g. col-auto)")
    attr(:align, :string, doc: "Text alignment (start, center, end)")

    attr(:span, :string,
      doc: "Responsive-grid cell span — \"2\", \"3\", or \"full\" (emits `data-span` on the `<td>`)."
    )
  end

  slot :action, doc: "Action column" do
    attr(:label, :string)
    attr(:class, :string)
  end

  slot(:foot, doc: "Table footer rows (tfoot content)")

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    # `is_responsive` is expressed entirely by the `pa-table--responsive`
    # modifier on the <table> (the mobile row→card transform). No wrapper is
    # needed — the old `.pa-table-responsive` div had no upstream CSS.
    #
    # Two shapes share the one `pa-table` block:
    #   • data-driven (the default) — `:col` slots generate thead/tbody.
    #   • container-only — NO `:col` slots: render a bare `<table class="pa-table">`
    #     around `inner_block`, where the consumer hand-authors thead/tbody (the
    #     shape core's `snippets/tables.html` leads with). Same class contract, so
    #     every `pa-table--*` modifier still applies.
    ~H"""
    <.table_container_only :if={@col == []} {assigns} />
    <.table_inner :if={@col != []} {assigns} />
    """
  end

  defp table_container_only(assigns) do
    ~H"""
    <table id={@id} class={table_classes(assigns)} {@rest}>{render_slot(@inner_block)}</table>
    """
  end

  defp table_inner(assigns) do
    ~H"""
    <table id={@id} class={table_classes(assigns)} {@rest}>
      <thead>
        <tr>
          <th :if={@selectable} class="pa-table__checkbox-col">
            <.checkbox
              checked={@all_selected}
              is_indeterminate={@some_selected && !@all_selected}
              phx-click={@on_select_all}
            />
          </th>
          <th :for={action <- @action} class={action[:class] || "col-auto"}><%= action[:label] %></th>
          <th :for={col <- @col} class={col_header_class(col)}><%= col[:label] %></th>
        </tr>
      </thead>
      <tbody id={@id && "#{@id}-body"} phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}>
        <tr
          :for={row <- @rows}
          id={@row_id && @row_id.(row)}
          class={@row_selected && @row_selected.(row) && "pa-table__row--selected"}
          phx-click={@row_click && @row_click.(row)}
          data-grid={@is_responsive_grid && (@responsive_grid_cols || "")}
        >
          <td :if={@selectable} class="pa-table__checkbox-col">
            <label class="pa-checkbox">
              <input
                type="checkbox"
                checked={@row_selected && @row_selected.(row)}
                phx-click={@on_row_select}
                phx-value-id={select_value(assigns, row)}
              />
              <span class="pa-checkbox__box"></span>
            </label>
          </td>
          <td
            :for={action <- @action}
            class={action[:class] || "col-auto"}
            data-label={(@is_responsive || @is_responsive_grid) && action[:label]}
          >
            <div class="pa-btn-group">
              <%= render_slot(action, @row_id && @row_id.(row) && elem(row, 1) || row) %>
            </div>
          </td>
          <td
            :for={col <- @col}
            class={col_cell_class(col)}
            data-label={(@is_responsive || @is_responsive_grid) && col[:label]}
            data-span={col[:span]}
          >
            <%= render_slot(col, @row_id && @row_id.(row) && elem(row, 1) || row) %>
          </td>
        </tr>
      </tbody>
      <tfoot :if={@foot != []}>
        <%= render_slot(@foot) %>
      </tfoot>
    </table>
    """
  end

  # phx-value-id for a row checkbox: prefer the explicit select_id fn, else fall
  # back to row_id (the DOM-id fn). nil → attribute omitted.
  defp select_value(assigns, row) do
    cond do
      assigns.select_id -> assigns.select_id.(row)
      assigns.row_id -> assigns.row_id.(row)
      true -> nil
    end
  end

  defp col_header_class(col) do
    classes = [col[:col_class], align_class(col[:align])]

    case Enum.reject(classes, &is_nil/1) do
      [] -> nil
      parts -> Enum.join(parts, " ")
    end
  end

  defp col_cell_class(col) do
    classes = [col[:class], align_class(col[:align])]

    case Enum.reject(classes, &is_nil/1) do
      [] -> nil
      parts -> Enum.join(parts, " ")
    end
  end

  defp align_class("end"), do: "text-end"
  defp align_class("center"), do: "text-center"
  defp align_class("start"), do: "text-start"
  defp align_class(_), do: nil

  defp table_classes(assigns) do
    effective_size = if assigns.is_compact && assigns.size == nil, do: "xs", else: assigns.size

    build_classes(
      "pa-table",
      [
        {"pa-table--striped", assigns.is_striped},
        {"pa-table--bordered", assigns.is_bordered},
        {"pa-table--plain", assigns.is_plain},
        {"pa-table--responsive", assigns.is_responsive},
        {"pa-table--responsive-grid", assigns.is_responsive_grid},
        {"pa-table--#{effective_size}", effective_size != nil}
      ],
      assigns.class
    )
  end

  @doc """
  Two-line cell content: a primary item name with a secondary description stacked
  in a single `<td>` (a line-item name + spec on an invoice, or a name + email in
  an app table). Use inside a `:col` slot body.

  ## Examples

      <:col :let={r} label="Item">
        <.table_item title={r.name} desc={r.spec} />
      </:col>
  """
  attr(:title, :string, required: true, doc: "Primary item name (`pa-table__item-title`).")
  attr(:desc, :string, default: nil, doc: "Secondary description (`pa-table__item-desc`), smaller/italic/muted.")

  def table_item(assigns) do
    ~H"""
    <span class="pa-table__item-title">{@title}</span><span :if={@desc} class="pa-table__item-desc">{@desc}</span>
    """
  end

  @doc """
  Wraps a table in a bordered, horizontally-scrollable container with **no header**.

  This is one of the two blessed table-in-container shapes (the card-less one).
  For a table that needs a header, actions, footer, or card chrome, use
  `table_card/1` instead.

  ## Examples

      <.table_container>
        <.table rows={@data}>...</.table>
      </.table_container>

  > #### Deprecated: `is_panel` {: .warning}
  >
  > The `is_panel` mode emits `pa-table-container--panel` (plus
  > `__header`/`__title`/`__actions`), which upstream deprecated in
  > pure-admin-core 2.9.0-rc10 as a near-duplicate of `table_card/1`. It still
  > renders (legacy tolerance) but is undocumented upstream and slated for
  > removal in a future major. Use `table_card/1` for any table that needs a
  > header/actions/footer.
  """
  attr(:is_panel, :boolean,
    default: false,
    doc: "DEPRECATED (rc10): panel styling with header. Use table_card/1 instead."
  )

  attr(:title_text, :string, default: nil, doc: "Header title (panel mode only)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:header, doc: "Custom header content (overrides title_text)")
  slot(:actions, doc: "Header action buttons (panel mode only)")
  slot(:inner_block, required: true)

  def table_container(assigns) do
    has_header = assigns.header != [] || assigns.title_text != nil || assigns.actions != []

    assigns = assign(assigns, :has_header, has_header)

    ~H"""
    <div class={build_classes("pa-table-container", [{"pa-table-container--panel", @is_panel}], @class)} {@rest}>
      <div :if={@is_panel && @has_header} class="pa-table-container__header">
        <%= if @header != [] do %>
          <%= render_slot(@header) %>
        <% else %>
          <h3 :if={@title_text} class="pa-table-container__title"><%= @title_text %></h3>
        <% end %>
        <div :if={@actions != []} class="pa-table-container__actions">
          <%= render_slot(@actions) %>
        </div>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # -- table_card/1 --

  @doc """
  Renders a card wrapper for tables with header, footer, and color variants.

  ## Examples

      <.table_card title_text="Recent Orders">
        <.table rows={@orders}>
          <:col :let={o} label="Order"><%= o.id %></:col>
          <:col :let={o} label="Total"><%= o.total %></:col>
        </.table>
      </.table_card>

      <.table_card title_text="Sales" subtitle_text="Last 30 days" variant="primary" is_scrollable>
        <:actions><.button size="sm">Export</.button></:actions>
        <.table rows={@data}>...</.table>
        <:footer><.pager page={@page} total_pages={@total_pages} /></:footer>
      </.table_card>
  """
  attr(:title_text, :string, default: nil, doc: "Card title")

  attr(:subtitle_text, :string,
    default: nil,
    doc: "Optional subtitle (rc11) — emits pa-table-card__description, flexes + truncates"
  )

  attr(:variant, :string,
    default: nil,
    values: [nil, "primary", "success", "warning", "danger"],
    doc: "Semantic color variant for header accent"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    doc: "Theme color 1-9"
  )

  attr(:is_scrollable, :boolean, default: false, doc: "Horizontal scrolling for wide tables")
  attr(:is_plain, :boolean, default: false, doc: "Remove card styling (border, shadow, background)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:header, doc: "Custom header content (overrides title_text)")
  slot(:subtitle, doc: "Subtitle content (overrides subtitle_text)")
  slot(:actions, doc: "Header action buttons")
  slot(:inner_block, required: true)
  slot(:footer, doc: "Footer content (e.g. pagination)")

  def table_card(assigns) do
    has_header =
      assigns.header != [] || assigns.title_text != nil ||
        assigns.subtitle_text != nil || assigns.subtitle != [] || assigns.actions != []

    assigns = assign(assigns, :has_header, has_header)

    ~H"""
    <div class={build_classes("pa-table-card", [
      {"pa-table-card--#{@variant}", @variant != nil},
      {"pa-table-card--color-#{@color}", @color != nil},
      {"pa-table-card--plain", @is_plain}
    ], @class)} {@rest}>
      <div :if={@has_header} class="pa-table-card__header">
        <%= if @header != [] do %>
          <%= render_slot(@header) %>
        <% else %>
          <div :if={@title_text} class="pa-table-card__title">
            <h3 class="pa-table-card__title-text"><%= @title_text %></h3>
          </div>
          <p :if={@subtitle != [] || @subtitle_text} class="pa-table-card__description">
            <%= if @subtitle != [], do: render_slot(@subtitle), else: @subtitle_text %>
          </p>
        <% end %>
        <div :if={@actions != []} class="pa-table-card__actions">
          <%= render_slot(@actions) %>
        </div>
      </div>
      <div class={build_classes("pa-table-card__body", [{"pa-table-card__body--scrollable", @is_scrollable}])}>
        <%= render_slot(@inner_block) %>
      </div>
      <div :if={@footer != []} class="pa-table-card__footer">
        <%= render_slot(@footer) %>
      </div>
    </div>
    """
  end
end
