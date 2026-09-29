defmodule PureAdmin.Components.IconTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Icon

  defp render(overrides) do
    base = %{
      name: "fa-solid fa-rocket",
      class: nil,
      color: nil,
      size: nil,
      variant: nil,
      fill: nil,
      stroke: nil,
      title: nil,
      aria_label: nil,
      is_interactive: false
    }

    render_component(&Icon.icon/1, Map.merge(base, overrides))
  end

  describe "hover marker stamping (provider-owned)" do
    test "FA-style fallback stamps pc-icon-hover-fill and keeps the name class" do
      html = render(%{name: "fa-solid fa-rocket"})
      assert_class(html, "pc-icon-hover-fill")
      assert_class(html, "fa-rocket")
    end

    test "heroicon stamps pc-icon-hover-highlight" do
      html = render(%{name: "hero-rocket-launch"})
      assert_class(html, "pc-icon-hover-highlight")
    end

    test "consumer class is preserved alongside the marker" do
      html = render(%{name: "fa-solid fa-rocket", class: "text-color-2"})
      assert_class(html, "text-color-2")
      assert_class(html, "pc-icon-hover-fill")
    end
  end

  describe "is_interactive (standalone hover context)" do
    test "wraps the icon in span.pc-icon-hover when set" do
      html = render(%{name: "fa-solid fa-rocket", is_interactive: true})
      assert html =~ ~r/<span class="pc-icon-hover">.*<\/span>/s
      assert_class(html, "pc-icon-hover")
    end

    test "no pc-icon-hover wrapper by default" do
      html = render(%{name: "fa-solid fa-rocket"})
      refute html =~ ~s(class="pc-icon-hover")
    end
  end

  describe "empty names render nothing" do
    test "nil name" do
      assert render(%{name: nil}) =~ ~r/\A\s*\z/
    end

    test "empty string name" do
      assert render(%{name: ""}) =~ ~r/\A\s*\z/
    end
  end
end
