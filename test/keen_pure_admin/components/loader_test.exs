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

    test "no color → omits the style attribute entirely (no phantom style=\"\")" do
      # HEEx renders `style={nil}` as `style=""`, a phantom attribute vs the core
      # golden. Colour is routed through @rest so the attribute is dropped when
      # absent. (Markup-fidelity harness: fidelity/fixtures/loader.json.)
      html = render_component(&Loader.loader/1, %{type: "dots"})

      refute html =~ ~s(style="")
      refute html =~ "style="
    end

    test "size still emits the real --lg modifier" do
      html = render_component(&Loader.loader/1, %{type: "bars", size: "lg"})

      assert_class(html, "pa-loader-bars--lg")
    end
  end

  describe "loader/1 structure" do
    test "dots emits exactly 3 child spans" do
      html = render_component(&Loader.loader/1, %{type: "dots"})

      assert_class(html, "pa-loader-dots")
      assert length(String.split(html, "<span>")) - 1 == 3
    end

    test "bars and wave emit exactly 5 child spans" do
      for type <- ["bars", "wave"] do
        html = render_component(&Loader.loader/1, %{type: type})

        assert_class(html, "pa-loader-#{type}")
        assert length(String.split(html, "<span>")) - 1 == 5
      end
    end

    test "pulse and ring are CSS-only — no child spans" do
      for type <- ["pulse", "ring"] do
        html = render_component(&Loader.loader/1, %{type: type})

        assert_class(html, "pa-loader-#{type}")
        refute html =~ "<span>"
      end
    end
  end

  describe "spinner/1" do
    test "restricts size to the real --xs and emits color variants" do
      html = render_component(&Loader.spinner/1, %{size: "xs", variant: "success"})

      assert_class(html, "pa-spinner--xs")
      assert_class(html, "pa-spinner--success")
    end

    # Locks the harness fixture fidelity/fixtures/spinner.json.
    test "bare spinner is an empty pa-spinner <div> with no children" do
      html = render_component(&Loader.spinner/1, %{})

      assert_class(html, "pa-spinner")
      refute html =~ "<span"
    end

    test "every colour variant emits its real pa-spinner--{variant} class" do
      for v <- ["primary", "secondary", "success", "danger", "warning", "info"] do
        html = render_component(&Loader.spinner/1, %{variant: v})
        assert_class(html, "pa-spinner--#{v}")
      end
    end
  end

  describe "loader_center/1 — markup-fidelity contract (core = oracle)" do
    # Locks the harness fixture fidelity/fixtures/loader-center.json.
    test "renders the bare pa-loader-center container around its slot" do
      html =
        render_component(&Loader.loader_center/1, %{
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "X" end}]
        })

      assert html =~ ~r/<div[^>]*class="pa-loader-center"/
      assert html =~ "X"
    end
  end

  describe "loader_overlay/1 — markup-fidelity contract (core = oracle)" do
    # Locks the harness fixture fidelity/fixtures/loader-overlay.json, incl. the
    # keen-only spinner fallback when the slot is truly ABSENT (the harness always
    # passes a slot, so the shared goldens never exercise the fallback).
    test "renders the pa-loader-overlay container around its slot" do
      html =
        render_component(&Loader.loader_overlay/1, %{
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "X" end}]
        })

      assert html =~ ~r/<div[^>]*class="pa-loader-overlay"/
      assert html =~ "X"
    end

    test "absent slot falls back to a <.spinner /> (keen-only convenience)" do
      html = render_component(&Loader.loader_overlay/1, %{inner_block: []})

      assert_class(html, "pa-loader-overlay")
      assert_class(html, "pa-spinner")
    end
  end
end
