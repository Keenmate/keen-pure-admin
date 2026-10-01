defmodule PureAdmin.Components.KpiStrip do
  @moduledoc """
  KPI Numeric strip showcase — tabular spreadsheet-style table card.

  Tracks `_kpi-numeric-strip.scss` from `@keenmate/pure-admin-core` 2.7.1+.
  Default 5-column layout (metric · now · prev · Δ% · target). Drop columns
  via `no_previous_value` / `no_delta_percent` / `no_target_bar` — toggles
  compose, so the visible column count ranges from 2 (all three optional
  columns dropped) to 5 (none dropped). The header row is auto-generated
  from the visible columns; override individual labels via `header_labels`,
  suppress via `no_header`, or fully replace via the `:head` slot.

  Wide-only by design — no responsive collapse. Narrow placements should
  use `kpi_gauge_list/1` instead.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  alias PureAdmin.Components.Kpi
  alias PureAdmin.Components.KpiDetail

  @delta_variants [nil, "positive", "negative", "neutral", "up_strong", "down_strong"]

  @default_header_labels %{
    metric: "Metric",
    now: "Now",
    previous_value: "Prev",
    delta_percent: "Δ%",
    target_bar: "vs Target"
  }

  @numeric_columns [:now, :previous_value, :delta_percent]

  # Core (`_kpi-numeric-strip.scss`) blesses only the short head modifiers
  # `--prev` / `--delta` / `--target` (the `--no-*` hide rules target these);
  # `metric` / `now` head cells carry no modifier. Map the column atoms to the
  # blessed names rather than dasherizing the full atom.
  @head_modifiers %{
    previous_value: "prev",
    delta_percent: "delta",
    target_bar: "target"
  }

  # ----------------------------------------------------------------------
  # kpi_strip/1
  # ----------------------------------------------------------------------

  attr(:title_text, :string, default: nil)
  attr(:is_live, :boolean, default: false)
  attr(:live_text, :string, default: "LIVE")
  attr(:footer_text, :string, default: nil)

  attr(:no_previous_value, :boolean, default: false, doc: "Drop the prev column (`pa-kpi-strip--no-prev`)")
  attr(:no_delta_percent, :boolean, default: false, doc: "Drop the Δ% column (`pa-kpi-strip--no-delta`)")
  attr(:no_target_bar, :boolean, default: false, doc: "Drop the target-bar column (`pa-kpi-strip--no-target`)")

  attr(:no_header, :boolean, default: false, doc: "Suppress the auto-generated header row")

  attr(:header_labels, :map,
    default: %{},
    doc:
      "Per-column header overrides — keys are `:metric` | `:now` | `:previous_value` | `:delta_percent` | `:target_bar`"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:head, doc: "Fully replace the auto-generated header row with custom markup")
  slot(:inner_block, required: true, doc: "Row content — `kpi_strip_row/1` instances")
  slot(:footer)

  def kpi_strip(assigns) do
    visible_columns = visible_columns(assigns)
    assigns = assign(assigns, :visible_columns, visible_columns)

    ~H"""
    <div class={strip_classes(@no_previous_value, @no_delta_percent, @no_target_bar, @class)} {@rest}>
      <div :if={@title_text || @is_live} class="pa-card__header pa-kpi-header">
        <div :if={@title_text} class="pa-card__title">
          <h3 class="pa-card__title-text">{@title_text}</h3>
        </div>
        <span :if={@is_live} class="pa-kpi-live">
          <span class="pa-kpi-live__dot"></span>{@live_text}
        </span>
      </div>

      <div class="pa-card__body pa-kpi-strip__body">
        <%= cond do %>
          <% @head != [] -> %>
            <div class="pa-kpi-strip__head-row">{render_slot(@head)}</div>
          <% @no_header -> %>
          <% true -> %>
            <div class="pa-kpi-strip__head-row">
              <%= for col <- @visible_columns do %>
                <div class={head_cell_classes(col)}>{label_of(col, @header_labels)}</div>
              <% end %>
            </div>
        <% end %>
        {render_slot(@inner_block)}
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

  defp visible_columns(%{
         no_previous_value: no_prev,
         no_delta_percent: no_delta,
         no_target_bar: no_target
       }) do
    base = [:metric, :now]

    base
    |> maybe_append(:previous_value, not no_prev)
    |> maybe_append(:delta_percent, not no_delta)
    |> maybe_append(:target_bar, not no_target)
  end

  defp maybe_append(list, _value, false), do: list
  defp maybe_append(list, value, true), do: list ++ [value]

  defp strip_classes(no_prev, no_delta, no_target, extra) do
    build_classes(
      "pa-card",
      [
        {"pa-kpi-strip", true},
        {"pa-kpi-strip--no-prev", no_prev},
        {"pa-kpi-strip--no-delta", no_delta},
        {"pa-kpi-strip--no-target", no_target}
      ],
      extra
    )
  end

  defp label_of(col, overrides), do: Map.get(overrides, col) || Map.fetch!(@default_header_labels, col)

  defp head_cell_classes(col) do
    modifier = Map.get(@head_modifiers, col)

    build_classes("pa-kpi-strip__head", [
      {"pa-kpi-strip__head--num", col in @numeric_columns},
      {"pa-kpi-strip__head--#{modifier}", modifier != nil}
    ])
  end

  # ----------------------------------------------------------------------
  # kpi_strip_row/1
  # ----------------------------------------------------------------------

  @doc """
  Renders one data row inside a `kpi_strip/1`.

  The row is the hover host for the detail popover. Set `detail_title_text`
  plus any combination of `previous_value_text` / `delta_absolute_text` /
  `target_text` to auto-build the popover body. `target_bar_percent` drives
  the bar fill (visually capped at 100%); `target_percent_text` is the
  label below the bar (may exceed 100, e.g. "108%").
  """
  attr(:id, :string, default: nil)
  attr(:metric_text, :string, default: nil)
  attr(:value_text, :string, default: nil)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:delta_variant, :string, default: nil, values: @delta_variants)
  attr(:target_bar_percent, :integer, default: nil, doc: "Bar fill width as a percentage (visually capped at 100)")
  attr(:target_percent_text, :string, default: nil, doc: "Label below the target bar — may exceed 100% (e.g. \"108%\")")

  attr(:detail_title_text, :string, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:delta_absolute_text, :string, default: nil)
  attr(:delta_absolute_sentiment, :atom, default: nil, values: [nil, :pos, :neg, :warn])
  attr(:detail_rows, :list, default: nil)

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:metric)
  slot(:now)
  slot(:previous_value)
  slot(:delta)
  slot(:target)
  slot(:detail)

  def kpi_strip_row(assigns) do
    has_detail? = assigns.detail != [] or assigns.detail_title_text != nil

    capped =
      case assigns.target_bar_percent do
        nil -> nil
        n -> n |> max(0) |> min(100)
      end

    assigns =
      assigns
      |> assign(:has_detail?, has_detail?)
      |> assign(:capped_bar_width, capped)

    ~H"""
    <div
      id={@id}
      class={build_classes("pa-kpi-strip__row", [], @class)}
      phx-hook={if @has_detail?, do: "PureAdminKpiTile"}
      {@rest}
    >
      <%= if @metric != [] do %>
        <div class="pa-kpi-strip__metric">{render_slot(@metric)}</div>
      <% else %>
        <div class="pa-kpi-strip__metric">{@metric_text}</div>
      <% end %>

      <%= if @now != [] do %>
        <div class="pa-kpi-strip__now">{render_slot(@now)}</div>
      <% else %>
        <div class="pa-kpi-strip__now">
          <span :if={@prefix_text} class="pa-kpi-strip__unit">{@prefix_text}</span>
          <span :if={@value_text} class="pa-kpi-strip__num">{@value_text}</span>
          <span :if={@unit_text} class="pa-kpi-strip__unit">{@unit_text}</span>
        </div>
      <% end %>

      <%= if @previous_value != [] do %>
        <div class="pa-kpi-strip__prev">{render_slot(@previous_value)}</div>
      <% else %>
        <div :if={@previous_value_text} class="pa-kpi-strip__prev">{@previous_value_text}</div>
      <% end %>

      <%= if @delta != [] do %>
        <div class={delta_classes(@delta_variant)}>{render_slot(@delta)}</div>
      <% else %>
        <div class={delta_classes(@delta_variant)}>{@delta_text}</div>
      <% end %>

      <%= if @target != [] do %>
        <div class="pa-kpi-strip__target">{render_slot(@target)}</div>
      <% else %>
        <div class="pa-kpi-strip__target">
          <div class="pa-kpi-strip__bar">
            <div class="pa-kpi-strip__fill" style={"width: #{@capped_bar_width || 0}%"}></div>
          </div>
          <div :if={@target_percent_text} class="pa-kpi-strip__bar-pct">{@target_percent_text}</div>
        </div>
      <% end %>

      <%= if @detail != [] do %>
        <Kpi.kpi_detail :if={@has_detail?}>
          <%= for d <- @detail do %>
            {render_slot(d)}
          <% end %>
        </Kpi.kpi_detail>
      <% else %>
        <Kpi.kpi_detail
          :if={@has_detail?}
          title_text={@detail_title_text}
          rows={@detail_rows || auto_rows(assigns)}
        />
      <% end %>
    </div>
    """
  end

  defp delta_classes(variant) do
    v = KpiDetail.dasherize(variant)

    build_classes("pa-kpi-strip__delta", [
      {"pa-kpi-strip__delta--#{v}", v != nil}
    ])
  end

  defp auto_rows(assigns) do
    KpiDetail.build_auto_rows(
      prefix_text: assigns.prefix_text,
      value_text: assigns.value_text,
      unit_text: assigns.unit_text,
      previous_value_text: assigns.previous_value_text,
      delta_absolute_text: assigns.delta_absolute_text,
      delta_absolute_sentiment: assigns.delta_absolute_sentiment,
      delta_text: assigns.delta_text,
      delta_sentiment: KpiDetail.delta_to_sentiment(assigns.delta_variant),
      target_text: assigns.target_text
    )
  end
end
