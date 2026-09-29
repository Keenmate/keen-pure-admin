defmodule PureAdmin.Components.NavigationTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Navigation

  defp render_tabs(overrides) do
    base = %{
      id: "t",
      style: nil,
      size: nil,
      align: nil,
      overflow: nil,
      is_wrap_labels: false,
      class: nil,
      rest: %{},
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
    }

    render_component(&Navigation.tabs/1, Map.merge(base, overrides))
  end

  describe "tabs/1 is_wrap_labels" do
    test "emits pa-tabs--wrap-labels when set" do
      html = render_tabs(%{is_wrap_labels: true})
      assert_class(html, "pa-tabs--wrap-labels")
    end

    test "omits the modifier by default" do
      html = render_tabs(%{})
      assert_class(html, "pa-tabs")
      refute_class(html, "pa-tabs--wrap-labels")
    end
  end
end
