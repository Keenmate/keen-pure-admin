defmodule PureAdmin.Components.KpiGaugeList do
  @moduledoc """
  KPI Comparison gauges showcase — goal-oriented progress bars.

  Tracks `_kpi-comparison-gauges.scss` from `@keenmate/pure-admin-core` 2.7.1+.
  Default layout is a cell-min-driven `auto-fit` grid (cells stay at least
  `--pa-kpi-gauge-cell-min` wide, default 20rem). `grid_layout` switches to
  `2col` (deterministic 2-cols) or `max_2..max_6` (cap auto-fit at N).
  Override the cell minimum per instance via `cell_min_width`.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  alias PureAdmin.Components.Kpi
  alias PureAdmin.Components.KpiDetail

  @grid_layouts [nil, "2col", "max_2", "max_3", "max_4", "max_5", "max_6"]
  @gauge_variants [nil, "positive", "warning", "negative", "neutral"]

  # ----------------------------------------------------------------------
  # kpi_gauge_list/1
  # ----------------------------------------------------------------------

  attr(:title_text, :string, default: nil)
  attr(:is_live, :boolean, default: false)
  attr(:live_text, :string, default: "LIVE")
  attr(:footer_text, :string, default: nil)
  attr(:grid_layout, :string, default: nil, values: @grid_layouts)

  attr(:cell_min_width, :string,
    default: nil,
    doc: "CSS length for `--pa-kpi-gauge-cell-min` (default upstream `20rem`)"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Gauge tiles — `kpi_gauge/1` instances")
  slot(:footer)

  def kpi_gauge_list(assigns) do
    ~H"""
    <div class={build_classes("pa-card", ["pa-kpi-gauge-list"], @class)} {@rest}>
      <div :if={@title_text || @is_live} class="pa-card__header pa-kpi-header">
        <h3 :if={@title_text}>{@title_text}</h3>
        <span :if={@is_live} class="pa-kpi-live">
          <span class="pa-kpi-live__dot"></span>{@live_text}
        </span>
      </div>

      <div class="pa-card__body pa-kpi-gauge-list__body">
        <div class={grid_classes(@grid_layout)} style={grid_style(@cell_min_width)}>
          {render_slot(@inner_block)}
        </div>
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

  defp grid_classes(nil), do: "pa-kpi-gauge-list__grid"

  defp grid_classes(layout) do
    v = KpiDetail.dasherize(layout)

    build_classes("pa-kpi-gauge-list__grid", [
      {"pa-kpi-gauge-list__grid--#{v}", true}
    ])
  end

  defp grid_style(nil), do: nil
  defp grid_style(width), do: "--pa-kpi-gauge-cell-min: #{width};"

  # ----------------------------------------------------------------------
  # kpi_gauge/1
  # ----------------------------------------------------------------------

  @doc """
  Renders one gauge tile inside a `kpi_gauge_list/1`.

  Bar fill width = `bar_percent` (0–100; not capped — overshoots are
  signalled by sentiment colour, not by overflowing the bar). `tick_position`
  shifts the target tick along the bar (default upstream `100%` = right
  edge); useful when the bar represents a wider scale with the target
  inside.
  """
  attr(:id, :string, default: nil)
  attr(:variant, :string, default: nil, values: @gauge_variants)
  attr(:label_text, :string, default: nil)
  attr(:value_text, :string, default: nil)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:bar_percent, :integer, default: nil, doc: "Bar fill width as a percentage (0-100; not capped visually)")

  attr(:tick_position, :string,
    default: nil,
    doc: "CSS length / percent for `--pa-kpi-gauge-tick-pos` (default upstream `100%`)"
  )

  attr(:tick_color, :string, default: nil, doc: "Override for `--pa-kpi-gauge-tick-color`")
  attr(:scale_start_text, :string, default: "0")
  attr(:scale_end_text, :string, default: nil)

  attr(:detail_title_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:delta_absolute_text, :string, default: nil)
  attr(:delta_absolute_sentiment, :atom, default: nil, values: [nil, :pos, :neg, :warn])
  attr(:detail_rows, :list, default: nil)

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:label)
  slot(:value)
  slot(:scale)
  slot(:detail)

  def kpi_gauge(assigns) do
    has_detail? = assigns.detail != [] or assigns.detail_title_text != nil
    fill_width = if assigns.bar_percent, do: max(0, assigns.bar_percent), else: 0

    assigns =
      assigns
      |> assign(:has_detail?, has_detail?)
      |> assign(:fill_width, fill_width)

    ~H"""
    <div
      id={@id}
      class={tile_classes(@variant, @class)}
      phx-hook={if @has_detail?, do: "PureAdminKpiTile"}
      {@rest}
    >
      <div class="pa-kpi-gauge__head">
        <%= if @label != [] do %>
          <div class="pa-kpi-gauge__label">{render_slot(@label)}</div>
        <% else %>
          <div class="pa-kpi-gauge__label">{@label_text}</div>
        <% end %>

        <%= if @value != [] do %>
          <div class="pa-kpi-gauge__value">{render_slot(@value)}</div>
        <% else %>
          <div class="pa-kpi-gauge__value">
            <span :if={@prefix_text} class="pa-kpi-gauge__unit">{@prefix_text}</span>
            <span :if={@value_text} class="pa-kpi-gauge__num">{@value_text}</span>
            <span :if={@unit_text} class="pa-kpi-gauge__unit">{@unit_text}</span>
          </div>
        <% end %>
      </div>

      <div class="pa-kpi-gauge__bar" style={bar_style(@tick_position, @tick_color)}>
        <div class="pa-kpi-gauge__fill" style={"width: #{@fill_width}%"}></div>
      </div>

      <%= if @scale != [] do %>
        <div class="pa-kpi-gauge__scale">{render_slot(@scale)}</div>
      <% else %>
        <div :if={@scale_start_text != nil || @scale_end_text != nil} class="pa-kpi-gauge__scale">
          <span>{@scale_start_text}</span>
          <span>{@scale_end_text}</span>
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

  defp tile_classes(variant, extra) do
    v = KpiDetail.dasherize(variant)

    build_classes(
      "pa-kpi-gauge",
      [{"pa-kpi-gauge--#{v}", v != nil}],
      extra
    )
  end

  defp bar_style(nil, nil), do: nil
  defp bar_style(pos, nil), do: "--pa-kpi-gauge-tick-pos: #{pos};"
  defp bar_style(nil, color), do: "--pa-kpi-gauge-tick-color: #{color};"
  defp bar_style(pos, color), do: "--pa-kpi-gauge-tick-pos: #{pos}; --pa-kpi-gauge-tick-color: #{color};"

  defp auto_rows(assigns) do
    KpiDetail.build_auto_rows(
      prefix_text: assigns.prefix_text,
      value_text: assigns.value_text,
      unit_text: assigns.unit_text,
      previous_value_text: assigns.previous_value_text,
      delta_absolute_text: assigns.delta_absolute_text,
      delta_absolute_sentiment: assigns.delta_absolute_sentiment,
      delta_text: assigns.delta_text,
      delta_sentiment: KpiDetail.delta_to_sentiment(assigns.variant),
      target_text: assigns.target_text
    )
  end
end
