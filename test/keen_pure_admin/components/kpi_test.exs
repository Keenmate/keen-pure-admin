defmodule PureAdmin.Components.KpiTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Kpi

  # ----------------------------------------------------------------------
  # kpi_tile/1
  # ----------------------------------------------------------------------

  defp render_tile(overrides) do
    base = %{
      id: nil,
      variant: nil,
      is_standalone: false,
      id_text: nil,
      status_text: nil,
      status_variant: nil,
      label_text: nil,
      value_text: nil,
      unit_text: nil,
      prefix_text: nil,
      value_variant: nil,
      previous_value_text: nil,
      delta_text: nil,
      delta_variant: nil,
      detail_title_text: nil,
      delta_absolute_text: nil,
      delta_absolute_sentiment: nil,
      target_text: nil,
      detail_rows: nil,
      class: nil,
      head: [],
      label: [],
      value: [],
      previous_value: [],
      chart: [],
      detail: []
    }

    render_component(&Kpi.kpi_tile/1, Map.merge(base, overrides))
  end

  describe "kpi_tile block + modifiers" do
    test "bare tile is just pa-kpi-tile (no modifier)" do
      html = render_tile(%{label_text: "Completion Rate", value_text: "88.6"})
      assert_class(html, "pa-kpi-tile")
      refute html =~ ~r{pa-kpi-tile--}
    end

    test "variant dasherizes underscored trend directions to the block modifier" do
      assert render_tile(%{variant: "up_strong"}) |> String.contains?("pa-kpi-tile--up-strong")
      assert render_tile(%{variant: "down_strong"}) |> String.contains?("pa-kpi-tile--down-strong")
      assert render_tile(%{variant: "up"}) |> String.contains?("pa-kpi-tile--up")
    end

    test "is_standalone adds the --standalone modifier" do
      assert_class(render_tile(%{is_standalone: true}), "pa-kpi-tile--standalone")
    end

    test "class passthrough is appended to the tile shell" do
      assert_class(render_tile(%{class: "mb-4"}), "mb-4")
    end
  end

  describe "kpi_tile head row" do
    test "renders __id + __status pill with its variant" do
      html =
        render_tile(%{id_text: "KPI.01 · 30d", status_text: "WARN", status_variant: "warn"})

      assert_class(html, "pa-kpi-tile__head")
      assert html =~ ~r{<span class="pa-kpi-tile__id">KPI.01 · 30d</span>}
      assert_class(html, "pa-kpi-tile__status")
      assert_class(html, "pa-kpi-tile__status--warn")
    end

    test "no head row when neither id nor status is set" do
      html = render_tile(%{label_text: "X", value_text: "1"})
      refute html =~ "pa-kpi-tile__head"
    end
  end

  describe "kpi_tile value group" do
    test "renders __values > __value > prefix/num/unit in order" do
      html =
        render_tile(%{prefix_text: "$", value_text: "835", unit_text: "K"})

      assert_class(html, "pa-kpi-tile__values")
      assert_class(html, "pa-kpi-tile__value")

      assert html =~
               ~r{<span class="pa-kpi-tile__unit">\$</span>\s*<span class="pa-kpi-tile__num">835</span>\s*<span class="pa-kpi-tile__unit">K</span>}
    end

    test "value_variant tints the __value" do
      assert_class(
        render_tile(%{value_text: "88.6", value_variant: "very_positive"}),
        "pa-kpi-tile__value--very-positive"
      )
    end
  end

  describe "kpi_tile previous/delta row" do
    test "renders a bare `prev <value>` span + the __delta chip with its variant" do
      html =
        render_tile(%{previous_value_text: "84.2%", delta_text: "▲ 5.2%", delta_variant: "positive"})

      assert_class(html, "pa-kpi-tile__prev")
      assert html =~ ~r{<span>prev 84.2%</span>}
      assert_class(html, "pa-kpi-tile__delta")
      assert_class(html, "pa-kpi-tile__delta--positive")
    end
  end

  describe "kpi_tile no empty style / no popover by default" do
    test "no style=\"\" artifact on the tile" do
      refute render_tile(%{label_text: "X", value_text: "1"}) =~ ~r{style=""}
    end

    test "no popover and no phx-hook when detail is not engaged" do
      html = render_tile(%{label_text: "X", value_text: "1"})
      refute html =~ "pa-kpi-detail"
      refute html =~ "PureAdminKpiTile"
    end
  end

  # ----------------------------------------------------------------------
  # kpi_detail/1
  # ----------------------------------------------------------------------

  defp render_detail(overrides \\ %{}) do
    base = %{
      title_text: nil,
      rows: [],
      class: nil,
      inner_block: []
    }

    render_component(&Kpi.kpi_detail/1, Map.merge(base, overrides))
  end

  describe "kpi_detail popover" do
    test "title-only popover is the tooltip wrapper + __title div, no <dl>" do
      html = render_detail(%{title_text: "Completion Rate · 30D"})

      assert html =~ ~r{<div class="pa-kpi-detail" role="tooltip">}
      assert html =~ ~r{<div class="pa-kpi-detail__title">Completion Rate · 30D</div>}
      refute html =~ "<dl"
    end

    test "renders nothing when there is no title, no rows, no inner_block" do
      assert String.trim(render_detail()) == ""
    end

    test "auto-rows render a native <dl> with dt/dd and sentiment class on dd" do
      html =
        render_detail(%{
          title_text: "Completion Rate · 30D",
          rows: [
            %{label_text: "Current", value_text: "88.6%"},
            %{label_text: "Δ percent", value_text: "+5.2%", sentiment: :pos}
          ]
        })

      assert html =~ ~r{<dt>Current</dt>\s*<dd[^>]*>88.6%</dd>}
      assert html =~ ~r{<dd class="pos">\+5.2%</dd>}
    end
  end

  # ----------------------------------------------------------------------
  # kpi_sparkline/1
  # ----------------------------------------------------------------------

  defp render_sparkline(overrides \\ %{}) do
    base = %{
      id: nil,
      points: "0,18 12,16 24,17 36,12 48,15",
      view_box: "0 0 100 24",
      dot_at: nil,
      class: nil
    }

    render_component(&Kpi.kpi_sparkline/1, Map.merge(base, overrides))
  end

  describe "kpi_sparkline" do
    test "emits the pa-kpi-tile__spark svg with viewBox + preserveAspectRatio + polyline" do
      html = render_sparkline()

      assert html =~ ~r{<svg[^>]*class="pa-kpi-tile__spark"}
      assert html =~ ~r{viewBox="0 0 100 24"}
      assert html =~ ~r{preserveAspectRatio="none"}
      assert html =~ ~r{<polyline points="0,18 12,16 24,17 36,12 48,15"}
    end

    test "no trailing <circle> when dot_at is unset, and no spark-dot hook" do
      html = render_sparkline()
      refute html =~ "<circle"
      refute html =~ "PureAdminKpiSparkDot"
    end

    test "dot_at emits a <circle> at the given point" do
      html = render_sparkline(%{dot_at: {96, 5}})
      assert html =~ ~r{<circle cx="96" cy="5" r="2"}
    end

    test "view_box override flows to the SVG attribute" do
      assert render_sparkline(%{view_box: "0 0 120 20"}) =~ ~r{viewBox="0 0 120 20"}
    end
  end
end
