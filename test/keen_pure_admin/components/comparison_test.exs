defmodule PureAdmin.Components.ComparisonTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Comparison

  describe "comparison_row/1 data_label" do
    test "emits data-label on the value cell for mobile stacking" do
      html =
        render_component(&Comparison.comparison_row/1, %{
          label: "Town",
          cells: nil,
          class: nil,
          rest: %{},
          cell: [
            %{__slot__: :cell, data_label: "Base", inner_block: fn _, _ -> "Beveren" end},
            %{__slot__: :cell, data_label: "New", inner_block: fn _, _ -> "Antwerpen" end}
          ]
        })

      assert html =~ ~s(data-label="Base")
      assert html =~ ~s(data-label="New")
    end

    test "omits data-label when not provided" do
      html =
        render_component(&Comparison.comparison_row/1, %{
          label: "Town",
          cells: nil,
          class: nil,
          rest: %{},
          cell: [%{__slot__: :cell, inner_block: fn _, _ -> "x" end}]
        })

      refute html =~ "data-label"
    end
  end
end
