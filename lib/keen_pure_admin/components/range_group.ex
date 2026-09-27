defmodule PureAdmin.Components.RangeGroup do
  @moduledoc """
  Range group + range slider components for Pure Admin.

  Wraps the upstream `.pa-range` slider primitive and the `.pa-range-group`
  compact multi-range filter (pure-admin-core v2.9.0-rc04+).

  Two components ship together on purpose:

    * `range/1` — the standalone slider primitive (`.pa-range`). Single- or
      dual-thumb, optional handle-shape modifier, optional tick marks. Emits
      the exact BEM markup the `PaRangeGroup` JS reads (thumbs, fill, rail).
    * `range_group/1` — the compact toggle + floating panel wrapper
      (`.pa-range-group`) over N range rows. One toggle summarises several
      numeric filters inline ("Age 25–60 / Salary $40,000+ / Children 2+")
      and expands into a Floating-UI panel with one `range/1` per dimension.

  The behaviour (dual-thumb drag, keyboard nav, click-to-seek, tick marks,
  the floating panel that reparents to `<body>`) is driven by the
  `PureAdminRangeGroup` hook (`range_group_core.js`, a verbatim port of the
  upstream IIFE). Values are read from per-row `data-*` attributes at init.

  ## Row API

  `range_group/1` takes one `:range` slot per dimension. Each slot carries the
  per-row config as slot attributes, mirroring the upstream `data-*` contract:

  | Slot attr        | data-attr           | Notes                                   |
  |------------------|---------------------|-----------------------------------------|
  | `key`            | `data-key`          | Identity, used in event payloads        |
  | `label`          | `data-label`        | Display label                           |
  | `min` / `max`    | `data-min/-max`     | Bounds (required)                       |
  | `step`           | `data-step`         | Increment (default 1)                   |
  | `mode`           | `data-mode`         | `"range"` (default) or `"single"`       |
  | `bound`          | `data-bound`        | single only: `"gte"` (default) / `"lte"`|
  | `value`          | `data-value`        | single initial value                    |
  | `value_min/_max` | `data-value-min/-max`| range initial low / high               |
  | `prefix`/`suffix`| `data-prefix/-suffix`| strings wrapping the number            |
  | `is_thousands`   | `data-thousands`    | group integer with `,` separators       |
  | `ticks`          | `data-ticks`        | major tick interval (value units)       |
  | `ticks_minor`    | `data-ticks-minor`  | minor tick interval                     |
  | `is_tick_labels` | `data-tick-labels`  | print major values under the ticks      |
  | `is_snap_ticks`  | `data-snap-ticks`   | thumbs settle on nearest tick           |
  | `handle`         | `pa-range--handle-*`| `"rect"`/`"bar"`/`"arrow"`/`"needle"`   |
  | `row_label`      | —                   | override row-head label (defaults label)|

  The same attrs are accepted directly by `range/1` when used standalone.

  ## Theming caveat

  The `__panel` reparents to `<body>` while open, so per-instance
  `--pa-range-*` token overrides must sit on the panel (via `panel_style`) or
  the `.pa-range` rows — NOT on the `.pa-range-group` root.

  ## Examples

      <.range_group id="people-filters">
        <:range key="age" label="Age" min={18} max={80}
                value_min={25} value_max={60} />
        <:range key="salary" label="Salary" min={0} max={200_000} step={5000}
                value_min={40_000} value_max={200_000} prefix="$" is_thousands />
        <:range key="children" label="Children" min={0} max={8}
                mode="single" bound="gte" value={2} />
      </.range_group>

      <.range key="age" label="Age" min={18} max={80}
              value_min={25} value_max={60} />
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  @handle_shapes ~w(rect bar arrow needle)

  @doc """
  Renders a standalone `.pa-range` slider primitive.

  Single- or dual-thumb, with an optional handle-shape modifier and optional
  tick marks. Emits the exact markup the `PaRangeGroup` JS reads — the
  interactive positioning is applied at init from the `data-*` attributes.

  Standalone `range/1` still needs the `PureAdminRangeGroup` JS to become
  interactive; use it inside a `range_group/1`, or auto-init runs at
  `DOMContentLoaded` for statically-rendered rows.

  ## Examples

      <.range key="age" label="Age" min={18} max={80} value_min={25} value_max={60} />

      <.range key="rating" label="Rating" min={0} max={5} step={0.5}
              mode="single" bound="gte" value={4} suffix="★" />

      <.range key="score" label="Score" min={0} max={100} step={5}
              value_min={40} value_max={90} ticks={25} handle="rect" />
  """
  attr(:key, :string, default: nil, doc: "data-key — identity used in event payloads")
  attr(:label, :string, default: nil, doc: "data-label — display label")
  attr(:min, :any, default: nil, doc: "data-min — lower bound (required)")
  attr(:max, :any, default: nil, doc: "data-max — upper bound (required)")
  attr(:step, :any, default: nil, doc: "data-step — increment (default 1)")

  attr(:mode, :string,
    default: "range",
    values: ["range", "single"],
    doc: "data-mode — `range` (dual-thumb, default) or `single` (threshold)"
  )

  attr(:bound, :string,
    default: nil,
    values: [nil, "gte", "lte"],
    doc: "data-bound — single mode only: `gte` (default) or `lte`"
  )

  attr(:value, :any, default: nil, doc: "data-value — single-mode initial value")
  attr(:value_min, :any, default: nil, doc: "data-value-min — range-mode initial low")
  attr(:value_max, :any, default: nil, doc: "data-value-max — range-mode initial high")
  attr(:prefix, :string, default: nil, doc: "data-prefix — string prepended to the number")
  attr(:suffix, :string, default: nil, doc: "data-suffix — string appended to the number")
  attr(:is_thousands, :boolean, default: false, doc: "data-thousands — group the integer with `,`")
  attr(:ticks, :any, default: nil, doc: "data-ticks — major tick interval (value units)")
  attr(:ticks_minor, :any, default: nil, doc: "data-ticks-minor — minor tick interval")
  attr(:is_tick_labels, :boolean, default: false, doc: "data-tick-labels — print major values")
  attr(:is_snap_ticks, :boolean, default: false, doc: "data-snap-ticks — settle on nearest tick")

  attr(:handle, :string,
    default: nil,
    values: [nil | @handle_shapes],
    doc: "Handle-shape modifier: `rect` / `bar` / `arrow` / `needle` (default round)"
  )

  attr(:aria_label_min, :string, default: nil, doc: "aria-label for the min thumb")
  attr(:aria_label_max, :string, default: nil, doc: "aria-label for the max thumb")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def range(assigns) do
    assigns = assign(assigns, :single, assigns.mode == "single")

    ~H"""
    <div
      class={range_classes(assigns)}
      data-range
      data-key={@key}
      data-label={@label}
      data-min={@min}
      data-max={@max}
      data-step={@step}
      data-mode={if @single, do: "single"}
      data-bound={if @single, do: @bound}
      data-value={if @single, do: @value}
      data-value-min={unless @single, do: @value_min}
      data-value-max={unless @single, do: @value_max}
      data-prefix={@prefix}
      data-suffix={@suffix}
      data-thousands={@is_thousands || nil}
      data-ticks={@ticks}
      data-ticks-minor={@ticks_minor}
      data-tick-labels={@is_tick_labels || nil}
      data-snap-ticks={@is_snap_ticks || nil}
      {@rest}
    >
      <div class="pa-range__rail">
        <div class="pa-range__track"></div>
        <div class="pa-range__fill" data-range-fill></div>
        <button
          type="button"
          class="pa-range__thumb pa-range__thumb--min"
          data-range-thumb="min"
          aria-hidden={if @single, do: "true"}
          aria-label={unless @single, do: @aria_label_min || min_label(@label)}
        >
        </button>
        <button
          type="button"
          class="pa-range__thumb pa-range__thumb--max"
          data-range-thumb="max"
          aria-label={@aria_label_max || thumb_label(assigns)}
        >
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Renders a `.pa-range-group` — a compact toggle + floating panel over N range
  rows.

  Wires the `PureAdminRangeGroup` hook (requires `id`). Each `:range` slot
  becomes one `.pa-range-group__row` (head + slider) inside the panel. The
  toggle summary and each row's value readout are populated by the JS.

  Per-instance `--pa-range-*` token overrides go on `panel_style` (the panel
  reparents to `<body>` when open, so tokens on the root wouldn't reach the
  sliders).

  ## Examples

      <.range_group id="people-filters">
        <:range key="age" label="Age" min={18} max={80}
                value_min={25} value_max={60} />
        <:range key="salary" label="Salary" min={0} max={200_000} step={5000}
                value_min={40_000} value_max={200_000} prefix="$" is_thousands />
        <:range key="children" label="Children" min={0} max={8}
                mode="single" bound="gte" value={2} />
      </.range_group>
  """
  attr(:id, :string, required: true, doc: "DOM id — required to wire the hook")
  attr(:panel_aria_label, :string, default: "Numeric filters", doc: "aria-label on the panel dialog")
  attr(:panel_style, :string, default: nil, doc: "Inline style on the __panel (place --pa-range-* here)")
  attr(:reset_text, :string, default: "Reset", doc: "Reset button label")
  attr(:apply_text, :string, default: "Apply", doc: "Apply button label")
  attr(:has_actions, :boolean, default: true, doc: "Render the Reset / Apply footer")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :range, required: true, doc: "One filter dimension. Attrs mirror `range/1` + `row_label`." do
    attr(:key, :string)
    attr(:label, :string)
    attr(:row_label, :string)
    attr(:min, :any)
    attr(:max, :any)
    attr(:step, :any)
    attr(:mode, :string)
    attr(:bound, :string)
    attr(:value, :any)
    attr(:value_min, :any)
    attr(:value_max, :any)
    attr(:prefix, :string)
    attr(:suffix, :string)
    attr(:is_thousands, :boolean)
    attr(:ticks, :any)
    attr(:ticks_minor, :any)
    attr(:is_tick_labels, :boolean)
    attr(:is_snap_ticks, :boolean)
    attr(:handle, :string)
  end

  def range_group(assigns) do
    ~H"""
    <div
      id={@id}
      class={build_classes("pa-range-group", [], @class)}
      data-range-group
      phx-hook="PureAdminRangeGroup"
      phx-update="ignore"
      {@rest}
    >
      <button
        type="button"
        class="pa-range-group__toggle"
        data-range-group-toggle
        aria-expanded="false"
      >
        <span class="pa-range-group__summary" data-range-group-summary></span>
        <span class="pa-range-group__caret" aria-hidden="true"></span>
      </button>

      <div
        class="pa-range-group__panel"
        data-range-group-panel
        role="dialog"
        aria-label={@panel_aria_label}
        style={@panel_style}
      >
        <div :for={row <- @range} class="pa-range-group__row">
          <div class="pa-range-group__row-head">
            <span class="pa-range-group__row-label"><%= row_label(row) %></span>
            <span class="pa-range-group__row-value" data-range-output></span>
          </div>
          <.range {row_assigns(row)} />
        </div>

        <div :if={@has_actions} class="pa-range-group__actions">
          <button type="button" class="pa-btn pa-btn--sm pa-btn--ghost" data-range-group-reset>
            <%= @reset_text %>
          </button>
          <button type="button" class="pa-btn pa-btn--sm pa-btn--primary" data-range-group-apply>
            <%= @apply_text %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ── private ────────────────────────────────────────────────────────────────

  defp range_classes(assigns) do
    build_classes(
      "pa-range",
      [
        {"pa-range--single", assigns.mode == "single"},
        {"pa-range--handle-#{assigns.handle}", assigns.handle in @handle_shapes}
      ],
      assigns.class
    )
  end

  # aria-label for the lone (max) thumb in single mode, or the max thumb in
  # range mode — mirrors the snippet's "Minimum children" (gte) phrasing.
  defp thumb_label(%{single: true, bound: "lte", label: label}), do: "Maximum #{downcase(label)}"
  defp thumb_label(%{single: true, label: label}), do: "Minimum #{downcase(label)}"
  defp thumb_label(%{label: label}), do: "Maximum #{downcase(label)}"

  defp min_label(nil), do: nil
  defp min_label(label), do: "Minimum #{downcase(label)}"

  defp downcase(nil), do: "value"
  defp downcase(label), do: String.downcase(label)

  # Prefer an explicit row_label; fall back to the range's label.
  defp row_label(%{row_label: rl}) when is_binary(rl) and rl != "", do: rl
  defp row_label(%{label: label}), do: label

  # Map a slot entry to the keyword list `range/1` accepts, dropping slot-only
  # keys (row_label, inner_block, __slot__) and nil values so defaults apply.
  @slot_only [:row_label, :inner_block, :__slot__]
  defp row_assigns(row) do
    row
    |> Map.drop(@slot_only)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end
end
