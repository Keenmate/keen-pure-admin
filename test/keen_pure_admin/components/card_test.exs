defmodule PureAdmin.Components.CardTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Card

  defp default_assigns(overrides \\ %{}) do
    Map.merge(
      %{
        variant: nil,
        live_state: nil,
        is_ghost: false,
        has_padding: true,
        title_text: nil,
        description_text: nil,
        subtitle_text: nil,
        is_header_underlined: false,
        header_underline_color: nil,
        has_inline_tabs: false,
        header_wrap: false,
        header_class: nil,
        class: nil,
        header: [],
        title: [],
        title_icon: [],
        description: [],
        tools: [],
        meta: [],
        tabs: [],
        footer: [],
        actions: [],
        inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Content" end}]
      },
      overrides
    )
  end

  describe "card/1" do
    test "renders simple card" do
      html = render_component(&Card.card/1, default_assigns())

      assert_class(html, "pa-card")
      assert_class(html, "pa-card__body")
      assert html =~ "Content"
      refute html =~ "pa-card__header"
    end

    test "is_bordered is a no-op — never emits pa-card--bordered (no core rule)" do
      html = render_component(&Card.card/1, default_assigns(%{is_bordered: true}))

      refute_class(html, "pa-card--bordered")
    end

    test "renders card with variant" do
      html = render_component(&Card.card/1, default_assigns(%{variant: "primary"}))

      assert_class(html, "pa-card--primary")
    end

    test "renders card with no-padding body" do
      html = render_component(&Card.card/1, default_assigns(%{has_padding: false}))

      assert_class(html, "pa-card__body--no-padding")
    end

    test "renders card with title_text" do
      html = render_component(&Card.card/1, default_assigns(%{title_text: "My Title"}))

      assert html =~ "pa-card__header"
      assert html =~ "My Title"
      # rc05: title is always the canonical .pa-card__title > .pa-card__title-text
      # structure (never a bare <h3>).
      assert_class(html, "pa-card__title")
      assert html =~ ~s(<h3 class="pa-card__title-text">My Title</h3>)
    end

    test "renders ghost card" do
      html = render_component(&Card.card/1, default_assigns(%{is_ghost: true}))

      assert_class(html, "pa-card--ghost")
    end

    test "renders card with header underline" do
      html =
        render_component(
          &Card.card/1,
          default_assigns(%{
            title_text: "Test",
            is_header_underlined: true,
            header_underline_color: "success"
          })
        )

      assert html =~ "pa-card__header--underlined"
      assert html =~ "pa-card__header--underline-success"
    end

    test "renders header underline with a theme colour slot" do
      html =
        render_component(
          &Card.card/1,
          default_assigns(%{
            title_text: "Test",
            is_header_underlined: true,
            header_underline_theme_color: "3"
          })
        )

      assert html =~ "pa-card__header--underlined"
      assert html =~ "pa-card__header--underline-color-3"
    end

    test "renders tabs INSIDE the header, coexisting with the title" do
      # Canonical placement (snippets/cards.html): the tab strip lives inside
      # pa-card__header, after the title — NOT outside the header, and the title
      # is not dropped. Covers both default and inline tabs.
      for inline <- [false, true] do
        html =
          render_component(
            &Card.card/1,
            default_assigns(%{
              title_text: "Sales",
              has_inline_tabs: inline,
              tabs: [%{__slot__: :tabs, inner_block: fn _, _ -> "Overview" end}]
            })
          )

        {:ok, doc} = Floki.parse_fragment(html)

        # tab strip nested within the header (not a sibling after it)
        assert Floki.find(doc, ".pa-card__header .pa-card__tabs") != []
        # title still present alongside the tabs
        assert Floki.find(doc, ".pa-card__header .pa-card__title") != []
        assert html =~ "Overview"
        # no stray tab strip outside the header
        assert Floki.find(doc, ".pa-card > .pa-card__tabs") == []

        if inline,
          do: assert(html =~ "pa-card__tabs--inline"),
          else: refute(html =~ "pa-card__tabs--inline")
      end
    end
  end
end
