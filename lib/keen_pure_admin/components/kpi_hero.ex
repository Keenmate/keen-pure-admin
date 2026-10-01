defmodule PureAdmin.Components.KpiHero do
  @moduledoc """
  KPI Hero + supporting showcase — headline metric + vertical rail of supporting tiles.

  Tracks `_kpi-hero-supporting.scss` from `@keenmate/pure-admin-core` 2.7.1+.
  Default split is 1:1 (50/50). `hero_split="2_3"` gives the hero 2/3 of
  the width; `hero_split="3_4"` makes the rail a thin sidebar. Container
  query collapses to single column under 700px.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  alias PureAdmin.Components.Kpi
  alias PureAdmin.Components.KpiDetail

  @hero_splits [nil, "2_3", "3_4"]
  @hero_variants [nil, "positive", "negative", "neutral", "up_strong"]

  # ----------------------------------------------------------------------
  # kpi_hero_list/1
  # ----------------------------------------------------------------------

  attr(:title_text, :string, default: nil)
  attr(:is_live, :boolean, default: false)
  attr(:live_text, :string, default: "LIVE")
  attr(:footer_text, :string, default: nil)
  attr(:hero_split, :string, default: nil, values: @hero_splits)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "Hero content — typically a `kpi_hero_main/1`")
  slot(:rail, doc: "Right-side rail content — typically multiple `kpi_hero_side/1` tiles")
  slot(:footer)

  def kpi_hero_list(assigns) do
    ~H"""
    <div class={build_classes("pa-card pa-kpi-hero-list", [], @class)} {@rest}>
      <div :if={@title_text || @is_live} class="pa-card__header pa-kpi-header">
        <div :if={@title_text} class="pa-card__title"><h3 class="pa-card__title-text">{@title_text}</h3></div>
        <span :if={@is_live} class="pa-kpi-live">
          <span class="pa-kpi-live__dot"></span>{@live_text}
        </span>
      </div>

      <div class="pa-card__body pa-kpi-hero-list__body">
        <div class={layout_classes(@hero_split)}>
          {render_slot(@inner_block)}
          <%= if @rail != [] do %>
            <div class="pa-kpi-hero-list__rail">
              <%= for r <- @rail do %>
                {render_slot(r)}
              <% end %>
            </div>
          <% end %>
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

  defp layout_classes(nil), do: "pa-kpi-hero-list__layout"

  defp layout_classes(split) do
    v = KpiDetail.dasherize(split)

    build_classes("pa-kpi-hero-list__layout", [
      {"pa-kpi-hero-list__layout--hero-#{v}", true}
    ])
  end

  # ----------------------------------------------------------------------
  # kpi_hero_main/1
  # ----------------------------------------------------------------------

  @doc """
  Renders the headline hero panel inside a `kpi_hero_list/1`.
  """
  attr(:id, :string, default: nil)
  attr(:variant, :string, default: nil, values: @hero_variants)
  attr(:label_text, :string, default: nil)
  attr(:value_text, :string, default: nil)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:period_text, :string, default: nil, doc: "Inline period label in the meta row (e.g. \"vs last month\")")
  attr(:target_text, :string, default: nil, doc: "Inline target label in the meta row; also fed into the popover")

  attr(:detail_title_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)
  attr(:delta_absolute_text, :string, default: nil)
  attr(:delta_absolute_sentiment, :atom, default: nil, values: [nil, :pos, :neg, :warn])
  attr(:detail_rows, :list, default: nil)

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:label)
  slot(:value)
  slot(:meta)
  slot(:chart)
  slot(:detail)

  def kpi_hero_main(assigns) do
    has_detail? = assigns.detail != [] or assigns.detail_title_text != nil
    assigns = assign(assigns, :has_detail?, has_detail?)

    ~H"""
    <div
      id={@id}
      class={main_classes(@variant, @class)}
      phx-hook={if @has_detail?, do: "PureAdminKpiTile"}
      {@rest}
    >
      <%= if @label != [] do %>
        <div class="pa-kpi-hero-main__label">{render_slot(@label)}</div>
      <% else %>
        <div :if={@label_text} class="pa-kpi-hero-main__label">{@label_text}</div>
      <% end %>

      <%= if @value != [] do %>
        <div class="pa-kpi-hero-main__value">{render_slot(@value)}</div>
      <% else %>
        <div :if={@value_text || @prefix_text || @unit_text} class="pa-kpi-hero-main__value">
          <span :if={@prefix_text} class="pa-kpi-hero-main__unit">{@prefix_text}</span>
          <span :if={@value_text} class="pa-kpi-hero-main__num">{@value_text}</span>
          <span :if={@unit_text} class="pa-kpi-hero-main__unit">{@unit_text}</span>
        </div>
      <% end %>

      <%= if @meta != [] do %>
        <div class="pa-kpi-hero-main__meta">{render_slot(@meta)}</div>
      <% else %>
        <div :if={@delta_text || @period_text || @target_text} class="pa-kpi-hero-main__meta">
          <span :if={@delta_text} class="pa-kpi-hero-main__delta">{@delta_text}</span>
          <span :if={@period_text} class="pa-kpi-hero-main__period">{@period_text}</span>
          <span :if={@target_text} class="pa-kpi-hero-main__target">{@target_text}</span>
        </div>
      <% end %>

      <%= if @chart != [] do %>
        <div class="pa-kpi-hero-main__chart">
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

  defp main_classes(variant, extra) do
    v = KpiDetail.dasherize(variant)

    build_classes(
      "pa-kpi-hero-main",
      [{"pa-kpi-hero-main--#{v}", v != nil}],
      extra
    )
  end

  # ----------------------------------------------------------------------
  # kpi_hero_side/1
  # ----------------------------------------------------------------------

  @doc """
  Renders one supporting tile in the right-side rail.
  """
  attr(:id, :string, default: nil)
  attr(:variant, :string, default: nil, values: @hero_variants)
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
  slot(:detail)

  def kpi_hero_side(assigns) do
    has_detail? = assigns.detail != [] or assigns.detail_title_text != nil
    assigns = assign(assigns, :has_detail?, has_detail?)

    ~H"""
    <div
      id={@id}
      class={side_classes(@variant, @class)}
      phx-hook={if @has_detail?, do: "PureAdminKpiTile"}
      {@rest}
    >
      <%= if @label != [] do %>
        <div class="pa-kpi-hero-side__label">{render_slot(@label)}</div>
      <% else %>
        <div class="pa-kpi-hero-side__label">{@label_text}</div>
      <% end %>

      <%= if @value != [] do %>
        <div class="pa-kpi-hero-side__value">{render_slot(@value)}</div>
      <% else %>
        <div class="pa-kpi-hero-side__value">
          <span :if={@prefix_text} class="pa-kpi-hero-side__unit">{@prefix_text}</span>
          <span :if={@value_text} class="pa-kpi-hero-side__num">{@value_text}</span>
          <span :if={@unit_text} class="pa-kpi-hero-side__unit">{@unit_text}</span>
        </div>
      <% end %>

      <%= if @delta != [] do %>
        <div class="pa-kpi-hero-side__delta">{render_slot(@delta)}</div>
      <% else %>
        <div :if={@delta_text} class="pa-kpi-hero-side__delta">{@delta_text}</div>
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
          rows={@detail_rows || side_auto_rows(assigns)}
        />
      <% end %>
    </div>
    """
  end

  defp side_classes(variant, extra) do
    v = KpiDetail.dasherize(variant)

    build_classes(
      "pa-kpi-hero-side",
      [{"pa-kpi-hero-side--#{v}", v != nil}],
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

  defp side_auto_rows(assigns), do: auto_rows(assigns)
end
