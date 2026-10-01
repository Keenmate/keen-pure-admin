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
end
