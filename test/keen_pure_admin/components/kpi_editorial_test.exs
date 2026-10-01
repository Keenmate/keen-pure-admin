defmodule PureAdmin.Components.KpiEditorialTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.KpiEditorial

  defp render_editorial(overrides \\ %{}) do
    base = %{
      title_text: nil,
      is_live: false,
      live_text: "LIVE",
      footer_text: nil,
      grid_layout: nil,
      is_2_columns: false,
      cell_min_width: nil,
      class: nil,
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}],
      footer: []
    }

    render_component(&KpiEditorial.kpi_editorial/1, Map.merge(base, overrides))
  end

  describe "card namespace class" do
    test "the card carries both pa-card and the pa-kpi-edit namespace" do
      html = render_editorial()

      # Regression: build_classes/3's second arg is a {class, bool} tuple list —
      # a bare string "pa-kpi-edit" is silently dropped, so the namespace must be
      # passed as {"pa-kpi-edit", true}.
      assert_class(html, "pa-card")
      assert_class(html, "pa-kpi-edit")
    end
  end

  describe "header title uses the canonical card-title shape" do
    test "title_text renders pa-card__title > h3.pa-card__title-text, not a bare <h3>" do
      html = render_editorial(%{title_text: "Key Performance Indicators"})

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
      html = render_editorial()

      # Regression: `style={nil}` renders as `style=""` in HEEx (unlike class),
      # which drifts from the svelte wrapper (it omits the attribute). The grid
      # must emit NO empty style attribute.
      refute html =~ ~s(style="")
    end

    test "emits --pa-kpi-edit-cell-min on the grid when cell_min_width is set" do
      html = render_editorial(%{cell_min_width: "12rem"})

      assert html =~ ~s(style="--pa-kpi-edit-cell-min: 12rem;")
    end
  end

  describe "grid column-cap modifier" do
    test "grid_layout maps to the pa-kpi-edit__grid--<value> element modifier" do
      html = render_editorial(%{grid_layout: "max_3"})

      assert_class(html, "pa-kpi-edit__grid")
      assert_class(html, "pa-kpi-edit__grid--max-3")
    end
  end

  # --------------------------------------------------------------------------
  # kpi_editorial_tile/1 — the per-KPI editorial cell (fidelity fragment
  # kpi-editorial-tile). Flat-sibling block pa-kpi-edit__tile.
  # --------------------------------------------------------------------------

  defp render_tile(overrides) do
    base = %{
      id: nil,
      label_text: nil,
      value_text: nil,
      unit_text: nil,
      prefix_text: nil,
      delta_text: nil,
      delta_variant: nil,
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
      detail: []
    }

    render_component(&KpiEditorial.kpi_editorial_tile/1, Map.merge(base, overrides))
  end

  describe "tile block + cells" do
    test "the tile carries pa-kpi-edit__tile and its flat-sibling cells" do
      html = render_tile(%{label_text: "Active Users", value_text: "12.4"})

      assert_class(html, "pa-kpi-edit__tile")
      assert_class(html, "pa-kpi-edit__label")
      assert_class(html, "pa-kpi-edit__value")
      assert_class(html, "pa-kpi-edit__num")

      # No delta/target → no meta row.
      refute html =~ "pa-kpi-edit__meta"
    end

    test "prefix + unit render as __unit spans around __num" do
      html = render_tile(%{prefix_text: "$", value_text: "849", unit_text: "K"})

      assert_class(html, "pa-kpi-edit__unit")
      assert html =~ "849"
    end
  end

  describe "tile meta row (delta + target)" do
    test "bare delta opens the meta row with NO tint modifier (default --pa-positive)" do
      html = render_tile(%{value_text: "87.1", delta_text: "+3.4%"})

      assert_class(html, "pa-kpi-edit__meta")
      assert_class(html, "pa-kpi-edit__delta")
      refute html =~ "pa-kpi-edit__delta--"
    end

    test "delta_variant produces the matching __delta--<value> tint (dashed pass-through)" do
      for v <- ~w(positive negative neutral up-strong down-strong) do
        html = render_tile(%{value_text: "1", delta_text: "+1%", delta_variant: v})
        assert_class(html, "pa-kpi-edit__delta--#{v}")
      end
    end

    test "target renders __target with a literal <em>tgt</em> before the value" do
      html = render_tile(%{value_text: "87.1", target_text: "90.0%"})

      assert_class(html, "pa-kpi-edit__target")
      assert html =~ ~r{<span class="pa-kpi-edit__target"><em>tgt</em>90.0%</span>}
    end
  end
end
