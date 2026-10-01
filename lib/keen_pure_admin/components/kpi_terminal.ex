defmodule PureAdmin.Components.KpiTerminal do
  @moduledoc """
  KPI Terminal grid showcase — Bloomberg-style dense panel of KPI tiles.

  Tracks `_kpi-terminal.scss` from `@keenmate/pure-admin-core` 2.7.1+. The
  tile primitive lives in `PureAdmin.Components.Kpi.kpi_tile/1`; this module
  supplies the card chrome (`pa-kpi-terminal`) and the optional tab strip
  that swaps panes (each pane can hold a different tile count + grid).

  ## Usage

  Single grid (no tabs) — children are tiles, the wrapper supplies the
  `pa-kpi-terminal__grid--2col`:

      <.kpi_terminal title_text="Key Performance Indicators" is_live>
        <.kpi_tile id_text="KPI.01" .../>
        <.kpi_tile id_text="KPI.02" .../>
      </.kpi_terminal>

  Tabs + panes — `:pane` slots define each tab. The hook
  `PureAdminKpiTerminalTabs` toggles active tab/pane client-side. Mark one
  pane `is_active` for the initial state (defaults to the first pane).

      <.kpi_terminal id="exec-kpis" title_text="Key Performance Indicators" is_live>
        <:pane id="overview" label_text="OVERVIEW" is_active>
          <.kpi_tile .../>
          <.kpi_tile .../>
        </:pane>
        <:pane id="finance" label_text="FINANCE">
          <.kpi_tile .../>
        </:pane>
      </.kpi_terminal>
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  attr(:id, :string, default: nil, doc: "Required when tabs are used (the JS hook needs an id)")
  attr(:title_text, :string, default: nil)
  attr(:is_live, :boolean, default: false, doc: "Show the LIVE pill (animated green dot) in the header")
  attr(:live_text, :string, default: "LIVE")
  attr(:footer_text, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :pane, doc: "One pane per tab. When present, the tab strip is rendered." do
    attr(:id, :string, required: true)
    attr(:label_text, :string, required: true)
    attr(:tab_class, :string)
    attr(:class, :string)
    attr(:is_active, :boolean)
  end

  slot(:inner_block, doc: "Tile content when not using tabs — wrapped in a single `pa-kpi-terminal__grid--2col`")
  slot(:header_controls, doc: "Extra controls between the title and the LIVE pill (e.g. custom toolbars)")
  slot(:footer, doc: "Footer override")

  def kpi_terminal(assigns) do
    has_tabs? = assigns.pane != []
    panes = assigns.pane

    active_pane_id =
      Enum.find_value(panes, &(Map.get(&1, :is_active) && &1.id)) ||
        (List.first(panes) || %{}) |> Map.get(:id)

    assigns =
      assigns
      |> assign(:has_tabs?, has_tabs?)
      |> assign(:active_pane_id, active_pane_id)

    ~H"""
    <div
      id={@id}
      class={build_classes("pa-card pa-kpi-terminal", [], @class)}
      phx-hook={if @has_tabs?, do: "PureAdminKpiTerminalTabs"}
      {@rest}
    >
      <div :if={@title_text || @is_live || @header_controls != [] || @has_tabs?} class="pa-card__header pa-kpi-header">
        <div :if={@title_text} class="pa-card__title">
          <h3 class="pa-card__title-text">{@title_text}</h3>
        </div>
        <div class="pa-kpi-terminal__controls">
          <%= for c <- @header_controls do %>
            {render_slot(c)}
          <% end %>
          <div :if={@has_tabs?} class="pa-kpi-terminal__tabs" role="tablist" aria-label="Dashboard view">
            <%= for p <- @pane do %>
              <button
                type="button"
                class={tab_classes(p, @active_pane_id)}
                data-tab={p.id}
                role="tab"
                aria-selected={to_string(@active_pane_id == p.id)}
              >
                {p.label_text}
              </button>
            <% end %>
          </div>
          <span :if={@is_live} class="pa-kpi-live">
            <span class="pa-kpi-live__dot"></span>{@live_text}
          </span>
        </div>
      </div>

      <div class="pa-card__body pa-kpi-terminal__body">
        <%= if @has_tabs? do %>
          <%= for p <- @pane do %>
            <div class={pane_classes(p, @active_pane_id)} data-tab={p.id}>
              <div class="pa-kpi-terminal__grid pa-kpi-terminal__grid--2col">
                {render_slot(p)}
              </div>
            </div>
          <% end %>
        <% else %>
          <div class="pa-kpi-terminal__grid pa-kpi-terminal__grid--2col">
            {render_slot(@inner_block)}
          </div>
        <% end %>
      </div>

      <div :if={@footer != [] || @footer_text} class="pa-card__footer pa-kpi-footer">
        <%= if @footer != [] do %>
          {render_slot(@footer)}
        <% else %>
          <span>{@footer_text}</span>
        <% end %>
      </div>
    </div>
    """
  end

  defp tab_classes(pane, active_id) do
    build_classes(
      "pa-kpi-terminal__tab",
      [{"is-active", pane.id == active_id}],
      Map.get(pane, :tab_class)
    )
  end

  defp pane_classes(pane, active_id) do
    build_classes(
      "pa-kpi-terminal__pane",
      [{"is-active", pane.id == active_id}],
      Map.get(pane, :class)
    )
  end
end
