defmodule DemoWeb.Live.TypographyLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Typography")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>
      {gettext("Typography — headings, paragraphs, colours, alignment, and compound semantic styles. The size scale is absolute: one name, one size, everywhere.")}
    </.paragraph>

    <.card title_text={gettext("Headings")}>
      <.heading level="1">Heading 1</.heading>
      <.heading level="2">Heading 2</.heading>
      <.heading level="3">Heading 3</.heading>
      <.heading level="4">Heading 4</.heading>
      <.heading level="5">Heading 5</.heading>
      <.heading level="6">Heading 6</.heading>
    </.card>

    <.card title_text={gettext("Paragraph Sizes")}>
      <.paragraph color="secondary" class="mb-4">
        {gettext("No size is the body default (16px). Each size maps directly to the same-named text-* utility.")}
      </.paragraph>
      <div style="display: flex; flex-direction: column; gap: 4px;">
        <.paragraph size="xs" class="m-0">text-xs — 12px</.paragraph>
        <.paragraph size="sm" class="m-0">text-sm — 14px (UI-control size)</.paragraph>
        <.paragraph class="m-0">no size — body default (16px)</.paragraph>
        <.paragraph size="lg" class="m-0">text-lg — 18px</.paragraph>
        <.paragraph size="xl" class="m-0">text-xl — 20px</.paragraph>
      </div>
    </.card>

    <.grid>
      <.column size="100" md="50">
        <.card title_text={gettext("Text Colour")}>
          <.paragraph color="secondary" class="mb-2">
            {gettext("Neutral text hierarchy. Role colours are in the Inline Text section.")}
          </.paragraph>
          <div style="display: flex; flex-direction: column; gap: 4px;">
            <.paragraph color="primary" class="m-0">Body text — the default (--pc-text-color-1)</.paragraph>
            <.paragraph color="secondary" class="m-0">Secondary — muted / subdued (--pc-text-color-2)</.paragraph>
          </div>
        </.card>
      </.column>
      <.column size="100" md="50">
        <.card title_text={gettext("Alignment")}>
          <.paragraph color="secondary" class="mb-2">{gettext("Logical, RTL-aware.")}</.paragraph>
          <div style="display: flex; flex-direction: column; gap: 4px;">
            <.paragraph align="start" class="m-0">Start — leading edge</.paragraph>
            <.paragraph align="center" class="m-0">Center</.paragraph>
            <.paragraph align="end" class="m-0">End — trailing edge</.paragraph>
          </div>
        </.card>
      </.column>
    </.grid>

    <.card title_text={gettext("Semantic Text")}>
      <.paragraph color="secondary" class="mb-2">{gettext("Compound shorthands.")}</.paragraph>
      <div style="display: flex; flex-direction: column; gap: 8px;">
        <.paragraph semantic="lead" class="m-0">
          Lead — an introductory paragraph at 16px with relaxed line-height, for the opening sentence of a section.
        </.paragraph>
        <.paragraph semantic="caption" class="m-0">
          Caption — small muted text at 12px, for figure captions and fine print.
        </.paragraph>
      </div>
    </.card>

    <.grid>
      <.column size="100" md="50">
        <.card title_text={gettext("Inline Text")}>
          <.paragraph>
            Inline spans: <.text variant="secondary">secondary</.text>,
            <.text variant="primary">primary</.text>,
            <.text variant="success">success</.text>,
            <.text variant="danger">danger</.text>,
            <.text variant="warning">warning</.text>,
            <.text variant="info">info</.text>.
          </.paragraph>
          <.paragraph class="m-0">Emphasis: <strong>strong</strong> and <em>em</em>.</.paragraph>
        </.card>
      </.column>
      <.column size="100" md="50">
        <.card title_text={gettext("Links")}>
          <div style="display: flex; flex-direction: column; gap: 4px;">
            <.pa_link href="#">Default link</.pa_link>
            <.pa_link href="#" class="text-secondary">Muted link</.pa_link>
          </div>
        </.card>
      </.column>
    </.grid>

    <.card title_text={gettext("Class Reference")}>
      <table class="pa-table pa-table--striped pa-table--sm">
        <thead>
          <tr>
            <th>{gettext("Category")}</th>
            <th>{gettext("Classes")}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{gettext("Font size")}</td>
            <td><code>text-2xs</code>, <code>text-xs</code>, <code>text-sm</code>, <code>text-base</code>, <code>text-lg</code>, <code>text-xl</code>, <code>text-2xl</code></td>
          </tr>
          <tr>
            <td>{gettext("Colour")}</td>
            <td><code>text-body</code>, <code>text-secondary</code>, <code>text-primary</code>, <code>text-success</code>, <code>text-danger</code>, <code>text-warning</code>, <code>text-info</code></td>
          </tr>
          <tr>
            <td>{gettext("Alignment")}</td>
            <td><code>text-start</code>, <code>text-center</code>, <code>text-end</code></td>
          </tr>
          <tr>
            <td>{gettext("Wrapping")}</td>
            <td><code>text-nowrap</code>, <code>text-truncate</code></td>
          </tr>
          <tr>
            <td>{gettext("Semantic")}</td>
            <td><code>text-caption</code>, <code>text-lead</code></td>
          </tr>
        </tbody>
      </table>
    </.card>
    """
  end
end
