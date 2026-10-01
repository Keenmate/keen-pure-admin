defmodule PureAdmin.Components.KpiTerminalTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.KpiTerminal

  defp render_terminal(overrides \\ %{}) do
    base = %{
      id: nil,
      title_text: nil,
      is_live: false,
      live_text: "LIVE",
      footer_text: nil,
      class: nil,
      pane: [],
      inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "TILES" end}],
      header_controls: [],
      footer: []
    }

    render_component(&KpiTerminal.kpi_terminal/1, Map.merge(base, overrides))
  end

  defp demo_panes do
    [
      %{__slot__: :pane, id: "overview", label_text: "OVERVIEW", is_active: true, inner_block: fn _, _ -> "TILES" end},
      %{__slot__: :pane, id: "finance", label_text: "FINANCE", is_active: false, inner_block: fn _, _ -> "TILES" end}
    ]
  end

  describe "container namespace class" do
    test "the card shell carries both pa-card and the pa-kpi-terminal namespace class" do
      html = render_terminal()

      # pa-kpi-terminal is the showcase namespace on the card. A bare string in
      # build_classes/3's modifier list is silently dropped (only {class, true}
      # tuples survive); the class has to be folded into the base. This locks the
      # fix for that dropped-namespace bug.
      assert_class(html, "pa-card")
      assert_class(html, "pa-kpi-terminal")
      assert_class(html, "pa-kpi-terminal__body")
      assert_class(html, "pa-kpi-terminal__grid")
      assert_class(html, "pa-kpi-terminal__grid--2col")
    end
  end

  describe "header title uses the canonical card-title shape" do
    test "title_text renders pa-card__title > h3.pa-card__title-text, not a bare <h3>" do
      html = render_terminal(%{title_text: "Key Performance Indicators"})

      # Canonical card-header shape (matches core snippets/kpi.html L223 + the
      # card-header canonicalization rule): the title is wrapped in pa-card__title
      # and the <h3> carries pa-card__title-text.
      assert_class(html, "pa-card__title")
      assert_class(html, "pa-card__title-text")

      assert html =~
               ~r{<div class="pa-card__title">\s*<h3 class="pa-card__title-text">Key Performance Indicators</h3>}

      # The legacy bare-<h3> shape must not be emitted.
      refute html =~ ~r{<h3>Key Performance Indicators</h3>}
    end
  end

  describe "header rendering conditions" do
    test "no header when there is no title, no live, no controls, no tabs" do
      html = render_terminal()
      refute html =~ "pa-card__header"
    end

    test "the LIVE pill renders inside __controls with the hardcoded default label" do
      html = render_terminal(%{is_live: true})

      assert_class(html, "pa-card__header")
      assert_class(html, "pa-kpi-terminal__controls")
      assert html =~ ~r{<span class="pa-kpi-live">\s*<span class="pa-kpi-live__dot"></span>LIVE\s*</span>}
    end
  end

  describe "no-tabs body" do
    test "wraps the tile slot in a single __grid--2col and renders no panes" do
      html = render_terminal(%{inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "TILES" end}]})

      assert html =~ ~r{<div class="pa-card__body pa-kpi-terminal__body">}
      assert html =~ ~r{<div class="pa-kpi-terminal__grid pa-kpi-terminal__grid--2col">\s*TILES}
      refute html =~ "pa-kpi-terminal__pane"
      refute html =~ "pa-kpi-terminal__tabs"
    end
  end

  describe "tabs body" do
    test "renders the tab strip + one pane per tab, with is-active + attributes" do
      html = render_terminal(%{pane: demo_panes()})

      # Tab strip
      assert html =~ ~r{<div class="pa-kpi-terminal__tabs" role="tablist" aria-label="Dashboard view">}
      assert_class(html, "pa-kpi-terminal__tab")

      # Active tab button: is-active + explicit aria-selected="true".
      assert html =~
               ~r{<button type="button" class="pa-kpi-terminal__tab is-active" data-tab="overview" role="tab" aria-selected="true">\s*OVERVIEW}

      # Inactive tab button: no is-active + explicit aria-selected="false" (not
      # a bare/omitted boolean attr — matches the blessed snippet string form).
      assert html =~
               ~r{<button type="button" class="pa-kpi-terminal__tab" data-tab="finance" role="tab" aria-selected="false">\s*FINANCE}

      # Panes: one per tab, active pane carries is-active, each wraps its own grid.
      assert html =~ ~r{<div class="pa-kpi-terminal__pane is-active" data-tab="overview">}
      assert html =~ ~r{<div class="pa-kpi-terminal__pane" data-tab="finance">}
      assert html =~ "PureAdminKpiTerminalTabs"
    end

    test "aria-selected is an explicit string, never a bare/omitted boolean attr" do
      html = render_terminal(%{pane: demo_panes()})

      assert html =~ ~s(aria-selected="true")
      assert html =~ ~s(aria-selected="false")
      # No bare `aria-selected` / `aria-selected>` (the HEEx boolean-attr form).
      refute html =~ ~r{aria-selected(?!=)}
    end
  end

  describe "footer" do
    test "plain-string footer renders a bare <span> inside pa-kpi-footer" do
      html = render_terminal(%{footer_text: "Updated 2 min ago"})

      assert html =~ ~r{<div class="pa-card__footer pa-kpi-footer">\s*<span>Updated 2 min ago</span>}
    end

    test "no footer when footer_text is unset and no footer slot" do
      refute render_terminal() =~ "pa-card__footer"
    end
  end

  describe "class passthrough" do
    test "extra class is appended to the card shell" do
      assert_class(render_terminal(%{class: "mb-4"}), "mb-4")
    end
  end
end
