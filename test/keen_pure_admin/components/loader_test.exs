defmodule PureAdmin.Components.LoaderTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Loader

  describe "loader/1 color" do
    test "emits an inline currentColor style, not an invented --color class" do
      html = render_component(&Loader.loader/1, %{type: "dots", color: "primary"})

      # Core themes loaders via currentColor on the wrapper — there is no
      # pa-loader-{type}--{color} rule.
      refute_class(html, "pa-loader-dots--primary")
      assert html =~ "color: var(--pc-accent)"
    end

    test "semantic colors map to --pa-{color}-bg" do
      html = render_component(&Loader.loader/1, %{type: "ring", color: "danger"})

      refute_class(html, "pa-loader-ring--danger")
      assert html =~ "color: var(--pa-danger-bg)"
    end

    test "no color → no inline color style" do
      html = render_component(&Loader.loader/1, %{type: "dots"})

      refute html =~ "color: var("
    end

    test "size still emits the real --lg modifier" do
      html = render_component(&Loader.loader/1, %{type: "bars", size: "lg"})

      assert_class(html, "pa-loader-bars--lg")
    end
  end

  describe "spinner/1" do
    test "restricts size to the real --xs and emits color variants" do
      html = render_component(&Loader.spinner/1, %{size: "xs", variant: "success"})

      assert_class(html, "pa-spinner--xs")
      assert_class(html, "pa-spinner--success")
    end
  end
end
