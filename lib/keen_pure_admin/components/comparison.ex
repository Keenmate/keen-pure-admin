defmodule PureAdmin.Components.Comparison do
  @moduledoc """
  Comparison table components for Pure Admin.

  Provides components for two-column and three-column data comparison patterns
  (version control, data changes, merge conflicts).

  ## Examples

      <.comparison_table>
        <:head>
          <th style="width: 20%;">#</th>
          <th style="width: 40%;">Base values</th>
          <th style="width: 40%;">New values</th>
        </:head>

        <.comparison_row label="Town">
          <:cell>
            <.comparison_value value="Beveren" is_copyable />
          </:cell>
          <:cell is_changed>
            <.comparison_value value="Antwerpen" is_copyable />
          </:cell>
        </.comparison_row>

        <.comparison_section colspan={3}>Address metadata</.comparison_section>
      </.comparison_table>
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  # -- comparison_table/1 --

  @doc """
  Renders a comparison table wrapper.

  Wraps content in `<table class="pa-table pa-comparison-table">` with a thead
  from the `:head` slot and tbody from `inner_block`.

  ## Examples

      <.comparison_table>
        <:head>
          <th style="width: 20%;">#</th>
          <th style="width: 40%;">Base</.th>
          <th style="width: 40%;">New</.th>
        </:head>
        ...rows...
      </.comparison_table>
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:head, required: true, doc: "Table header row content (<th> elements)")
  slot(:inner_block, required: true, doc: "Table body content (comparison_row, comparison_section)")

  def comparison_table(assigns) do
    ~H"""
    <table class={build_classes("pa-table pa-comparison-table", [], @class)} {@rest}>
      <thead>
        <tr>
          <%= render_slot(@head) %>
        </tr>
      </thead>
      <tbody>
        <%= render_slot(@inner_block) %>
      </tbody>
    </table>
    """
  end

  # -- comparison_row/1 --

  @doc """
  Renders a comparison table row with a label and value cells.

  The `:cell` slot renders each value column. Use slot attrs `is_changed`,
  `is_solid`, and `is_conflict` to highlight differences.

  ## Examples

      <.comparison_row label="Town">
        <:cell>
          <.comparison_value value="Beveren" is_copyable />
        </:cell>
        <:cell is_changed>
          <.comparison_value value="Antwerpen" is_copyable />
        </:cell>
      </.comparison_row>

      <%!-- Empty row (no cells or empty cells) --%>
      <.comparison_row label="Region" cells={2} />
  """
  attr(:label, :string, required: true, doc: "Field name shown in the label column")
  attr(:cells, :integer, default: nil, doc: "Number of empty cells to render (when no :cell slot)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :cell, doc: "Value cell content" do
    attr(:is_changed, :boolean, doc: "Pink highlight for changed values")
    attr(:is_solid, :boolean, doc: "Solid background variant (no left border)")
    attr(:is_conflict, :boolean, doc: "Orange highlight for merge conflicts")

    attr(:data_label, :string,
      doc:
        "Column name for the ≤mobile stacked view (emits `data-label`). Core renders it as the " <>
          "per-cell label when the table collapses to one cell per line — set it to the column " <>
          "header (e.g. \"Base\" / \"New\"). Without it the mobile stack shows a blank label gutter."
    )
  end

  def comparison_row(assigns) do
    ~H"""
    <tr class={@class} {@rest}>
      <td class="pa-comparison-table__label"><%= @label %></td>
      <%= if @cell != [] do %>
        <td
          :for={cell <- @cell}
          class={cell_classes(cell)}
          data-label={cell[:data_label]}
        >
          <%= render_slot(cell) %>
        </td>
      <% else %>
        <td :for={_ <- 1..(@cells || 2)}></td>
      <% end %>
    </tr>
    """
  end

  defp cell_classes(cell) do
    changed = !!cell[:is_changed]
    solid = !!cell[:is_solid]
    conflict = !!cell[:is_conflict]

    cond do
      conflict and solid ->
        "pa-comparison-table__changed pa-comparison-table__conflict pa-comparison-table__conflict--solid"

      conflict ->
        "pa-comparison-table__changed pa-comparison-table__conflict"

      changed and solid ->
        "pa-comparison-table__changed pa-comparison-table__changed--solid"

      changed ->
        "pa-comparison-table__changed"

      true ->
        nil
    end
  end

  # -- comparison_section/1 --

  @doc """
  Renders a section header row in a comparison table.

  ## Examples

      <.comparison_section colspan={3}>Address metadata</.comparison_section>
  """
  attr(:colspan, :integer, required: true, doc: "Number of columns to span")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def comparison_section(assigns) do
    ~H"""
    <tr class="pa-comparison-table__section" {@rest}>
      <td colspan={@colspan}><%= render_slot(@inner_block) %></td>
    </tr>
    """
  end

  # -- comparison_value/1 --

  @doc """
  Renders a comparison value cell content with optional copy button.

  ## Examples

      <.comparison_value value="Antwerpen" is_copyable />
      <.comparison_value value="be" />
  """
  attr(:value, :string, required: true, doc: "The value to display")
  attr(:is_copyable, :boolean, default: true, doc: "Show copy-to-clipboard button")
  attr(:rest, :global)

  def comparison_value(assigns) do
    ~H"""
    <div class="pa-comparison-table__value" {@rest}>
      <span><%= @value %></span>
      <button
        :if={@is_copyable}
        class="pa-btn pa-btn--xs pa-btn--icon-only pa-comparison-table__copy"
        type="button"
        phx-click={copy_to_clipboard(@value)}
      >
        <span class="pa-icon pa-icon--copy" aria-hidden="true"></span>
      </button>
    </div>
    """
  end

  @doc """
  JS command to copy a value to clipboard.

  Uses the Clipboard API via a JS dispatch event.
  """
  def copy_to_clipboard(value) do
    Phoenix.LiveView.JS.dispatch("kpa:clipboard-copy", detail: %{text: value})
  end
end
