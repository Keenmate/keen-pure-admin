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

    # Locks the harness fixture fidelity/fixtures/basic-list.json — the
    # icon-variant coupling (emit pa-list-basic--{variant} only with has_icon
    # AND variant != success; success is the default ✓ with NO class).
    test "has_icon default success → only --icon, no phantom --success" do
      html =
        render_component(&List.basic_list/1, %{
          has_icon: true,
          icon_variant: "success",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "<li>Item</li>" end}]
        })

      assert_class(html, "pa-list-basic--icon")
      refute_class(html, "pa-list-basic--success")
    end

    test "has_icon + danger emits --icon AND --danger" do
      html =
        render_component(&List.basic_list/1, %{
          has_icon: true,
          icon_variant: "danger",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "<li>Item</li>" end}]
        })

      assert_class(html, "pa-list-basic--icon")
      assert_class(html, "pa-list-basic--danger")
    end

    test "icon_variant without has_icon emits NO variant class (pseudo needs --icon)" do
      html =
        render_component(&List.basic_list/1, %{
          has_icon: false,
          icon_variant: "danger",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "<li>Item</li>" end}]
        })

      refute_class(html, "pa-list-basic--icon")
      refute_class(html, "pa-list-basic--danger")
    end
  end

  describe "ordered_list/1 — markup-fidelity contract (core = oracle)" do
    # Locks the harness fixture fidelity/fixtures/ordered-list.json.
    test "default numeric emits the bare <ol> with no style modifier" do
      html =
        render_component(&List.ordered_list/1, %{
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "<li>Step</li>" end}]
        })

      assert html =~ ~r/<ol[^>]*class="pa-list-ordered"/
      refute_class(html, "pa-list-ordered--roman")
      refute_class(html, "pa-list-ordered--alpha")
    end

    test "style=roman / style=alpha emit their modifier" do
      for style <- ["roman", "alpha"] do
        html =
          render_component(&List.ordered_list/1, %{
            style: style,
            inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "<li>Step</li>" end}]
          })

        assert_class(html, "pa-list-ordered--#{style}")
      end
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

    test "list appends class passthrough after pa-list" do
      html =
        render_component(&List.list/1, %{
          as: "div",
          class: "mb-4",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Body" end}]
        })

      # Container-only contract (markup-fidelity `list` slice): the .pa-list block
      # ships NO block modifiers, so the only container variability is the tag
      # (as=) and the class passthrough. Both must land on the shell verbatim.
      assert_class(html, "pa-list")
      assert_class(html, "mb-4")
      assert html =~ "Body"
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
