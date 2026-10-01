defmodule PureAdmin.Components.RangeGroupTest do
  use PureAdmin.ComponentCase, async: true

  import Phoenix.Component, only: [sigil_H: 2]
  import PureAdmin.Components.RangeGroup

  defp render(template_fun, assigns) do
    Phoenix.LiveViewTest.render_component(template_fun, assigns)
  end

  describe "range/1 disabled" do
    test "emits pa-range--disabled on the root and disabled on both thumbs" do
      html = render(fn assigns -> ~H'<.range key="k" label="Locked" disabled />' end, %{})
      assert_class(html, "pa-range--disabled")
      # both thumb buttons carry disabled
      assert length(Regex.scan(~r/<button[^>]*data-range-thumb[^>]*disabled/, html)) == 2
    end

    test "not disabled by default" do
      html = render(fn assigns -> ~H'<.range key="k" label="Free" />' end, %{})
      refute_class(html, "pa-range--disabled")
    end
  end

  describe "range_group/1 panel style" do
    # Regression guard: a nil panel_style must emit NO style attribute. A bare
    # `style={nil}` renders as style="" in HEEx (unlike class), which drifts
    # from the canonical snippet + the svelte wrapper (both omit the attribute
    # when there's no per-instance token override). Mirrors desc_table/loader.
    test "no panel_style emits no style attribute on the __panel" do
      html =
        render(
          fn assigns ->
            ~H'<.range_group id="flt"><:range key="age" label="Age" min={0} max={9} /></.range_group>'
          end,
          %{}
        )

      refute html =~ ~r/<div[^>]*class="pa-range-group__panel"[^>]*style=/,
             "a nil panel_style must not emit a style attribute (no phantom style=\"\")"
    end

    test "panel_style is emitted on the __panel when present" do
      html =
        render(
          fn assigns ->
            ~H'<.range_group id="flt" panel_style="--pa-range-fill: red"><:range key="age" label="Age" min={0} max={9} /></.range_group>'
          end,
          %{}
        )

      assert html =~ ~s(style="--pa-range-fill: red")
    end
  end

  describe "range_group/1 shell" do
    test "renders the toggle + panel shell with a Reset / Apply footer by default" do
      html =
        render(
          fn assigns ->
            ~H'<.range_group id="flt"><:range key="age" label="Age" min={0} max={9} /></.range_group>'
          end,
          %{}
        )

      assert_class(html, "pa-range-group__toggle")
      assert_class(html, "pa-range-group__summary")
      assert_class(html, "pa-range-group__caret")
      assert_class(html, "pa-range-group__panel")
      assert_class(html, "pa-range-group__actions")
      assert html =~ "data-range-group-reset"
      assert html =~ "data-range-group-apply"
    end

    test "has_actions=false omits the __actions footer" do
      html =
        render(
          fn assigns ->
            ~H'<.range_group id="flt" has_actions={false}><:range key="age" label="Age" min={0} max={9} /></.range_group>'
          end,
          %{}
        )

      refute_class(html, "pa-range-group__actions")
    end
  end
end
