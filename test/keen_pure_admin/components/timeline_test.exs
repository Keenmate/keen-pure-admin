defmodule PureAdmin.Components.TimelineTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Timeline

  describe "timeline/1" do
    test "renders simple variant as ul" do
      html =
        render_component(&Timeline.timeline/1, %{
          variant: "simple",
          align: nil,
          is_keep_layout: false,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}]
        })

      assert html =~ "<ul"
      assert_class(html, "pa-timeline")
      assert_class(html, "pa-timeline--simple")
    end

    test "renders alternating variant as ul" do
      html =
        render_component(&Timeline.timeline/1, %{
          variant: "alternating",
          align: nil,
          is_keep_layout: false,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}]
        })

      # Container is always <ul> — the SCSS keys off :nth-child, not the tag, so
      # the alternating variant works identically as a semantic list (matches
      # svelte, which always emits <ul>).
      assert html =~ "<ul"
      refute html =~ "<div"
      assert_class(html, "pa-timeline--alternating")
    end

    test "renders feed variant as ul" do
      html =
        render_component(&Timeline.timeline/1, %{
          variant: "feed",
          align: nil,
          is_keep_layout: false,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}]
        })

      assert html =~ "<ul"
      assert_class(html, "pa-timeline--feed")
    end

    test "renders align prop" do
      html =
        render_component(&Timeline.timeline/1, %{
          variant: "alternating",
          align: "start",
          is_keep_layout: false,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}]
        })

      assert_class(html, "pa-timeline--start")
    end

    test "renders is_keep_layout" do
      html =
        render_component(&Timeline.timeline/1, %{
          variant: "alternating",
          align: nil,
          is_keep_layout: true,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}]
        })

      assert_class(html, "pa-timeline--keep-layout")
    end

    test "renders is_single_column" do
      html =
        render_component(&Timeline.timeline/1, %{
          variant: "alternating",
          align: nil,
          is_keep_layout: false,
          is_single_column: true,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}]
        })

      assert_class(html, "pa-timeline--single-column")
    end

    test "renders align + keep_layout combo" do
      html =
        render_component(&Timeline.timeline/1, %{
          variant: "alternating",
          align: "end",
          is_keep_layout: true,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}]
        })

      assert_class(html, "pa-timeline--end")
      assert_class(html, "pa-timeline--keep-layout")
    end
  end

  describe "timeline_item/1" do
    test "renders simple item with time_text" do
      html =
        render_component(&Timeline.timeline_item/1, %{
          variant: "success",
          is_filled: false,
          is_date_header: false,
          time_text: "09:00",
          icon_text: nil,
          avatar_url: nil,
          avatar_alt: "User",
          class: nil,
          icon: [],
          title: [],
          meta: [],
          comment: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Event" end}]
        })

      assert html =~ "<li"
      assert_class(html, "pa-timeline__item--success")
      assert html =~ "pa-timeline__time"
      assert html =~ "09:00"
      assert html =~ "Event"
    end

    test "renders block item with icon_text as div" do
      html =
        render_component(&Timeline.timeline_item/1, %{
          variant: nil,
          is_filled: false,
          is_date_header: false,
          time_text: "Jan",
          icon_text: "🏠",
          avatar_url: nil,
          avatar_alt: "User",
          class: nil,
          icon: [],
          title: [],
          meta: [],
          comment: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Content" end}]
        })

      assert html =~ "<div"
      assert html =~ "pa-timeline__date"
      assert html =~ "pa-timeline__icon"
      assert html =~ "Jan"
    end

    test "renders feed item with avatar" do
      html =
        render_component(&Timeline.timeline_item/1, %{
          variant: nil,
          is_filled: false,
          is_date_header: false,
          time_text: "14:32",
          icon_text: nil,
          avatar_url: "https://example.com/avatar.jpg",
          avatar_alt: "John",
          class: nil,
          icon: [],
          title: [],
          meta: [],
          comment: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Action" end}]
        })

      assert html =~ "pa-timeline__avatar"
      assert html =~ "https://example.com/avatar.jpg"
      assert html =~ "pa-timeline__time"
    end

    test "renders date header" do
      html =
        render_component(&Timeline.timeline_item/1, %{
          variant: nil,
          is_filled: false,
          is_date_header: true,
          time_text: nil,
          icon_text: "📅",
          avatar_url: nil,
          avatar_alt: "User",
          class: nil,
          icon: [],
          title: [],
          meta: [],
          comment: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "January 21" end}]
        })

      assert html =~ "pa-timeline__date-icon"
      assert html =~ "pa-timeline__date-label"
      assert html =~ "January 21"
    end

    test "renders filled modifier" do
      html =
        render_component(&Timeline.timeline_item/1, %{
          variant: "primary",
          is_filled: true,
          is_date_header: false,
          time_text: "10:00",
          icon_text: nil,
          avatar_url: nil,
          avatar_alt: "User",
          class: nil,
          icon: [],
          title: [],
          meta: [],
          comment: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "text" end}]
        })

      assert_class(html, "pa-timeline__item--filled")
    end
  end
end
