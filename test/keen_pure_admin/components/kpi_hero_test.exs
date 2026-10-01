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
end
