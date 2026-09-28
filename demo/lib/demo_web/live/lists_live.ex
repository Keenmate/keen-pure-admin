defmodule DemoWeb.Live.ListsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Lists")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Styled lists for content organization - from basic bullets to icon lists and definition lists.</.paragraph>

    <.grid>
      <%!-- Left Column --%>
      <.column size="100" lg="1-2">
        <%!-- Basic Unordered Lists --%>
        <.card title_text={gettext("Basic Unordered Lists")} class="mb-8">
          <.heading level={4}>{gettext("Default Spacing")}</.heading>
          <.basic_list>
            <li>Dashboard with real-time metrics</li>
            <li>User management and permissions</li>
            <li>Advanced reporting tools</li>
            <li>API integration capabilities</li>
            <li>Multi-language support</li>
          </.basic_list>

          <.heading level={4} class="mt-8">{gettext("Compact Spacing")}</.heading>
          <.basic_list spacing="compact">
            <li>Reduced vertical spacing</li>
            <li>Perfect for dense content</li>
            <li>Saves vertical space</li>
            <li>Easy to scan quickly</li>
          </.basic_list>

          <.heading level={4} class="mt-8">{gettext("Spacious Layout")}</.heading>
          <.basic_list spacing="spacious">
            <li>More breathing room between items</li>
            <li>Better for longer content blocks</li>
            <li>Improved readability</li>
          </.basic_list>
        </.card>

        <%!-- Ordered Lists --%>
        <.card title_text={gettext("Ordered Lists")} class="mb-8">
          <.heading level={4}>{gettext("Numeric (Default)")}</.heading>
          <.ordered_list>
            <li>Create a new project</li>
            <li>Configure basic settings</li>
            <li>Invite team members</li>
            <li>Set up workflows</li>
            <li>Launch and monitor</li>
          </.ordered_list>

          <.heading level={4} class="mt-8">{gettext("Roman Numerals")}</.heading>
          <.ordered_list style="roman">
            <li>Executive summary</li>
            <li>Market analysis</li>
            <li>Financial projections</li>
            <li>Implementation roadmap</li>
          </.ordered_list>

          <.heading level={4} class="mt-8">{gettext("Alphabetical")}</.heading>
          <.ordered_list style="alpha">
            <li>Appendix A: Technical specifications</li>
            <li>Appendix B: User testimonials</li>
            <li>Appendix C: Pricing structure</li>
          </.ordered_list>
        </.card>

        <%!-- Definition Lists --%>
        <.card title_text={gettext("Definition Lists")} class="mb-8">
          <.heading level={4}>{gettext("Standard Layout")}</.heading>
          <.definition_list>
            <dt>API Key</dt>
            <dd>A unique identifier used to authenticate requests to the API</dd>
            <dt>Webhook</dt>
            <dd>HTTP callbacks that send real-time data to your application when events occur</dd>
            <dt>OAuth 2.0</dt>
            <dd>Industry-standard protocol for authorization allowing third-party access</dd>
          </.definition_list>

          <.heading level={4} class="mt-8">{gettext("Inline Layout")}</.heading>
          <.definition_list is_inline>
            <dt>{gettext("Status")}</dt>
            <dd>Active</dd>
            <dt>{gettext("Created")}</dt>
            <dd>2025-01-15</dd>
            <dt>{gettext("Modified")}</dt>
            <dd>2025-10-05</dd>
            <dt>{gettext("Author")}</dt>
            <dd>John Doe</dd>
          </.definition_list>
        </.card>
      </.column>

      <%!-- Right Column --%>
      <.column size="100" lg="1-2">
        <%!-- Icon Lists --%>
        <.card title_text={gettext("Icon Lists")} class="mb-8">
          <.heading level={4}>{gettext("Success (Checkmarks)")}</.heading>
          <.basic_list has_icon>
            <li>SSL/TLS encryption enabled</li>
            <li>Automatic daily backups</li>
            <li>99.9% uptime SLA guarantee</li>
            <li>24/7 customer support</li>
          </.basic_list>

          <.heading level={4} class="mt-8">{gettext("Danger (X marks)")}</.heading>
          <.basic_list has_icon icon_variant="danger">
            <li>Deprecated API endpoint</li>
            <li>Unsupported browser version</li>
            <li>Missing required permissions</li>
          </.basic_list>

          <.heading level={4} class="mt-8">{gettext("Info (Arrows)")}</.heading>
          <.basic_list has_icon icon_variant="info">
            <li>Navigate to Settings panel</li>
            <li>Select Integration options</li>
            <li>Choose your provider</li>
            <li>Complete authentication</li>
          </.basic_list>

          <.heading level={4} class="mt-8">{gettext("Warning (Exclamation)")}</.heading>
          <.basic_list has_icon icon_variant="warning">
            <li>Rate limit approaching threshold</li>
            <li>Certificate expires in 30 days</li>
            <li>Low disk space warning</li>
          </.basic_list>
        </.card>

        <%!-- Bordered & Striped Lists --%>
        <.card title_text={gettext("Bordered & Striped Lists")} class="mb-8">
          <.heading level={4}>{gettext("Bordered List")}</.heading>
          <.basic_list is_bordered>
            <li>User Management Module</li>
            <li>Content Management System</li>
            <li>Analytics Dashboard</li>
            <li>Email Campaign Tools</li>
            <li>Reporting Engine</li>
          </.basic_list>

          <.heading level={4} class="mt-8">{gettext("Striped List")}</.heading>
          <.basic_list is_striped>
            <li>Monthly subscription: $99/month</li>
            <li>Annual subscription: $990/year (2 months free)</li>
            <li>Enterprise plan: Custom pricing</li>
            <li>Educational discount: 50% off</li>
          </.basic_list>
        </.card>

        <%!-- Inline & Unstyled Lists --%>
        <.card title_text={gettext("Inline & Unstyled Lists")} class="mb-8">
          <.heading level={4}>{gettext("Inline List")}</.heading>
          <.basic_list is_inline>
            <li><a href="#home">Home</a></li>
            <li><a href="#about">About</a></li>
            <li><a href="#services">Services</a></li>
            <li><a href="#contact">Contact</a></li>
          </.basic_list>

          <.heading level={4} class="mt-8">{gettext("Unstyled List")}</.heading>
          <.basic_list is_unstyled>
            <li>No bullets or numbers</li>
            <li>Just plain text items</li>
            <li>Perfect for custom styling</li>
            <li>Or semantic markup needs</li>
          </.basic_list>
        </.card>

        <%!-- Complex Lists with Avatars --%>
        <.card title_text={gettext("Complex Lists with Avatars")} class="mb-8" has_padding={false}>
          <.list>
            <.list_item title_text="Sarah Johnson" subtitle_text="Product Manager" meta_text="Last active: 2 hours ago">
              <:avatar>👤</:avatar>
            </.list_item>
            <.list_item title_text="Michael Chen" subtitle_text="Lead Developer" meta_text="Last active: 15 minutes ago">
              <:avatar>👤</:avatar>
            </.list_item>
            <.list_item title_text="Emily Rodriguez" subtitle_text="UX Designer" meta_text="Last active: 1 day ago">
              <:avatar>👤</:avatar>
            </.list_item>
          </.list>
        </.card>
      </.column>
    </.grid>

    <%!-- Implementation Guide --%>
    <.card title_text={gettext("Implementation Guide")}>
      <.heading level={4}>{gettext("Available Classes")}</.heading>

      <.heading level={5} class="mt-4">{gettext("Unordered Lists (ul)")}</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-list-basic</code> - Base unordered list</li>
        <li><code>pa-list-basic--compact</code> - Reduced spacing</li>
        <li><code>pa-list-basic--spacious</code> - Increased spacing</li>
        <li><code>pa-list-basic--unstyled</code> - No bullets, no padding</li>
        <li><code>pa-list-basic--inline</code> - Horizontal layout</li>
        <li><code>pa-list-basic--bordered</code> - Border between items</li>
        <li><code>pa-list-basic--striped</code> - Zebra striping</li>
        <li><code>pa-list-basic--icon</code> - Checkmarks (success)</li>
        <li><code>pa-list-basic--icon pa-list-basic--danger</code> - X marks</li>
        <li><code>pa-list-basic--icon pa-list-basic--info</code> - Arrows</li>
        <li><code>pa-list-basic--icon pa-list-basic--warning</code> - Exclamation marks</li>
      </.basic_list>

      <.heading level={5} class="mt-4">{gettext("Ordered Lists (ol)")}</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-list-ordered</code> - Base ordered list (numeric)</li>
        <li><code>pa-list-ordered--roman</code> - Roman numerals (I, II, III)</li>
        <li><code>pa-list-ordered--alpha</code> - Lowercase letters (a, b, c)</li>
      </.basic_list>

      <.heading level={5} class="mt-4">{gettext("Definition Lists (dl)")}</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-list-definition</code> - Standard definition list</li>
        <li><code>pa-list-definition--inline</code> - Horizontal key-value pairs</li>
      </.basic_list>

      <.heading level={5} class="mt-4">{gettext("Complex Lists")}</.heading>
      <.basic_list spacing="compact">
        <li><code>pa-list</code> - Container for complex list items</li>
        <li><code>pa-list__item</code> - Individual list item with avatar/content</li>
        <li><code>pa-list__avatar</code> - Avatar/icon container</li>
        <li><code>pa-list__content</code> - Content wrapper</li>
        <li><code>pa-list__title</code> - Primary text</li>
        <li><code>pa-list__subtitle</code> - Secondary text</li>
        <li><code>pa-list__meta</code> - Metadata text</li>
      </.basic_list>
    </.card>
    """
  end
end
