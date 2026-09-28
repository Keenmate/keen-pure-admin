defmodule DemoWeb.Live.CoreComponentsLive do
  use DemoWeb, :live_view

  @setup_project "mix phx.new my_app --no-tailwind"

  @setup_dep ~S'{:keen_pure_admin, "~> 1.0"}'

  @setup_import ~S"""
  # In your MyAppWeb module, replace:
  #   import MyAppWeb.CoreComponents
  # With:
  use PureAdmin.Components
  """

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "CoreComponents Migration",
       setup_project: @setup_project,
       setup_dep: @setup_dep,
       setup_import: @setup_import
     )}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>
      PureAdmin replaces Phoenix's generated <code>CoreComponents</code> module.
      This page shows what's replaced, what's new, and how to handle the migration.
    </.paragraph>

    <%!-- Migration overview --%>
    <.card title_text={gettext("Migration Overview")}>
      <.callout variant="info">
        Replace <code>import MyAppWeb.CoreComponents</code> with <code>use PureAdmin.Components</code>
        in your <code>html_helpers/0</code> function. All replaced functions keep the same name and
        similar signatures, so most templates work without changes.
      </.callout>

      <.table_container>
        <table class="pa-table">
          <thead>
            <tr>
              <th>{gettext("CoreComponents function")}</th>
              <th>{gettext("PureAdmin replacement")}</th>
              <th>{gettext("Status")}</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><code>button/1</code></td>
              <td><code>PureAdmin.Components.Button.button/1</code></td>
              <td><.badge variant="success">{gettext("Replaced")}</.badge></td>
            </tr>
            <tr>
              <td><code>input/1</code></td>
              <td>
                <code>PureAdmin.Components.Form.input/1</code>
                — accepts <code>field=&#123;@form[:x]&#125;</code> the same way CoreComponents does; auto-renders
                error help. Same treatment on <code>textarea/1</code>, <code>select/1</code>,
                <code>checkbox/1</code>, <code>radio/1</code>, and <code>form_group/1</code>.
              </td>
              <td><.badge variant="success">{gettext("Replaced")}</.badge></td>
            </tr>
            <tr>
              <td><code>simple_form/1</code></td>
              <td><code>PureAdmin.Components.Form.simple_form/1</code></td>
              <td><.badge variant="success">{gettext("Replaced")}</.badge></td>
            </tr>
            <tr>
              <td><code>modal/1</code></td>
              <td><code>PureAdmin.Components.Modal.modal/1</code></td>
              <td><.badge variant="success">{gettext("Replaced")}</.badge></td>
            </tr>
            <tr>
              <td><code>table/1</code></td>
              <td><code>PureAdmin.Components.Table.table/1</code></td>
              <td><.badge variant="success">{gettext("Replaced")}</.badge></td>
            </tr>
            <tr>
              <td><code>list/1</code></td>
              <td><code>PureAdmin.Components.List.list/1</code></td>
              <td><.badge variant="success">{gettext("Replaced")}</.badge></td>
            </tr>
            <tr>
              <td><code>label/1</code></td>
              <td><code>PureAdmin.Components.Badge.label/1</code></td>
              <td><.badge variant="success">{gettext("Replaced")}</.badge></td>
            </tr>
            <tr>
              <td><code>flash/1</code>, <code>flash_group/1</code></td>
              <td>
                <code>PureAdmin.Components.Flash</code>
                — see <a href="/phoenix/flash" class="pa-link">Flash Messages</a>
              </td>
              <td><.badge variant="success">{gettext("Replaced")}</.badge></td>
            </tr>
            <tr>
              <td><code>header/1</code></td>
              <td>Page title via <code>@page_title</code> in <code>&lt;.page_header&gt;</code> (layout renders it, LiveView sets it)</td>
              <td><.badge variant="info">{gettext("Not needed")}</.badge></td>
            </tr>
            <tr>
              <td><code>icon/1</code></td>
              <td>Use Font Awesome directly: <code>&lt;i class="fa-solid fa-..."&gt;</code></td>
              <td><.badge variant="warning">{gettext("Manual")}</.badge></td>
            </tr>
            <tr>
              <td><code>show/1</code>, <code>hide/1</code></td>
              <td>Use <code>Phoenix.LiveView.JS.show/1</code> and <code>JS.hide/1</code> directly (thin wrappers, not needed)</td>
              <td><.badge variant="info">{gettext("Not needed")}</.badge></td>
            </tr>
            <tr>
              <td><code>translate_error/1</code></td>
              <td>
                <code>PureAdmin.Components.Form.translate_error/1</code> ships a plain
                <code>{"%{key}"}</code>-interpolating default. For Gettext, point
                <code>config :keen_pure_admin, :error_formatter</code> at your app's
                <code>translate_error/1</code> (see <code>form.ex</code> moduledoc).
              </td>
              <td><.badge variant="success">{gettext("Replaced")}</.badge></td>
            </tr>
          </tbody>
        </table>
      </.table_container>
    </.card>

    <%!-- Setup instructions --%>
    <.card title_text={gettext("Setup Steps")}>
      <.timeline variant="simple">
        <.timeline_item>
          <:title>{gettext("Create project without Tailwind")}</:title>
          <.code_block language="bash">{@setup_project}</.code_block>
        </.timeline_item>
        <.timeline_item>
          <:title>{gettext("Add dependency")}</:title>
          <.code_block language="elixir">{@setup_dep}</.code_block>
        </.timeline_item>
        <.timeline_item>
          <:title>{gettext("Replace CoreComponents import")}</:title>
          <.code_block language="elixir">{@setup_import}</.code_block>
        </.timeline_item>
        <.timeline_item>
          <:title>{gettext("Add translate_error/1")}</:title>
          <.paragraph>
            PureAdmin does not include <code>translate_error/1</code> since it depends on your app's
            Gettext configuration. Copy it from the generated CoreComponents or define your own.
          </.paragraph>
        </.timeline_item>
        <.timeline_item>
          <:title>{gettext("Replace icon references")}</:title>
          <.paragraph>
            CoreComponents uses Heroicons via <code>&lt;.icon name="hero-..." /&gt;</code>.
            PureAdmin uses Font Awesome: <code>&lt;i class="fa-solid fa-..."&gt;&lt;/i&gt;</code>.
          </.paragraph>
        </.timeline_item>
      </.timeline>
    </.card>
    """
  end
end
