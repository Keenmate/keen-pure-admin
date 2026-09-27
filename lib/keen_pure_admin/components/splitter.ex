defmodule PureAdmin.Components.Splitter do
  @moduledoc """
  Splitter component — resizable container with two or more panes.

  Wraps pure-admin-core's `.pa-splitter` (v2.9.0+). Renders the splitter
  root + alternating pane / gutter children + wires the `PureAdminSplitter`
  hook for LiveView mount safety. All drag, keyboard, minimize-to-rail, and
  localStorage persistence behaviour lives in the JS hook (ported verbatim
  from upstream).

  ## Examples

      <.splitter id="demo" orientation="horizontal" style="height: 400px;">
        <:pane size="280px" min="200px" max="60%">
          <!-- Sidebar / list content -->
        </:pane>
        <:pane>
          <!-- Main / detail content (fills remainder) -->
        </:pane>
      </.splitter>

      <.splitter
        id="three-pane"
        orientation="horizontal"
        style="height: 400px;"
      >
        <:pane size="240px" min="180px" max="360px" is_minimizable>
          File tree
        </:pane>
        <:pane min="240px">
          Editor (fills remainder)
        </:pane>
        <:pane size="280px" min="220px" max="420px" is_minimizable>
          Inspector
        </:pane>
      </.splitter>

  ## Persistence

  Pass `id` to enable `localStorage` persistence under `pa-splitter:<id>`.
  Saved layout shape (N-pane): `{ v: 2, sizes: [...], lasts: [...], minimized: [...] }`.
  Omit `id` for a session-only splitter.

  ## Minimize-to-rail

  Set `is_minimizable` on the first and / or last pane. The pane collapses
  to a thin rail (default 40px, configurable via `rail_size`) on:

    * gutter double-click / `Enter` / `Space`
    * click of any descendant with `data-pa-splitter-toggle`
    * drag-into-rail across the snap threshold
    * click on the rail itself (to restore)

  Cards inside minimizable panes adapt automatically — `_cards.scss` rotates
  the header inside any `.pa-splitter__pane--minimized`. For non-card
  content, mark the title element with `data-pa-splitter-rail-title` so it
  also rotates.

  ## Events (v2.9.0-rc04+)

  The splitter emits three bubbling `CustomEvent`s from the affected pane, so
  a consumer can listen once on the splitter root (or higher):

    * `pa-splitter:resize` — `detail: { index, pane, size }`, fired per pane on
      every size application (unfiltered during drag — debounce if expensive).
    * `pa-splitter:collapse` — `detail: { index, pane }`, when a pane rails.
    * `pa-splitter:expand` — `detail: { index, pane }`, when a pane restores.

  Init from saved state does *not* fire `collapse` for panes that load already
  rail'd — only user-initiated transitions emit. Each pane is also stamped with
  `pa-splitter__pane--horizontal` / `--vertical` at registration.

  ## Two markup modes

  Upstream v2.9.0-rc05 dropped the legacy 2-pane shorthand. This wrapper always
  emits the N-pane form (per-pane attributes); for backward compatibility with
  hand-written legacy markup, `splitter_core.js` carries a keen-only
  `normalizeLegacyMarkup()` shim that translates the old root-level `min-start` /
  `max-start` / `default` / `minimize="start|end"` attributes into per-pane form
  at init, so both shapes keep working through a single code path.
  """
  use Phoenix.Component

  attr(:id, :string,
    default: nil,
    doc:
      "Persistence id. When set, layout saves to `localStorage` under `pa-splitter:<id>`. Also used as the hook anchor for LiveView lifecycle."
  )

  attr(:orientation, :string,
    default: "horizontal",
    values: ["horizontal", "vertical"],
    doc:
      "`\"horizontal\"` → panes side-by-side, vertical gutter. `\"vertical\"` → panes stacked, horizontal gutter. The splitter takes whatever cross-axis size its parent provides (height for horizontal, width for vertical) — make sure the parent is sized or panes collapse."
  )

  attr(:rail_size, :integer,
    default: nil,
    doc:
      "Rail width in px when a pane is minimized. Defaults to the `--pa-splitter-rail-size` CSS custom property (or `40` if unset)."
  )

  attr(:step, :integer,
    default: nil,
    doc: "Keyboard arrow-step in px. Default `10`."
  )

  attr(:minimize_threshold, :string,
    default: nil,
    doc: "Drag-into-rail snap ratio of the drag-start size, floored at `rail × 1.5`. Default `\"0.40\"`."
  )

  attr(:is_minimize_mirror, :boolean,
    default: false,
    doc:
      "Flip the minimized rail-title text 180° (transform: scale(-1,-1) on the heading inside `[data-pa-splitter-rail-title]` or `.pa-card__header`). Useful when bottom-to-top reading direction is preferred."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(style))

  slot :pane,
    required: true,
    doc: "One slot entry per pane. Panes and gutters interleave automatically (N panes → N-1 gutters)." do
    attr(:size, :string,
      doc:
        "Initial size as a px (`\"240px\"`) or percent (`\"30%\"`) value. Panes without `size` share the leftover equally — or, if every pane has a `size`, the last one absorbs the remainder."
    )

    attr(:min, :string, doc: "Minimum size as px or %. Default `0`.")
    attr(:max, :string, doc: "Maximum size as px or %. Default `available`.")

    attr(:is_minimizable, :boolean,
      doc:
        "Mark this pane as collapsible-to-rail. Only honoured on the first and last panes (middle panes have no clean rail edge to dock against)."
    )

    attr(:class, :string, doc: "Extra classes on the `.pa-splitter__pane` element.")
    attr(:style, :string, doc: "Inline style on the `.pa-splitter__pane` element.")
  end

  def splitter(assigns) do
    assigns =
      assigns
      |> assign(:pane_count, length(assigns.pane))
      |> assign(:gutter_aria, gutter_aria(assigns.orientation))

    ~H"""
    <div
      id={@id}
      class={[
        "pa-splitter",
        "pa-splitter--#{@orientation}",
        @is_minimize_mirror && "pa-splitter--minimize-mirror",
        @class
      ]}
      data-pa-splitter
      data-pa-splitter-id={@id}
      data-pa-splitter-step={@step}
      data-pa-splitter-rail-size={@rail_size}
      data-pa-splitter-minimize-threshold={@minimize_threshold}
      phx-hook={@id && "PureAdminSplitter"}
      phx-update="ignore"
      {@rest}
    >
      <%= for {pane, idx} <- Enum.with_index(@pane) do %>
        <div
          class={["pa-splitter__pane", pane[:class]]}
          style={pane[:style]}
          data-pa-splitter-size={pane[:size]}
          data-pa-splitter-min={pane[:min]}
          data-pa-splitter-max={pane[:max]}
          data-pa-splitter-minimize={pane[:is_minimizable] && "" || nil}
        ><%= render_slot(pane) %></div>
        <div
          :if={idx < @pane_count - 1}
          class="pa-splitter__gutter"
          role="separator"
          aria-orientation={@gutter_aria}
          tabindex="0"
        ></div>
      <% end %>
    </div>
    """
  end

  defp gutter_aria("horizontal"), do: "vertical"
  defp gutter_aria("vertical"), do: "horizontal"
end
