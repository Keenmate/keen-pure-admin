defmodule PureAdmin.Components.DataVizTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.DataViz

  describe "progress/1 — primary is the default, emits no dead modifier" do
    test "variant=primary emits no --primary class (base fill is accent)" do
      html =
        render_component(&DataViz.progress/1, %{
          value: 40,
          variant: "primary",
          size: nil,
          is_striped: false,
          is_animated: false,
          is_rounded: false,
          class: nil
        })

      assert_class(html, "pa-progress")
      refute_class(html, "pa-progress--primary")
    end

    test "semantic variant still emits its class" do
      html =
        render_component(&DataViz.progress/1, %{
          value: 40,
          variant: "success",
          size: nil,
          is_striped: false,
          is_animated: false,
          is_rounded: false,
          class: nil
        })

      assert_class(html, "pa-progress--success")
    end

    test "bar carries the progressbar aria contract" do
      html =
        render_component(&DataViz.progress/1, %{
          value: 65,
          variant: nil,
          size: nil,
          is_striped: false,
          is_animated: false,
          is_rounded: false,
          class: nil
        })

      assert html =~ ~s(role="progressbar")
      assert html =~ ~s(aria-valuenow="65")
      assert html =~ ~s(aria-valuemin="0")
      assert html =~ ~s(aria-valuemax="100")
      assert html =~ "--value: 65%"
    end
  end

  describe "gauge/1 / sparkline/1 — primary suppressed" do
    test "gauge primary emits no --primary" do
      html =
        render_component(&DataViz.gauge/1, %{
          value: 72,
          value_text: nil,
          label: "CPU",
          variant: "primary",
          is_zones: false,
          size: nil,
          min: "0",
          max: "100",
          class: nil
        })

      refute_class(html, "pa-gauge--primary")
    end

    test "sparkline primary emits no --primary" do
      html =
        render_component(&DataViz.sparkline/1, %{
          values: [40, 65, 55],
          variant: "primary",
          size: nil,
          class: nil
        })

      refute_class(html, "pa-sparkline--primary")
    end
  end

  describe "heatmap/1 — core-real variants + compact" do
    test "is_compact emits pa-heatmap--compact" do
      html =
        render_component(&DataViz.heatmap/1, %{
          columns: 7,
          levels: [0, 1, 2, 3, 4, 2, 0],
          variant: nil,
          is_compact: true,
          class: nil
        })

      assert_class(html, "pa-heatmap--compact")
    end
  end

  describe "data_bar/1 — exposes core --negative" do
    test "negative variant emits pa-data-bar--negative" do
      html =
        render_component(&DataViz.data_bar/1, %{
          value: 30,
          variant: "negative",
          class: nil
        })

      assert_class(html, "pa-data-bar--negative")
    end

    test "primary variant emits no dead --primary" do
      html =
        render_component(&DataViz.data_bar/1, %{
          value: 30,
          variant: "primary",
          class: nil
        })

      refute_class(html, "pa-data-bar--primary")
    end

    test "value_text renders the pa-data-bar__value label above the track" do
      html = render_component(&DataViz.data_bar/1, %{value: 95, value_text: "95%"})
      assert_class(html, "pa-data-bar__value")
      assert html =~ "95%"
    end

    test "no value label when value_text omitted" do
      html = render_component(&DataViz.data_bar/1, %{value: 95})
      refute_class(html, "pa-data-bar__value")
    end
  end

  describe "stacked_bar/1 — size modifiers core blesses" do
    test "size=sm emits pa-stacked-bar--sm (core ships the --sm height)" do
      html =
        render_component(&DataViz.stacked_bar/1, %{
          size: "sm",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert_class(html, "pa-stacked-bar--sm")
    end

    test "size=lg emits pa-stacked-bar--lg" do
      html =
        render_component(&DataViz.stacked_bar/1, %{
          size: "lg",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert_class(html, "pa-stacked-bar--lg")
    end
  end
end
