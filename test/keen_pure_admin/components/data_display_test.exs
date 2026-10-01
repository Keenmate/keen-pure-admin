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

  describe "desc_table/1 label_width → --label-width style" do
    defp desc_table(assigns) do
      base = %{
        inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Body" end}],
        rest: %{}
      }

      render_component(&DataDisplay.desc_table/1, Map.merge(base, assigns))
    end

    test "no label_width emits NO style attribute (not style=\"\")" do
      html = desc_table(%{})

      assert_class(html, "pa-desc-table")
      # A bare style={nil} renders as style="" in HEEx (unlike class) — the
      # wrapper must omit the attribute entirely to match the canonical snippet
      # and the svelte wrapper.
      refute html =~ ~s(style=")
    end

    test "a valid label_width emits the --label-width custom property" do
      html = desc_table(%{label_width: "16rem"})

      assert html =~ ~s(style="--label-width: 16rem")
    end

    test "an invalid label_width is dropped and emits no style attribute" do
      html = desc_table(%{label_width: "16rem; color: red"})

      refute html =~ ~s(style=")
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
