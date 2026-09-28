defmodule DemoWeb.Live.BadgesLive do
  use DemoWeb, :live_view

  @project_tags [
    %{label: "React", variant: "primary"},
    %{label: "TypeScript", variant: "info"},
    %{label: "Node.js", variant: "success"},
    %{label: "Express", variant: "warning"},
    %{label: "PostgreSQL", variant: "secondary"},
    %{label: "Redux", variant: "primary"},
    %{label: "Sass", variant: "info"},
    %{label: "Docker", variant: "success"},
    %{label: "AWS", variant: "warning"},
    %{label: "Redis", variant: "danger"},
    %{label: "GraphQL", variant: "secondary"},
    %{label: "Jest", variant: "primary"},
    %{label: "Webpack", variant: "info"},
    %{label: "ESLint", variant: "success"},
    %{label: "GitHub Actions", variant: "dark"}
  ]

  @user_skills [
    %{label: "JavaScript", variant: "primary"},
    %{label: "Python", variant: "info"},
    %{label: "Java", variant: "success"},
    %{label: "C++", variant: "warning"},
    %{label: "Ruby", variant: "secondary"},
    %{label: "Go", variant: "primary"},
    %{label: "Rust", variant: "info"}
  ]

  @status_badges [
    %{label: "Approved", variant: "success"},
    %{label: "Pending", variant: "warning"},
    %{label: "Rejected", variant: "danger"},
    %{label: "Review", variant: "info"},
    %{label: "Draft", variant: "secondary"},
    %{label: "Published", variant: "primary"},
    %{label: "Archived", variant: "light"},
    %{label: "Deleted", variant: "dark"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Badges",
      project_tags: @project_tags,
      project_tags_expanded: false,
      user_skills: @user_skills,
      status_badges: @status_badges
    )}
  end

  def handle_event("expand_project_tags", _params, socket) do
    {:noreply, assign(socket, project_tags_expanded: !socket.assigns.project_tags_expanded)}
  end

  def handle_event("badge_label_click", %{"label" => label}, socket) do
    {:noreply, put_flash(socket, :info, "Viewing details for: #{label}")}
  end

  def handle_event("badge_button_click", %{"label" => label, "action" => action}, socket) do
    {:noreply, put_flash(socket, :info, "Action '#{action}' on: #{label}")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Badges, labels, and composite badges for status display and categorization.</.paragraph>

    <%!-- Badge Sizes Reference --%>
    <.card title_text={gettext("Badge Sizes Reference")} has_padding={false}>
      <.table rows={[
        %{size: "XS", class: ".pa-badge--xs", font: "1rem (10px)", padding: "0.2rem 0.4rem", example_size: "xs", example_text: "Extra Small"},
        %{size: "SM", class: ".pa-badge--sm", font: "1.2rem (12px)", padding: "0.25rem 0.5rem", example_size: "sm", example_text: "Small Badge"},
        %{size: "Default", class: ".pa-badge", font: "1.2rem (12px)", padding: "0.4rem 0.8rem", example_size: nil, example_text: "Default Badge"},
        %{size: "LG", class: ".pa-badge--lg", font: "1.4rem (14px)", padding: "0.5rem 1rem", example_size: "lg", example_text: "Large Badge"},
        %{size: "XL", class: ".pa-badge--xl", font: "1.6rem (16px)", padding: "0.6rem 1.2rem", example_size: "xl", example_text: "Extra Large"}
      ]} is_striped>
        <:col :let={row} label={gettext("Size")}><strong>{row.size}</strong></:col>
        <:col :let={row} label={gettext("Class")}><code>{row.class}</code></:col>
        <:col :let={row} label={gettext("Font Size")}>{row.font}</:col>
        <:col :let={row} label={gettext("Padding")}>{row.padding}</:col>
        <:col :let={row} label={gettext("Example")}><.badge size={row.example_size} variant="primary">{row.example_text}</.badge></:col>
      </.table>
    </.card>

    <%!-- Basic Badges --%>
    <.card title_text={gettext("Basic Badges")}>
      <:description>Simple badges for status indication and categorization</:description>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Default Badges")}</.heading>
          <div class="component-showcase">
            <.badge>Default</.badge>
            <.badge variant="primary">Primary</.badge>
            <.badge variant="secondary">Secondary</.badge>
            <.badge variant="success">Success</.badge>
            <.badge variant="warning">Warning</.badge>
            <.badge variant="danger">Danger</.badge>
            <.badge variant="info">Info</.badge>
            <.badge variant="light">Light</.badge>
            <.badge variant="dark">Dark</.badge>
          </div>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Small Badges")}</.heading>
          <div class="component-showcase">
            <.badge size="sm">Default</.badge>
            <.badge size="sm" variant="primary">Primary</.badge>
            <.badge size="sm" variant="secondary">Secondary</.badge>
            <.badge size="sm" variant="success">Success</.badge>
            <.badge size="sm" variant="warning">Warning</.badge>
            <.badge size="sm" variant="danger">Danger</.badge>
            <.badge size="sm" variant="info">Info</.badge>
            <.badge size="sm" variant="light">Light</.badge>
            <.badge size="sm" variant="dark">Dark</.badge>
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- Pill Badges --%>
    <.card title_text={gettext("Pill Badges")}>
      <:description>Rounded badges for a softer, modern appearance</:description>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Regular Pills")}</.heading>
          <div class="component-showcase">
            <.badge is_pill>Default</.badge>
            <.badge is_pill variant="primary">Primary</.badge>
            <.badge is_pill variant="secondary">Secondary</.badge>
            <.badge is_pill variant="success">Success</.badge>
            <.badge is_pill variant="warning">Warning</.badge>
            <.badge is_pill variant="danger">Danger</.badge>
            <.badge is_pill variant="info">Info</.badge>
          </div>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Small Pills")}</.heading>
          <div class="component-showcase">
            <.badge is_pill size="sm">Default</.badge>
            <.badge is_pill size="sm" variant="primary">Primary</.badge>
            <.badge is_pill size="sm" variant="secondary">Secondary</.badge>
            <.badge is_pill size="sm" variant="success">Success</.badge>
            <.badge is_pill size="sm" variant="warning">Warning</.badge>
            <.badge is_pill size="sm" variant="danger">Danger</.badge>
            <.badge is_pill size="sm" variant="info">Info</.badge>
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- Badges with Icons --%>
    <.card title_text={gettext("Badges with Icons")}>
      <:description>Enhanced badges with icon indicators</:description>
      <div class="component-showcase">
        <.badge variant="primary">
          <:icon>✓</:icon>
          {gettext("Completed")}
        </.badge>
        <.badge variant="warning">
          <:icon>!</:icon>
          {gettext("Warning")}
        </.badge>
        <.badge variant="danger">
          <:icon>✕</:icon>
          {gettext("Error")}
        </.badge>
        <.badge variant="info">
          <:icon>ℹ</:icon>
          {gettext("Info")}
        </.badge>
        <.badge variant="success">
          <:icon>★</:icon>
          {gettext("Featured")}
        </.badge>
        <.badge variant="secondary">
          <:icon>⏱</:icon>
          {gettext("Pending")}
        </.badge>
      </div>
    </.card>

    <%!-- Label Sizes Reference --%>
    <.card title_text={gettext("Label Sizes Reference")} has_padding={false}>
      <.table rows={[
        %{size: "XS", class: ".pa-label--xs", font: "1rem (10px)", padding: "0.2rem 0.4rem", example_size: "sm", example_text: "Extra Small"},
        %{size: "SM", class: ".pa-label--sm", font: "1.2rem (12px)", padding: "0.25rem 0.5rem", example_size: "sm", example_text: "Small Label"},
        %{size: "Default", class: ".pa-label", font: "1.2rem (12px)", padding: "0.4rem 0.8rem", example_size: nil, example_text: "Default Label"},
        %{size: "LG", class: ".pa-label--lg", font: "1.4rem (14px)", padding: "0.5rem 1rem", example_size: "lg", example_text: "Large Label"}
      ]} is_striped>
        <:col :let={row} label={gettext("Size")}><strong>{row.size}</strong></:col>
        <:col :let={row} label={gettext("Class")}><code>{row.class}</code></:col>
        <:col :let={row} label={gettext("Font Size")}>{row.font}</:col>
        <:col :let={row} label={gettext("Padding")}>{row.padding}</:col>
        <:col :let={row} label={gettext("Example")}><.label size={row.example_size} variant="primary">{row.example_text}</.label></:col>
      </.table>
    </.card>

    <%!-- Labels --%>
    <.card title_text={gettext("Labels")}>
      <:description>Text labels for categorization and tagging</:description>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Basic Labels")}</.heading>
          <div class="component-showcase">
            <.label>{gettext("Frontend")}</.label>
            <.label variant="primary">React</.label>
            <.label variant="secondary">TypeScript</.label>
            <.label variant="success">{gettext("Bug Fix")}</.label>
            <.label variant="warning">{gettext("Enhancement")}</.label>
            <.label variant="danger">{gettext("Breaking Change")}</.label>
            <.label variant="info">{gettext("Documentation")}</.label>
          </div>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Outlined Labels")}</.heading>
          <div class="component-showcase">
            <.label is_outline>{gettext("Frontend")}</.label>
            <.label is_outline variant="primary">React</.label>
            <.label is_outline variant="secondary">TypeScript</.label>
            <.label is_outline variant="success">{gettext("Bug Fix")}</.label>
            <.label is_outline variant="warning">{gettext("Enhancement")}</.label>
            <.label is_outline variant="danger">{gettext("Breaking Change")}</.label>
            <.label is_outline variant="info">{gettext("Documentation")}</.label>
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- Badge Groups with Limits --%>
    <.card title_text={gettext("Badge Groups with Limits")}>
      <:description>Display many badges with automatic overflow handling - shows 5 badges and "... N more" indicator</:description>
      <.grid>
        <.column size="100">
          <.heading level={4}>Server-side: Project Tags (15 total, click loads from server)</.heading>
          <% visible_tags = if @project_tags_expanded, do: @project_tags, else: Enum.take(@project_tags, 5) %>
          <.badge_group limit={5} total={length(@project_tags)} is_expanded={@project_tags_expanded} on_toggle="expand_project_tags" class="mb-3">
            <.badge :for={tag <- visible_tags} variant={tag.variant}><%= tag.label %></.badge>
          </.badge_group>

          <.heading level={4}>Client-side: User Skills (7 total, JS toggle, no server round-trip)</.heading>
          <.badge_group limit={5} total={length(@user_skills)} class="mb-3">
            <.badge :for={skill <- @user_skills} is_pill variant={skill.variant}><%= skill.label %></.badge>
          </.badge_group>

          <.heading level={4}>Client-side: Status Badges (8 total, small size)</.heading>
          <.badge_group limit={5} total={length(@status_badges)}>
            <.badge :for={status <- @status_badges} size="sm" variant={status.variant}><%= status.label %></.badge>
          </.badge_group>
        </.column>
      </.grid>

      <.alert variant="info" class="mt-4">
        <small><strong>Two modes:</strong> Set <code>on_toggle="event_name"</code> for server-side loading (fires LiveView event). Omit it for client-side JS toggle (no round-trip). Both support <code>limit</code>, <code>total</code>, and translatable <code>more_text</code>/<code>collapse_text</code>.</small>
      </.alert>

      <.grid class="mt-4">
        <.column size="100" md="1-3">
          <.heading level={4}>{gettext("Narrow Container")}</.heading>
          <.badge_group limit={5} total={length(@project_tags)}>
            <.badge :for={tag <- @project_tags} variant={tag.variant}><%= tag.label %></.badge>
          </.badge_group>
        </.column>
        <.column size="100" md="2-3">
          <.heading level={4}>{gettext("Full Width Comparison")}</.heading>
          <.badge_group limit={5} total={length(@project_tags)}>
            <.badge :for={tag <- @project_tags} variant={tag.variant}><%= tag.label %></.badge>
          </.badge_group>
        </.column>
      </.grid>

      <.grid class="mt-4">
        <.column size="100" md="1-6">
          <.heading level={4}>{gettext("Wrapping Demo (Static)")}</.heading>
          <.badge_group is_show_all>
            <.badge size="sm" variant="primary">React</.badge>
            <.badge size="sm" variant="info">Vue</.badge>
            <.badge size="sm" variant="success">Angular</.badge>
            <.badge size="sm" variant="warning">Svelte</.badge>
            <.badge size="sm" variant="secondary">Solid</.badge>
            <.badge size="sm" variant="primary">TypeScript</.badge>
            <.badge size="sm" variant="info">JavaScript</.badge>
            <.badge size="sm" variant="success">Python</.badge>
            <.badge size="sm" variant="warning">Go</.badge>
            <.badge size="sm" variant="danger">Rust</.badge>
            <.badge size="sm" variant="secondary">Java</.badge>
            <.badge size="sm" variant="primary">C++</.badge>
            <.badge size="sm" variant="info">Elixir</.badge>
          </.badge_group>
        </.column>
        <.column size="100" md="5-6">
          <.heading level={4}>{gettext("Full Width Comparison")}</.heading>
          <.badge_group is_show_all>
            <.badge size="sm" variant="primary">React</.badge>
            <.badge size="sm" variant="info">Vue</.badge>
            <.badge size="sm" variant="success">Angular</.badge>
            <.badge size="sm" variant="warning">Svelte</.badge>
            <.badge size="sm" variant="secondary">Solid</.badge>
            <.badge size="sm" variant="primary">TypeScript</.badge>
            <.badge size="sm" variant="info">JavaScript</.badge>
            <.badge size="sm" variant="success">Python</.badge>
            <.badge size="sm" variant="warning">Go</.badge>
            <.badge size="sm" variant="danger">Rust</.badge>
            <.badge size="sm" variant="secondary">Java</.badge>
            <.badge size="sm" variant="primary">C++</.badge>
            <.badge size="sm" variant="info">Elixir</.badge>
          </.badge_group>
        </.column>
      </.grid>
    </.card>

    <%!-- Fixed-Width Badges with Ellipsis --%>
    <.card title_text={gettext("Fixed-Width Badges with Ellipsis")}>
      <:description>Badges with constrained width show ellipsis for overflow text. Hover for tooltip with full text.</:description>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Various Fixed Widths")}</.heading>
          <div class="component-showcase">
            <.tooltip text="Short" position="bottom">
              <.badge variant="primary" max_width="5">Short</.badge>
            </.tooltip>
            <.tooltip text="This is medium text" position="bottom">
              <.badge variant="info" max_width="8">This is medium text</.badge>
            </.tooltip>
            <.tooltip text="This is longer text that will be truncated" position="bottom">
              <.badge variant="success" max_width="10">This is longer text that will be truncated</.badge>
            </.tooltip>
            <.tooltip text="Very long badge text that definitely needs ellipsis" position="bottom">
              <.badge variant="warning" max_width="15">Very long badge text that definitely needs ellipsis</.badge>
            </.tooltip>
            <.tooltip text="Super extremely long badge text example" position="bottom">
              <.badge variant="danger" max_width="20">Super extremely long badge text example</.badge>
            </.tooltip>
          </div>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Small Fixed-Width Badges")}</.heading>
          <div class="component-showcase">
            <.tooltip text="OK" position="bottom">
              <.badge size="sm" variant="primary" max_width="4">OK</.badge>
            </.tooltip>
            <.tooltip text="Status" position="bottom">
              <.badge size="sm" variant="info" max_width="6">Status</.badge>
            </.tooltip>
            <.tooltip text="Completed Task" position="bottom">
              <.badge size="sm" variant="success" max_width="8">Completed Task</.badge>
            </.tooltip>
            <.tooltip text="Pending Review Process" position="bottom">
              <.badge size="sm" variant="warning" max_width="10">Pending Review Process</.badge>
            </.tooltip>
            <.tooltip text="Critical Error in Production" position="bottom">
              <.badge size="sm" variant="danger" max_width="15">Critical Error in Production</.badge>
            </.tooltip>
          </div>
        </.column>
      </.grid>

      <.grid class="mt-4">
        <.column size="100">
          <.heading level={4}>Practical Example: Tags with Consistent Width</.heading>
          <div class="component-showcase">
            <.tooltip text="JavaScript" position="bottom">
              <.badge is_pill variant="secondary" max_width="10">JavaScript</.badge>
            </.tooltip>
            <.tooltip text="TypeScript" position="bottom">
              <.badge is_pill variant="secondary" max_width="10">TypeScript</.badge>
            </.tooltip>
            <.tooltip text="React" position="bottom">
              <.badge is_pill variant="secondary" max_width="10">React</.badge>
            </.tooltip>
            <.tooltip text="Node.js" position="bottom">
              <.badge is_pill variant="secondary" max_width="10">Node.js</.badge>
            </.tooltip>
            <.tooltip text="PostgreSQL Database" position="bottom">
              <.badge is_pill variant="secondary" max_width="10">PostgreSQL Database</.badge>
            </.tooltip>
            <.tooltip text="Express.js Framework" position="bottom">
              <.badge is_pill variant="secondary" max_width="10">Express.js Framework</.badge>
            </.tooltip>
          </div>
        </.column>
      </.grid>

      <.grid class="mt-4">
        <.column size="100">
          <.heading level={4}>Start-Side Ellipsis (Path/Hierarchy Display)</.heading>
          <.paragraph class="text-xs mb-2">When the important part is at the end (breadcrumbs, file paths, etc.)</.paragraph>
          <div class="component-showcase">
            <.tooltip text="Settings > User Preferences > Notifications > Email" position="bottom" multiline>
              <.badge variant="secondary" max_width="15" is_ellipsis_start>Settings > User Preferences > Notifications > Email</.badge>
            </.tooltip>
            <.tooltip text="/var/www/html/application/config/database.php" position="bottom" multiline>
              <.badge variant="info" max_width="20" is_ellipsis_start>/var/www/html/application/config/database.php</.badge>
            </.tooltip>
            <.tooltip text="Components > Forms > Inputs > TextArea.svelte" position="bottom" multiline>
              <.badge variant="primary" max_width="15" is_ellipsis_start>Components > Forms > Inputs > TextArea.svelte</.badge>
            </.tooltip>
            <.tooltip text="Europe > Germany > Berlin > Mitte > Alexanderplatz" position="bottom" multiline>
              <.badge variant="warning" max_width="15" is_ellipsis_start>Europe > Germany > Berlin > Mitte > Alexanderplatz</.badge>
            </.tooltip>
          </div>
        </.column>
      </.grid>

      <.alert variant="info" class="mt-3">
        <small><strong>Note:</strong> Use <code>max_width="5"</code> etc. to constrain badge width with truncation. Use <code>is_ellipsis_start</code> to truncate from the start side instead.</small>
      </.alert>
    </.card>

    <%!-- Composite Badges --%>
    <.card title_text={gettext("Composite Badges")}>
      <:description>Three-part badges with separate icon, label, and button sections</:description>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Standard Color Variations")}</.heading>
          <div class="component-showcase">
            <.composite_badge variant="primary" icon="✓" label="Primary" button_text="×" is_interactive />
            <.composite_badge variant="secondary" icon="⚙" label="Secondary" button_text="×" is_interactive />
            <.composite_badge variant="success" icon="★" label="Success" button_text="×" is_interactive />
            <.composite_badge variant="danger" icon="🔥" label="Danger" button_text="×" is_interactive />
            <.composite_badge variant="warning" icon="⚠" label="Warning" button_text="×" is_interactive />
            <.composite_badge variant="info" icon="ℹ" label="Info" button_text="×" is_interactive />
            <.composite_badge variant="light" icon="◇" label="Light" button_text="×" is_interactive />
            <.composite_badge variant="dark" icon="◆" label="Dark" button_text="×" is_interactive />
          </div>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("More Examples")}</.heading>
          <div class="component-showcase">
            <.composite_badge variant="danger" icon="🔥" label="Critical" button_text="×" is_interactive />
            <.composite_badge variant="light" icon="◇" label="Draft" button_text="↗" is_interactive />
            <.composite_badge variant="dark" icon="◆" label="Published" button_text="⚙" is_interactive />
          </div>
        </.column>
      </.grid>

      <.grid class="mt-4">
        <.column size="100">
          <.heading level={4}>{gettext("Advanced: Mixed Section Colors")}</.heading>
          <.paragraph class="text-sm text-secondary mb-3">
            For advanced customization, you can mix individual section colors using separate classes.
          </.paragraph>
          <div class="component-showcase">
            <.composite_badge variant="primary" label_variant="secondary" button_variant="danger" icon="📁" label="Project Alpha" button_text="×" is_interactive />
            <.composite_badge variant="success" label_variant="light" button_variant="warning" icon="🎯" label="Target Met" button_text="⋯" is_interactive />
            <.composite_badge variant="dark" label_variant="primary" button_variant="info" icon="⚡" label="High Performance" button_text="↑" is_interactive />
            <.composite_badge variant="secondary" label_variant="warning" button_variant="success" icon="🔧" label="Maintenance" button_text="✓" is_interactive />
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- Interactive Composite Badges --%>
    <.card title_text={gettext("Interactive Composite Badges")}>
      <:description>Examples with click handlers and dynamic behavior</:description>
      <div class="component-showcase">
        <.composite_badge variant="info" icon="📋" label="Task #1234" button_text="×" is_interactive on_label_click="badge_label_click" on_button_click="badge_button_click" />
        <.composite_badge variant="success" icon="👤" label="John Doe" button_text="✎" is_interactive on_label_click="badge_label_click" on_button_click="badge_button_click" />
        <.composite_badge variant="warning" icon="🏷️" label="v2.1.0" button_text="↓" is_interactive on_label_click="badge_label_click" on_button_click="badge_button_click" />
      </div>

      <.alert variant="primary" class="mt-4">
        <small><strong>Try it:</strong> Click label text to see details flash, click the button (×, ✎, ↓) for action flash. Uses <code>on_label_click</code> and <code>on_button_click</code> attrs with separate LiveView events.</small>
      </.alert>
    </.card>

    <%!-- Usage Examples --%>
    <.card title_text={gettext("Usage Examples")}>
      <:description>Real-world examples of badges and labels in context</:description>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("User Status")}</.heading>
          <div class="usage-example">
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
              <span>John Doe</span>
              <.badge size="sm" variant="success">{gettext("Online")}</.badge>
            </div>
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
              <span>Jane Smith</span>
              <.badge size="sm" variant="warning">{gettext("Away")}</.badge>
            </div>
            <div style="display: flex; align-items: center; gap: 8px;">
              <span>Mike Johnson</span>
              <.badge size="sm" variant="secondary">{gettext("Offline")}</.badge>
            </div>
          </div>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Project Tags")}</.heading>
          <div class="usage-example">
            <div style="margin-bottom: 12px;">
              <.heading level={5}>{gettext("Website Redesign")}</.heading>
              <div style="display: flex; gap: 4px; flex-wrap: wrap; margin-top: 4px;">
                <.label size="sm" variant="primary">{gettext("Frontend")}</.label>
                <.label size="sm" variant="info">{gettext("Design")}</.label>
                <.label size="sm" variant="warning">{gettext("High Priority")}</.label>
              </div>
            </div>
            <div>
              <.heading level={5}>{gettext("API Integration")}</.heading>
              <div style="display: flex; gap: 4px; flex-wrap: wrap; margin-top: 4px;">
                <.label size="sm" variant="secondary">{gettext("Backend")}</.label>
                <.label size="sm" variant="success">REST API</.label>
                <.label size="sm" variant="danger">{gettext("Critical")}</.label>
              </div>
            </div>
          </div>
        </.column>
      </.grid>
    </.card>
    """
  end
end
