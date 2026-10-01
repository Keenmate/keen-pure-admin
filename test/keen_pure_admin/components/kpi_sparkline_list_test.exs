defmodule PureAdmin.Components.KpiSparklineListTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.KpiSparklineList

  defp render_list(overrides \\ %{}) do
    base = %{
      title_text: nil,
      is_live: false,
      live_text: "LIVE",
      footer_text: nil,
      is_no_delta: false,
      is_chart_first: false,
      class: nil,
      footer: [],
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
    }

    render_component(&KpiSparklineList.kpi_sparkline_list/1, Map.merge(base, overrides))
  end

  describe "container chrome" do
    test "renders the pa-card pa-kpi-spark-list host with the __body region" do
      html = render_list()

      assert_class(html, "pa-card")
      assert_class(html, "pa-kpi-spark-list")
      assert_class(html, "pa-kpi-spark-list__body")
    end

    test "emits the block modifiers from is_no_delta / is_chart_first" do
      html = render_list(%{is_no_delta: true, is_chart_first: true})

      assert_class(html, "pa-kpi-spark-list--no-delta")
      assert_class(html, "pa-kpi-spark-list--chart-first")
    end
  end

  describe "header title uses the canonical card-title shape" do
    test "title_text renders pa-card__title > h3.pa-card__title-text, not a bare <h3>" do
      html = render_list(%{title_text: "Key Performance Indicators"})

      # Canonical card-header shape (matches core snippets/kpi.html L333 + the
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

  # ----------------------------------------------------------------------
  # kpi_sparkline_row/1 — the .pa-kpi-spark-row block (core fixture
  # kpi-sparkline-row.json). Guards the markup-fidelity contract the row
  # shares with svelte KpiSparklineRow.
  # ----------------------------------------------------------------------

  defp render_row(overrides) do
    base = %{
      id: nil,
      variant: nil,
      label_text: nil,
      value_text: nil,
      unit_text: nil,
      prefix_text: nil,
      delta_text: nil,
      delta_variant: nil,
      detail_title_text: nil,
      previous_value_text: nil,
      target_text: nil,
      delta_absolute_text: nil,
      delta_absolute_sentiment: nil,
      detail_rows: nil,
      class: nil,
      label: [],
      chart: [],
      value: [],
      delta: [],
      detail: []
    }

    render_component(&KpiSparklineList.kpi_sparkline_row/1, Map.merge(base, overrides))
  end

  describe "kpi_sparkline_row sentiment modifiers" do
    test "variant emits the dasherized row --* modifier (tuple form, not dropped)" do
      # build_classes keeps only {class, true} tuples — a bare-string modifier
      # would be silently dropped. row_classes must pass a tuple.
      html = render_row(%{variant: "up_strong", label_text: "Signups", value_text: "1,204"})

      assert_class(html, "pa-kpi-spark-row")
      assert_class(html, "pa-kpi-spark-row--up-strong")
    end

    test "delta_variant emits the dasherized __delta--* tint (distinct scale)" do
      html = render_row(%{label_text: "Error Rate", value_text: "0.25", delta_text: "-38.1%", delta_variant: "very_negative"})

      assert_class(html, "pa-kpi-spark-row__delta")
      assert_class(html, "pa-kpi-spark-row__delta--very-negative")
    end

    test "no variant / no delta_variant → bare block + bare __delta, no phantom modifiers" do
      html = render_row(%{label_text: "Throughput", value_text: "9.2", delta_text: "+1.1%"})

      assert_class(html, "pa-kpi-spark-row")
      refute html =~ ~r{pa-kpi-spark-row--}
      assert_class(html, "pa-kpi-spark-row__delta")
      refute html =~ ~r{pa-kpi-spark-row__delta--}
    end
  end

  describe "kpi_sparkline_row structure" do
    test "always emits the __chart wrapper (hosts the author SVG)" do
      html = render_row(%{label_text: "Revenue", value_text: "900"})
      assert_class(html, "pa-kpi-spark-row__chart")
    end

    test "prefix + unit both render as __unit affixes around __num" do
      html = render_row(%{variant: "up", label_text: "Revenue", prefix_text: "$", value_text: "848", unit_text: "K"})

      # Order (whitespace-tolerant): prefix affix, then __num, then unit affix.
      assert html =~
               ~r{<span class="pa-kpi-spark-row__unit">\$</span>\s*<span class="pa-kpi-spark-row__num">848</span>\s*<span class="pa-kpi-spark-row__unit">K</span>}
    end
  end
end
