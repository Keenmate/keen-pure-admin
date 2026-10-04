defmodule DemoWeb.Live.ModalsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Modals")}
  end

  def render(assigns) do
    ~H"""
    <%!-- Basic Modals --%>
    <.card title_text={gettext("Basic Modals")} subtitle_text={gettext("Standard modal dialogs for user interactions")}>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Standard Sizes")}</.heading>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <.button variant="primary" phx-click={show_modal("modal-sm")}>{gettext("Small Modal")}</.button>
            <.button variant="primary" phx-click={show_modal("modal-md")}>{gettext("Medium Modal")}</.button>
            <.button variant="primary" phx-click={show_modal("modal-lg")}>{gettext("Large Modal")}</.button>
            <.button variant="primary" phx-click={show_modal("modal-xl")}>{gettext("XL Modal")}</.button>
            <.button variant="primary" phx-click={show_modal("modal-xxl")}>{gettext("XXL Modal")}</.button>
            <.button variant="dark" phx-click={show_modal("modal-fw")}>{gettext("Full Width")}</.button>
          </div>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Modal Types")}</.heading>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <.button variant="success" phx-click={show_modal("modal-success")}>{gettext("Success Modal")}</.button>
            <.button variant="warning" phx-click={show_modal("modal-warning")}>{gettext("Warning Modal")}</.button>
            <.button variant="danger" phx-click={show_modal("modal-danger")}>{gettext("Danger Modal")}</.button>
          </div>
        </.column>
      </.grid>

      <.grid class="mt-4">
        <.column size="100">
          <.heading level={4}>Banded Modals · v2.7.0</.heading>
          <.paragraph color="secondary" class="mb-2">
            <code>is_banded</code> emits <code>pa-modal--banded</code> alongside the role variant. Both header AND footer get filled bands using the alert tokens (15% role-mix in light mode, 45% in dark). Buttons inside the bands auto-invert via <code>--pc-text-color-1</code> for cross-theme contrast.
          </.paragraph>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <.button variant="success" phx-click={show_modal("modal-banded-success")}>{gettext("Banded Success")}</.button>
            <.button variant="warning" phx-click={show_modal("modal-banded-warning")}>{gettext("Banded Warning")}</.button>
            <.button variant="danger" phx-click={show_modal("modal-banded-danger")}>{gettext("Banded Danger")}</.button>
            <.button variant="info" phx-click={show_modal("modal-banded-info")}>{gettext("Banded Info")}</.button>
          </div>
        </.column>
      </.grid>
      <.grid class="mt-4">
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Position Modifiers")}</.heading>
          <div style="display: flex; gap: 8px;">
            <.button variant="secondary" phx-click={show_modal("modal-centered")}>
              {gettext("Centered (Default)")}
            </.button>
            <.button variant="secondary" phx-click={show_modal("modal-top")}>{gettext("Top-Aligned")}</.button>
          </div>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={4}>{gettext("Behavior Modifiers")}</.heading>
          <div style="display: flex; gap: 8px;">
            <.button variant="warning" phx-click={show_modal("modal-static")}>{gettext("Static Modal")}</.button>
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- Form Modals --%>
    <.card title_text={gettext("Form Modals")} subtitle_text={gettext("Modals containing forms and interactive content")}>
      <div style="display: flex; gap: 8px; flex-wrap: wrap;">
        <.button variant="secondary" phx-click={show_modal("modal-contact")}>{gettext("Contact Form")}</.button>
        <.button variant="info" phx-click={show_modal("modal-login")}>{gettext("Login Form")}</.button>
        <.button variant="dark" phx-click={show_modal("modal-settings")}>{gettext("Settings Modal")}</.button>
      </div>
    </.card>

    <%!-- Confirmation Modals --%>
    <.card title_text={gettext("Confirmation Modals")} subtitle_text={gettext("Action confirmation and decision dialogs")}>
      <div style="display: flex; gap: 8px; flex-wrap: wrap;">
        <.button variant="danger" is_outline phx-click={show_modal("modal-delete")}>
          {gettext("Delete Confirmation")}
        </.button>
        <.button variant="warning" is_outline phx-click={show_modal("modal-confirm")}>
          {gettext("Action Confirmation")}
        </.button>
        <.button variant="info" is_outline phx-click={show_modal("modal-info")}>
          {gettext("Information Dialog")}
        </.button>
      </div>
    </.card>

    <%!-- Modal Definitions --%>

    <%!-- Size Modals --%>
    <.modal id="modal-sm" size="sm" title_text={gettext("Small Modal")}>
      <p>This is a small modal dialog. Perfect for quick notifications or simple confirmations.</p>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-sm")}>{gettext("Close")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-sm")}>{gettext("Save")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-md" title_text={gettext("Medium Modal")}>
      <p>This is a medium-sized modal dialog. Great for forms and detailed content.</p>
      <p>You can include multiple paragraphs, lists, and other content here.</p>
      <ul>
        <li>Feature 1</li>
        <li>Feature 2</li>
        <li>Feature 3</li>
      </ul>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-md")}>{gettext("Cancel")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-md")}>{gettext("Continue")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-lg" size="lg" title_text={gettext("Large Modal")}>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={5}>Column 1</.heading>
          <p>Large modals are perfect for complex content layouts with multiple columns.</p>
          <p>You can use the PureCSS grid system inside modals to create sophisticated layouts.</p>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={5}>Column 2</.heading>
          <p>This second column demonstrates how you can organize content in larger modal dialogs.</p>
          <.alert variant="info">
            <strong>Tip:</strong> Large modals work great for dashboards and detailed forms.
          </.alert>
        </.column>
      </.grid>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-lg")}>{gettext("Cancel")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-lg")}>{gettext("Save Changes")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-xl" size="xl" title_text={gettext("Extra Large Modal")}>
      <.grid>
        <.column size="100" md="1-3">
          <.heading level={5}>Column 1</.heading>
          <p>Extra large modals provide ample space for comprehensive content displays.</p>
          <p>Perfect for data tables, reports, and detailed analytics dashboards.</p>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={5}>Column 2</.heading>
          <p>You can display complex data structures, charts, and visualizations.</p>
          <.alert variant="info">
            <strong>Note:</strong> XL modals are 70rem wide (1120px).
          </.alert>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={5}>Column 3</.heading>
          <p>Three-column layouts work beautifully in extra large modals.</p>
          <p>Ideal for comparison views and side-by-side content.</p>
        </.column>
      </.grid>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-xl")}>{gettext("Close")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-xl")}>{gettext("Apply Changes")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-xxl" size="xxl" title_text={gettext("XXL Modal - Maximum Size")}>
      <.grid>
        <.column size="100" md="25">
          <.heading level={5}>Section 1</.heading>
          <p>XXL modals are the largest available size at 90rem (1440px) wide.</p>
          <p>Perfect for full-featured application interfaces within a modal.</p>
        </.column>
        <.column size="100" md="25">
          <.heading level={5}>Section 2</.heading>
          <p>Ideal for complex workflows that require maximum screen real estate.</p>
          <.alert variant="success">
            <strong>Great for:</strong> Data grids, reporting tools, and analytics.
          </.alert>
        </.column>
        <.column size="100" md="25">
          <.heading level={5}>Section 3</.heading>
          <p>Four-column layouts provide exceptional flexibility for content organization.</p>
          <ul>
            <li>Dashboard views</li>
            <li>Complex forms</li>
            <li>Data comparisons</li>
          </ul>
        </.column>
        <.column size="100" md="25">
          <.heading level={5}>Section 4</.heading>
          <p>On smaller screens, these columns will stack responsively.</p>
          <.alert variant="warning">
            <strong>Note:</strong> Consider viewport size when using XXL modals.
          </.alert>
        </.column>
      </.grid>
      <.grid class="mt-4">
        <.column size="100">
          <.heading level={5}>Full Width Content Area</.heading>
          <p>You can also use the full width for single-column content when needed. This is particularly useful for wide tables, code editors, or visual design tools.</p>
          <.card class="mt-3">
            <p>Nested cards and components work seamlessly within XXL modals, allowing you to create rich, interactive interfaces.</p>
          </.card>
        </.column>
      </.grid>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-xxl")}>{gettext("Close")}</.button>
        <.button variant="info" phx-click={hide_modal("modal-xxl")}>{gettext("Export")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-xxl")}>{gettext("Save All Changes")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-fw" size="fw" title_text={gettext("Full Width Modal - Maximum Screen Coverage")}>
      <.grid>
        <.column size="100">
          <.alert variant="info" class="mb-4">
            <strong>Full Width Mode:</strong> This modal takes up the entire viewport minus a small margin (1rem on all sides), providing maximum workspace while maintaining modal appearance.
          </.alert>
        </.column>
      </.grid>
      <.grid>
        <.column size="100" lg="20">
          <.card title_text={gettext("Navigation")}>
            <ul style="list-style: none; padding: 0;">
              <li style="padding: 0.5rem 0;">Dashboard</li>
              <li style="padding: 0.5rem 0;">Analytics</li>
              <li style="padding: 0.5rem 0;">Reports</li>
              <li style="padding: 0.5rem 0;">Settings</li>
            </ul>
          </.card>
        </.column>
        <.column size="100" lg="60">
          <.card title_text={gettext("Main Content Area")}>
            <p>Full-width modals are perfect for complex applications that need to run within a modal context. Examples include:</p>
            <ul>
              <li><strong>Code Editors:</strong> Full IDE-like experiences</li>
              <li><strong>Design Tools:</strong> Canvas-based applications</li>
              <li><strong>Data Analysis:</strong> Large spreadsheets or pivot tables</li>
              <li><strong>Media Galleries:</strong> Full-screen photo/video management</li>
              <li><strong>Document Viewers:</strong> PDF readers, document editors</li>
            </ul>
          </.card>
        </.column>
        <.column size="100" lg="20">
          <.card title_text={gettext("Properties")}>
            <.form_group label={gettext("Width")}>
              <.input type="text" value="100vw - 2rem" readonly />
            </.form_group>
            <.form_group label={gettext("Height")}>
              <.input type="text" value="100vh - 2rem" readonly />
            </.form_group>
            <.form_group label={gettext("Margin")}>
              <.input type="text" value="1rem" readonly />
            </.form_group>
          </.card>
        </.column>
      </.grid>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-fw")}>{gettext("Close")}</.button>
        <.button variant="success" phx-click={hide_modal("modal-fw")}>{gettext("Save")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-fw")}>{gettext("Apply")}</.button>
      </:footer>
    </.modal>

    <%!-- Type Modals --%>
    <.modal id="modal-success" variant="success" title_text={gettext("✓ Success!")}>
      <p>Your action has been completed successfully!</p>
      <.alert variant="success">
        Operation completed without any errors.
      </.alert>
      <:footer>
        <.button variant="success" phx-click={hide_modal("modal-success")}>{gettext("Great!")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-warning" variant="warning" title_text={gettext("⚠ Warning")}>
      <p>Please review your action before proceeding.</p>
      <.alert variant="warning">
        This action may have consequences that cannot be undone.
      </.alert>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-warning")}>{gettext("Cancel")}</.button>
        <.button variant="warning" phx-click={hide_modal("modal-warning")}>{gettext("Proceed")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-danger" variant="danger" title_text={gettext("🔥 Danger Zone")}>
      <p>This action is potentially destructive.</p>
      <.alert variant="danger">
        <strong>Warning:</strong> This action cannot be undone and may result in data loss.
      </.alert>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-danger")}>{gettext("Cancel")}</.button>
        <.button variant="danger" phx-click={hide_modal("modal-danger")}>{gettext("Delete Forever")}</.button>
      </:footer>
    </.modal>

    <%!-- Position & Behavior Modals --%>
    <.modal id="modal-centered" title_text={gettext("Centered Modal (Default)")}>
      <p>This is the default modal behavior - centered vertically and horizontally in the viewport.</p>
      <p>This works well for most use cases where you want the modal to be the focal point.</p>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-centered")}>{gettext("Close")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-centered")}>{gettext("Confirm")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-top" is_top title_text={gettext("Top-Aligned Modal")}>
      <p>This modal uses the <code>pa-modal--top</code> modifier to position it near the top of the viewport.</p>
      <p>This is useful for:</p>
      <ul>
        <li>Search interfaces (similar to command palette)</li>
        <li>Quick actions that don't need full attention</li>
        <li>Modals that might contain tall content</li>
        <li>Better visual flow when content extends below fold</li>
      </ul>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-top")}>{gettext("Close")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-top")}>{gettext("Confirm")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-static" is_static variant="warning" title_text={gettext("Static Modal")}>
      <p>This modal <strong>cannot</strong> be closed by:</p>
      <ul>
        <li>Pressing the <kbd>Escape</kbd> key</li>
        <li>Clicking the backdrop</li>
      </ul>
      <.callout variant="warning">
        <strong>Use case:</strong> Critical confirmations, license agreements, or processes that must be completed.
      </.callout>
      <p>You must click a button below to close this modal.</p>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-static")}>{gettext("Cancel")}</.button>
        <.button variant="warning" phx-click={hide_modal("modal-static")}>{gettext("I Understand")}</.button>
      </:footer>
    </.modal>

    <%!-- Form Modals --%>
    <.modal id="modal-contact" title_text={gettext("Contact Us")}>
      <.form_group label={gettext("Name")}>
        <.input type="text" placeholder={gettext("Your name")} />
      </.form_group>
      <.form_group label={gettext("Email")}>
        <.input type="email" placeholder="your@email.com" />
      </.form_group>
      <.form_group label={gettext("Message")}>
        <.textarea placeholder={gettext("Your message...")} rows="4" />
      </.form_group>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-contact")}>{gettext("Cancel")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-contact")}>{gettext("Send Message")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-login" size="sm" title_text={gettext("Sign In")}>
      <.form_group label={gettext("Username")}>
        <.input type="text" placeholder={gettext("Enter username")} />
      </.form_group>
      <.form_group label={gettext("Password")}>
        <.input type="password" placeholder={gettext("Enter password")} />
      </.form_group>
      <.checkbox label={gettext("Remember me")} />
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-login")}>{gettext("Cancel")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-login")}>{gettext("Sign In")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-settings" size="lg" title_text={gettext("Settings")}>
      <.grid>
        <.column size="100" md="1-2">
          <.heading level={5}>{gettext("General Settings")}</.heading>
          <.form_group label={gettext("Theme")}>
            <.select options={["Default", "Dark", "Audi"]} />
          </.form_group>
          <.form_group>
            <.checkbox label={gettext("Enable notifications")} checked />
          </.form_group>
        </.column>
        <.column size="100" md="1-2">
          <.heading level={5}>{gettext("Privacy Settings")}</.heading>
          <.form_group>
            <.checkbox label={gettext("Share analytics data")} />
          </.form_group>
          <.form_group>
            <.checkbox label={gettext("Email updates")} checked />
          </.form_group>
        </.column>
      </.grid>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-settings")}>{gettext("Cancel")}</.button>
        <.button variant="primary" phx-click={hide_modal("modal-settings")}>{gettext("Save Settings")}</.button>
      </:footer>
    </.modal>

    <%!-- Confirmation Modals --%>
    <.modal id="modal-delete" size="sm" variant="danger" title_text={gettext("Confirm Delete")}>
      <p>Are you sure you want to delete this item?</p>
      <.alert variant="danger">
        <strong>This action cannot be undone.</strong>
      </.alert>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-delete")}>{gettext("Cancel")}</.button>
        <.button variant="danger" phx-click={hide_modal("modal-delete")}>{gettext("Delete")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-confirm" size="sm" title_text={gettext("Confirm Action")}>
      <p>Do you want to proceed with this action?</p>
      <p>This will update your preferences and may affect other users.</p>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-confirm")}>{gettext("Cancel")}</.button>
        <.button variant="warning" phx-click={hide_modal("modal-confirm")}>{gettext("Confirm")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-info" variant="info" title_text={gettext("Information")}>
      <p>Here's some important information you should know:</p>
      <.alert variant="info">
        Your subscription will expire in 7 days. Consider renewing to continue enjoying all features.
      </.alert>
      <ul>
        <li>Feature access will be limited after expiration</li>
        <li>Your data will remain safe for 30 days</li>
        <li>You can renew at any time</li>
      </ul>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-info")}>{gettext("Later")}</.button>
        <.button variant="info" phx-click={hide_modal("modal-info")}>{gettext("Renew Now")}</.button>
      </:footer>
    </.modal>

    <%!-- Banded modals · v2.7.0 --%>

    <.modal id="modal-banded-success" variant="success" is_banded title_text={gettext("✓ Backup completed")}>
      <p>All 2.4 GB of data has been backed up successfully. The archive is available in your cloud storage.</p>
      <p>Buttons inside the header and footer auto-invert (<code>--pc-text-color-1</code>) for cross-theme contrast — light theme renders dark-on-pale, dark theme renders light-on-muted.</p>
      <:footer>
        <.button variant="success" phx-click={hide_modal("modal-banded-success")}>{gettext("Got it")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-banded-warning" variant="warning" is_banded title_text={gettext("⚠ Storage almost full")}>
      <p>You're using 92% of your 100 GB quota. Consider upgrading or archiving older files.</p>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-banded-warning")}>{gettext("Later")}</.button>
        <.button variant="warning" phx-click={hide_modal("modal-banded-warning")}>{gettext("Upgrade")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-banded-danger" variant="danger" is_banded title_text={gettext("🔥 Permanent deletion")}>
      <p>This will permanently delete <strong>14 projects and 1,283 files</strong>. The action cannot be undone.</p>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-banded-danger")}>{gettext("Cancel")}</.button>
        <.button variant="danger" phx-click={hide_modal("modal-banded-danger")}>{gettext("Delete forever")}</.button>
      </:footer>
    </.modal>

    <.modal id="modal-banded-info" variant="info" is_banded title_text={gettext("New feature available")}>
      <p>Banded modals shipped in pure-admin v2.7.0. Combine the existing role variant with <code>is_banded</code> and both header + footer get filled bands using the alert tokens.</p>
      <:footer>
        <.button variant="secondary" phx-click={hide_modal("modal-banded-info")}>{gettext("Dismiss")}</.button>
        <.button variant="info" phx-click={hide_modal("modal-banded-info")}>{gettext("Try it")}</.button>
      </:footer>
    </.modal>
    """
  end
end
