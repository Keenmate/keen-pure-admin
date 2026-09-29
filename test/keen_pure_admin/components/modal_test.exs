defmodule PureAdmin.Components.ModalTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Modal

  describe "modal/1" do
    test "renders basic modal" do
      html =
        render_component(&Modal.modal/1, %{
          id: "test-modal",
          variant: nil,
          size: nil,
          is_static: false,
          is_top: false,
          is_scrollable: false,
          show: false,
          on_cancel: %Phoenix.LiveView.JS{},
          class: nil,
          header: [],
          footer: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Body content" end}]
        })

      assert_class(html, "pa-modal")
      assert_class(html, "pa-modal__backdrop")
      assert_class(html, "pa-modal__container")
      assert_class(html, "pa-modal__body")
      assert html =~ "Body content"
      assert html =~ ~s(id="test-modal")
    end

    test "renders modal with size and variant" do
      html =
        render_component(&Modal.modal/1, %{
          id: "lg-modal",
          variant: "danger",
          size: "lg",
          is_static: false,
          is_top: false,
          is_scrollable: true,
          show: false,
          on_cancel: %Phoenix.LiveView.JS{},
          class: nil,
          header: [],
          footer: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Content" end}]
        })

      assert_class(html, "pa-modal--danger")
      assert_class(html, "pa-modal__container--lg")
      assert_class(html, "pa-modal__body--scrollable")
    end

    test "renders static modal" do
      html =
        render_component(&Modal.modal/1, %{
          id: "static-modal",
          variant: nil,
          size: nil,
          is_static: true,
          is_top: false,
          is_scrollable: false,
          show: false,
          on_cancel: %Phoenix.LiveView.JS{},
          class: nil,
          header: [],
          footer: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Static" end}]
        })

      assert_class(html, "pa-modal--static")
    end
  end

  describe "is_banded guard" do
    defp render_banded(variant) do
      render_component(&Modal.modal/1, %{
        id: "b-modal",
        variant: variant,
        is_banded: true,
        size: nil,
        is_static: false,
        is_top: false,
        is_scrollable: false,
        show: false,
        on_cancel: %Phoenix.LiveView.JS{},
        class: nil,
        header: [],
        footer: [],
        inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "x" end}]
      })
    end

    test "band roles emit pa-modal--banded" do
      for variant <- ~w(success warning danger info) do
        assert_class(render_banded(variant), "pa-modal--banded")
      end
    end

    test "non-band variants do NOT emit pa-modal--banded (unstyled phantom)" do
      for variant <- ["primary", "secondary", "light", "dark", nil] do
        refute_class(render_banded(variant), "pa-modal--banded")
      end
    end
  end

  describe "show_modal/1 and hide_modal/1" do
    test "returns JS structs" do
      assert %Phoenix.LiveView.JS{} = Modal.show_modal("test")
      assert %Phoenix.LiveView.JS{} = Modal.hide_modal("test")
    end
  end
end
