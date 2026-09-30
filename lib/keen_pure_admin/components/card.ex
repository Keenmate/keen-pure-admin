defmodule PureAdmin.Components.Card do
  @moduledoc """
  Card components for Pure Admin.

  Provides `card/1` with named slots for header, body, footer, tabs, and tools.
  Supports ghost mode, header underlines, live state indicators, and theme colors.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  @doc """
  Renders a card with Pure Admin BEM classes.

  ## Examples

      <.card>
        <p>Simple card content.</p>
      </.card>

      <.card title_text="Analytics Dashboard" description_text="Last 30 days">
        Dashboard content.
      </.card>

      <.card variant="primary" is_header_underlined>
        <:title text="Analytics Dashboard" icon="📊" />
        <:tools>
          <.button variant="secondary" size="sm">Refresh</.button>
        </:tools>
        Dashboard content.
      </.card>

      <.card is_ghost>
        <p>Ghost card with no background, border, or shadow.</p>
      </.card>
  """
  attr(:variant, :string,
    default: nil,
    values: [
      nil,
      "primary",
      "success",
      "warning",
      "danger",
      "stat",
      "color-1",
      "color-2",
      "color-3",
      "color-4",
      "color-5",
      "color-6",
      "color-7",
      "color-8",
      "color-9"
    ]
  )

  attr(:live_state, :string,
    default: nil,
    values: [nil, "up", "down", "neutral"],
    doc: "Persistent tinted background reflecting latest change"
  )

  attr(:is_ghost, :boolean, default: false, doc: "Ghost mode with no bg, border, shadow")
  attr(:is_bordered, :boolean,
    default: false,
    doc:
      "Deprecated no-op — core has no `pa-card--bordered` rule. For a coloured left " <>
        "border use a `variant` (primary/success/warning/danger) or `color-{1..9}`."
  )
  attr(:has_padding, :boolean, default: true, doc: "Body padding toggle")
  attr(:title_text, :string, default: nil, doc: "Simple title text (shorthand for :title slot)")
  attr(:description_text, :string, default: nil, doc: "Inline description text, truncates with ellipsis")
  attr(:subtitle_text, :string, default: nil, doc: "Secondary/subtitle text")
  attr(:is_header_underlined, :boolean, default: false, doc: "Accent border under heading")

  attr(:header_underline_color, :string,
    default: nil,
    values: [nil, "success", "warning", "danger", "info"],
    doc: "Underline color variant"
  )

  attr(:header_underline_theme_color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    doc:
      "Theme-slot underline colour (1-9). Emits `pa-card__header--underline-color-{n}`; " <>
        "requires `is_header_underlined`. Mirrors core's `pa-card__header--underline-color-*` " <>
        "(2.9.0) and svelte-pure-admin's `headerUnderlineThemeColor`."
  )

  attr(:has_inline_tabs, :boolean, default: false, doc: "Pill-style buttons in header")
  attr(:header_wrap, :boolean, default: false, doc: "Allow header description to wrap")
  attr(:header_class, :string, default: nil, doc: "Additional CSS classes for header element")

  attr(:title_class, :string,
    default: nil,
    doc:
      "Additional CSS classes for the `.pa-card__title` element. Useful with `actions_variant=\"overflow\"` to give the title a min-width floor (e.g. `\"minw-45\"`) so it yields before the header actions collapse, matching the pure-admin card-overflow snippet."
  )

  attr(:actions_variant, :string,
    default: nil,
    values: [nil, "responsive", "overflow"],
    doc:
      "Collapse model for header `:tools` actions. `\"responsive\"` swaps the full button row for a `<.btn_split>` form via a container query (CSS-only — provide both `.pa-card__actions-full` and `.pa-card__actions-collapsed` subtrees inside `:tools`). `\"overflow\"` JS-collapses buttons into a `...` menu one at a time as the row shrinks (wires up `PureAdminCardActionsOverflow` automatically); buttons can carry `data-pa-actions-priority=\"N\"` to pin (higher stays longer)."
  )

  attr(:actions_overflow_from, :string,
    default: "end",
    values: ["start", "end"],
    doc:
      "Tiebreak direction for `actions_variant=\"overflow\"`. `\"end\"` (default) drops the rightmost button first; `\"start\"` drops leftmost first. Flips at runtime via DOM attribute (MutationObserver re-runs the drop walk)."
  )

  attr(:actions_overflow_trigger, :string,
    default: nil,
    values: [nil, "secondary", "ghost"],
    doc:
      "`[⋮]` more-trigger look for `actions_variant=\"overflow\"`, emitted as `data-pa-overflow-trigger`. Default (nil) is the standard bordered `pa-btn--secondary` square (upstream default as of 2.9.0-rc06); `\"ghost\"` swaps in the chromeless look."
  )

  attr(:actions_id, :string,
    default: nil,
    doc:
      "Optional id for the `:tools` actions wrapper. Required when `actions_variant=\"overflow\"` to wire the hook; auto-derived from `:rest`'s `id` if not given."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:header, doc: "Full custom header content (overrides title_text/description_text)")

  slot :title, doc: "Structured title with icon" do
    attr(:icon, :string)
    attr(:text, :string, required: true)
  end

  slot(:title_icon, doc: "Icon rendering before title")
  slot(:subtitle, doc: "Rich subtitle content (alternative to subtitle_text)")
  slot(:description, doc: "Rich description content (alternative to description_text)")
  slot(:tools, doc: "Header tools/actions")
  slot(:meta, doc: "Metadata text in header")
  slot(:tabs, doc: "Card tabs in header")
  slot(:footer, doc: "Card footer content")
  slot(:actions, doc: "Footer actions (right-aligned)")
  slot(:inner_block, required: true)

  def card(assigns) do
    has_structured_header =
      assigns.title != [] || assigns.title_text != nil || assigns.tools != [] ||
        assigns.meta != [] || assigns.tabs != [] || assigns.description != [] ||
        assigns.description_text != nil || assigns.title_icon != [] ||
        assigns.subtitle != [] || assigns.subtitle_text != nil

    has_header = assigns.header != [] || has_structured_header

    # rc05: the title is ALWAYS `.pa-card__title` > `.pa-card__title-text`
    # (the icon span is the only optional part) — never a bare <h3>. Resolve
    # a single title text + optional icon from the (:title slot | title_text)
    # and (:title_icon slot | :title slot's `icon` attr) inputs.
    title_slot = List.first(assigns.title)
    title_display_text = (title_slot && title_slot.text) || assigns.title_text
    title_slot_icon = title_slot && title_slot[:icon]

    assigns =
      assigns
      |> assign(:has_header, has_header)
      |> assign(:has_structured_header, has_structured_header)
      |> assign(:title_display_text, title_display_text)
      |> assign(:title_slot_icon, title_slot_icon)
      |> assign(:has_title, title_display_text != nil)
      |> assign(:has_title_icon, assigns.title_icon != [] || title_slot_icon != nil)

    ~H"""
    <div class={card_classes(assigns)} {@rest}>
      <%!-- Full custom header --%>
      <div :if={@has_header && @header != []} class={header_classes(assigns)}>
        <%= for header <- @header do %>
          <%= render_slot(header) %>
        <% end %>
      </div>

      <%!-- Structured header --%>
      <div :if={@has_header && @header == []} class={header_classes(assigns)}>
        <%!-- Canonical title (rc05): always .pa-card__title > .pa-card__title-text,
             with an optional .pa-card__title-icon span. Never a bare <h3>. --%>
        <div :if={@has_title} class={build_classes("pa-card__title", [], @title_class)}>
          <span :if={@has_title_icon} class="pa-card__title-icon"><%= if @title_icon != [], do: render_slot(@title_icon), else: @title_slot_icon %></span>
          <h3 class="pa-card__title-text"><%= @title_display_text %></h3>
        </div>

        <%!-- Inline tabs (after title) --%>
        <div :if={@tabs != [] && @has_inline_tabs} class="pa-card__tabs pa-card__tabs--inline">
          <%= for tabs <- @tabs do %>
            <%= render_slot(tabs) %>
          <% end %>
        </div>

        <%!-- Description (canonical .pa-card__description; truncates by default,
             `header_wrap` → pa-card__header--wrap opts out via CSS). --%>
        <p :if={@description_text != nil && @description == []} class="pa-card__description"><%= @description_text %></p>
        <%= for description <- @description do %>
          <p class="pa-card__description"><%= render_slot(description) %></p>
        <% end %>

        <%!-- Subtitle (legacy alias for the muted header byline). The canonical
             element is `.pa-card__meta` — a real card sub-element that
             participates in the header slot layout (styled --pc-text-color-2 +
             font-size-sm). Core defines NO `.pa-card__subtitle`, and the old
             `pa-text pa-text--secondary` was a generic utility off-contract.
             Matches the `:meta` slot below and svelte-pure-admin's card fix. --%>
        <span :if={@subtitle_text != nil && @subtitle == []} class="pa-card__meta"><%= @subtitle_text %></span>
        <%= for subtitle <- @subtitle do %>
          <span class="pa-card__meta"><%= render_slot(subtitle) %></span>
        <% end %>

        <%!-- Metadata --%>
        <%= for meta <- @meta do %>
          <span class="pa-card__meta"><%= render_slot(meta) %></span>
        <% end %>

        <%!-- Tools (slot kept as `:tools` for API stability; CSS class is
             `pa-card__actions` per pure-admin-core snippet). When
             `actions_variant` is set, the wrapper carries the matching
             `--responsive` / `--overflow` modifier; overflow wires the
             hook + drop direction. --%>
        <%= for tools <- @tools do %>
          <div
            class={actions_classes(@actions_variant)}
            data-pa-actions-overflow-from={@actions_variant == "overflow" && @actions_overflow_from || nil}
            data-pa-overflow-trigger={@actions_variant == "overflow" && @actions_overflow_trigger == "ghost" && "ghost" || nil}
            id={@actions_variant == "overflow" && (@actions_id || actions_auto_id(@rest)) || nil}
            phx-hook={@actions_variant == "overflow" && "PureAdminCardActionsOverflow" || nil}
            phx-update={@actions_variant == "overflow" && "ignore" || nil}
          ><%= render_slot(tools) %></div>
        <% end %>

      </div>
      <%!-- Tabs (non-inline, outside header) --%>
      <div :if={@has_header && @header == [] && @tabs != [] && !@has_inline_tabs} class="pa-card__tabs">
        <%= for tabs <- @tabs do %>
          <%= render_slot(tabs) %>
        <% end %>
      </div>

      <div class={body_classes(assigns)}>
        <%= render_slot(@inner_block) %>
      </div>
      <div :if={@footer != [] || @actions != []} class="pa-card__footer">
        <%= for footer <- @footer do %>
          <%= render_slot(footer) %>
        <% end %>
        <%= for actions <- @actions do %>
          <div class="pa-card__actions"><%= render_slot(actions) %></div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a card tab button.

  ## Examples

      <.card_tab is_active phx-click="switch-tab" phx-value-tab="overview">Overview</.card_tab>
  """
  attr(:is_active, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-click phx-value-tab))
  slot(:inner_block, required: true)

  def card_tab(assigns) do
    ~H"""
    <button
      class={build_classes("pa-card__tab", [{"pa-card__tab--active", @is_active}], @class)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp card_classes(assigns) do
    build_classes(
      "pa-card",
      [
        {"pa-card--#{assigns.variant}", assigns.variant != nil},
        {"pa-card--ghost", assigns.is_ghost},
        {"pa-card--live-#{assigns.live_state}", assigns.live_state != nil}
      ],
      assigns.class
    )
  end

  defp header_classes(assigns) do
    build_classes(
      "pa-card__header",
      [
        {"pa-card__header--wrap", assigns.header_wrap},
        {"pa-card__header--underlined", assigns.is_header_underlined},
        {"pa-card__header--underline-#{assigns.header_underline_color}", assigns.header_underline_color != nil},
        {"pa-card__header--underline-color-#{assigns.header_underline_theme_color}", assigns.header_underline_theme_color != nil}
      ],
      assigns.header_class
    )
  end

  defp body_classes(assigns) do
    build_classes("pa-card__body", [
      {"pa-card__body--no-padding", !assigns.has_padding}
    ])
  end

  defp actions_classes(variant) do
    build_classes(
      "pa-card__actions",
      [
        {"pa-card__actions--responsive", variant == "responsive"},
        {"pa-card__actions--overflow", variant == "overflow"}
      ],
      nil
    )
  end

  # Generate a stable-ish id for the overflow wrapper when no `actions_id` is
  # given and `:rest` doesn't carry one. The hook needs an id to track which
  # element it's attached to across LiveView patches.
  defp actions_auto_id(rest) do
    case Map.get(rest, :id) do
      nil -> "pa-card-actions-#{System.unique_integer([:positive])}"
      id -> "#{id}-actions"
    end
  end
end
