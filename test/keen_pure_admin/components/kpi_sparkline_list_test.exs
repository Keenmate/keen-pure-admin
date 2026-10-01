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
end
