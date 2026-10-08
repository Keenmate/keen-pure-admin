defmodule PureAdmin.Components.Navigation do
  @moduledoc """
  Tab and navigation components for Pure Admin.

  Provides standalone tabs (`tabs/1`, `tab_item/1`, `tab_panel/1`) and
  card tabs, with JS-command-based tab switching.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import PureAdmin.Helpers

  @doc """
  Renders a tab bar container.

  ## Examples

      <.tabs id="my-tabs">
        <.tab_item target="panel-1" is_active>Overview</.tab_item>
        <.tab_item target="panel-2">Details</.tab_item>
      </.tabs>
      <.tabs_content>
        <.tab_panel id="panel-1" is_active>Overview content</.tab_panel>
        <.tab_panel id="panel-2">Details content</.tab_panel>
      </.tabs_content>
  """
  attr(:id, :string, default: nil)

  attr(:style, :string,
    default: nil,
    values: [nil, "pills", "boxed", "border-top", "vertical"],
    doc: "Tab style variant"
  )

  attr(:size, :string, default: nil, values: [nil, "sm", "lg"])
  attr(:align, :string, default: nil, values: [nil, "centered", "full"])
  attr(:overflow, :string, default: nil, values: [nil, "nowrap", "scrollable", "collapse"])

  attr(:is_wrap_labels, :boolean,
    default: false,
    doc:
      "Emit pa-tabs--wrap-labels: let long tab titles wrap to multiple lines (items are white-space:nowrap by default) with a unified row height. Pair with a maxwr-* width cap on the item to choose the wrap point."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def tabs(assigns) do
    ~H"""
    <div id={@id} class={tabs_classes(assigns)} data-tabs-scroll={if @overflow == "scrollable", do: ""} {@rest}>
      <%= if @overflow == "scrollable" do %>
        <button type="button" class="pa-tabs__scroll-btn pa-tabs__scroll-btn--start" data-pa-tab-scroll="start" aria-label="Scroll tabs left">
          <span class="pa-icon pa-icon--chevron-left" aria-hidden="true"></span>
        </button>
        <div class="pa-tabs__scroll-container">
          <%= render_slot(@inner_block) %>
        </div>
        <button type="button" class="pa-tabs__scroll-btn pa-tabs__scroll-btn--end" data-pa-tab-scroll="end" aria-label="Scroll tabs right">
          <span class="pa-icon pa-icon--chevron-right" aria-hidden="true"></span>
        </button>
      <% else %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </div>
    """
  end

  defp tabs_classes(assigns) do
    build_classes(
      "pa-tabs",
      [
        {"pa-tabs--#{assigns.style}", assigns.style != nil},
        {"pa-tabs--#{assigns.size}", assigns.size != nil},
        {"pa-tabs--#{assigns.align}", assigns.align != nil},
        {"pa-tabs--#{assigns.overflow}", assigns.overflow != nil},
        {"pa-tabs--wrap-labels", assigns.is_wrap_labels}
      ],
      assigns.class
    )
  end

  @doc """
  Renders an individual tab item/button.

  ## Examples

      <.tab_item target="panel-1" is_active>Home</.tab_item>

      <.tab_item target="panel-2">
        <:icon><i class="fa-solid fa-gear"></i></:icon>
        Settings
      </.tab_item>
  """
  attr(:target, :string, required: true, doc: "ID of the target tab panel")
  attr(:tabs_id, :string, default: nil, doc: "ID of the parent tabs container (for JS switching)")
  attr(:is_active, :boolean, default: false)

  # Fixed-size tabs are done with the generic rem width/height utilities via
  # `class`, NOT dedicated attrs: `minwr-N` (min-width), `maxwr-N` (max-width,
  # pairs with the container's `is_wrap_labels`), `minhr-N` (min-height, e.g. a
  # square icon tab = `class="minwr-3 minhr-3"`). Core resolved the fixed-size-tab
  # design as `pa-tabs--wrap-labels` + these utilities and explicitly retired the
  # old `pa-tabs__item--w-{N}x`/`--h-{N}x` scale (it never had matching CSS).
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled))
  slot(:icon, doc: "Icon content (rendered before text)")
  slot(:inner_block, required: true)

  def tab_item(assigns) do
    tab_item_id = "tab-btn-#{assigns.target}"
    assigns = assign(assigns, :tab_item_id, tab_item_id)

    ~H"""
    <button
      id={@tab_item_id}
      class={tab_item_classes(assigns)}
      phx-click={switch_tab(@target, @tabs_id, @tab_item_id)}
      data-tab-target={@target}
      {@rest}
    >
      <%= for icon <- @icon do %>
        <%= render_slot(icon) %>
      <% end %>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp tab_item_classes(assigns) do
    build_classes(
      "pa-tabs__item",
      [
        {"pa-tabs__item--active", assigns.is_active}
      ],
      assigns.class
    )
  end

  @doc """
  Renders a tab content container.
  """
  attr(:id, :string, default: nil, doc: "Content container ID (use {tabs_id}-content for scoped switching)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def tabs_content(assigns) do
    ~H"""
    <div id={@id} class={build_classes("pa-tabs__content", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a tab panel (content for a single tab).

  ## Examples

      <.tab_panel id="panel-1" is_active>Content here</.tab_panel>
  """
  attr(:id, :string, required: true)
  attr(:is_active, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def tab_panel(assigns) do
    ~H"""
    <div
      id={@id}
      class={build_classes("pa-tabs__panel", [{"pa-tabs__panel--active", @is_active}], @class)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a vertical tabs layout wrapper.
  """
  attr(:is_bordered, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def tabs_vertical_layout(assigns) do
    ~H"""
    <div
      class={build_classes("pa-tabs__vertical-layout", [{"pa-tabs__vertical-layout--bordered", @is_bordered}], @class)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a horizontal tabs container wrapper.

  `is_bordered` wraps the tabs system in a card-like border; `is_card` makes
  the tab row act as the card header (same height as `pa-card__header`), which
  is the layout the `tabs_overflow/1` dropdown lives in.
  """
  attr(:is_bordered, :boolean, default: false)
  attr(:is_card, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def tabs_container(assigns) do
    ~H"""
    <div
      class={build_classes("pa-tabs__container", [{"pa-tabs__container--bordered", @is_bordered}, {"pa-tabs__container--card", @is_card}], @class)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders the card-header tabs overflow dropdown (`pa-tabs__overflow`).

  Lives inside a `tabs_container is_card` header for tabs that don't fit. The
  `:toggle` slot is the trigger glyph (defaults to an ellipsis icon); the
  default slot holds the overflow `tab_item`s. Clicking the toggle opens the
  menu; a click anywhere outside the wrapper closes it.

  ## Examples

      <.tabs_overflow id="more-tabs" has_active>
        <.tab_item target="panel-9" tabs_id="my-tabs">Archived</.tab_item>
      </.tabs_overflow>
  """
  attr(:id, :string, required: true, doc: "wrapper id; the menu uses \"{id}-menu\"")
  attr(:has_active, :boolean, default: false, doc: "an overflow tab is the active one")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:toggle, doc: "trigger button content (defaults to an ellipsis icon)")
  slot(:inner_block, required: true, doc: "overflow tab_item entries")

  def tabs_overflow(assigns) do
    menu_id = "#{assigns.id}-menu"
    assigns = assign(assigns, :menu_id, menu_id)

    ~H"""
    <div
      id={@id}
      class={build_classes("pa-tabs__overflow", [], @class)}
      phx-click-away={JS.remove_class("pa-tabs__overflow-menu--open", to: "##{@menu_id}")}
      {@rest}
    >
      <button
        type="button"
        class={build_classes("pa-tabs__overflow-toggle", [{"pa-tabs__overflow-toggle--has-active", @has_active}], nil)}
        aria-haspopup="menu"
        phx-click={JS.toggle_class("pa-tabs__overflow-menu--open", to: "##{@menu_id}")}
      >
        <%= if @toggle != [] do %>
          <%= render_slot(@toggle) %>
        <% else %>
          <span class="pa-icon pa-icon--ellipsis" aria-hidden="true"></span>
        <% end %>
      </button>
      <div id={@menu_id} class="pa-tabs__overflow-menu">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Returns a JS command that switches tab panels.

  Deactivates all sibling tabs and panels, then activates the target.
  """
  @spec switch_tab(String.t(), String.t() | nil, String.t() | nil) :: JS.t()
  def switch_tab(target_panel_id, tabs_id \\ nil, tab_item_id \\ nil) do
    tab_scope = if tabs_id, do: "##{tabs_id} .pa-tabs__item", else: ".pa-tabs__item"
    tab_scope = if tab_item_id, do: "#{tab_scope}:not(##{tab_item_id})", else: tab_scope
    # Scope panels to a content container with id derived from tabs id
    panel_scope = if tabs_id, do: "##{tabs_id}-content .pa-tabs__panel", else: ".pa-tabs__panel"

    %JS{}
    |> JS.add_class("pa-tabs__item--active")
    |> JS.remove_class("pa-tabs__item--active", to: tab_scope)
    |> JS.add_class("pa-tabs__panel--active", to: "##{target_panel_id}")
    |> JS.remove_class("pa-tabs__panel--active", to: "#{panel_scope}:not(##{target_panel_id})")
  end
end
