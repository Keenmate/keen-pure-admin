defmodule PureAdmin.Components.DataDisplayTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.DataDisplay

  describe "accent_grid_item/1" do
    test "semantic variant emits the real modifier" do
      html =
        render_component(&DataDisplay.accent_grid_item/1, %{
          label: "Revenue",
          value: "$12,430",
          variant: "success"
        })

      assert_class(html, "pa-accent-grid__item")
      assert_class(html, "pa-accent-grid__item--success")
    end

    test "never emits invented --color-N or --primary (core has only success/warning/danger/info)" do
      html =
        render_component(&DataDisplay.accent_grid_item/1, %{
          label: "Orders",
          value: "847",
          variant: "info"
        })

      refute html =~ "pa-accent-grid__item--color-"
      refute_class(html, "pa-accent-grid__item--primary")
    end
  end

  describe "field_group/1" do
    test "title is an <h3>, matching the blessed snippet shape" do
      html =
        render_component(&DataDisplay.field_group/1, %{
          title: "Personal",
          class: nil,
          rest: %{},
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "x" end}]
        })

      assert html =~ ~s(<h3 class="pa-field-group__title">Personal</h3>)
    end
  end

  describe "field/1 copy button — canonical shape (no inner wrapper span)" do
    test "copy-btn puts data-copy-value on .pa-field__value with the button as sibling" do
      html =
        render_component(&DataDisplay.field/1, %{
          label: "API key",
          is_copy_btn: true,
          copy_value: "sk_live_123",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "sk_live_123" end}]
        })

      assert html =~ ~r/<span class="pa-field__value"[^>]*data-copy-value="sk_live_123"/
      assert_class(html, "pa-field__copy")
      # no extra inner wrapper span carrying data-copy-value (button resolves via ancestor)
      refute html =~ ~r/<span data-copy-value=/
    end
  end
end
