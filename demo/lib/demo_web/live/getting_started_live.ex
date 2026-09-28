defmodule DemoWeb.Live.GettingStartedLive do
  use DemoWeb, :live_view

  @dep_hex ~S'{:keen_pure_admin, "~> 1.0"}'
  @dep_github ~S'{:keen_pure_admin, github: "KeenMate/keen-pure-admin", tag: "v1.0.0"}'

  @font_custom_breakpoint ~S"""
  @media (max-width: 640px) {
    html { font-size: 12px; }
  }
  """

  @font_responsive_html ~S"""
  <html class="pa-font-responsive">
  <!-- Desktop: 10px base (16px body text) -->
  <!-- Mobile (<=768px): 12px base (~19px body text) -->
  """

  @setup_layout ~S"""
  <.navbar>
    <:burger><.navbar_burger /></:burger>
    <:start>
      <.app_header>My App</.app_header>
    </:start>
  </.navbar>

  <.layout>
    <.layout_inner>
      <.sidebar>
        <.sidebar_item label="Dashboard" icon="fa-solid fa-gauge" href="/" />
      </.sidebar>
      <.layout_content>
        <.main>
          <%= @inner_content %>
        </.main>
      </.layout_content>
    </.layout_inner>
  </.layout>
  """

  @setup_hooks ~S"""
  import { PureAdminHooks } from "keen_pure_admin"

  let liveSocket = new LiveSocket("/live", Socket, {
    hooks: { ...PureAdminHooks }
  })
  """

  @setup_usage ~S"""
  <.card title_text="My Card">
    <.alert variant="info">Welcome to Pure Admin!</.alert>
    <.button variant="primary">Submit</.button>
  </.card>
  """

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Getting Started",
       font_custom_breakpoint: @font_custom_breakpoint,
       font_responsive_html: @font_responsive_html,
       dep_hex: @dep_hex,
       dep_github: @dep_github,
       setup_layout: @setup_layout,
       setup_hooks: @setup_hooks,
       setup_usage: @setup_usage
     )}
  end

  def render(assigns) do
    ~H"""
    <%!-- Hero/Intro --%>
    <.card title_text={gettext("Welcome to PureAdmin for Phoenix")}>
      <.paragraph>
        <strong>keen_pure_admin</strong> is a Phoenix LiveView component library that wraps the
        Pure Admin CSS framework (<code>@keenmate/pure-admin-core</code>) into function components
        and LiveComponents.
      </.paragraph>
      <.paragraph>
        Drop-in replacement for Phoenix <code>CoreComponents</code> — provides <code>button/1</code>,
        <code>modal/1</code>, <code>table/1</code>, <code>input/1</code>, and 35+ more components
        with full BEM class support.
      </.paragraph>
      <.grid class="mt-4">
        <.column size="100" md="1-3">
          <div class="text-center">
            <div class="text-4xl mb-2">35+</div>
            <.paragraph class="mb-0"><strong>Components</strong><br/>Ready to use</.paragraph>
          </div>
        </.column>
        <.column size="100" md="1-3">
          <div class="text-center">
            <div class="text-4xl mb-2">14</div>
            <.paragraph class="mb-0"><strong>JS Hooks</strong><br/>LiveView integrated</.paragraph>
          </div>
        </.column>
        <.column size="100" md="1-3">
          <div class="text-center">
            <div class="text-4xl mb-2">5</div>
            <.paragraph class="mb-0"><strong>Themes</strong><br/>Fully customizable</.paragraph>
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- About This Demo --%>
    <.card title_text={gettext("About This Demo")}>
      <.paragraph>
        This documentation site showcases the keen_pure_admin component library with multiple theme options.
        Use the settings panel (gear icon) to switch between themes and customize the appearance.
      </.paragraph>

      <.callout variant="info" heading_text={gettext("Theme Switching & FOUC")}>
        <p>On initial page load, you may notice a brief flash of the default theme before your selected theme loads. This is expected behavior in this demo.</p>
        <p class="mb-0"><strong>Why?</strong> The default theme is bundled statically to prevent unstyled content (FOUC), then your saved theme preference loads dynamically via JavaScript.</p>
      </.callout>

      <.callout variant="success" heading_text={gettext("Production Usage")}>
        <p>In a production application, you would import only <strong>one</strong> theme statically in your CSS. This eliminates the flash entirely since there's no theme switching overhead.</p>
      </.callout>
    </.card>

    <%!-- About SettingsPanel --%>
    <.card title_text={gettext("About SettingsPanel")}>
      <.paragraph>
        The <code>SettingsPanel</code> component (gear icon in the corner) is primarily a <strong>demo and development tool</strong>
        to showcase what's possible with pure-admin-core. It's not typically something you'd expose to end users in production.
      </.paragraph>

      <.callout variant="warning" heading_text={gettext("Production Architecture")}>
        <p>In a real application, these settings would be handled differently:</p>
        <ul>
          <li><strong>App-level constants</strong> (hardcoded): theme, layout width, sidebar behavior — decided during development</li>
          <li><strong>User preferences</strong> (stored per-user): font size, compact mode — saved to user profile/database</li>
          <li><strong>Design decisions</strong> (not configurable): avatar visibility, icon-only tabs — part of your app's design</li>
        </ul>
        <p class="mb-0">The SettingsPanel demonstrates runtime customization, but most apps would make these choices at build time or store them server-side.</p>
      </.callout>
    </.card>

    <%!-- Installation --%>
    <.card title_text={gettext("Installation")}>
      <.paragraph>Prerequisites: create a Phoenix project <strong>without Tailwind</strong>:</.paragraph>
      <.code_block language="bash">mix phx.new my_app --no-tailwind</.code_block>

      <.callout variant="info" size="sm" class="mt-4">
        If you have an existing project that uses Tailwind, remove the Tailwind dependency and its configuration before adding Pure Admin, as the two CSS frameworks will conflict.
      </.callout>

      <.paragraph class="mt-4">Add <code>keen_pure_admin</code> to your <code>mix.exs</code>:</.paragraph>

      <.grid>
        <.column size="100" md="1-2">
          <p><strong>{gettext("From Hex (recommended)")}</strong></p>
          <.code_block language="elixir">{@dep_hex}</.code_block>
        </.column>
        <.column size="100" md="1-2">
          <p><strong>{gettext("From GitHub")}</strong></p>
          <.code_block language="elixir">{@dep_github}</.code_block>
        </.column>
      </.grid>
    </.card>

    <%!-- Basic Setup --%>
    <.card title_text={gettext("Basic Setup")}>
      <.paragraph>
        After installation, replace Phoenix's CoreComponents with PureAdmin and set up the layout.
      </.paragraph>

      <.timeline variant="simple">
        <.timeline_item>
          <:title>{gettext("Replace CoreComponents import")}</:title>
          <.paragraph>
            In your <code>MyAppWeb</code> module, replace
            <code>import MyAppWeb.CoreComponents</code> with:
          </.paragraph>
          <.code_block language="elixir">use PureAdmin.Components</.code_block>
        </.timeline_item>
        <.timeline_item>
          <:title>{gettext("Install a theme")}</:title>
          <.paragraph>
            Download a theme from <a href="https://pureadmin.io" class="pa-link">pureadmin.io</a> or use the Pure Admin CLI:
          </.paragraph>
          <.code_block language="bash">npx @keenmate/pureadmin install audi</.code_block>
        </.timeline_item>
        <.timeline_item>
          <:title>{gettext("Set up the layout")}</:title>
          <.code_block language="html">{@setup_layout}</.code_block>
        </.timeline_item>
        <.timeline_item>
          <:title>{gettext("Register JS hooks")}</:title>
          <.paragraph>In your <code>app.js</code>:</.paragraph>
          <.code_block language="javascript">{@setup_hooks}</.code_block>
        </.timeline_item>
        <.timeline_item>
          <:title>{gettext("Use components anywhere")}</:title>
          <.code_block language="html">{@setup_usage}</.code_block>
        </.timeline_item>
      </.timeline>
    </.card>

    <%!-- Responsive Font Sizing --%>
    <.card title_text={gettext("Responsive Font Sizing")}>
      <.paragraph>
        Pure Admin uses a <strong>10px rem base</strong> — the <code>html</code> font-size is 10px, so all rem values
        scale proportionally. Changing the html font-size scales the entire UI: text, spacing, components.
      </.paragraph>

      <h4>{gettext("Shorthand (recommended)")}</h4>
      <.paragraph>One class for the common case — default on desktop, larger on mobile:</.paragraph>
      <.code_block language="html">{@font_responsive_html}</.code_block>

      <h4 class="mt-4">{gettext("Granular Control")}</h4>
      <.paragraph>Pick exact sizes for desktop and mobile independently:</.paragraph>
      <.code_block language="html">&lt;html class="pa-font-base-10 pa-font-mobile-12"&gt;</.code_block>

      <.table_container>
        <table class="pa-table pa-table--striped pa-table--compact mt-4">
          <thead>
            <tr>
              <th>{gettext("Class")}</th>
              <th>{gettext("html font-size")}</th>
              <th>{gettext("Body text result")}</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><code>pa-font-base-9</code> / <code>pa-font-mobile-9</code></td>
              <td>9px</td>
              <td>~14px</td>
            </tr>
            <tr>
              <td><code>pa-font-base-10</code> / <code>pa-font-mobile-10</code></td>
              <td>10px</td>
              <td>16px (default)</td>
            </tr>
            <tr>
              <td><code>pa-font-base-11</code> / <code>pa-font-mobile-11</code></td>
              <td>11px</td>
              <td>~18px</td>
            </tr>
            <tr>
              <td><code>pa-font-base-12</code> / <code>pa-font-mobile-12</code></td>
              <td>12px</td>
              <td>~19px</td>
            </tr>
          </tbody>
        </table>
      </.table_container>

      <.callout variant="info" class="mt-4">
        <strong>No FOUC.</strong> These are CSS classes set directly in your HTML markup — styles apply before
        first paint, unlike the JS-based settings panel approach.
      </.callout>

      <.callout variant="warning" class="mt-2">
        <strong>Custom breakpoint?</strong> If you need a different mobile breakpoint, use a plain media query instead:
        <.code_block language="css">{@font_custom_breakpoint}</.code_block>
      </.callout>
    </.card>

    <%!-- Available Themes --%>
    <.card title_text={gettext("Available Themes")}>
      <.paragraph>
        Pure Admin comes with 5 example themes that serve as starter packs for your own customization.
        Each theme demonstrates different color schemes and provides a foundation you can build upon.
      </.paragraph>

      <.callout variant="info" size="sm">
        These themes are visual examples to get you started quickly. For production, you will likely want to
        customize the CSS variables to match your brand identity.
      </.callout>

      <.grid>
        <.column size="100" md="1-2" lg="2-5">
          <.card>
            <:header><h4>Audi</h4></:header>
            <.paragraph class="mb-0">
              Clean design with sharp contrasts. A good starting point for modern admin interfaces.
            </.paragraph>
            <:footer><code>@keenmate/pure-admin-theme-audi</code></:footer>
          </.card>
        </.column>
        <.column size="100" md="1-2" lg="2-5">
          <.card>
            <:header><h4>Corporate</h4></:header>
            <.paragraph class="mb-0">
              Traditional look with conservative colors. Starter for business-oriented applications.
            </.paragraph>
            <:footer><code>@keenmate/pure-admin-theme-corporate</code></:footer>
          </.card>
        </.column>
        <.column size="100" md="1-2" lg="2-5">
          <.card>
            <:header><h4>Dark</h4></:header>
            <.paragraph class="mb-0">
              Dark mode example. Use as a base for building your own dark theme variant.
            </.paragraph>
            <:footer><code>@keenmate/pure-admin-theme-dark</code></:footer>
          </.card>
        </.column>
        <.column size="100" md="1-2" lg="2-5">
          <.card>
            <:header><h4>Express</h4></:header>
            <.paragraph class="mb-0">
              Bolder accent colors. Example of a more vibrant color palette.
            </.paragraph>
            <:footer><code>@keenmate/pure-admin-theme-express</code></:footer>
          </.card>
        </.column>
        <.column size="100" md="1-2" lg="2-5">
          <.card>
            <:header><h4>Minimal</h4></:header>
            <.paragraph class="mb-0">
              Subtle colors with reduced visual noise. Starting point for minimalist designs.
            </.paragraph>
            <:footer><code>@keenmate/pure-admin-theme-minimal</code></:footer>
          </.card>
        </.column>
      </.grid>
    </.card>

    <%!-- Component Categories --%>
    <.card title_text={gettext("Component Overview")}>
      <.paragraph>
        The library includes 35+ components organized into logical categories:
      </.paragraph>

      <.grid>
        <.column size="100" md="1-2" lg="1-3">
          <h4>{gettext("Layout")}</h4>
          <ul>
            <li>Layout, LayoutInner, LayoutContent</li>
            <li>Navbar, NavItem, NavDropdown</li>
            <li>Sidebar, SidebarItem</li>
            <li>Main, Footer</li>
          </ul>
        </.column>
        <.column size="100" md="1-2" lg="1-3">
          <h4>{gettext("Forms")}</h4>
          <ul>
            <li>Input, Select, Textarea</li>
            <li>Checkbox, Radio</li>
            <li>SimpleForm, FormGroup</li>
            <li>CheckboxList</li>
          </ul>
        </.column>
        <.column size="100" md="1-2" lg="1-3">
          <h4>{gettext("Feedback")}</h4>
          <ul>
            <li>Alert, Callout</li>
            <li>Toast, Flash</li>
            <li>Modal, DialogService</li>
            <li>Loader</li>
          </ul>
        </.column>
        <.column size="100" md="1-2" lg="1-3">
          <h4>{gettext("Data Display")}</h4>
          <ul>
            <li>Table, TableResponsive</li>
            <li>Card, Stat</li>
            <li>Badge, BadgeGroup</li>
            <li>Code, CodeBlock</li>
          </ul>
        </.column>
        <.column size="100" md="1-2" lg="1-3">
          <h4>{gettext("Navigation")}</h4>
          <ul>
            <li>Tabs</li>
            <li>CommandPalette</li>
            <li>Pager</li>
            <li>SettingsPanel</li>
          </ul>
        </.column>
        <.column size="100" md="1-2" lg="1-3">
          <h4>{gettext("Interactive")}</h4>
          <ul>
            <li>Button, ButtonGroup</li>
            <li>Tooltip, Popover</li>
            <li>Popconfirm</li>
            <li>Timeline</li>
          </ul>
        </.column>
      </.grid>

      <.paragraph class="mt-4">
        Explore the sidebar navigation to see detailed examples and documentation for each component.
      </.paragraph>
    </.card>

    <%!-- Next Steps --%>
    <.card title_text={gettext("Next Steps")}>
      <.grid>
        <.column size="100" md="1-2">
          <.callout variant="primary">
            <strong>{gettext("Explore Components")}</strong>
            <p class="mb-0">Browse the <a href="/components" class="pa-link">Components Overview</a> to see all available components with live examples.</p>
          </.callout>
        </.column>
        <.column size="100" md="1-2">
          <.callout variant="info">
            <strong>{gettext("CoreComponents Migration")}</strong>
            <p class="mb-0">See the <a href="/phoenix/core-components" class="pa-link">CoreComponents Migration</a> guide for a full mapping from Phoenix defaults.</p>
          </.callout>
        </.column>
      </.grid>
    </.card>
    """
  end
end
