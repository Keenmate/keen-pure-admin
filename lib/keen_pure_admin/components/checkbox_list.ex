defmodule PureAdmin.Components.CheckboxList do
  @moduledoc """
  Checkbox list components for Pure Admin.

  Provides `checkbox_list/1` container, `checkbox_list_item/1` for individual items,
  and `checkbox_box/1` as a low-level checkbox building block (for tables, etc.).
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  @doc """
  Renders a low-level checkbox (input + box) without label text.

  Used as a building block in tables, checkbox lists, and other composite components.

  ## Examples

      <.checkbox_box id="select-row-1" checked={@row.checked} phx-click="toggle_row" phx-value-id="1" />
  """
  attr(:id, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:value, :string, default: "true")
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)

  attr(:is_indeterminate, :boolean,
    default: false,
    doc: "Indeterminate/partial state (requires PureAdminCheckbox hook)"
  )

  attr(:is_x_mark, :boolean, default: false, doc: "X mark instead of checkmark")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-click phx-change phx-value-id))

  def checkbox_box(assigns) do
    hook_id = if assigns.is_indeterminate, do: assigns.id || "cb-box-#{:erlang.phash2(assigns)}"
    assigns = assign(assigns, :hook_id, hook_id)

    ~H"""
    <label
      class={build_classes("pa-checkbox", [
        {"pa-checkbox--#{@size}", @size != nil},
        {"pa-checkbox--x", @is_x_mark},
        {"pa-checkbox--disabled", @disabled}
      ], @class)}
      id={@hook_id}
      phx-hook={if @is_indeterminate, do: "PureAdminCheckbox"}
      data-indeterminate={to_string(@is_indeterminate)}
    >
      <input type="checkbox" id={@id} name={@name} value={@value} checked={@checked} disabled={@disabled} {@rest} />
      <span class="pa-checkbox__box"></span>
    </label>
    """
  end

  @doc """
  Renders a checkbox list container.

  ## Examples

      <.checkbox_list>
        <.checkbox_list_item id="opt1" label_text="Option 1" />
        <.checkbox_list_item id="opt2" label_text="Option 2" checked />
      </.checkbox_list>

      <.checkbox_list variant="bordered" layout="2col">
        ...
      </.checkbox_list>
  """
  attr(:variant, :string, default: nil, values: [nil, "compact", "bordered", "striped"])
  attr(:layout, :string, default: nil, values: [nil, "inline", "grid", "2col", "3col"])
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def checkbox_list(assigns) do
    ~H"""
    <ul class={build_classes("pa-checkbox-list", [
      {"pa-checkbox-list--#{@variant}", @variant != nil},
      {"pa-checkbox-list--#{@layout}", @layout != nil}
    ], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  @doc """
  Renders a checkbox list item with label, optional description, and actions.

  ## Examples

      <.checkbox_list_item id="feat1" label_text="Email Notifications" description_text="Receive updates via email" />

      <.checkbox_list_item id="task1" label_text="Complete proposal" checked>
        <:actions>
          <.button size="xs" variant="danger" is_icon_only>🗑️</.button>
        </:actions>
      </.checkbox_list_item>
  """
  attr(:id, :string, required: true)
  attr(:label_text, :string, required: true)
  attr(:description_text, :string, default: nil)
  attr(:state, :string, default: nil, values: [nil, "selected", "disabled", "locked"])
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)

  attr(:size, :string,
    default: nil,
    values: [nil, "xs", "sm", "lg", "xl"],
    doc: "Forwarded to the item's checkbox_box."
  )

  attr(:is_x_mark, :boolean, default: false, doc: "X mark instead of checkmark (forwarded to checkbox_box).")

  attr(:is_indeterminate, :boolean,
    default: false,
    doc: "Indeterminate/partial state (forwarded to checkbox_box; needs its hook)."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-click phx-change phx-value-id))
  slot(:actions, doc: "Action buttons for the item")

  def checkbox_list_item(assigns) do
    is_disabled = assigns.disabled || assigns.state in ["disabled", "locked"]
    assigns = assign(assigns, :is_disabled, is_disabled)

    ~H"""
    <li class={build_classes("pa-checkbox-list__item", [
      {"pa-checkbox-list__item--selected", @state == "selected"},
      {"pa-checkbox-list__item--disabled", @state == "disabled"},
      {"pa-checkbox-list__item--locked", @state == "locked"}
    ], @class)}>
      <label class="pa-checkbox-list__label">
        <.checkbox_box id={@id} checked={@checked} disabled={@is_disabled} size={@size} is_x_mark={@is_x_mark} is_indeterminate={@is_indeterminate} {@rest} />
        <span class="pa-checkbox-list__text">
          <%= @label_text %>
          <span :if={@description_text} class="pa-checkbox-list__description"><%= @description_text %></span>
        </span>
      </label>
      <div :if={@actions != []} class="pa-checkbox-list__actions">
        <%= for actions <- @actions do %>
          <%= render_slot(actions) %>
        <% end %>
      </div>
    </li>
    """
  end
end
