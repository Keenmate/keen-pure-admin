defmodule PureAdmin.Components.StatTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Stat

  describe "stat/1" do
    test "renders hero variant" do
      html =
        render_component(&Stat.stat/1, %{
          variant: "hero",
          color: nil,
          icon_variant: "primary",
          number: "$847,392",
          label_text: "Revenue",
          change_text: "+12.5%",
          change_direction: "positive",
          symbol_text: nil,
          value: nil,
          label: nil,
          trend: nil,
          trend_direction: nil,
          class: nil,
          icon: [],
          inner_block: []
        })

      assert_class(html, "pa-stat--hero")
      assert html =~ "$847,392"
      assert html =~ "Revenue"
      assert html =~ "+12.5%"
      assert_class(html, "pa-stat__change--positive")
    end

    test "renders square variant with color" do
      html =
        render_component(&Stat.stat/1, %{
          variant: "square",
          color: "warning",
          icon_variant: "primary",
          number: "78",
          label_text: "Capacity",
          change_text: nil,
          change_direction: nil,
          symbol_text: "%",
          value: nil,
          label: nil,
          trend: nil,
          trend_direction: nil,
          class: nil,
          icon: [],
          inner_block: []
        })

      assert_class(html, "pa-stat--square")
      assert_class(html, "pa-stat--warning")
      assert html =~ "78"
      assert html =~ "%"
      assert html =~ "Capacity"
    end

    test "color is suppressed on non-square stats (core only styles it compounded with --square)" do
      html =
        render_component(&Stat.stat/1, %{
          variant: "hero",
          color: "warning",
          icon_variant: "primary",
          number: "78",
          label_text: "Capacity",
          change_text: nil,
          change_direction: nil,
          symbol_text: nil,
          value: nil,
          label: nil,
          trend: nil,
          trend_direction: nil,
          class: nil,
          icon: [],
          inner_block: []
        })

      # .pa-stat--warning only exists as `.pa-stat--square.pa-stat--warning`, so a
      # hero stat must not emit the standalone (dead) colour class.
      refute_class(html, "pa-stat--warning")
    end

    test "fit-mode square emits __number and __symbol as <span> (canonical snippet shape)" do
      html =
        render_component(&Stat.stat/1, %{
          variant: "square",
          color: "info",
          icon_variant: "primary",
          number: "847K",
          label_text: "Monthly Revenue",
          change_text: "12.5% vs last month",
          change_direction: "positive",
          symbol_text: "$",
          is_prefix_symbol: true,
          is_fit: true,
          context_text: "Updated 2 min ago",
          value: nil,
          label: nil,
          trend: nil,
          trend_direction: nil,
          class: nil,
          icon: [],
          context: [],
          inner_block: []
        })

      # Fit mode opts into the JS hook + the flat authored shape core's snippet
      # blesses: __symbol/__number are <span> (they flow inline inside the
      # JS-built __group), the disclosure rows are <div>.
      assert html =~ ~r{<span[^>]*class="pa-stat__symbol"[^>]*>\s*\$\s*</span>}
      assert html =~ ~r{<span[^>]*class="pa-stat__number"[^>]*>\s*847K\s*</span>}
      refute html =~ ~r{<div[^>]*class="pa-stat__symbol"}
      refute html =~ ~r{<div[^>]*class="pa-stat__number"}
      assert html =~ "data-pa-stat-fit"
      assert_class(html, "pa-stat__change--positive")
      assert html =~ "pa-stat__context"
      assert html =~ "Updated 2 min ago"
    end

    test "non-fit square emits __number and __symbol as <div>" do
      html =
        render_component(&Stat.stat/1, %{
          variant: "square",
          color: "primary",
          icon_variant: "primary",
          number: "87",
          label_text: "Completion",
          change_text: nil,
          change_direction: nil,
          symbol_text: "%",
          is_prefix_symbol: false,
          is_fit: false,
          context_text: nil,
          value: nil,
          label: nil,
          trend: nil,
          trend_direction: nil,
          class: nil,
          icon: [],
          context: [],
          inner_block: []
        })

      assert html =~ ~r{<div[^>]*class="pa-stat__number"[^>]*>\s*87\s*</div>}
      assert html =~ ~r{<div[^>]*class="pa-stat__symbol"[^>]*>\s*%\s*</div>}
      refute html =~ "data-pa-stat-fit"
      # non-fit square has no disclosure rows
      refute html =~ "pa-stat__context"
    end

    test "renders negative change direction" do
      html =
        render_component(&Stat.stat/1, %{
          variant: "hero",
          color: nil,
          icon_variant: "primary",
          number: "3.47%",
          label_text: "Rate",
          change_text: "-2.1%",
          change_direction: "negative",
          symbol_text: nil,
          value: nil,
          label: nil,
          trend: nil,
          trend_direction: nil,
          class: nil,
          icon: [],
          inner_block: []
        })

      assert_class(html, "pa-stat__change--negative")
    end
  end
end
