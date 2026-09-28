defmodule DemoWeb.Live.TypographyLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Typography")}
  end

  def render(assigns) do
    ~H"""
    <p>Text styles and heading components.</p>

    <.card title_text={gettext("Headings")}>
      <.heading level="1">Heading 1</.heading>
      <.heading level="2">Heading 2</.heading>
      <.heading level="3">Heading 3</.heading>
      <.heading level="4">Heading 4</.heading>
      <.heading level="5">Heading 5</.heading>
      <.heading level="6">Heading 6</.heading>
    </.card>

    <.card title_text={gettext("Paragraphs")}>
      <.paragraph>
        This is a standard paragraph with default styling. Lorem ipsum dolor sit amet, consectetur
        adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim
        ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
      </.paragraph>
      <.paragraph>
        Another paragraph to demonstrate spacing between text blocks. Duis aute irure dolor in
        reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint
        occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
      </.paragraph>
    </.card>

    <.grid>
      <.column size="50">
        <.card title_text={gettext("Text Variants")}>
          <div style="display: flex; flex-direction: column; gap: 8px;">
            <.text>Default text</.text>
            <.text variant="muted">Muted text for secondary information</.text>
            <.text variant="small">Small text for fine print</.text>
            <strong>Bold text for emphasis</strong>
            <em>Italic text for emphasis</em>
          </div>
        </.card>
      </.column>
      <.column size="50">
        <.card title_text={gettext("Links")}>
          <div style="display: flex; flex-direction: column; gap: 8px;">
            <.pa_link href="#">Default link style</.pa_link>
            <%!-- pa-link has no colour modifiers; for a dimmed link add a .text-* utility --%>
            <.pa_link href="#" class="text-secondary">Secondary link</.pa_link>
          </div>
        </.card>
      </.column>
    </.grid>
    """
  end
end
