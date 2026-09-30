defmodule PureAdmin.Components.BadgeTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Badge

  describe "badge/1" do
    test "renders default badge" do
      html =
        render_component(&Badge.badge/1, %{
          variant: "primary",
          size: nil,
          is_pill: false,
          class: nil,
          icon: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Active" end}]
        })

      assert_class(html, "pa-badge")
      assert_class(html, "pa-badge--primary")
      assert html =~ "Active"
    end

    test "renders pill badge with size" do
      html =
        render_component(&Badge.badge/1, %{
          variant: "success",
          size: "sm",
          is_pill: true,
          class: nil,
          icon: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "OK" end}]
        })

      assert_class(html, "pa-badge--success")
      assert_class(html, "pa-badge--sm")
      assert_class(html, "pa-badge--pill")
    end

    test "theme_color emits pa-badge--color-N and suppresses the variant class" do
      html =
        render_component(&Badge.badge/1, %{
          variant: "primary",
          size: nil,
          is_pill: false,
          theme_color: "5",
          class: nil,
          icon: [],
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Slot 5" end}]
        })

      assert_class(html, "pa-badge--color-5")
      # theme_color is the sole colour class — the default variant must not co-exist.
      refute_class(html, "pa-badge--primary")
    end
  end

  describe "label/1" do
    test "renders label" do
      html =
        render_component(&Badge.label/1, %{
          variant: "danger",
          size: nil,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Error" end}]
        })

      assert_class(html, "pa-label")
      assert_class(html, "pa-label--danger")
    end
  end

  describe "composite_badge/1" do
    test "renders three-part badge" do
      html =
        render_component(&Badge.composite_badge/1, %{
          variant: "primary",
          icon: "🔔",
          label: "Notifications",
          count: "5",
          class: nil
        })

      assert_class(html, "pa-composite-badge")
      assert_class(html, "pa-composite-badge--primary")
      assert_class(html, "pa-composite-badge__icon")
      assert_class(html, "pa-composite-badge__label")
      assert_class(html, "pa-composite-badge__button")
      assert html =~ "Notifications"
      assert html =~ "5"
    end

    test "is_interactive is a no-op — never emits pa-composite-badge--interactive" do
      html =
        render_component(&Badge.composite_badge/1, %{
          variant: "primary",
          icon: "🔔",
          label: "Notifications",
          count: "5",
          is_interactive: true,
          class: nil
        })

      refute_class(html, "pa-composite-badge--interactive")
    end
  end

  describe "badge_group/1" do
    test "renders badge group" do
      html =
        render_component(&Badge.badge_group/1, %{
          is_show_all: false,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "badges" end}]
        })

      assert_class(html, "pa-badge-group")
      refute_class(html, "pa-badge-group--show-all")
    end
  end
end
