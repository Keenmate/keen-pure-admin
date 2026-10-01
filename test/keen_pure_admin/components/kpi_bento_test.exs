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

  # --------------------------------------------------------------------------
  # kpi_bento_tile/1 — the per-KPI bento cell (fidelity fragment kpi-bento-tile)
  # --------------------------------------------------------------------------

  alias PureAdmin.Components.KpiBento, as: Bento

  defp render_tile(overrides) do
    base = %{
      id: nil,
      variant: nil,
      is_hero: false,
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
      chart: [],
      detail: []
    }

    render_component(&Bento.kpi_bento_tile/1, Map.merge(base, overrides))
  end

  describe "tile block + default sentiment" do
    test "the bare tile carries pa-kpi-bento-tile and NO sentiment modifier" do
      html = render_tile(%{label_text: "Active Users", value_text: "12.4"})

      assert_class(html, "pa-kpi-bento-tile")
      assert_class(html, "pa-kpi-bento-tile__label")
      assert_class(html, "pa-kpi-bento-tile__value")
      assert_class(html, "pa-kpi-bento-tile__num")

      # Default sentiment seeds --pa-positive via SCSS on the bare tile — the
      # wrapper must NOT emit a phantom --positive modifier class.
      refute html =~ "pa-kpi-bento-tile--"
    end
  end

  describe "tile modifiers (tuple list — no namespace-drop)" do
    test "variant + is_hero emit both modifier classes" do
      # build_classes/3 keeps only {class, true} tuples; a bare-string modifier
      # is silently dropped. The sentiment + hero modifiers must survive.
      html = render_tile(%{variant: "positive", is_hero: true, label_text: "Rev", value_text: "849"})

      assert_class(html, "pa-kpi-bento-tile--positive")
      assert_class(html, "pa-kpi-bento-tile--hero")
    end

    test "each sentiment variant produces the matching modifier (dashed pass-through)" do
      for v <- ~w(positive negative neutral up-strong down-strong) do
        html = render_tile(%{variant: v, label_text: "L", value_text: "1"})
        assert_class(html, "pa-kpi-bento-tile--#{v}")
      end
    end
  end

  describe "tile cells" do
    test "prefix + unit render as __unit spans around __num, delta only when set" do
      html = render_tile(%{prefix_text: "$", value_text: "849", unit_text: "K", delta_text: "+12.8%"})

      assert_class(html, "pa-kpi-bento-tile__unit")
      assert_class(html, "pa-kpi-bento-tile__delta")
      assert html =~ "+12.8%"
    end

    test "no delta cell when delta_text is unset" do
      html = render_tile(%{label_text: "L", value_text: "1"})
      refute html =~ "pa-kpi-bento-tile__delta"
    end
  end
end
