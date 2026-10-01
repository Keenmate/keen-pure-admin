defmodule PureAdmin.Components.ProfileTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Profile

  defp default_assigns(overrides \\ %{}) do
    Map.merge(
      %{
        id: "profile-panel",
        name: "John Doe",
        email: "john.doe@company.com",
        role: nil,
        has_avatar: true,
        has_icon_only_tabs: false,
        class: nil,
        rest: %{},
        avatar: [],
        tabs: [],
        nav: [],
        actions: [],
        footer_: [],
        inner_block: []
      },
      overrides
    )
  end

  describe "profile_panel/1" do
    test "renders the shell + header + body" do
      html = render_component(&Profile.profile_panel/1, default_assigns())

      assert_class(html, "pa-profile-panel")
      assert_class(html, "pa-profile-panel__overlay")
      assert_class(html, "pa-profile-panel__content")
      assert_class(html, "pa-profile-panel__header")
      assert_class(html, "pa-profile-panel__avatar")
      assert_class(html, "pa-profile-panel__info")
      assert_class(html, "pa-profile-panel__name")
      assert_class(html, "pa-profile-panel__email")
      assert_class(html, "pa-profile-panel__close")
      assert_class(html, "pa-profile-panel__body")
      assert html =~ "John Doe"
      assert html =~ "john.doe@company.com"
    end

    test "default avatar is the masked pa-icon--user primitive" do
      html = render_component(&Profile.profile_panel/1, default_assigns())

      assert_class(html, "pa-profile-panel__avatar-icon")
      assert html =~ ~s(pa-icon pa-icon--user)
    end

    test "close button carries aria-label=\"Close Profile\" (Title-Case, matches oracle)" do
      html = render_component(&Profile.profile_panel/1, default_assigns())

      assert html =~ ~s(aria-label="Close Profile")
      refute html =~ ~s(aria-label="Close profile")
    end

    test "name + email render title tooltip attrs" do
      html = render_component(&Profile.profile_panel/1, default_assigns())

      assert html =~ ~s(title="John Doe")
      assert html =~ ~s(title="john.doe@company.com")
    end

    test "role present renders the shared pa-badge chip" do
      html = render_component(&Profile.profile_panel/1, default_assigns(%{role: "Administrator"}))

      assert_class(html, "pa-badge")
      assert html =~ "Administrator"
    end

    test "role absent renders no badge" do
      html = render_component(&Profile.profile_panel/1, default_assigns())

      refute_class(html, "pa-badge")
    end

    test "has_avatar=false adds __header--no-avatar (avatar markup stays)" do
      html = render_component(&Profile.profile_panel/1, default_assigns(%{has_avatar: false}))

      assert_class(html, "pa-profile-panel__header--no-avatar")
      assert_class(html, "pa-profile-panel__avatar")
    end

    test "nav slot emits the __nav wrapper" do
      html =
        render_component(
          &Profile.profile_panel/1,
          default_assigns(%{
            nav: [%{__slot__: :nav, inner_block: fn _, _ -> "NavItems" end}]
          })
        )

      assert_class(html, "pa-profile-panel__nav")
      assert html =~ "NavItems"
    end

    test "actions slot emits the __actions wrapper" do
      html =
        render_component(
          &Profile.profile_panel/1,
          default_assigns(%{
            actions: [%{__slot__: :actions, inner_block: fn _, _ -> "Actions" end}]
          })
        )

      assert_class(html, "pa-profile-panel__actions")
    end

    test "footer_ slot emits the __footer wrapper" do
      html =
        render_component(
          &Profile.profile_panel/1,
          default_assigns(%{
            footer_: [%{__slot__: :footer_, inner_block: fn _, _ -> "Footer" end}]
          })
        )

      assert_class(html, "pa-profile-panel__footer")
    end

    test "tabs slot emits the __tabs wrapper; icon-only adds the modifier" do
      base_tabs = [%{__slot__: :tabs, inner_block: fn _, _ -> "Tabs" end}]

      html = render_component(&Profile.profile_panel/1, default_assigns(%{tabs: base_tabs}))
      assert_class(html, "pa-profile-panel__tabs")
      refute_class(html, "pa-profile-panel__tabs--icon-only")

      html_icon =
        render_component(
          &Profile.profile_panel/1,
          default_assigns(%{tabs: base_tabs, has_icon_only_tabs: true})
        )

      assert_class(html_icon, "pa-profile-panel__tabs--icon-only")
    end
  end
end
