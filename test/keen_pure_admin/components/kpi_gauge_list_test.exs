defmodule PureAdmin.Components.KpiGaugeListTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.KpiGaugeList

  defp render_gauge_list(overrides \\ %{}) do
    base = %{
      title_text: nil,
      is_live: false,
      live_text: "LIVE",
      footer_text: nil,
      grid_layout: nil,
      cell_min_width: nil,
      class: nil,
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Body" end}],
      footer: []
    }

    render_component(&KpiGaugeList.kpi_gauge_list/1, Map.merge(base, overrides))
  end

  describe "card namespace class" do
    test "the card carries both pa-card and the pa-kpi-gauge-list namespace" do
      html = render_gauge_list()

      # Regression: build_classes/3's second arg is a {class, bool} tuple list —
      # a bare string "pa-kpi-gauge-list" is silently dropped, so the namespace
      # must be passed as {"pa-kpi-gauge-list", true}.
      assert_class(html, "pa-card")
      assert_class(html, "pa-kpi-gauge-list")
      assert_class(html, "pa-kpi-gauge-list__body")
      assert_class(html, "pa-kpi-gauge-list__grid")
    end
  end

  describe "header title uses the canonical card-title shape" do
    test "title_text renders pa-card__title > h3.pa-card__title-text, not a bare <h3>" do
      html = render_gauge_list(%{title_text: "Key Performance Indicators"})

      # Canonical card-header shape (matches core snippets/kpi.html + the
      # card-header canonicalization rule): the title is wrapped in
      # pa-card__title and the <h3> carries pa-card__title-text.
      assert_class(html, "pa-card__title")
      assert_class(html, "pa-card__title-text")

      assert html =~
               ~r{<div class="pa-card__title">\s*<h3 class="pa-card__title-text">Key Performance Indicators</h3>}

      # The legacy bare-<h3> shape must not be emitted.
      refute html =~ ~r{<h3>Key Performance Indicators</h3>}
    end
  end

  describe "cell-min inline style" do
    test "omits the style attribute entirely when no cell_min_width is given" do
      html = render_gauge_list()

      # Regression: `style={nil}` renders as `style=""` in HEEx (unlike class),
      # which drifts from the svelte wrapper (it omits the attribute). The grid
      # must emit NO empty style attribute.
      refute html =~ ~s(style="")
    end

    test "emits --pa-kpi-gauge-cell-min on the grid when cell_min_width is set" do
      html = render_gauge_list(%{cell_min_width: "16rem"})

      assert html =~ ~s(style="--pa-kpi-gauge-cell-min: 16rem;")
    end
  end

  describe "grid column-cap modifier" do
    test "grid_layout dasherizes underscored values to the __grid--* element modifier" do
      html = render_gauge_list(%{grid_layout: "max_3"})

      assert_class(html, "pa-kpi-gauge-list__grid")
      assert_class(html, "pa-kpi-gauge-list__grid--max-3")
    end

    test "the 2col layout emits the __grid--2col modifier" do
      html = render_gauge_list(%{grid_layout: "2col"})

      assert_class(html, "pa-kpi-gauge-list__grid--2col")
    end

    test "default layout emits the bare grid, no modifier" do
      html = render_gauge_list()
      refute html =~ "pa-kpi-gauge-list__grid--"
    end
  end
end
