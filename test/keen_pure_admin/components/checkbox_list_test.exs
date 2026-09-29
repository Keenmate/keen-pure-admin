defmodule PureAdmin.Components.CheckboxListTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.CheckboxList

  describe "checkbox_list_item/1 forwards checkbox attrs" do
    test "size / is_x_mark / is_indeterminate reach the inner checkbox_box" do
      html =
        render_component(&CheckboxList.checkbox_list_item/1, %{
          id: "t1",
          label_text: "Task",
          size: "lg",
          is_x_mark: true,
          is_indeterminate: true,
          actions: []
        })

      assert_class(html, "pa-checkbox--lg")
      assert_class(html, "pa-checkbox--x")
      # indeterminate wires the hook on the inner checkbox_box
      assert html =~ ~s(data-indeterminate="true")
    end

    test "defaults: none of the forwarded modifiers present" do
      html =
        render_component(&CheckboxList.checkbox_list_item/1, %{
          id: "t2",
          label_text: "Task",
          actions: []
        })

      refute_class(html, "pa-checkbox--lg")
      refute_class(html, "pa-checkbox--x")
    end
  end
end
