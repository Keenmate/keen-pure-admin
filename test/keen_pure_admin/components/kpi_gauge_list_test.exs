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

  # --------------------------------------------------------------------
  # kpi_gauge/1 — the per-tile sub-component (fidelity fragment slice)
  # --------------------------------------------------------------------
  defp render_gauge(overrides \\ %{}) do
    base = %{
      id: nil,
      variant: nil,
      label_text: nil,
      value_text: nil,
      unit_text: nil,
      prefix_text: nil,
      bar_percent: nil,
      tick_position: nil,
      tick_color: nil,
      scale_start_text: "0",
      scale_end_text: nil,
      detail_title_text: nil,
      previous_value_text: nil,
      target_text: nil,
      delta_text: nil,
      delta_absolute_text: nil,
      delta_absolute_sentiment: nil,
      detail_rows: nil,
      class: nil,
      label: [],
      value: [],
      scale: [],
      detail: []
    }

    render_component(&KpiGaugeList.kpi_gauge/1, Map.merge(base, overrides))
  end

  describe "gauge tile sentiment modifier" do
    test "variant emits the pa-kpi-gauge--* modifier via a {class, bool} tuple" do
      html = render_gauge(%{variant: "positive"})

      # Regression: build_classes/3's modifier list must use {class, bool}
      # tuples — a bare string modifier is silently dropped. tile_classes/2
      # guards nil with `v != nil`, so a set variant produces the class.
      assert_class(html, "pa-kpi-gauge")
      assert_class(html, "pa-kpi-gauge--positive")
    end

    test "no variant emits the bare block, no sentiment modifier" do
      html = render_gauge()

      assert_class(html, "pa-kpi-gauge")
      refute html =~ "pa-kpi-gauge--"
    end
  end

  describe "gauge tile value head" do
    test "prefix/value/unit render as __unit · __num · __unit inside __value" do
      html = render_gauge(%{prefix_text: "$", value_text: "859", unit_text: "K"})

      assert html =~
               ~r{<div class="pa-kpi-gauge__value">\s*<span class="pa-kpi-gauge__unit">\$</span>\s*<span class="pa-kpi-gauge__num">859</span>\s*<span class="pa-kpi-gauge__unit">K</span>}
    end

    test "omits the __num span entirely when no value_text is given" do
      html = render_gauge(%{label_text: "Open Tickets"})

      # keen's __num span is conditional on value_text — absence omits it
      # (the fidelity goldens therefore only cover the value-present shape,
      # where keen and svelte agree).
      refute html =~ ~s(class="pa-kpi-gauge__num")
    end
  end

  describe "gauge tile bar fill + target tick" do
    test "the fill width is an inline style, defaulting to 0% with no bar_percent" do
      html = render_gauge()

      assert html =~ ~s(<div class="pa-kpi-gauge__fill" style="width: 0%">)
    end

    test "bar_percent sets the inline fill width" do
      html = render_gauge(%{bar_percent: 95})

      assert html =~ ~s(<div class="pa-kpi-gauge__fill" style="width: 95%">)
    end

    test "negative bar_percent is floored at 0%" do
      html = render_gauge(%{bar_percent: -10})

      assert html =~ ~s(style="width: 0%")
    end

    test "omits the bar style attribute entirely when no tick override is given" do
      html = render_gauge()

      # Regression: `style={nil}` renders as `style=""` in HEEx. bar_style/2
      # returns nil when neither tick_position nor tick_color is set, so the
      # __bar must carry NO empty style attribute (drifts from svelte, which
      # now also omits the attribute entirely).
      assert html =~ ~s(<div class="pa-kpi-gauge__bar">)
      refute html =~ ~s(style="")
    end

    test "tick_position emits --pa-kpi-gauge-tick-pos inline on the bar" do
      html = render_gauge(%{tick_position: "80%"})

      assert html =~ ~s(<div class="pa-kpi-gauge__bar" style="--pa-kpi-gauge-tick-pos: 80%;">)
    end
  end

  describe "gauge tile scale row" do
    test "the scale row is always emitted with left/right spans" do
      html = render_gauge(%{scale_end_text: "tgt $900K"})

      assert html =~
               ~r{<div class="pa-kpi-gauge__scale">\s*<span>0</span>\s*<span>tgt \$900K</span>}
    end
  end
end
