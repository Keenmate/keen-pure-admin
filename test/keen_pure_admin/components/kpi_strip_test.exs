defmodule PureAdmin.Components.KpiStripTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.KpiStrip

  defp render_strip(overrides \\ %{}) do
    base = %{
      title_text: "Test",
      is_live: false,
      live_text: "LIVE",
      footer_text: nil,
      no_previous_value: false,
      no_delta_percent: false,
      no_target_bar: false,
      no_header: false,
      header_labels: %{},
      class: nil,
      head: [],
      footer: [],
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
    }

    render_component(&KpiStrip.kpi_strip/1, Map.merge(base, overrides))
  end

  describe "head cells use core's blessed short modifiers" do
    test "emits --prev/--delta/--target, never the invented column-atom forms" do
      html = render_strip()

      # blessed short forms exist in core (_kpi-numeric-strip.scss)
      assert_class(html, "pa-kpi-strip__head--prev")
      assert_class(html, "pa-kpi-strip__head--delta")
      assert_class(html, "pa-kpi-strip__head--target")

      # invented / non-existent modifiers must not be emitted
      refute_class(html, "pa-kpi-strip__head--previous-value")
      refute_class(html, "pa-kpi-strip__head--delta-percent")
      refute_class(html, "pa-kpi-strip__head--target-bar")
      refute_class(html, "pa-kpi-strip__head--metric")
      refute_class(html, "pa-kpi-strip__head--now")
    end

    test "numeric head cells still carry --num" do
      html = render_strip()
      assert_class(html, "pa-kpi-strip__head--num")
    end
  end

  describe "header title uses the canonical card-title shape" do
    test "title_text renders pa-card__title > h3.pa-card__title-text, not a bare <h3>" do
      html = render_strip(%{title_text: "Key Performance Indicators"})

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

  # ----------------------------------------------------------------------
  # kpi_strip_row/1 — the .pa-kpi-strip__row fragment (core fixture
  # kpi-strip-row.json). Guards the markup-fidelity contract the row shares
  # with svelte KpiStripRow.
  # ----------------------------------------------------------------------

  defp render_row(overrides) do
    base = %{
      id: nil,
      metric_text: nil,
      value_text: nil,
      unit_text: nil,
      prefix_text: nil,
      previous_value_text: nil,
      delta_text: nil,
      delta_variant: nil,
      target_bar_percent: nil,
      target_percent_text: nil,
      detail_title_text: nil,
      target_text: nil,
      delta_absolute_text: nil,
      delta_absolute_sentiment: nil,
      detail_rows: nil,
      class: nil,
      metric: [],
      now: [],
      previous_value: [],
      delta: [],
      target: [],
      detail: []
    }

    render_component(&KpiStrip.kpi_strip_row/1, Map.merge(base, overrides))
  end

  describe "kpi_strip_row delta sentiment modifier" do
    test "delta_variant emits the dasherized --* modifier (tuple form, not dropped)" do
      # build_classes keeps only {class, true} tuples — a bare-string modifier
      # would be silently dropped. delta_classes must pass a tuple.
      html = render_row(%{value_text: "87.1", delta_text: "+3.4%", delta_variant: "up_strong"})

      assert_class(html, "pa-kpi-strip__delta")
      assert_class(html, "pa-kpi-strip__delta--up-strong")
    end

    test "no delta_variant → bare __delta, no phantom default modifier" do
      html = render_row(%{value_text: "128", delta_text: "-2.3%"})

      assert_class(html, "pa-kpi-strip__delta")
      refute html =~ ~r{pa-kpi-strip__delta--}
    end
  end

  describe "kpi_strip_row target bar fill" do
    test "__fill carries an inline width percent (never an empty style)" do
      html = render_row(%{value_text: "87.1", target_bar_percent: 97})

      assert html =~ ~r{<div class="pa-kpi-strip__fill" style="width: 97%">}
      refute html =~ ~s(style="")
    end

    test "target_bar_percent is visually capped at 100 for the fill width" do
      html = render_row(%{value_text: "4.1", target_bar_percent: 114, target_percent_text: "114%"})

      # Fill width clamps to 100 …
      assert html =~ ~r{style="width: 100%"}
      # … while the printed label keeps the raw overshoot.
      assert html =~ ~r{<div class="pa-kpi-strip__bar-pct">114%</div>}
    end

    test "missing target_percent_text drops __bar-pct but keeps __bar/__fill" do
      html = render_row(%{value_text: "1,204", target_bar_percent: 75})

      assert_class(html, "pa-kpi-strip__bar")
      assert_class(html, "pa-kpi-strip__fill")
      refute_class(html, "pa-kpi-strip__bar-pct")
    end
  end

  describe "kpi_strip_row optional cells" do
    test "missing previous_value_text omits the __prev cell" do
      html = render_row(%{value_text: "1,204", delta_text: "+6.0%"})
      refute_class(html, "pa-kpi-strip__prev")
    end

    test "prefix + unit both render as __unit affixes around __num" do
      html = render_row(%{prefix_text: "$", value_text: "835", unit_text: "K"})

      assert_class(html, "pa-kpi-strip__num")
      assert_class(html, "pa-kpi-strip__unit")
      # Order (whitespace-tolerant): prefix affix, then __num, then unit affix.
      assert html =~
               ~r{<span class="pa-kpi-strip__unit">\$</span>\s*<span class="pa-kpi-strip__num">835</span>\s*<span class="pa-kpi-strip__unit">K</span>}
    end
  end
end
