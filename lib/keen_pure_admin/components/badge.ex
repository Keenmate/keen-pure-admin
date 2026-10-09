defmodule PureAdmin.Components.Badge do
  @moduledoc """
  Badge, Label, CompositeBadge, and BadgeGroup components for Pure Admin.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  # -- badge/1 --

  @doc """
  Renders a badge with Pure Admin BEM classes.

  ## Examples

      <.badge variant="success">Active</.badge>
      <.badge variant="warning" size="sm" is_pill>Pending</.badge>
  """
  attr(:variant, :string,
    default: "primary",
    values: ["primary", "secondary", "success", "warning", "danger", "info", "light", "dark"],
    doc: "Color variant"
  )

  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])

  attr(:max_width, :string,
    default: nil,
    doc: "Max width in rem units (e.g. '5', '10', '15') - adds maxwr-N text-truncate"
  )

  attr(:is_pill, :boolean, default: false, doc: "Rounded pill shape")
  attr(:is_ellipsis_start, :boolean, default: false, doc: "Truncate from the left side")

  attr(:theme_color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    doc:
      "Theme colour slot 1-9. Emits `pa-badge--color-N` (v2.9.0-rc15+), which paints `--pc-color-N` with a guaranteed-contrasting `--pc-color-N-text` label — unlike the old generic `pa-bg-color-N` utility that only set the background and could land dark-text-on-dark."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon, doc: "Icon content inside pa-badge__icon")
  slot(:inner_block, required: true)

  def badge(assigns) do
    ~H"""
    <span class={badge_classes(assigns)} {@rest}>
      <span :for={icon <- @icon} class="pa-badge__icon"><%= render_slot(icon) %></span>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  defp badge_classes(assigns) do
    build_classes(
      "pa-badge",
      [
        # theme_color paints pa-badge--color-N and is the sole colour class —
        # it overrides `variant` (mirrors button/1), so the variant class is
        # suppressed when a theme_color slot is set.
        {"pa-badge--#{assigns.variant}", assigns.theme_color == nil},
        {"pa-badge--#{assigns.size}", assigns.size != nil},
        {"maxwr-#{assigns.max_width}", assigns.max_width != nil},
        {"text-truncate", assigns.max_width != nil},
        {"pa-badge--pill", assigns.is_pill},
        {"pa-badge--ellipsis-start", assigns.is_ellipsis_start},
        {"pa-badge--color-#{assigns.theme_color}", assigns.theme_color != nil}
      ],
      assigns.class
    )
  end

  # -- label/1 --

  @doc """
  Renders a lightweight label indicator.

  ## Examples

      <.label variant="success">Active</.label>
  """
  attr(:variant, :string,
    default: nil,
    values: [nil, "primary", "secondary", "success", "warning", "danger", "info"],
    doc: "Color variant — label has no light/dark (core emits no pa-label--light/--dark)"
  )

  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:is_outline, :boolean, default: false, doc: "Outline style")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def label(assigns) do
    ~H"""
    <span class={label_classes(assigns)} {@rest}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  defp label_classes(assigns) do
    build_classes(
      "pa-label",
      [
        {"pa-label--#{assigns.variant}", assigns.variant != nil},
        {"pa-label--#{assigns.size}", assigns.size != nil},
        {"pa-label--outline", assigns.is_outline}
      ],
      assigns.class
    )
  end

  # -- composite_badge/1 --

  @doc """
  Renders a three-part composite badge (icon + label + button/count).

  ## Examples

      <.composite_badge variant="primary" icon="🔔" label="Notifications" count="5" />

      <.composite_badge variant="info" label="Task #1234" button_text="×" is_interactive>
        <:icon_content>📋</:icon_content>
      </.composite_badge>

      <.composite_badge variant="primary" label_variant="secondary" button_variant="danger"
        label="Project" button_text="×" is_interactive />
  """
  attr(:variant, :string,
    default: "primary",
    values: ["primary", "secondary", "success", "warning", "danger", "info", "light", "dark"],
    doc: "Base color variant (icon section)"
  )

  attr(:label_variant, :string,
    default: nil,
    values: [nil, "primary", "secondary", "success", "warning", "danger", "info", "light", "dark"],
    doc: "Label section color (overrides variant)"
  )

  attr(:button_variant, :string,
    default: nil,
    values: [nil, "primary", "secondary", "success", "warning", "danger", "info", "light", "dark"],
    doc: "Button section color (overrides variant)"
  )

  attr(:icon_variant, :string,
    default: nil,
    values: [nil, "primary", "secondary", "success", "warning", "danger", "info", "light", "dark"],
    doc: "Icon section color (overrides variant)"
  )

  attr(:icon, :string, default: nil, doc: "Icon text or emoji")
  attr(:label, :string, required: true, doc: "Label text")
  attr(:count, :string, default: nil, doc: "Count/button text (legacy alias for button_text)")
  attr(:button_text, :string, default: nil, doc: "Button section text")

  attr(:is_interactive, :boolean,
    default: false,
    doc:
      "Deprecated no-op. Core bakes hover/cursor into the base `__label`/`__button`; " <>
        "there is no `pa-composite-badge--interactive` rule. Wire `on_label_click`/`on_button_click` instead."
  )

  attr(:on_label_click, :string, default: nil, doc: "LiveView event fired when label is clicked")
  attr(:on_button_click, :string, default: nil, doc: "LiveView event fired when button is clicked")
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-click phx-value-id phx-value-label phx-value-action))
  slot(:icon_content, doc: "Rich icon content (alternative to icon attr)")

  def composite_badge(assigns) do
    btn_text = assigns.button_text || assigns.count

    assigns = assign(assigns, :btn_text, btn_text)

    ~H"""
    <div class={build_classes("pa-composite-badge", [
      {"pa-composite-badge--#{@variant}", true},
      {"pa-composite-badge--label-#{@label_variant}", @label_variant != nil},
      {"pa-composite-badge--btn-#{@button_variant}", @button_variant != nil},
      {"pa-composite-badge--icon-#{@icon_variant}", @icon_variant != nil}
    ], @class)} {@rest}>
      <span :if={@icon && @icon_content == []} class="pa-composite-badge__icon"><%= @icon %></span>
      <span :for={ic <- @icon_content} class="pa-composite-badge__icon"><%= render_slot(ic) %></span>
      <span
        class="pa-composite-badge__label"
        phx-click={@on_label_click}
        phx-value-label={if @on_label_click, do: @label}
      ><%= @label %></span>
      <span
        :if={@btn_text}
        class="pa-composite-badge__button"
        phx-click={@on_button_click}
        phx-value-label={if @on_button_click, do: @label}
        phx-value-action={if @on_button_click, do: @btn_text}
      ><%= @btn_text %></span>
    </div>
    """
  end

  # -- badge_group/1 --

  @doc """
  Renders a container for multiple badges with optional expand/collapse.

  ## Modes

  - **No limit** — all badges visible (default)
  - **Client-side** — set `limit` and `total`, JS toggles visibility without server round-trip
  - **Server-side** — set `limit`, `total`, `is_expanded`, and `on_toggle` event name;
    server loads additional data on expand

  ## Examples

      <%!-- Simple group, no limit --%>
      <.badge_group>
        <.badge variant="primary">Elixir</.badge>
        <.badge variant="info">Phoenix</.badge>
      </.badge_group>

      <%!-- Client-side expand/collapse --%>
      <.badge_group limit={5} total={15}>
        <.badge :for={tag <- @tags} variant={tag.variant}><%= tag.label %></.badge>
      </.badge_group>

      <%!-- Server-side expand (fires phx event to load more) --%>
      <.badge_group limit={5} total={@total} is_expanded={@expanded} on_toggle="expand_tags">
        <.badge :for={tag <- @tags} variant={tag.variant}><%= tag.label %></.badge>
      </.badge_group>
  """
  attr(:limit, :integer, default: nil, doc: "Max visible badges before showing 'N more' (nil = no limit)")
  attr(:total, :integer, default: nil, doc: "Total badge count (for 'N more' calculation when server hasn't sent all)")
  attr(:is_expanded, :boolean, default: false, doc: "Current expand state (server-side mode)")

  attr(:on_toggle, :string,
    default: nil,
    doc: "LiveView event name for expand/collapse (server-side mode). When nil, uses client-side JS."
  )

  attr(:is_show_all, :boolean, default: false, doc: "Show all badges (CSS class, no limit logic)")

  attr(:more_text, :string,
    default: "» {count} more",
    doc: "Text for 'show more' badge. {count} is replaced with hidden count."
  )

  attr(:collapse_text, :string, default: "« Collapse", doc: "Text for 'collapse' badge")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def badge_group(assigns) do
    hidden_count =
      if assigns.limit && assigns.total do
        max(assigns.total - assigns.limit, 0)
      else
        0
      end

    show_more = assigns.limit != nil && hidden_count > 0 && !assigns.is_expanded
    show_collapse = assigns.limit != nil && assigns.is_expanded && hidden_count > 0

    more_label = String.replace(assigns.more_text, "{count}", "#{hidden_count}")

    assigns =
      assigns
      |> assign(:hidden_count, hidden_count)
      |> assign(:show_more, show_more)
      |> assign(:show_collapse, show_collapse)
      |> assign(:more_label, more_label)
      |> assign(:use_js, assigns.on_toggle == nil)

    # Client-side mode needs a stable unique id
    js_id =
      if assigns.limit && assigns.on_toggle == nil do
        assigns[:id] || "badge-group-#{:erlang.phash2(assigns)}"
      end

    assigns = assign(assigns, :js_id, js_id)

    ~H"""
    <div
      id={@js_id}
      class={build_classes("pa-badge-group", [
        {"pa-badge-group--show-all", @is_show_all || @limit != nil}
      ], @class)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <%!-- Server-side mode: fires event --%>
      <span
        :if={@show_more && !@use_js}
        class="pa-badge pa-badge--secondary cursor-pointer"
        phx-click={@on_toggle}
      >
        <%= @more_label %>
      </span>
      <span
        :if={@show_collapse && !@use_js}
        class="pa-badge pa-badge--secondary cursor-pointer"
        phx-click={@on_toggle}
      >
        <%= @collapse_text %>
      </span>
      <%!-- Client-side mode: CSS hides overflow, the delegated event wired via
           `initPureAdminEvents()` toggles the expanded class on click. --%>
      <span
        :if={@show_more && @use_js}
        class="pa-badge pa-badge--secondary cursor-pointer pa-badge-group__toggle-more"
        data-pa-badge-group-expand
      >
        <%= @more_label %>
      </span>
      <span
        :if={@show_more && @use_js}
        class="pa-badge pa-badge--secondary cursor-pointer pa-badge-group__toggle-collapse"
        data-pa-badge-group-collapse
      >
        <%= @collapse_text %>
      </span>
    </div>
    <%!-- CSS-based hiding: survives LiveView DOM patching --%>
    <style :if={@show_more && @use_js}>
      /* Collapsed: hide badges beyond limit */
      #<%= @js_id %> > :nth-child(n+<%= @limit + 1 %>):not(.pa-badge-group__toggle-more):not(.pa-badge-group__toggle-collapse) {
        display: none;
      }
      /* Collapsed: hide collapse button */
      #<%= @js_id %> > .pa-badge-group__toggle-collapse {
        display: none;
      }
      /* Expanded: show all badges */
      #<%= @js_id %>.pa-badge-group--expanded > :nth-child(n+<%= @limit + 1 %>):not(.pa-badge-group__toggle-more) {
        display: inline-flex;
      }
      /* Expanded: hide more button */
      #<%= @js_id %>.pa-badge-group--expanded > .pa-badge-group__toggle-more {
        display: none !important;
      }
    </style>
    """
  end
end
