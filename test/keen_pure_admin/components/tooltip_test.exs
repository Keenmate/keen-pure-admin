defmodule PureAdmin.Components.TooltipTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Tooltip

  defp render(overrides) do
    base = %{
      text: "Save your changes",
      position: nil,
      variant: nil,
      multiline: false,
      is_help: false,
      is_keyword: false,
      class: nil,
      rest: %{},
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Trigger" end}]
    }

    render_component(&Tooltip.tooltip/1, Map.merge(base, overrides))
  end

  describe "tooltip/1" do
    test "always emits pa-tooltip--floating (JS portal is canonical; suppresses CSS pseudo)" do
      # Guards against the old is_inline double-tooltip: without --floating the
      # CSS ::before/::after AND the JS portal both render.
      assert_class(render(%{}), "pa-tooltip--floating")
      assert render(%{}) =~ ~s(data-tooltip="Save your changes")
    end

    test "is_keyword emits pa-tooltip--keyword (the inline-term dotted underline)" do
      assert_class(render(%{is_keyword: true}), "pa-tooltip--keyword")
      # still floating — keyword tooltips must not double-render
      assert_class(render(%{is_keyword: true}), "pa-tooltip--floating")
    end

    test "position/variant/multiline/help modifiers" do
      html = render(%{position: "bottom", variant: "success", multiline: true, is_help: true})
      assert_class(html, "pa-tooltip--bottom")
      assert_class(html, "pa-tooltip--success")
      assert_class(html, "pa-tooltip--multiline")
      assert_class(html, "pa-tooltip--help")
    end

    test "default position emits no pa-tooltip--top" do
      refute render(%{position: "top"}) =~ "pa-tooltip--top"
    end
  end
end
