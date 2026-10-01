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

  describe "sparkline/1 — markup-fidelity contract (core = oracle)" do
    test "size=sm emits pa-sparkline--sm (core ships the --sm height)" do
      html =
        render_component(&DataViz.sparkline/1, %{
          values: [40, 65, 55],
          variant: nil,
          size: "sm",
          class: nil
        })

      assert_class(html, "pa-sparkline--sm")
    end

    test "size=lg emits pa-sparkline--lg" do
      html =
        render_component(&DataViz.sparkline/1, %{
          values: [40, 65, 55],
          variant: nil,
          size: "lg",
          class: nil
        })

      assert_class(html, "pa-sparkline--lg")
    end

    test "each value renders a pa-sparkline__bar carrying the inline --value style" do
      html =
        render_component(&DataViz.sparkline/1, %{
          values: [40, 65],
          variant: nil,
          size: nil,
          class: nil
        })

      assert_class(html, "pa-sparkline__bar")
      assert html =~ "--value: 40%"
      assert html =~ "--value: 65%"
    end
  end

  describe "gauge/1 — markup-fidelity contract (core = oracle)" do
    defp gauge_html(overrides) do
      base = %{
        value: 72,
        value_text: "72%",
        label: "CPU",
        variant: nil,
        is_zones: false,
        size: nil,
        min: "0",
        max: "100",
        class: nil
      }

      render_component(&DataViz.gauge/1, Map.merge(base, overrides))
    end

    test "emits the bare pa-gauge block — no text-center layout wrapper" do
      # text-center is a demo grid cell, not part of pa-gauge. The wrapper must
      # not leak it (no other DataViz component does).
      refute gauge_html(%{}) =~ ~s(class="text-center")
    end

    test "size appends --pa-gauge-size with NO trailing semicolon" do
      html = gauge_html(%{size: "16rem"})
      assert html =~ "--value: 72; --pa-gauge-size: 16rem"
      refute html =~ "16rem;"
    end

    test "zones suppresses the colour variant class (zones wins the fill)" do
      html = gauge_html(%{is_zones: true, variant: "success"})
      assert_class(html, "pa-gauge--zones")
      refute_class(html, "pa-gauge--success")
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
