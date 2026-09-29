defmodule PureAdmin.Components.DataDisplay do
  @moduledoc """
  Data display components for Pure Admin.

  Includes Field, Fields, FieldGroup, DescTable, DotLeaders, PropCard,
  Banded, AccentGrid and their sub-components.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  # -- field/1 --

  @doc """
  Renders a single field display (label + value).

  ## Examples

      <.field label="Name">John Doe</.field>
      <.field label="Status" is_full><.badge variant="success">Active</.badge></.field>
  """
  attr(:label, :string, required: true)
  attr(:is_full, :boolean, default: false, doc: "Span all columns in a grid layout")
  attr(:is_copy_btn, :boolean, default: false, doc: "Always-visible copy button")
  attr(:is_copy_click, :boolean, default: false, doc: "Click value to copy")
  attr(:is_copy_hover, :boolean, default: false, doc: "Copy icon on hover only")

  attr(:value_variant, :string,
    default: nil,
    values: [nil, "success", "warning", "danger", "info"],
    doc: "Color variant for the value (used in chips layout)"
  )

  attr(:copy_value, :string, default: nil, doc: "Value to copy to clipboard")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def field(assigns) do
    ~H"""
    <div class={build_classes("pa-field", [
      {"pa-field--full", @is_full},
      {"pa-field--copy-btn", @is_copy_btn},
      {"pa-field--copy-click", @is_copy_click},
      {"pa-field--copy-hover", @is_copy_hover}
    ], @class)} {@rest}>
      <span class="pa-field__label"><%= @label %></span>
      <%= if @is_copy_click do %>
        <span class={build_classes("pa-field__value", [{"pa-field__value--#{@value_variant}", @value_variant != nil}])}
              data-pa-copy-on-click
              data-copy-value={@copy_value}><%= render_slot(@inner_block) %></span>
      <% else %>
        <%!-- Canonical shape (snippets/data-display.html): value text sits directly
             in .pa-field__value with the copy button as its sibling — no inner
             wrapper span. data-copy-value goes on .pa-field__value; the copy JS
             resolves it via its ancestor lookup (copy_value.js rule 3). --%>
        <span
          class={build_classes("pa-field__value", [{"pa-field__value--#{@value_variant}", @value_variant != nil}])}
          data-copy-value={(@is_copy_btn || @is_copy_hover) && @copy_value || nil}
        >
          <%= render_slot(@inner_block) %>
          <button
            :if={@is_copy_btn || @is_copy_hover}
            type="button"
            class="pa-field__copy"
            data-pa-copy
            title="Copy to clipboard"
          >
            <span class="pa-icon pa-icon--copy" aria-hidden="true"></span>
          </button>
        </span>
      <% end %>
    </div>
    """
  end

  # -- fields/1 --

  @doc """
  Renders a container for field components with layout modifiers.

  ## Examples

      <.fields>
        <.field label="Name">John</.field>
      </.fields>

      <.fields cols="2" is_horizontal>
        <.field label="Company">Acme</.field>
        <.field label="Phone">+420 234 567</.field>
      </.fields>

      <.fields is_striped is_filled color="1">
        <.field label="Status">Active</.field>
      </.fields>
  """
  attr(:cols, :string, default: nil, values: [nil, "2", "3", "4"], doc: "Grid columns")
  attr(:is_horizontal, :boolean, default: false, doc: "Label and value side by side")
  attr(:is_table, :boolean, default: false, doc: "Table-style layout")
  attr(:is_bordered, :boolean, default: false, doc: "Bordered rows")
  attr(:is_striped, :boolean, default: false, doc: "Alternating row backgrounds")
  attr(:is_compact, :boolean, default: false, doc: "Reduced spacing")
  attr(:is_inline, :boolean, default: false, doc: "Inline display")
  attr(:is_row, :boolean, default: false, doc: "Horizontal row layout")
  attr(:is_relaxed, :boolean, default: false, doc: "Extra spacing")
  attr(:is_filled, :boolean, default: false, doc: "Filled background")
  attr(:is_linear, :boolean, default: false, doc: "Linear minimal layout")
  attr(:is_chips, :boolean, default: false, doc: "Chip/tag layout")
  attr(:is_no_border, :boolean, default: false, doc: "Remove border")

  attr(:color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    doc: "Color variant 1-9"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def fields(assigns) do
    ~H"""
    <div class={fields_classes(assigns)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp fields_classes(assigns) do
    build_classes(
      "pa-fields",
      [
        {"pa-fields--cols-#{assigns.cols}", assigns.cols != nil},
        {"pa-fields--horizontal", assigns.is_horizontal},
        {"pa-fields--table", assigns.is_table},
        {"pa-fields--bordered", assigns.is_bordered},
        {"pa-fields--striped", assigns.is_striped},
        {"pa-fields--compact", assigns.is_compact},
        {"pa-fields--inline", assigns.is_inline},
        {"pa-fields--row", assigns.is_row},
        {"pa-fields--relaxed", assigns.is_relaxed},
        {"pa-fields--filled", assigns.is_filled},
        {"pa-fields--linear", assigns.is_linear},
        {"pa-fields--chips", assigns.is_chips},
        {"pa-fields--no-border", assigns.is_no_border},
        {"pa-fields--color-#{assigns.color}", assigns.color != nil}
      ],
      assigns.class
    )
  end

  # -- field_group/1 --

  @doc """
  Renders a field group with a title.

  ## Examples

      <.field_group title="Personal">
        <.fields>
          <.field label="Name">John</.field>
        </.fields>
      </.field_group>
  """
  attr(:title, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def field_group(assigns) do
    ~H"""
    <div class={build_classes("pa-field-group", [], @class)} {@rest}>
      <h3 class="pa-field-group__title"><%= @title %></h3>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # -- desc_table/1 --

  @doc """
  Renders an Ant Design-style descriptions table.

  ## Examples

      <.desc_table>
        <.desc_label>Company</.desc_label>
        <.desc_value>Acme Corp</.desc_value>
        <.desc_label>Email</.desc_label>
        <.desc_value>info@acme.com</.desc_value>
      </.desc_table>

      <.desc_table cols="2" is_fixed is_truncate>
        ...
      </.desc_table>
  """
  attr(:cols, :string, default: nil, values: [nil, "2"], doc: "2-column layout")
  attr(:is_fixed, :boolean, default: false, doc: "Fixed label width")
  attr(:is_truncate, :boolean, default: false, doc: "Truncate long values")
  attr(:is_middle, :boolean, default: false, doc: "Vertically center cells")
  attr(:is_label_end, :boolean, default: false, doc: "Right-align labels")
  attr(:is_label_center, :boolean, default: false, doc: "Center-align labels")
  attr(:is_value_end, :boolean, default: false, doc: "Right-align values")
  attr(:is_value_center, :boolean, default: false, doc: "Center-align values")

  attr(:label_width, :string,
    default: nil,
    doc:
      "Custom label width as a single CSS length (e.g. `\"30%\"`, `\"12rem\"`, `\"180px\"`). Invalid input is ignored."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  # Matches a single CSS length token: optional minus, digits, optional
  # decimal, and one of the common length units. Anything with `;`, parens,
  # whitespace after the unit, or any other CSS syntax is rejected — so the
  # value can be safely interpolated into a `style=` attribute.
  @css_length_regex ~r/^-?\d+(?:\.\d+)?(?:%|px|rem|em|vw|vh|ch|ex|cm|mm|in|pt|pc)$/

  def desc_table(assigns) do
    style =
      case assigns.label_width do
        nil -> nil
        value -> if Regex.match?(@css_length_regex, value), do: "--label-width: #{value}", else: nil
      end

    assigns = assign(assigns, :computed_style, style)

    ~H"""
    <div class="pa-desc-container">
      <div
        class={build_classes("pa-desc-table", [
          {"pa-desc-table--cols-2", @cols == "2"},
          {"pa-desc-table--fixed", @is_fixed},
          {"pa-desc-table--truncate", @is_truncate},
          {"pa-desc-table--middle", @is_middle},
          {"pa-desc-table--label-end", @is_label_end},
          {"pa-desc-table--label-center", @is_label_center},
          {"pa-desc-table--value-end", @is_value_end},
          {"pa-desc-table--value-center", @is_value_center}
        ], @class)}
        style={@computed_style}
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc "Renders a label cell in a desc_table."
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  def desc_label(assigns) do
    ~H"""
    <span class={build_classes("pa-desc-table__label", [], @class)}><%= render_slot(@inner_block) %></span>
    """
  end

  @doc "Renders a value cell in a desc_table."
  attr(:is_full, :boolean, default: false, doc: "Span full width")
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  def desc_value(assigns) do
    ~H"""
    <span class={build_classes("pa-desc-table__value", [{"pa-desc-table__value--full", @is_full}], @class)}><%= render_slot(@inner_block) %></span>
    """
  end

  # -- dot_leaders/1 --

  @doc """
  Renders a dot-leaders container (restaurant menu / invoice style).

  ## Examples

      <.dot_leaders>
        <.dot_leader label="Subtotal" value="$1,200.00" />
        <.dot_leader label="Tax" value="$96.00" />
        <.dot_leader label="Total" value="$1,296.00" is_total />
      </.dot_leaders>
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dot_leaders(assigns) do
    ~H"""
    <div class={build_classes("pa-dot-leaders", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc "Renders a single dot-leader item."
  attr(:label, :string, required: true)
  attr(:value, :string, required: true)
  attr(:is_total, :boolean, default: false, doc: "Bold total line")
  attr(:class, :string, default: nil)

  def dot_leader(assigns) do
    ~H"""
    <div class={build_classes("pa-dot-leaders__item", [{"pa-dot-leaders__item--total", @is_total}], @class)}>
      <span class="pa-dot-leaders__label"><%= if @is_total do %><strong><%= @label %></strong><% else %><%= @label %><% end %></span>
      <span class="pa-dot-leaders__leader"></span>
      <span class="pa-dot-leaders__value"><%= if @is_total do %><strong><%= @value %></strong><% else %><%= @value %><% end %></span>
    </div>
    """
  end

  # -- prop_card/1 --

  @doc """
  Renders a property card with header and label-value rows.

  ## Examples

      <.prop_card header="Order Details">
        <.prop_card_row label="Order ID" value="#ORD-001" />
        <.prop_card_row label="Status"><.badge variant="success">Delivered</.badge></.prop_card_row>
        <.prop_card_row label="Total" is_bold>$1,249.00</.prop_card_row>
      </.prop_card>
  """
  attr(:header, :string, default: nil, doc: "Card header text")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def prop_card(assigns) do
    ~H"""
    <div class={build_classes("pa-prop-card", [], @class)} {@rest}>
      <div :if={@header} class="pa-prop-card__header"><%= @header %></div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc "Renders a row inside a prop_card."
  attr(:label, :string, required: true)
  attr(:value, :string, default: nil)
  attr(:is_bold, :boolean, default: false, doc: "Bold value text")
  attr(:class, :string, default: nil)
  slot(:inner_block, doc: "Rich value content")

  def prop_card_row(assigns) do
    ~H"""
    <div class={build_classes("pa-prop-card__row", [], @class)}>
      <span class="pa-prop-card__label"><%= @label %></span>
      <span class={build_classes("pa-prop-card__value", [{"pa-prop-card__value--bold", @is_bold}])}>
        <%= if @inner_block != [] do %>
          <%= render_slot(@inner_block) %>
        <% else %>
          <%= @value %>
        <% end %>
      </span>
    </div>
    """
  end

  # -- banded/1 --

  @doc """
  Renders banded rows (alternating background) for data display.

  ## Examples

      <.banded>
        <.banded_row label="Server" value="prod-api-01" />
        <.banded_row label="IP" value="10.0.12.45" />
      </.banded>
  """
  attr(:is_narrow, :boolean, default: false, doc: "Narrow label band (8rem)")
  attr(:is_wide, :boolean, default: false, doc: "Wide label band (20rem)")
  attr(:is_truncate, :boolean, default: false, doc: "Truncate long values")
  attr(:is_middle, :boolean, default: false, doc: "Vertically center labels")
  attr(:is_label_end, :boolean, default: false, doc: "Right-align labels")
  attr(:is_label_center, :boolean, default: false, doc: "Center-align labels")
  attr(:is_value_end, :boolean, default: false, doc: "Right-align values")
  attr(:is_value_center, :boolean, default: false, doc: "Center-align values")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def banded(assigns) do
    ~H"""
    <div class={build_classes("pa-banded", [
      {"pa-banded--narrow", @is_narrow},
      {"pa-banded--wide", @is_wide},
      {"pa-banded--truncate", @is_truncate},
      {"pa-banded--middle", @is_middle},
      {"pa-banded--label-end", @is_label_end},
      {"pa-banded--label-center", @is_label_center},
      {"pa-banded--value-end", @is_value_end},
      {"pa-banded--value-center", @is_value_center}
    ], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc "Renders a single banded row."
  attr(:label, :string, required: true)
  attr(:value, :string, default: nil)
  attr(:class, :string, default: nil)
  slot(:inner_block, doc: "Rich value content (alternative to value attr)")

  def banded_row(assigns) do
    ~H"""
    <div class={build_classes("pa-banded__row", [], @class)}>
      <span class="pa-banded__label"><%= @label %></span>
      <span class="pa-banded__value">
        <%= if @inner_block != [] do %>
          <%= render_slot(@inner_block) %>
        <% else %>
          <%= @value %>
        <% end %>
      </span>
    </div>
    """
  end

  # -- accent_grid/1 --

  @doc """
  Renders an accent-bar grid for visual data cards.

  ## Examples

      <.accent_grid>
        <.accent_grid_item label="Revenue" value="$12,430" variant="success" />
        <.accent_grid_item label="Orders" value="847" variant="info" />
      </.accent_grid>
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def accent_grid(assigns) do
    ~H"""
    <div class={build_classes("pa-accent-grid", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc "Renders a single accent grid item."
  attr(:label, :string, required: true)
  attr(:value, :string, required: true)

  # Core defines accent-grid item accents ONLY as the four semantic variants —
  # there is no `--color-{1..9}` nor `--primary` (verified against main.css).
  attr(:variant, :string,
    default: nil,
    values: [nil, "success", "warning", "danger", "info"],
    doc: "Semantic accent variant (success/warning/danger/info)"
  )

  attr(:class, :string, default: nil)

  def accent_grid_item(assigns) do
    ~H"""
    <div class={build_classes("pa-accent-grid__item", [
      {"pa-accent-grid__item--#{@variant}", @variant != nil}
    ], @class)}>
      <div class="pa-accent-grid__label"><%= @label %></div>
      <div class="pa-accent-grid__value"><%= @value %></div>
    </div>
    """
  end
end
