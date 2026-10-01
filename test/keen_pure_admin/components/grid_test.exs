defmodule PureAdmin.Components.GridTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Grid

  describe "grid/1" do
    test "renders basic row" do
      html =
        render_component(&Grid.grid/1, %{
          is_no_gutter: false,
          is_same_height: false,
          align: nil,
          valign: nil,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "columns" end}]
        })

      assert_class(html, "pc-row")
    end

    test "renders row with modifiers" do
      html =
        render_component(&Grid.grid/1, %{
          is_no_gutter: true,
          is_same_height: true,
          align: "center",
          valign: "middle",
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert_class(html, "pc-row--no-gutter")
      assert_class(html, "pc-row--same-height")
      assert_class(html, "pc-row--center")
      assert_class(html, "pc-row--middle")
    end

    test "valign accepts stretch (the explicit default align-items)" do
      html =
        render_component(&Grid.grid/1, %{
          is_no_gutter: false,
          is_same_height: false,
          align: nil,
          valign: "stretch",
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert_class(html, "pc-row--stretch")
    end
  end

  describe "column/1" do
    test "renders responsive column" do
      html =
        render_component(&Grid.column/1, %{
          size: "100",
          sm: nil,
          md: "50",
          lg: "1-3",
          xl: nil,
          offset: nil,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert_class(html, "pc-col-100")
      assert_class(html, "pc-col-md-50")
      assert_class(html, "pc-col-lg-1-3")
    end

    test "renders column with offset" do
      html =
        render_component(&Grid.column/1, %{
          size: "50",
          sm: nil,
          md: nil,
          lg: nil,
          xl: nil,
          offset: "25",
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert_class(html, "pc-col-50")
      assert_class(html, "pc-offset-25")
    end

    test "a sizeless column is the bare pc-col" do
      html =
        render_component(&Grid.column/1, %{
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert_class(html, "pc-col")
      assert html =~ "content"
    end

    test "off flex modifiers never leak the literal \"false\" into the class string" do
      # `cond && \"class\"` yields `false` when off; it must be dropped, not joined.
      html =
        render_component(&Grid.column/1, %{
          size: "50",
          is_no_padding: false,
          is_grow: false,
          is_shrink: false,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert_class(html, "pc-col-50")
      refute html =~ "false"
      refute_class(html, "pc-col--no-padding")
      refute_class(html, "pc-col--grow")
      refute_class(html, "pc-col--shrink")
    end

    test "flex modifiers emit their pc-col--* classes when on" do
      html =
        render_component(&Grid.column/1, %{
          size: "auto",
          is_no_padding: true,
          is_grow: true,
          is_shrink: true,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert_class(html, "pc-col--no-padding")
      assert_class(html, "pc-col--grow")
      assert_class(html, "pc-col--shrink")
    end
  end
end
