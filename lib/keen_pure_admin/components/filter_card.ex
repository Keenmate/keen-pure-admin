defmodule PureAdmin.Components.FilterCard do
  @moduledoc """
  Filter card component for Pure Admin.

  Provides an expandable filter card with inline filters and a collapsible
  advanced section, matching the Svelte `FilterCard` component.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  @doc """
  Renders an expandable filter card with inline filters and optional advanced section.

  ## Examples

      <.filter_card>
        <:filters>
          <.input_wrapper>
            <.input type="text" placeholder="Search..." />
          </.input_wrapper>
        </:filters>
      </.filter_card>

      <.filter_card
        is_expanded={@filters_expanded}
        on_toggle="toggle-filters"
        on_clear="clear-filters"
        on_refresh="refresh"
      >
        <:filters>
          <.input_group style="flex: 1; min-width: 200px;">
            <:prepend>🔍</:prepend>
            <.input type="text" placeholder="Search..." />
          </.input_group>
        </:filters>
        <:advanced_filters>
          <.grid>
            <.column size="100" md="1-3">
              <.form_group>
                <.form_label>Category</.form_label>
                <.input_wrapper>
                  <.select prompt="All" options={["A", "B"]} />
                </.input_wrapper>
              </.form_group>
            </.column>
          </.grid>
        </:advanced_filters>
      </.filter_card>
  """
  attr(:is_expanded, :boolean, default: false, doc: "Whether advanced filters are visible")
  attr(:has_toggle, :boolean, default: true, doc: "Show expand/collapse toggle button")
  attr(:has_clear, :boolean, default: true, doc: "Show the clear all button")
  attr(:has_refresh, :boolean, default: true, doc: "Show the refresh button")
  attr(:has_advanced_actions, :boolean, default: true, doc: "Show Apply/Clear in advanced footer")
  attr(:is_disabled, :boolean, default: false, doc: "Disable all filter interactions")
  attr(:is_loading, :boolean, default: false, doc: "Loading state (disables inputs, dims the card via pa-filter-card--loading)")
  attr(:on_toggle, :string, default: nil, doc: "phx-click event for toggle button")
  attr(:on_clear, :string, default: nil, doc: "phx-click event for clear button")
  attr(:on_refresh, :string, default: nil, doc: "phx-click event for refresh button")
  attr(:on_apply, :string, default: nil, doc: "phx-click event for apply button")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:filters, required: true, doc: "Main inline filter controls")
  slot(:advanced_filters, doc: "Collapsible advanced filter section")
  slot(:actions, doc: "Custom action buttons before toggle")

  def filter_card(assigns) do
    has_advanced = assigns.advanced_filters != []

    assigns = assign(assigns, :has_advanced, has_advanced)

    ~H"""
    <div class={filter_card_classes(assigns)} {@rest}>
      <div class="pa-card__body">
        <div class="pa-filter-card__row">
          <div class="pa-filter-card__filters">
            <%= render_slot(@filters) %>
          </div>

          <div class="pa-filter-card__actions">
            <button
              :if={@has_toggle && @has_advanced}
              class="pa-btn pa-btn--primary pa-btn--icon-only"
              type="button"
              title={if @is_expanded, do: "Hide filters", else: "More filters"}
              disabled={@is_disabled}
              phx-click={@on_toggle}
            >
              <span class={"pa-icon pa-icon--chevron-#{if @is_expanded, do: "up", else: "down"}"} aria-hidden="true"></span>
            </button>

            <%= render_slot(@actions) %>

            <button
              :if={@has_clear}
              class="pa-btn pa-btn--secondary pa-btn--icon-only"
              type="button"
              title="Clear all"
              disabled={@is_disabled}
              phx-click={@on_clear}
            >
              <span class="pa-icon pa-icon--clear" aria-hidden="true"></span>
            </button>

            <button
              :if={@has_refresh}
              class="pa-btn pa-btn--primary pa-btn--icon-only"
              type="button"
              title="Refresh"
              disabled={@is_disabled || @is_loading}
              phx-click={@on_refresh}
            >
              <span class="pa-icon pa-icon--refresh" aria-hidden="true"></span>
            </button>
          </div>
        </div>

        <div :if={@has_advanced && @is_expanded} class="pa-filter-card__advanced">
          <%= render_slot(@advanced_filters) %>

          <div :if={@has_advanced_actions} class="pa-filter-card__advanced-actions">
            <button class="pa-btn pa-btn--secondary" type="button" disabled={@is_disabled} phx-click={@on_clear}>
              Clear Filters
            </button>
            <button class="pa-btn pa-btn--primary" type="button" disabled={@is_disabled || @is_loading} phx-click={@on_apply}>
              Apply Filters
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp filter_card_classes(assigns) do
    build_classes(
      "pa-card pa-filter-card",
      [
        {"pa-filter-card--loading", assigns.is_loading},
        {"pa-filter-card--disabled", assigns.is_disabled}
      ],
      assigns.class
    )
  end
end
