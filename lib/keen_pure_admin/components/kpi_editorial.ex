defmodule PureAdmin.Components.KpiEditorial do
  @moduledoc """
  KPI Editorial minimal showcase — magazine-restraint grid with hairline rules.

  Tracks `_kpi-editorial-minimal.scss` from `@keenmate/pure-admin-core` 2.7.1+.
  Default layout is a cell-min-driven `auto-fit` grid; `is_2_columns` forces
  2 columns; `grid_layout="max_N"` caps at N columns. Override the cell
  minimum per instance via `cell_min_width`.

  No charts, no pills — the design's identity is the thin numeral.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  alias PureAdmin.Components.Kpi
  alias PureAdmin.Components.KpiDetail

  @grid_layouts [nil, "2col", "max_2", "max_3", "max_4", "max_5", "max_6"]
  @delta_variants [nil, "positive", "negative", "neutral", "up_strong", "down_strong"]

  # ----------------------------------------------------------------------
  # kpi_editorial/1
  # ----------------------------------------------------------------------

  attr(:title_text, :string, default: nil)
  attr(:is_live, :boolean, default: false)
  attr(:live_text, :string, default: "LIVE")
  attr(:footer_text, :string, default: nil)
  attr(:grid_layout, :string, default: nil, values: @grid_layouts)

  attr(:is_2_columns, :boolean,
    default: false,
    doc: "Force 2-col grid (`pa-kpi-edit__grid--2col`) — shorthand for `grid_layout=\"2col\"`"
  )

  attr(:cell_min_width, :string,
    default: nil,
    doc: "CSS length for `--pa-kpi-edit-cell-min` (default upstream `14rem`)"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)
  slot(:footer)

  def kpi_editorial(assigns) do
    layout = if assigns.is_2_columns, do: "2col", else: assigns.grid_layout
    assigns = assign(assigns, :effective_layout, layout)

    ~H"""
    <div class={build_classes("pa-card", ["pa-kpi-edit"], @class)} {@rest}>
      <div :if={@title_text || @is_live} class="pa-card__header pa-kpi-header">
        <h3 :if={@title_text}>{@title_text}</h3>
        <span :if={@is_live} class="pa-kpi-live">
          <span class="pa-kpi-live__dot"></span>{@live_text}
        </span>
      </div>

      <div class="pa-card__body pa-kpi-edit__body">
        <div class={grid_classes(@effective_layout)} style={grid_style(@cell_min_width)}>
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

  defp grid_classes(nil), do: "pa-kpi-edit__grid"

  defp grid_classes(layout) do
    v = KpiDetail.dasherize(layout)

    build_classes("pa-kpi-edit__grid", [
      {"pa-kpi-edit__grid--#{v}", true}
    ])
  end

  defp grid_style(nil), do: nil
  defp grid_style(width), do: "--pa-kpi-edit-cell-min: #{width};"

  # ----------------------------------------------------------------------
  # kpi_editorial_tile/1
  # ----------------------------------------------------------------------

  @doc """
  Renders one cell inside a `kpi_editorial/1` grid.

  The `target_text` attr is wrapped in `<em>tgt</em>` automatically in the
  meta row (matching upstream) — pass just the value (e.g. `"90.0%"`). Use
  the `:meta` slot to render the meta row from scratch.
  """
  attr(:id, :string, default: nil)
  attr(:label_text, :string, default: nil)
  attr(:value_text, :string, default: nil)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:delta_variant, :string, default: nil, values: @delta_variants)
  attr(:target_text, :string, default: nil, doc: "Target value; auto-rendered as `tgt <value>` in the meta row")

  attr(:detail_title_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:delta_absolute_text, :string, default: nil)
  attr(:delta_absolute_sentiment, :atom, default: nil, values: [nil, :pos, :neg, :warn])
  attr(:detail_rows, :list, default: nil)

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:label, doc: "Override label cell — supports multi-line markup with `<br>`")
  slot(:value)
  slot(:meta)
  slot(:detail)

  def kpi_editorial_tile(assigns) do
    has_detail? = assigns.detail != [] or assigns.detail_title_text != nil
    assigns = assign(assigns, :has_detail?, has_detail?)

    ~H"""
    <div
      id={@id}
      class={build_classes("pa-kpi-edit__tile", [], @class)}
      phx-hook={if @has_detail?, do: "PureAdminKpiTile"}
      {@rest}
    >
      <%= if @label != [] do %>
        <div class="pa-kpi-edit__label">{render_slot(@label)}</div>
      <% else %>
        <div class="pa-kpi-edit__label">{@label_text}</div>
      <% end %>

      <%= if @value != [] do %>
        <div class="pa-kpi-edit__value">{render_slot(@value)}</div>
      <% else %>
        <div class="pa-kpi-edit__value">
          <span :if={@prefix_text} class="pa-kpi-edit__unit">{@prefix_text}</span>
          <span :if={@value_text} class="pa-kpi-edit__num">{@value_text}</span>
          <span :if={@unit_text} class="pa-kpi-edit__unit">{@unit_text}</span>
        </div>
      <% end %>

      <%= if @meta != [] do %>
        <div class="pa-kpi-edit__meta">{render_slot(@meta)}</div>
      <% else %>
        <div :if={@delta_text || @target_text} class="pa-kpi-edit__meta">
          <span :if={@delta_text} class={delta_classes(@delta_variant)}>{@delta_text}</span>
          <span :if={@target_text} class="pa-kpi-edit__target"><em>tgt</em>{@target_text}</span>
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

    build_classes("pa-kpi-edit__delta", [
      {"pa-kpi-edit__delta--#{v}", v != nil}
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
