defmodule PureAdmin.Components.Pager do
  @moduledoc """
  Pager and LoadMore components for Pure Admin.
  """
  use Phoenix.Component

  import PureAdmin.Helpers
  import PureAdmin.Translations, only: [t: 1, t: 2]

  @doc """
  Renders a pagination control.

  ## Icons

  The four navigation icons default to Unicode chevrons (`«‹›»`). Override them
  with either a plain string (rendered as escaped text) or a slot (for arbitrary
  markup like a Font Awesome icon or inline SVG).

  ### Examples

      <.pager page={@page} total_pages={@total_pages} on_previous="prev_page" on_next="next_page" />

      <.pager page={3} total_pages={10} on_previous="prev" on_next="next" on_first="first" on_last="last" />

      <.pager page={1} total_pages={10} align="end" info_text="Showing 1-25 of 250" />

      <.pager page={@page} total_pages={@total}>
        <:previous_icon><i class="fa-solid fa-angle-left"></i></:previous_icon>
        <:next_icon><i class="fa-solid fa-angle-right"></i></:next_icon>
      </.pager>
  """
  attr(:page, :integer, default: 1)
  attr(:total_pages, :integer, default: 1)
  attr(:align, :string, default: nil, values: [nil, "start", "center", "end"])
  attr(:show_page_input, :boolean, default: true, doc: "Show page number input")
  attr(:show_info, :boolean, default: true, doc: "Show info section")
  attr(:info_text, :string, default: nil, doc: "Custom info text (overrides page X of Y)")
  attr(:on_previous, :string, default: "prev-page", doc: "Event for previous button")
  attr(:on_next, :string, default: "next-page", doc: "Event for next button")
  attr(:on_first, :string, default: nil, doc: "Event for first button (nil = hidden)")
  attr(:on_last, :string, default: nil, doc: "Event for last button (nil = hidden)")
  attr(:on_page_change, :string, default: nil, doc: "Event for page input change")

  attr(:icon_first, :string,
    default: "«",
    doc: "First page button icon (plain text; rendered HTML-escaped). For markup, use the `first_icon` slot."
  )

  attr(:icon_previous, :string,
    default: "‹",
    doc: "Previous page button icon (plain text; rendered HTML-escaped). For markup, use the `previous_icon` slot."
  )

  attr(:icon_next, :string,
    default: "›",
    doc: "Next page button icon (plain text; rendered HTML-escaped). For markup, use the `next_icon` slot."
  )

  attr(:icon_last, :string,
    default: "»",
    doc: "Last page button icon (plain text; rendered HTML-escaped). For markup, use the `last_icon` slot."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:controls, doc: "Custom controls (overrides default buttons)")
  slot(:info, doc: "Custom info content (overrides default info)")
  slot(:first_icon, doc: "Custom first-page icon markup (overrides `icon_first` attr)")
  slot(:previous_icon, doc: "Custom previous-page icon markup (overrides `icon_previous` attr)")
  slot(:next_icon, doc: "Custom next-page icon markup (overrides `icon_next` attr)")
  slot(:last_icon, doc: "Custom last-page icon markup (overrides `icon_last` attr)")

  def pager(assigns) do
    ~H"""
    <div class={build_classes("pa-pager", [{"pa-pager--#{@align}", @align != nil}], @class)} {@rest}>
      <div class="pa-pager__container">
        <%= if @controls != [] do %>
          <%= render_slot(@controls) %>
        <% else %>
          <%!-- Canonical shape (snippets/tables.html:382-393): ALL nav buttons in a
               SINGLE .pa-pager__controls, then a trailing .pa-pager__info. (keen
               used to split into two __controls groups straddling __info.) --%>
          <%!-- Buttons carry NO title attr: the blessed snippet (snippets/tables.html)
               and the svelte wrapper emit none, and one-canonical-shape is a core
               rule. Icon-only a11y labels, when needed, ride the slots / an aria
               attr the caller supplies — not a hardcoded title that forks the markup. --%>
          <div class="pa-pager__controls">
            <button :if={@on_first} class="pa-btn pa-btn--sm pa-btn--secondary" disabled={@page <= 1} phx-click={@on_first}>
              <%= if @first_icon != [], do: render_slot(@first_icon), else: @icon_first %>
            </button>
            <button class="pa-btn pa-btn--sm pa-btn--secondary" disabled={@page <= 1} phx-click={@on_previous}>
              <%= if @previous_icon != [], do: render_slot(@previous_icon), else: @icon_previous %>
            </button>
            <button class="pa-btn pa-btn--sm pa-btn--secondary" disabled={@page >= @total_pages} phx-click={@on_next}>
              <%= if @next_icon != [], do: render_slot(@next_icon), else: @icon_next %>
            </button>
            <button :if={@on_last} class="pa-btn pa-btn--sm pa-btn--secondary" disabled={@page >= @total_pages} phx-click={@on_last}>
              <%= if @last_icon != [], do: render_slot(@last_icon), else: @icon_last %>
            </button>
          </div>

          <%= if @info != [] do %>
            <%= render_slot(@info) %>
          <% else %>
            <div :if={@show_info && @show_page_input && @info_text == nil} class="pa-pager__info">
              <input
                type="number"
                class="pa-input pa-input--sm pa-pager__input"
                value={@page}
                min="1"
                max={@total_pages}
                phx-change={@on_page_change}
                name="page"
              />
              <span class="pa-pager__text"><%= t("pureAdmin.pagination.pages", %{total: @total_pages}) %></span>
            </div>
            <span :if={@info_text} class="pa-pager__text"><%= @info_text %></span>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a load more button.

  ## Examples

      <.load_more phx-click="load_more" count="25 of 250" />
      <.load_more is_loading phx-click="load_more">Loading...</.load_more>
      <.load_more align="start" phx-click="load_more">Show More Items</.load_more>
  """
  attr(:is_loading, :boolean, default: false)
  attr(:count, :string, default: nil, doc: "Count text, e.g. '25 of 250'")
  attr(:align, :string, default: nil, values: [nil, "start", "center", "end"])
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-click))
  slot(:inner_block)

  def load_more(assigns) do
    ~H"""
    <div class={build_classes("pa-load-more", [{"pa-load-more--#{@align}", @align != nil}], @class)}>
      <button class={build_classes("pa-load-more__button", [{"pa-load-more__button--loading", @is_loading}])} {@rest}>
        <span :if={@is_loading} class="pa-load-more__spinner"></span>
        <span class="pa-load-more__text">
          <%= if @inner_block != [], do: render_slot(@inner_block), else: t("pureAdmin.pagination.loadMore") %>
        </span>
        <span :if={@count} class="pa-load-more__count">(<%= @count %>)</span>
      </button>
    </div>
    """
  end
end
