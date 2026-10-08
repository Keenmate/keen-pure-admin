defmodule DemoWeb.Live.CalloutsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Callouts")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Documentation-style callouts with left border accent for tips, notes, warnings in content areas.</.paragraph>

    <%!-- Basic Callouts --%>
    <.card title_text={gettext("Basic Callouts")}>
      <.callout variant="primary">
        <strong>Primary Callout</strong> - Use this for highlighting important information related to the main topic.
      </.callout>
      <.callout variant="secondary">
        <strong>Secondary Callout</strong> - Use this for supplementary or less critical information.
      </.callout>
      <.callout variant="success">
        <strong>Success Callout</strong> - Use this to highlight successful outcomes or positive tips.
      </.callout>
      <.callout variant="danger">
        <strong>Danger Callout</strong> - Use this to warn about critical issues or destructive actions.
      </.callout>
      <.callout variant="warning">
        <strong>Warning Callout</strong> - Use this to caution users about potential problems or deprecated features.
      </.callout>
      <.callout variant="info">
        <strong>Info Callout</strong> - Use this for helpful tips, hints, or additional context.
      </.callout>
    </.card>

    <%!-- Callouts with Headings --%>
    <.card title_text={gettext("Callouts with Headings")}>
      <.callout variant="info" heading_text={gettext("Note")}>
        <p>This is an informational callout with a heading. Use headings to make important callouts more scannable.</p>
      </.callout>
      <.callout variant="warning" heading_text={gettext("Deprecation Warning")}>
        <p>This API endpoint will be removed in version 3.0. Please migrate to the new endpoint.</p>
      </.callout>
      <.callout variant="danger" heading_text={gettext("Breaking Change")}>
        <p>The response format has changed. See the migration guide for details on updating your integration.</p>
      </.callout>
      <.callout variant="success" heading_text={gettext("Best Practice")}>
        <p>Always validate user input before processing. This prevents security vulnerabilities and improves reliability.</p>
      </.callout>
    </.card>

    <%!-- Callouts with Icons --%>
    <.card title_text={gettext("Callouts with Icons")}>
      <.callout variant="info">
        <:icon>i</:icon>
        <strong>Pro Tip:</strong> You can use keyboard shortcuts to speed up your workflow. Press <code>Ctrl+K</code> to open the command palette.
      </.callout>
      <.callout variant="warning">
        <:icon>!</:icon>
        <strong>Caution:</strong> Make sure to backup your data before proceeding with this operation.
      </.callout>
      <.callout variant="danger">
        <:icon>x</:icon>
        <strong>Critical:</strong> This action cannot be undone. All associated data will be permanently deleted.
      </.callout>
      <.callout variant="success">
        <:icon>v</:icon>
        <strong>Verified:</strong> This component has been tested and approved for production use.
      </.callout>
    </.card>

    <%!-- Callouts with Lists --%>
    <.card title_text={gettext("Callouts with Lists")}>
      <.grid>
        <.column size="100" md="50">
          <.callout variant="info" heading_text={gettext("Prerequisites")}>
            <p>Before you begin, make sure you have:</p>
            <ul>
              <li>Node.js 18 or higher installed</li>
              <li>npm or yarn package manager</li>
              <li>A code editor (VS Code recommended)</li>
              <li>Basic knowledge of JavaScript</li>
            </ul>
          </.callout>
        </.column>
        <.column size="100" md="50">
          <.callout variant="warning" heading_text={gettext("Known Limitations")}>
            <p>Please be aware of these current limitations:</p>
            <ol>
              <li>Maximum file size is 10MB</li>
              <li>Concurrent uploads limited to 5</li>
              <li>Some formats not yet supported</li>
              <li>Mobile optimization in progress</li>
            </ol>
          </.callout>
        </.column>
      </.grid>
    </.card>

    <%!-- Theme Color Callouts --%>
    <.card title_text={gettext("Theme Color Callouts")}>
      <.callout :for={n <- 1..9} theme_color={to_string(n)}>
        <strong>Color {n}</strong> - Theme color slot {n} callout.
      </.callout>
    </.card>

    <%!-- Callout Sizes --%>
    <.card title_text={gettext("Callout Sizes")}>
      <.callout variant="info" size="sm">
        <strong>Small Callout</strong> - Compact size for inline tips or short notes.
      </.callout>
      <.callout variant="info">
        <strong>Default Callout</strong> - Standard size suitable for most use cases.
      </.callout>
      <.callout variant="info" size="lg">
        <strong>Large Callout</strong> - Use this for prominent callouts that need extra emphasis and breathing room.
      </.callout>
    </.card>

    <%!-- Callouts with Code --%>
    <.card title_text={gettext("Callouts with Code")}>
      <.callout variant="info" heading_text={gettext("Quick Start")}>
        <p>Install the package using npm:</p>
        <p><code>npm install @keenmate/pure-admin-core</code></p>
        <p>Then import the styles in your SCSS:</p>
        <p><code>@import '@keenmate/pure-admin-core/src/scss/main';</code></p>
      </.callout>
      <.callout variant="warning" heading_text={gettext("Migration Note")}>
        <p>If upgrading from v0.x, replace <code>pa-alert--callout</code> with the new <code>pa-callout</code> class. The old class is deprecated and will be removed in v2.0.</p>
      </.callout>
    </.card>

    <%!-- Callouts with Links --%>
    <.card title_text={gettext("Callouts with Links")}>
      <.callout variant="info" heading_text={gettext("Learn More")}>
        <p>For detailed documentation on all available components, visit the <a href="/buttons">Buttons</a> and <a href="/surfaces/cards">Cards</a> documentation.</p>
      </.callout>
      <.callout variant="primary">
        <p>Need help? Check out our <a href="/">Dashboard</a> or join the community for support.</p>
      </.callout>
    </.card>

    <%!-- Callouts in Grid --%>
    <.card title_text={gettext("Callouts in Grid Layout")}>
      <.grid>
        <.column size="100" md="1-3">
          <.callout variant="success" size="sm">
            <strong>Tip:</strong> Use keyboard shortcuts for faster navigation.
          </.callout>
        </.column>
        <.column size="100" md="1-3">
          <.callout variant="warning" size="sm">
            <strong>Note:</strong> This feature requires admin privileges.
          </.callout>
        </.column>
        <.column size="100" md="1-3">
          <.callout variant="danger" size="sm">
            <strong>Alert:</strong> Scheduled maintenance tonight.
          </.callout>
        </.column>
      </.grid>
    </.card>

    <%!-- Callout vs Alert Comparison --%>
    <.card title_text={gettext("Callouts vs Alerts")}>
      <.grid>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("Callout")}</.heading>
          <.paragraph color="secondary">Documentation-style, left border accent, for static content</.paragraph>
          <.callout variant="info">
            <strong>Callouts</strong> are best for documentation, tips, and static informational content that doesn't require user action.
          </.callout>
        </.column>
        <.column size="100" md="50">
          <.heading level={4}>{gettext("Alert")}</.heading>
          <.paragraph color="secondary">Full background, dismissible, for dynamic feedback</.paragraph>
          <.alert variant="info">
            <strong>Alerts</strong> are best for dynamic feedback, notifications, and messages that may require user action or dismissal.
          </.alert>
        </.column>
      </.grid>
    </.card>

    """
  end
end
