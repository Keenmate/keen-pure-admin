defmodule PureAdmin.Components.KpiSparklineList do
  @moduledoc """
  KPI Sparkline list showcase — one row per KPI: label · sparkline · value · Δ%.

  Tracks `_kpi-sparkline-list.scss` from `@keenmate/pure-admin-core` 2.7.1+.
  Container queries on the card adapt the row template (4-col → 2-row →
  3-row) as the card narrows. `is_no_delta` drops the rightmost column;
  `is_chart_first` rotates the canonical L→R order 90° at narrow widths.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  alias PureAdmin.Components.Kpi
  alias PureAdmin.Components.KpiDetail

  @trend_directions [nil, "up_strong", "up", "flat", "down", "down_strong"]
  @delta_variants [nil, "very_positive", "positive", "neutral", "negative", "very_negative"]

  # ----------------------------------------------------------------------
  # kpi_sparkline_list/1
  # ----------------------------------------------------------------------

  @doc """
  Renders the card wrapper for a list of `kpi_sparkline_row/1` rows.

  ## Examples

      <.kpi_sparkline_list title_text="Live KPIs" is_live>
        <.kpi_sparkline_row label_text="Revenue" value_text="848" unit_text="K" prefix_text="$" delta_text="▲ 12%" delta_variant="positive" variant="up">
          <:chart>
            <svg viewBox="0 0 100 24" preserveAspectRatio="none">
              <polygon points="0,24 0,18 12,16 24,17 36,12 48,15 60,9 72,11 84,7 96,5 96,24"/>
              <polyline points="0,18 12,16 24,17 36,12 48,15 60,9 72,11 84,7 96,5"/>
              <circle cx="96" cy="5" r="2"/>
            </svg>
          </:chart>
        </.kpi_sparkline_row>
      </.kpi_sparkline_list>
  """
  attr(:title_text, :string, default: nil)
  attr(:is_live, :boolean, default: false)
  attr(:live_text, :string, default: "LIVE")
  attr(:footer_text, :string, default: nil)
  attr(:is_no_delta, :boolean, default: false, doc: "Drop the rightmost Δ% column (`pa-kpi-spark-list--no-delta`)")

  attr(:is_chart_first, :boolean,
    default: false,
    doc: "Rotate to label/chart/value+delta stacking at mid-narrow widths"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Row content — `kpi_sparkline_row/1` instances")
  slot(:footer)

  def kpi_sparkline_list(assigns) do
    ~H"""
    <div class={list_classes(@is_no_delta, @is_chart_first, @class)} {@rest}>
      <div :if={@title_text || @is_live} class="pa-card__header pa-kpi-header">
        <div :if={@title_text} class="pa-card__title">
          <h3 class="pa-card__title-text">{@title_text}</h3>
        </div>
        <span :if={@is_live} class="pa-kpi-live">
          <span class="pa-kpi-live__dot"></span>{@live_text}
        </span>
      </div>

      <div class="pa-card__body pa-kpi-spark-list__body">
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

  defp list_classes(is_no_delta, is_chart_first, extra) do
    build_classes(
      "pa-card",
      [
        {"pa-kpi-spark-list", true},
        {"pa-kpi-spark-list--no-delta", is_no_delta},
        {"pa-kpi-spark-list--chart-first", is_chart_first}
      ],
      extra
    )
  end

  # ----------------------------------------------------------------------
  # kpi_sparkline_row/1
  # ----------------------------------------------------------------------

  @doc """
  Renders one row inside a `kpi_sparkline_list/1`.

  The row is the hover host for the detail popover. Set `detail_title_text`
  plus any combination of `previous_value_text` / `delta_absolute_text` /
  `target_text` to auto-build the popover body, or pass raw markup via the
  `:detail` slot.

  ## Variants

  - `variant` colours the chart line/area/dot via `currentColor`
    (`up_strong` / `up` / `flat` / `down` / `down_strong`).
  - `delta_variant` colours the Δ% cell (`very_positive` / `positive` /
    `neutral` / `negative` / `very_negative`).
  """
  attr(:id, :string, default: nil)
  attr(:variant, :string, default: nil, values: @trend_directions)
  attr(:label_text, :string, default: nil)
  attr(:value_text, :string, default: nil)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:delta_variant, :string, default: nil, values: @delta_variants)

  attr(:detail_title_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:delta_absolute_text, :string, default: nil)
  attr(:delta_absolute_sentiment, :atom, default: nil, values: [nil, :pos, :neg, :warn])
  attr(:detail_rows, :list, default: nil)

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:label)
  slot(:chart, doc: "Chart cell content — any SVG / hook-mounted chart")
  slot(:value)
  slot(:delta)
  slot(:detail, doc: "Raw popover content — overrides the auto-built popover")

  def kpi_sparkline_row(assigns) do
    has_detail? = assigns.detail != [] or assigns.detail_title_text != nil
    assigns = assign(assigns, :has_detail?, has_detail?)

    ~H"""
    <div
      id={@id}
      class={row_classes(@variant, @class)}
      phx-hook={if @has_detail?, do: "PureAdminKpiTile"}
      {@rest}
    >
      <%= if @label != [] do %>
        <div class="pa-kpi-spark-row__label">{render_slot(@label)}</div>
      <% else %>
        <div class="pa-kpi-spark-row__label">{@label_text}</div>
      <% end %>

      <div class="pa-kpi-spark-row__chart">
        <%= for c <- @chart do %>
          {render_slot(c)}
        <% end %>
      </div>

      <%= if @value != [] do %>
        <div class="pa-kpi-spark-row__value">{render_slot(@value)}</div>
      <% else %>
        <div class="pa-kpi-spark-row__value">
          <span :if={@prefix_text} class="pa-kpi-spark-row__unit">{@prefix_text}</span>
          <span :if={@value_text} class="pa-kpi-spark-row__num">{@value_text}</span>
          <span :if={@unit_text} class="pa-kpi-spark-row__unit">{@unit_text}</span>
        </div>
      <% end %>

      <%= if @delta != [] do %>
        <div class={delta_classes(@delta_variant)}>{render_slot(@delta)}</div>
      <% else %>
        <div class={delta_classes(@delta_variant)}>{@delta_text}</div>
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

  defp row_classes(variant, extra) do
    v = KpiDetail.dasherize(variant)

    build_classes(
      "pa-kpi-spark-row",
      [{"pa-kpi-spark-row--#{v}", v != nil}],
      extra
    )
  end

  defp delta_classes(variant) do
    v = KpiDetail.dasherize(variant)

    build_classes(
      "pa-kpi-spark-row__delta",
      [{"pa-kpi-spark-row__delta--#{v}", v != nil}]
    )
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
