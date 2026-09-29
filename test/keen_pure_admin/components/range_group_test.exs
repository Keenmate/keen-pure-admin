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
end
