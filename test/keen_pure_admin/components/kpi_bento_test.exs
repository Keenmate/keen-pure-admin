defmodule PureAdmin.Components.KpiBentoTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.KpiBento

  defp render_bento(overrides \\ %{}) do
    base = %{
      title_text: nil,
      is_live: false,
      live_text: "LIVE",
      footer_text: nil,
      bento_layout: nil,
      row_height: nil,
      class: nil,
      footer: [],
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Body" end}]
    }

    render_component(&KpiBento.kpi_bento/1, Map.merge(base, overrides))
  end

  describe "container namespace class" do
    test "the card shell carries both pa-card and the pa-kpi-bento namespace class" do
      html = render_bento()

      # pa-kpi-bento is the showcase namespace on the card — it must not be
      # dropped (a bare string in build_classes/3's modifier list is silently
      # ignored; the class has to be folded into the base or passed as a tuple).
      assert_class(html, "pa-card")
      assert_class(html, "pa-kpi-bento")
      assert_class(html, "pa-kpi-bento__body")
      assert_class(html, "pa-kpi-bento__grid")
    end
  end

  describe "no empty style attribute" do
    test "omits style entirely when row_height is unset (no style=\"\" artifact)" do
      html = render_bento()

      # A bare style={nil} renders as style="" in HEEx (unlike class), which
      # drifts from the canonical snippet + the svelte wrapper. The row-height
      # style must be folded into :rest only when present.
      refute html =~ ~r{style=""}
    end

    test "emits the row-height custom property when row_height is set" do
      html = render_bento(%{row_height: "14rem"})

      assert html =~ "--pa-kpi-bento-row-height: 14rem;"
    end
  end

  describe "header title uses the canonical card-title shape" do
    test "title_text renders pa-card__title > h3.pa-card__title-text, not a bare <h3>" do
      html = render_bento(%{title_text: "Key Performance Indicators"})

      # Canonical card-header shape (matches core snippets/kpi.html + the
      # card-header canonicalization rule): the title is wrapped in
      # pa-card__title and the <h3> carries pa-card__title-text.
      assert_class(html, "pa-card__title")
      assert_class(html, "pa-card__title-text")
      assert html =~ ~r{<div class="pa-card__title">\s*<h3 class="pa-card__title-text">Key Performance Indicators</h3>}

      # The legacy bare-<h3> shape must not be emitted.
      refute html =~ ~r{<h3>Key Performance Indicators</h3>}
    end
  end

  describe "grid layout modifiers" do
    test "bento_layout dasherizes underscored values to the __grid--* class" do
      assert render_bento(%{bento_layout: "hero_right"}) |> String.contains?("pa-kpi-bento__grid--hero-right")
      assert render_bento(%{bento_layout: "5_tile"}) |> String.contains?("pa-kpi-bento__grid--5-tile")
    end

    test "default layout emits the bare grid, no modifier" do
      html = render_bento()
      refute html =~ "pa-kpi-bento__grid--"
    end
  end
end
