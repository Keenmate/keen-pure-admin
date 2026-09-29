defmodule PureAdmin.Components.ListTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.List

  describe "basic_list/1" do
    test "renders default list" do
      html =
        render_component(&List.basic_list/1, %{
          spacing: nil,
          is_bordered: false,
          is_striped: false,
          is_inline: false,
          is_unstyled: false,
          has_icon: false,
          icon_variant: nil,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "<li>Item</li>" end}]
        })

      assert html =~ "<ul"
      assert_class(html, "pa-list-basic")
    end

    test "renders compact spacing" do
      html =
        render_component(&List.basic_list/1, %{
          spacing: "compact",
          is_bordered: false,
          is_striped: false,
          is_inline: false,
          is_unstyled: false,
          has_icon: false,
          icon_variant: nil,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "<li>Item</li>" end}]
        })

      assert_class(html, "pa-list-basic--compact")
    end

    test "renders bordered and striped" do
      html =
        render_component(&List.basic_list/1, %{
          spacing: nil,
          is_bordered: true,
          is_striped: true,
          is_inline: false,
          is_unstyled: false,
          has_icon: false,
          icon_variant: nil,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "<li>Item</li>" end}]
        })

      assert_class(html, "pa-list-basic--bordered")
      assert_class(html, "pa-list-basic--striped")
    end
  end

  describe "list_item/1" do
    test "renders with title_text and meta_text" do
      html =
        render_component(&List.list_item/1, %{
          title_text: "API Services",
          subtitle_text: nil,
          meta_text: "Operational",
          class: nil,
          avatar: [],
          meta: [],
          inner_block: []
        })

      assert_class(html, "pa-list__item")
      assert html =~ "pa-list__title"
      assert html =~ "API Services"
      assert html =~ "pa-list__meta"
      assert html =~ "Operational"
    end

    test "renders custom inner_block content" do
      html =
        render_component(&List.list_item/1, %{
          title_text: nil,
          subtitle_text: nil,
          meta_text: nil,
          class: nil,
          avatar: [],
          meta: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Custom content" end}]
        })

      assert html =~ "Custom content"
    end
  end

  describe "list/1 + list_item/1 semantic as= form" do
    test "list defaults to <div>, as=\"ul\" emits <ul>" do
      div =
        render_component(&List.list/1, %{
          as: "div",
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "x" end}]
        })

      ul =
        render_component(&List.list/1, %{
          as: "ul",
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "x" end}]
        })

      assert div =~ ~r/<div[^>]*class="pa-list"/
      assert ul =~ ~r/<ul[^>]*class="pa-list"/
    end

    test "list_item as=\"li\" emits <li>" do
      li =
        render_component(&List.list_item/1, %{
          as: "li",
          title_text: "John",
          subtitle_text: nil,
          meta_text: nil,
          class: nil,
          avatar: [],
          meta: [],
          inner_block: []
        })

      assert li =~ ~r/<li[^>]*class="pa-list__item"/
      assert li =~ "pa-list__title"
    end
  end
end
