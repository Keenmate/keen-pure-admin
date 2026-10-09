defmodule PureAdmin.Components.TypographyTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Typography

  describe "heading/1" do
    test "renders h2 by default" do
      html =
        render_component(&Typography.heading/1, %{
          level: 2,
          class: nil,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Title" end}]
        })

      assert html =~ "<h2"
      assert html =~ "Title"
    end

    test "renders all heading levels as bare semantic tags (no class)" do
      for level <- 1..6 do
        html =
          render_component(&Typography.heading/1, %{
            level: level,
            class: nil,
            inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "H#{level}" end}]
          })

        assert html =~ "<h#{level}"
        # Core blesses a class-less bare heading — no pa-heading block class.
        refute html =~ "pa-heading"
      end
    end

    test "accepts extra class passthrough (e.g. a shared alignment utility)" do
      html =
        render_component(&Typography.heading/1, %{
          level: 4,
          class: "pa-text--center",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Title" end}]
        })

      assert html =~ "<h4"
      assert_class(html, "pa-text--center")
    end
  end

  describe "paragraph/1" do
    defp render_paragraph(extra) do
      render_component(
        &Typography.paragraph/1,
        Map.merge(
          %{
            size: nil,
            color: nil,
            align: nil,
            semantic: nil,
            class: nil,
            rest: %{},
            inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "body" end}]
          },
          extra
        )
      )
    end

    test "renders a bare <p> with no modifier class by default" do
      html = render_paragraph(%{})
      refute html =~ "text-"
      assert html =~ "body"
    end

    test "size/color/align/semantic emit flat text-* utilities" do
      assert_class(render_paragraph(%{size: "lg"}), "text-lg")
      assert_class(render_paragraph(%{color: "secondary"}), "text-secondary")
      assert_class(render_paragraph(%{color: "primary"}), "text-body")
      assert_class(render_paragraph(%{align: "center"}), "text-center")
      assert_class(render_paragraph(%{semantic: "lead"}), "text-lead")
    end

    test "stacks flat text-* utilities on a plain <p>" do
      html = render_paragraph(%{size: "sm", color: "secondary", align: "center"})
      assert_class(html, "text-sm")
      assert_class(html, "text-secondary")
      assert_class(html, "text-center")
    end
  end

  describe "text/1 (inline coloured span)" do
    defp render_text(variant) do
      render_component(&Typography.text/1, %{
        variant: variant,
        class: nil,
        rest: %{},
        inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "x" end}]
      })
    end

    test "semantic colours resolve to the flat .text-* utilities" do
      assert_class(render_text("primary"), "text-primary")
      assert_class(render_text("success"), "text-success")
      assert_class(render_text("danger"), "text-danger")
      assert_class(render_text("warning"), "text-warning")
      assert_class(render_text("info"), "text-info")
    end

    test "no variant → a bare span with no colour class (no pa-text base)" do
      html = render_text(nil)
      assert html =~ "<span"
      # No variant → no `.text-*` colour utility and no pa-text component base.
      # (HEEx may still emit an empty `class=""`, which the fidelity normalizer
      # treats as class-less; what matters is that no real class token appears.)
      refute html =~ "text-"
      refute html =~ "pa-text"
    end

    test "never adds the pa-text paragraph base nor invented pa-text--colour modifiers" do
      for v <- ["primary", "success", "danger", "warning", "info"] do
        html = render_text(v)
        # Inline text is the colour-only .text-* utility, NOT the pa-text component.
        refute html =~ ~s(class="pa-text)
        refute html =~ "pa-text--#{v}"
      end
    end
  end

  describe "pa_link/1" do
    test "emits the pa-link base with no invented variant modifier" do
      html =
        render_component(&Typography.pa_link/1, %{
          href: "/x",
          class: nil,
          rest: %{},
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "go" end}]
        })

      assert_class(html, "pa-link")
      refute html =~ "pa-link--"
    end
  end
end
