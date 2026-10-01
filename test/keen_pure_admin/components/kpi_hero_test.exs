defmodule PureAdmin.Components.KpiHeroTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.KpiHero

  defp render_hero(overrides \\ %{}) do
    base = %{
      title_text: nil,
      is_live: false,
      live_text: "LIVE",
      footer_text: nil,
      hero_split: nil,
      class: nil,
      rail: [],
      footer: [],
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Body" end}]
    }

    render_component(&KpiHero.kpi_hero_list/1, Map.merge(base, overrides))
  end

  describe "container namespace class" do
    test "the card shell carries both pa-card and the pa-kpi-hero-list namespace class" do
      html = render_hero()

      # pa-kpi-hero-list is the showcase namespace on the card — it must not be
      # dropped (a bare string in build_classes/3's modifier list is silently
      # ignored; the class has to be folded into the base or passed as a tuple).
      assert_class(html, "pa-card")
      assert_class(html, "pa-kpi-hero-list")
      assert_class(html, "pa-kpi-hero-list__body")
      assert_class(html, "pa-kpi-hero-list__layout")
    end
  end

  describe "header title uses the canonical card-title shape" do
    test "title_text renders pa-card__title > h3.pa-card__title-text, not a bare <h3>" do
      html = render_hero(%{title_text: "Key Performance Indicators"})

      # Canonical card-header shape (matches core snippets/kpi.html L474 + the
      # card-header canonicalization rule): the title is wrapped in
      # pa-card__title and the <h3> carries pa-card__title-text.
      assert_class(html, "pa-card__title")
      assert_class(html, "pa-card__title-text")
      assert html =~ ~r{<div class="pa-card__title">\s*<h3 class="pa-card__title-text">Key Performance Indicators</h3>}

      # The legacy bare-<h3> shape must not be emitted.
      refute html =~ ~r{<h3>Key Performance Indicators</h3>}
    end
  end

  describe "layout split modifiers" do
    test "hero_split dasherizes to the __layout--hero-* element modifier" do
      assert render_hero(%{hero_split: "2_3"})
             |> String.contains?("pa-kpi-hero-list__layout--hero-2-3")

      assert render_hero(%{hero_split: "3_4"})
             |> String.contains?("pa-kpi-hero-list__layout--hero-3-4")
    end

    test "default split emits the bare layout, no modifier" do
      html = render_hero()
      refute html =~ "pa-kpi-hero-list__layout--"
    end
  end

  # ----------------------------------------------------------------------
  # kpi_hero_main/1 — the headline hero panel
  # ----------------------------------------------------------------------

  defp render_main(overrides) do
    base = %{
      id: nil,
      variant: nil,
      label_text: nil,
      value_text: nil,
      unit_text: nil,
      prefix_text: nil,
      delta_text: nil,
      period_text: nil,
      target_text: nil,
      detail_title_text: nil,
      previous_value_text: nil,
      delta_absolute_text: nil,
      delta_absolute_sentiment: nil,
      detail_rows: nil,
      class: nil,
      label: [],
      value: [],
      meta: [],
      chart: [],
      detail: []
    }

    render_component(&KpiHero.kpi_hero_main/1, Map.merge(base, overrides))
  end

  describe "kpi_hero_main/1 sentiment modifier" do
    test "variant emits the tuple-guarded block modifier (not dropped as a bare string)" do
      # build_classes/3 only keeps {class, true} tuples in the modifier list — a
      # bare string would be silently dropped (namespace-drop bug). The sentiment
      # modifier must survive.
      for {input, dashed} <- [
            {"positive", "positive"},
            {"negative", "negative"},
            {"neutral", "neutral"},
            {"up_strong", "up-strong"}
          ] do
        html = render_main(%{variant: input, value_text: "852"})
        assert_class(html, "pa-kpi-hero-main--#{dashed}")
      end
    end

    test "default (nil) variant emits the bare block, no modifier" do
      html = render_main(%{value_text: "852"})
      assert_class(html, "pa-kpi-hero-main")
      refute html =~ "pa-kpi-hero-main--"
    end
  end

  describe "kpi_hero_main/1 element shape" do
    test "label renders only when set" do
      refute render_main(%{value_text: "852"}) =~ "pa-kpi-hero-main__label"

      assert render_main(%{label_text: "Monthly Revenue", value_text: "852"})
             |> String.contains?("pa-kpi-hero-main__label")
    end

    test "value wraps __num with prefix/suffix __unit spans in order" do
      html = render_main(%{prefix_text: "$", value_text: "852", unit_text: "K"})

      assert html =~
               ~r{<div class="pa-kpi-hero-main__value">\s*<span class="pa-kpi-hero-main__unit">\$</span>\s*<span class="pa-kpi-hero-main__num">852</span>\s*<span class="pa-kpi-hero-main__unit">K</span>}
    end

    test "meta row renders when any meta field is set; cells are spans in order" do
      refute render_main(%{value_text: "852"}) =~ "pa-kpi-hero-main__meta"

      html =
        render_main(%{
          value_text: "852",
          delta_text: "▲ 13.3%",
          period_text: "vs last month",
          target_text: "tgt $900K"
        })

      assert html =~
               ~r{<div class="pa-kpi-hero-main__meta">\s*<span class="pa-kpi-hero-main__delta">▲ 13.3%</span>\s*<span class="pa-kpi-hero-main__period">vs last month</span>\s*<span class="pa-kpi-hero-main__target">tgt \$900K</span>}
    end

    test "no inline style attribute is emitted when rest is empty" do
      # keen HEEx style={nil} would render style="" — this component must not.
      refute render_main(%{value_text: "852"}) =~ ~s(style="")
    end
  end

  # ----------------------------------------------------------------------
  # kpi_hero_side/1 — one supporting rail tile
  # ----------------------------------------------------------------------

  defp render_side(overrides) do
    base = %{
      id: nil,
      variant: nil,
      label_text: nil,
      value_text: nil,
      unit_text: nil,
      prefix_text: nil,
      delta_text: nil,
      detail_title_text: nil,
      previous_value_text: nil,
      target_text: nil,
      delta_absolute_text: nil,
      delta_absolute_sentiment: nil,
      detail_rows: nil,
      class: nil,
      label: [],
      value: [],
      delta: [],
      detail: []
    }

    render_component(&KpiHero.kpi_hero_side/1, Map.merge(base, overrides))
  end

  describe "kpi_hero_side/1 sentiment modifier" do
    test "variant emits the tuple-guarded block modifier (not dropped as a bare string)" do
      for {input, dashed} <- [
            {"positive", "positive"},
            {"negative", "negative"},
            {"neutral", "neutral"},
            {"up_strong", "up-strong"}
          ] do
        html = render_side(%{variant: input, value_text: "88.5"})
        assert_class(html, "pa-kpi-hero-side--#{dashed}")
      end
    end

    test "default (nil) variant emits the bare block, no modifier" do
      html = render_side(%{value_text: "88.5"})
      assert_class(html, "pa-kpi-hero-side")
      refute html =~ "pa-kpi-hero-side--"
    end
  end

  describe "kpi_hero_side/1 element shape" do
    test "the __label and __value grid cells always render" do
      # Fixed 2×2 grid areas — both cells are emitted even when the label is unset.
      html = render_side(%{value_text: "88.5"})
      assert_class(html, "pa-kpi-hero-side__label")
      assert_class(html, "pa-kpi-hero-side__value")
      assert_class(html, "pa-kpi-hero-side__num")
    end

    test "delta cell renders only when set" do
      refute render_side(%{value_text: "88.5"}) =~ "pa-kpi-hero-side__delta"

      assert render_side(%{value_text: "88.5", delta_text: "+5.1% vs prev"})
             |> String.contains?("pa-kpi-hero-side__delta")
    end

    test "no inline style attribute is emitted when rest is empty" do
      refute render_side(%{value_text: "88.5"}) =~ ~s(style="")
    end
  end
end
