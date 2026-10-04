defmodule DemoWeb.Live.ComponentsOverviewLive do
  use DemoWeb, :live_view

  @components [
    %{title: "Buttons", desc: "Primary, secondary, outline, sizes, loading, icon-only, split buttons", href: "/components/buttons", icon: "fa-solid fa-hand-pointer", count: "12 variants"},
    %{title: "Inputs", desc: "Text, select, textarea, checkboxes, radios, input groups", href: "/components/inputs", icon: "fa-solid fa-keyboard", count: "8 types"},
    %{title: "Validations", desc: "Inline errors, summary blocks, timing strategies", href: "/components/validations", icon: "fa-solid fa-circle-check", count: "10 patterns"},
    %{title: "Cards", desc: "Headers, footers, tabs, colors, bordered, ghost, stat cards", href: "/components/cards", icon: "fa-solid fa-square", count: "14 variants"},
    %{title: "Grid System", desc: "Percentage, fraction, responsive columns, offsets, alignment", href: "/components/grid", icon: "fa-solid fa-table-columns", count: "6 layouts"},
    %{title: "Tabs", desc: "Standard, pills, vertical, boxed, scrollable, icon-only", href: "/components/tabs", icon: "fa-solid fa-folder", count: "12 variants"},
    %{title: "Badges & Labels", desc: "Sizes, pills, icons, groups, composite badges", href: "/components/badges", icon: "fa-solid fa-tag", count: "8 variants"},
    %{title: "Lists", desc: "Basic, ordered, definition, icon, bordered, complex lists", href: "/components/lists", icon: "fa-solid fa-list", count: "7 types"},
    %{title: "Alerts", desc: "Variants, dismissible, rich content, outline, compact", href: "/components/alerts", icon: "fa-solid fa-triangle-exclamation", count: "5 variants"},
    %{title: "Callouts", desc: "Info boxes with headings, icons, sizes", href: "/components/callouts", icon: "fa-solid fa-comment-dots", count: "4 variants"},
    %{title: "Toasts", desc: "Positions, variants, persistent, action toasts", href: "/components/toasts", icon: "fa-solid fa-bell", count: "6 positions"},
    %{title: "Loaders", desc: "Spinners, centered, overlay, inline, button loading", href: "/components/loaders", icon: "fa-solid fa-spinner", count: "5 types"},
    %{title: "Modals", desc: "Sizes, scrollable, centered, nested modals", href: "/components/modals", icon: "fa-solid fa-window-restore", count: "6 variants"},
    %{title: "Modal Dialogs", desc: "Confirm, alert, prompt, sequential dialogs", href: "/components/modal-dialogs", icon: "fa-solid fa-message", count: "4 types"},
    %{title: "Popconfirm", desc: "Inline confirmation with placement, icon variants", href: "/components/popconfirm", icon: "fa-solid fa-circle-question", count: "4 placements"},
    %{title: "Tooltips", desc: "Positions, colors, multiline, popovers", href: "/components/tooltips", icon: "fa-solid fa-comment", count: "8 positions"},
    %{title: "Pagers", desc: "Page input, first/last, alignment, load more", href: "/components/pagers", icon: "fa-solid fa-chevron-right", count: "5 variants"},
    %{title: "Command Palette", desc: "Spotlight search with keyboard navigation", href: "/components/command-palette", icon: "fa-solid fa-magnifying-glass", count: "1 component"},
    %{title: "Data Display", desc: "Fields, field groups, horizontal, table, bordered", href: "/components/data-display", icon: "fa-solid fa-table-list", count: "12 layouts"},
    %{title: "Data Display 2", desc: "Descriptions table, dot leaders, property cards, banded", href: "/components/data-display-2", icon: "fa-solid fa-grip", count: "6 patterns"},
    %{title: "Data Visualization", desc: "Progress bars, rings, sparklines, heatmaps, data bars", href: "/components/data-visualization", icon: "fa-solid fa-chart-bar", count: "8 types"},
    %{title: "Detail Panel", desc: "Inline and overlay split-view panels", href: "/components/detail-panel", icon: "fa-solid fa-columns", count: "2 modes"},
    %{title: "Notifications", desc: "Notification list with filtering and actions", href: "/components/notifications", icon: "fa-solid fa-bell", count: "5 variants"},
    %{title: "Stats", desc: "Hero, compact, square stat cards", href: "/components/stats", icon: "fa-solid fa-chart-line", count: "3 variants"},
    %{title: "Code", desc: "Inline code and code blocks", href: "/components/code", icon: "fa-solid fa-code", count: "2 types"},
    %{title: "Typography", desc: "Headings, paragraphs, text utilities", href: "/components/typography", icon: "fa-solid fa-font", count: "6 levels"},
    %{title: "Checkbox Lists", desc: "Tri-state, select-all, variants, layouts", href: "/components/checkbox-lists", icon: "fa-solid fa-square-check", count: "4 layouts"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Components", components: @components)}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">Pure Admin LiveView component library — 35+ function components as a drop-in CoreComponents replacement</.paragraph>

    <.grid>
      <.column :for={comp <- @components} size="100" md="50" lg="1-3">
        <a href={comp.href} class="pa-card pa-card--interactive mb-2 d-block text-decoration-none">
          <div class="pa-card__header">
            <.heading level={4}><i class={comp.icon}></i> {comp.title}</.heading>
            <.badge variant="primary" size="sm">{comp.count}</.badge>
          </div>
          <div class="pa-card__body">
            <.paragraph color="secondary">{comp.desc}</.paragraph>
          </div>
        </a>
      </.column>
    </.grid>

    <.section title_text={gettext("Other Sections")}>
      <.grid>
        <.column size="1-3">
          <.card title_text={gettext("Tables")}>
            <.basic_list spacing="compact">
              <li><a href="/tables/standard">Standard Tables</a></li>
              <li><a href="/tables/sizing">Table Sizing</a></li>
              <li><a href="/tables/responsive">Responsive</a></li>
              <li><a href="/tables/filters">Filters</a></li>
              <li><a href="/tables/multi-select">Multi-Select</a></li>
              <li><a href="/tables/comparison">Comparison</a></li>
            </.basic_list>
          </.card>
        </.column>
        <.column size="1-3">
          <.card title_text={gettext("Timeline")}>
            <.basic_list spacing="compact">
              <li><a href="/timeline/simple">Simple</a></li>
              <li><a href="/timeline/block">Block / Alternating</a></li>
              <li><a href="/timeline/feed">Feed</a></li>
              <li><a href="/timeline/advanced">Advanced</a></li>
            </.basic_list>
          </.card>
        </.column>
        <.column size="1-3">
          <.card title_text={gettext("Design")}>
            <.basic_list spacing="compact">
              <li><a href="/design/colors">Colors</a></li>
              <li><a href="/design/theme-variables">Theme Variables</a></li>
              <li><a href="/design/helpers">CSS Helpers</a></li>
              <li><a href="/design/layouts">Layouts</a></li>
            </.basic_list>
          </.card>
        </.column>
      </.grid>
    </.section>
    """
  end
end
