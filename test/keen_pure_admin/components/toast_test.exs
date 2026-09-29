defmodule PureAdmin.Components.ToastTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Toast

  describe "toast/1" do
    test "renders with variant" do
      html =
        render_component(&Toast.toast/1, %{
          id: "t1",
          variant: "success",
          theme_color: nil,
          is_filled: false,
          title_text: "Saved",
          message_text: "Done.",
          is_visible: true,
          on_close: nil,
          class: nil,
          icon: [],
          inner_block: []
        })

      assert_class(html, "pa-toast")
      assert_class(html, "pa-toast--success")
      assert html =~ "Saved"
      assert html =~ "Done."
    end

    test "auto-derives the severity icon chip from variant (no :icon slot)" do
      for {variant, glyph} <- [{"success", "success"}, {"danger", "danger"}, {"warning", "warning"}, {"info", "info"}, {"primary", "info"}] do
        html =
          render_component(&Toast.toast/1, %{
            id: "t",
            variant: variant,
            icon: [],
            inner_block: []
          })

        assert_class(html, "pa-toast__icon")
        assert html =~ ~s(pa-icon pa-icon--#{glyph})
      end
    end

    test "renders theme color" do
      html =
        render_component(&Toast.toast/1, %{
          id: "t2",
          variant: "info",
          theme_color: "5",
          is_filled: false,
          title_text: "Info",
          message_text: "msg",
          is_visible: true,
          on_close: nil,
          class: nil,
          icon: [],
          inner_block: []
        })

      assert_class(html, "pa-toast--color-5")
      refute_class(html, "pa-toast--info")
    end

    test "renders filled variant" do
      html =
        render_component(&Toast.toast/1, %{
          id: "t3",
          variant: "danger",
          theme_color: nil,
          is_filled: true,
          title_text: "Error",
          message_text: "msg",
          is_visible: true,
          on_close: nil,
          class: nil,
          icon: [],
          inner_block: []
        })

      assert_class(html, "pa-toast--filled-danger")
    end

    test "renders filled theme color" do
      html =
        render_component(&Toast.toast/1, %{
          id: "t4",
          variant: "info",
          theme_color: "3",
          is_filled: true,
          title_text: "Info",
          message_text: "msg",
          is_visible: true,
          on_close: nil,
          class: nil,
          icon: [],
          inner_block: []
        })

      assert_class(html, "pa-toast--filled-color-3")
    end

    test "hidden when not visible" do
      html =
        render_component(&Toast.toast/1, %{
          id: "t5",
          variant: "info",
          theme_color: nil,
          is_filled: false,
          title_text: "X",
          message_text: "Y",
          is_visible: false,
          on_close: nil,
          class: nil,
          icon: [],
          inner_block: []
        })

      refute html =~ "pa-toast"
    end
  end
end
