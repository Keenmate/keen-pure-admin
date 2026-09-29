defmodule PureAdmin.Components.PopconfirmTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Popconfirm

  defp render(overrides) do
    base = %{
      id: "pc",
      message: "Are you sure?",
      placement: "bottom",
      icon_variant: nil,
      is_compact: false,
      confirm_text: nil,
      cancel_text: nil,
      confirm_variant: "danger",
      confirm_event: "confirm",
      confirm_value: %{},
      class: nil,
      rest: %{},
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Delete" end}]
    }

    render_component(&Popconfirm.popconfirm/1, Map.merge(base, overrides))
  end

  describe "icon_variant" do
    test "nil emits no icon" do
      refute render(%{icon_variant: nil}) =~ "pa-popconfirm__icon"
    end

    test "\"default\" emits the bare pa-popconfirm__icon (no colour modifier)" do
      html = render(%{icon_variant: "default"})
      assert_class(html, "pa-popconfirm__icon")
      refute html =~ "pa-popconfirm__icon--"
    end

    test "severity emits both the icon and its variant modifier" do
      for v <- ~w(danger warning info) do
        html = render(%{icon_variant: v})
        assert_class(html, "pa-popconfirm__icon")
        assert_class(html, "pa-popconfirm__icon--#{v}")
      end
    end
  end

  describe "confirm_value" do
    test "forwards every key as a phx-value-* attribute" do
      html = render(%{confirm_value: %{id: 7, kind: "row"}})
      assert html =~ ~s(phx-value-id="7")
      assert html =~ ~s(phx-value-kind="row")
    end

    test "empty map emits no phx-value-* attrs" do
      refute render(%{confirm_value: %{}}) =~ "phx-value-"
    end
  end
end
