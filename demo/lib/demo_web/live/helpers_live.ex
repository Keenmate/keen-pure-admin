defmodule DemoWeb.Live.HelpersLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "CSS Helpers")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">Utility classes for common layout patterns, borders, visibility, and more</.paragraph>

    <.card title_text={gettext("Visibility")}>
      <.table rows={[
        %{class: ".pc-hide", desc: "Always hidden"},
        %{class: ".pc-show", desc: "Always visible"},
        %{class: ".pc-hide-&#123;bp&#125;", desc: "Hidden at breakpoint and up"},
        %{class: ".pc-show-&#123;bp&#125;", desc: "Visible at breakpoint and up"},
        %{class: ".pc-hide-below-&#123;bp&#125;", desc: "Hidden below breakpoint"},
        %{class: ".pc-show-below-&#123;bp&#125;", desc: "Visible below breakpoint"}
      ]} is_striped>
        <:col :let={row} label={gettext("Class")}><code>{row.class}</code></:col>
        <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
      </.table>
      <.callout variant="info" class="mt-4">
        Breakpoints: <code>sm</code> (576px), <code>md</code> (768px), <code>lg</code> (992px), <code>xl</code> (1200px)
      </.callout>
    </.card>

    <.card title_text={gettext("Border Utilities")}>
      <.grid>
        <.column size="50">
          <.heading level={4}>{gettext("Border Add/Remove")}</.heading>
          <.basic_list spacing="compact">
            <li><code>border</code> - All sides</li>
            <li><code>border-top</code> / <code>border-bottom</code></li>
            <li><code>border-start</code> / <code>border-end</code></li>
            <li><code>border-0</code> - Remove all borders</li>
          </.basic_list>
        </.column>
        <.column size="50">
          <.heading level={4}>{gettext("Border Radius")}</.heading>
          <.basic_list spacing="compact">
            <li><code>rounded</code> - Default radius</li>
            <li><code>rounded-0</code> - No radius</li>
            <li><code>rounded-sm</code> - Small radius</li>
            <li><code>rounded-lg</code> - Large radius</li>
            <li><code>rounded-circle</code> - Circle (50%)</li>
            <li><code>rounded-pill</code> - Pill shape</li>
          </.basic_list>
        </.column>
      </.grid>
    </.card>

    <.card title_text={gettext("Overflow")}>
      <.table rows={[
        %{class: "overflow-auto", desc: "Scroll when needed"},
        %{class: "overflow-hidden", desc: "Clip overflow"},
        %{class: "overflow-visible", desc: "Show overflow"},
        %{class: "overflow-scroll", desc: "Always show scrollbar"},
        %{class: "overflow-x-auto", desc: "Horizontal scroll when needed"},
        %{class: "overflow-y-auto", desc: "Vertical scroll when needed"}
      ]} is_striped>
        <:col :let={row} label={gettext("Class")}><code>.{row.class}</code></:col>
        <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
      </.table>
    </.card>

    <.card title_text={gettext("Position")}>
      <.basic_list spacing="compact">
        <li><code>position-static</code> / <code>position-relative</code> / <code>position-absolute</code> / <code>position-fixed</code> / <code>position-sticky</code></li>
        <li><code>top-0</code>, <code>bottom-0</code>, <code>start-0</code>, <code>end-0</code> - Position edges</li>
        <li><code>translate-middle</code> - Center with transform</li>
      </.basic_list>
    </.card>

    <.card title_text={gettext("Cursor")}>
      <.table rows={[
        %{class: "cursor-pointer", desc: "Pointer (clickable)"},
        %{class: "cursor-default", desc: "Default arrow"},
        %{class: "cursor-not-allowed", desc: "Not allowed"},
        %{class: "cursor-grab", desc: "Grab (draggable)"},
        %{class: "cursor-help", desc: "Help (question mark)"},
        %{class: "cursor-text", desc: "Text selection"},
        %{class: "cursor-move", desc: "Move/drag"}
      ]} is_striped>
        <:col :let={row} label={gettext("Class")}><code>.{row.class}</code></:col>
        <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
      </.table>
    </.card>

    <.card title_text={gettext("Interaction")}>
      <.basic_list spacing="compact">
        <li><code>pe-none</code> - Disable pointer events</li>
        <li><code>pe-auto</code> - Enable pointer events</li>
        <li><code>user-select-none</code> - Prevent text selection</li>
        <li><code>user-select-all</code> - Select all on click</li>
      </.basic_list>
    </.card>
    """
  end
end
