defmodule PureAdmin.Components.KpiBento do
  @moduledoc """
  KPI Bento layout showcase — magazine-style asymmetric tile sizing.

  Tracks `_kpi-bento.scss` from `@keenmate/pure-admin-core` 2.7.1+. Default
  is the 6-tile hero-left layout; `bento_layout="hero_right"` mirrors it
  (hero on the right); `bento_layout="5_tile"` is hero + 4 supporting.
  Tile placement is by source order — markup stays identical across
  layout modifiers. Set `row_height` to override `--pa-kpi-bento-row-height`
  (default `12rem`).
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  alias PureAdmin.Components.Kpi
  alias PureAdmin.Components.KpiDetail

  @bento_layouts [nil, "hero_right", "5_tile"]
  @delta_variants [nil, "positive", "negative", "neutral", "up_strong", "down_strong"]

  # ----------------------------------------------------------------------
  # kpi_bento/1
  # ----------------------------------------------------------------------

  attr(:title_text, :string, default: nil)
  attr(:is_live, :boolean, default: false)
  attr(:live_text, :string, default: "LIVE")
  attr(:footer_text, :string, default: nil)
  attr(:bento_layout, :string, default: nil, values: @bento_layouts)
  attr(:row_height, :string, default: nil, doc: "CSS length for `--pa-kpi-bento-row-height` (default upstream `12rem`)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true)
  slot(:footer)

  def kpi_bento(assigns) do
    ~H"""
    <div class={build_classes("pa-card", ["pa-kpi-bento"], @class)} style={bento_style(@row_height)} {@rest}>
      <div :if={@title_text || @is_live} class="pa-card__header pa-kpi-header">
        <h3 :if={@title_text}>{@title_text}</h3>
        <span :if={@is_live} class="pa-kpi-live">
          <span class="pa-kpi-live__dot"></span>{@live_text}
        </span>
      </div>

      <div class="pa-card__body pa-kpi-bento__body">
        <div class={grid_classes(@bento_layout)}>
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

  defp bento_style(nil), do: nil
  defp bento_style(height), do: "--pa-kpi-bento-row-height: #{height};"

  defp grid_classes(nil), do: "pa-kpi-bento__grid"

  defp grid_classes(layout) do
    v = KpiDetail.dasherize(layout)

    build_classes("pa-kpi-bento__grid", [
      {"pa-kpi-bento__grid--#{v}", true}
    ])
  end

  # ----------------------------------------------------------------------
  # kpi_bento_tile/1
  # ----------------------------------------------------------------------

  @doc """
  Renders one cell inside a `kpi_bento/1` grid.

  Set `is_hero` on the **first** tile (the larger left/right half panel)
  so its value font-size + chart height bump up via `pa-kpi-bento-tile--hero`.
  """
  attr(:id, :string, default: nil)
  attr(:variant, :string, default: nil, values: @delta_variants)
  attr(:is_hero, :boolean, default: false)
  attr(:label_text, :string, default: nil)
  attr(:value_text, :string, default: nil)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)

  attr(:detail_title_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:delta_absolute_text, :string, default: nil)
  attr(:delta_absolute_sentiment, :atom, default: nil, values: [nil, :pos, :neg, :warn])
  attr(:detail_rows, :list, default: nil)

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:label)
  slot(:value)
  slot(:delta)
  slot(:chart)
  slot(:detail)

  def kpi_bento_tile(assigns) do
    has_detail? = assigns.detail != [] or assigns.detail_title_text != nil
    assigns = assign(assigns, :has_detail?, has_detail?)

    ~H"""
    <div
      id={@id}
      class={tile_classes(@variant, @is_hero, @class)}
      phx-hook={if @has_detail?, do: "PureAdminKpiTile"}
      {@rest}
    >
      <%= if @label != [] do %>
        <div class="pa-kpi-bento-tile__label">{render_slot(@label)}</div>
      <% else %>
        <div class="pa-kpi-bento-tile__label">{@label_text}</div>
      <% end %>

      <%= if @delta != [] do %>
        <div class="pa-kpi-bento-tile__delta">{render_slot(@delta)}</div>
      <% else %>
        <div :if={@delta_text} class="pa-kpi-bento-tile__delta">{@delta_text}</div>
      <% end %>

      <%= if @value != [] do %>
        <div class="pa-kpi-bento-tile__value">{render_slot(@value)}</div>
      <% else %>
        <div class="pa-kpi-bento-tile__value">
          <span :if={@prefix_text} class="pa-kpi-bento-tile__unit">{@prefix_text}</span>
          <span :if={@value_text} class="pa-kpi-bento-tile__num">{@value_text}</span>
          <span :if={@unit_text} class="pa-kpi-bento-tile__unit">{@unit_text}</span>
        </div>
      <% end %>

      <%= if @chart != [] do %>
        <div class="pa-kpi-bento-tile__chart">
          <%= for c <- @chart do %>
            {render_slot(c)}
          <% end %>
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

  defp tile_classes(variant, is_hero, extra) do
    v = KpiDetail.dasherize(variant)

    build_classes(
      "pa-kpi-bento-tile",
      [
        {"pa-kpi-bento-tile--#{v}", v != nil},
        {"pa-kpi-bento-tile--hero", is_hero}
      ],
      extra
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
      delta_sentiment: KpiDetail.delta_to_sentiment(assigns.variant),
      target_text: assigns.target_text
    )
  end
end
