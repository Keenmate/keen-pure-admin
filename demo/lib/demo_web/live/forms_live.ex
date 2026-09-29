defmodule DemoWeb.Live.FormsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Forms")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Complete set of form elements with various styles and states for data input.</.paragraph>

    <%!-- Input Sizes Reference — heights are measured client-side (MeasureFormSizes hook) --%>
    <.table_card title_text={gettext("Input Sizes Reference")} is_scrollable>
      <table id="sizesTable" class="pa-table pa-table--striped" phx-hook="MeasureFormSizes">
        <thead>
          <tr>
            <th>{gettext("Size")}</th>
            <th>{gettext("Class")}</th>
            <th>{gettext("Font Size")}</th>
            <th>{gettext("Padding (v/h)")}</th>
            <th>{gettext("Input + Button")}</th>
            <th>{gettext("Input Height")}</th>
            <th>{gettext("Button Height")}</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={row <- size_rows()}>
            <td><strong><%= row.size %></strong></td>
            <td><code><%= row.class %></code></td>
            <td><%= row.font %></td>
            <td><%= row.padding %></td>
            <td>
              <div class="d-flex align-items-center gap-sm">
                <.input type="text" size={row.mod} placeholder={row.placeholder} style="width: 120px;" data-measure="input" />
                <.button variant="primary" size={row.mod} data-measure="button">{gettext("Submit")}</.button>
              </div>
            </td>
            <td class="height-input">-</td>
            <td class="height-button">-</td>
          </tr>
        </tbody>
      </table>
    </.table_card>

    <%!-- Form with Buttons in Header --%>
    <.card title_text={gettext("User Profile")}>
      <:tools>
        <.button variant="secondary" size="sm"><:icon>×</:icon>{gettext("Cancel")}</.button>
        <.button type="submit" variant="success" size="sm"><:icon>✓</:icon>{gettext("Save")}</.button>
      </:tools>
      <form class="pa-form">
        <.grid>
          <.column size="100" md="50">
            <.form_group>
              <.form_label for="text-input">{gettext("Text Input")}</.form_label>
              <.input type="text" id="text-input" placeholder={gettext("Enter text")} required />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group>
              <.form_label for="email-input">{gettext("Email Input")}</.form_label>
              <.input type="email" id="email-input" placeholder="user@example.com" required />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group>
              <.form_label for="password-input">{gettext("Password Input")}</.form_label>
              <.input type="password" id="password-input" placeholder={gettext("Enter password")} />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group>
              <.form_label for="number-input">{gettext("Number Input")}</.form_label>
              <.input type="number" id="number-input" placeholder="0" />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group>
              <.form_label for="basic-select">{gettext("Select Dropdown")}</.form_label>
              <.select id="basic-select" prompt={gettext("Choose an option...")} options={["Option 1", "Option 2", "Option 3"]} required />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group>
              <.form_label for="date-input">{gettext("Date Input")}</.form_label>
              <.input type="date" id="date-input" />
            </.form_group>
          </.column>
          <.column size="100">
            <.form_group>
              <.form_label for="textarea">{gettext("Textarea (Full Width)")}</.form_label>
              <.textarea id="textarea" placeholder={gettext("Enter your message here...")} required />
            </.form_group>
          </.column>
        </.grid>
      </form>
    </.card>

    <%!-- Form with Buttons in Footer --%>
    <.card title_text={gettext("Contact Information")}>
      <form class="pa-form">
        <.grid>
          <.column size="100" md="50">
            <.form_group>
              <.form_label for="fname2">{gettext("First Name")}</.form_label>
              <.input type="text" id="fname2" placeholder="John" />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group>
              <.form_label for="lname2">{gettext("Last Name")}</.form_label>
              <.input type="text" id="lname2" placeholder="Doe" />
            </.form_group>
          </.column>
          <.column size="100">
            <.form_group>
              <.form_label for="address">{gettext("Address")}</.form_label>
              <.input type="text" id="address" placeholder="123 Main St" />
            </.form_group>
          </.column>
        </.grid>
      </form>
      <:footer>
        <.button variant="secondary"><:icon>←</:icon>{gettext("Back")}</.button>
        <.button variant="light"><:icon>🗑</:icon>{gettext("Delete")}</.button>
        <div class="ml-auto d-flex gap-5">
          <.button variant="secondary">{gettext("Cancel")}</.button>
          <.button type="submit" variant="success"><:icon>✓</:icon>{gettext("Save Changes")}</.button>
        </div>
      </:footer>
    </.card>

    <%!-- Form with Buttons in Body --%>
    <.card title_text={gettext("Quick Settings")}>
      <form class="pa-form">
        <.form_group>
          <.form_label for="setting1">{gettext("Setting Name")}</.form_label>
          <.input type="text" id="setting1" placeholder={gettext("Enter value")} />
        </.form_group>
        <.form_group>
          <.form_label for="setting2">{gettext("Notification Preference")}</.form_label>
          <.select id="setting2" options={[gettext("All notifications"), gettext("Important only"), gettext("None")]} />
        </.form_group>
        <.button_group>
          <.button variant="secondary">{gettext("Cancel")}</.button>
          <.button variant="primary"><:icon>📄</:icon>{gettext("Preview")}</.button>
          <.button type="submit" variant="success"><:icon>✓</:icon>{gettext("Apply")}</.button>
        </.button_group>
      </form>
    </.card>

    <%!-- Three Column Compact Form --%>
    <.card title_text={gettext("Compact Three Column Layout")}>
      <form class="pa-form">
        <.grid>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label for="fname">{gettext("First Name")}</.form_label>
              <.input type="text" id="fname" placeholder="John" />
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label for="lname">{gettext("Last Name")}</.form_label>
              <.input type="text" id="lname" placeholder="Doe" />
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label for="email3">{gettext("Email")}</.form_label>
              <.input type="email" id="email3" placeholder="john@example.com" />
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label for="phone">{gettext("Phone")}</.form_label>
              <.input type="tel" id="phone" placeholder="+1 234 567 8900" />
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label for="country">{gettext("Country")}</.form_label>
              <.select id="country" options={["United States", "Canada", "United Kingdom"]} />
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label for="zip">{gettext("ZIP Code")}</.form_label>
              <.input type="text" id="zip" placeholder="12345" />
            </.form_group>
          </.column>
        </.grid>
      </form>
    </.card>

    <%!-- Input Groups with Icons --%>
    <.card title_text={gettext("Input Groups")}>
      <form class="pa-form">
        <.grid>
          <.column size="100" md="50">
            <.form_group>
              <.form_label for="prepend-input">{gettext("Input with Prepended Text")}</.form_label>
              <.input_group>
                <:prepend>@</:prepend>
                <.input type="text" id="prepend-input" placeholder="username" />
              </.input_group>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label for="append-input">{gettext("Input with Appended Text")}</.form_label>
              <.input_group>
                <.input type="text" id="append-input" placeholder="0.00" />
                <:append>USD</:append>
              </.input_group>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label for="both-input">{gettext("Input with Both Prepend and Append")}</.form_label>
              <.input_group>
                <:prepend>$</:prepend>
                <.input type="text" id="both-input" placeholder="0.00" />
                <:append>.00</:append>
              </.input_group>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label for="button-append">{gettext("Input with Button")}</.form_label>
              <.input_group>
                <.input type="text" id="button-append" placeholder={gettext("Search...")} />
                <:button>
                  <.button variant="primary" class="pa-input-group__button">{gettext("Search")}</.button>
                </:button>
              </.input_group>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label for="prepend-button">{gettext("Prepend + Input + Button")}</.form_label>
              <.input_group>
                <:prepend>🔍</:prepend>
                <.input type="text" id="prepend-button" placeholder={gettext("Search...")} />
                <:button>
                  <.button variant="primary" class="pa-input-group__button">{gettext("Go")}</.button>
                </:button>
              </.input_group>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label for="append-button">{gettext("Input + Append + Button")}</.form_label>
              <.input_group>
                <.input type="text" id="append-button" placeholder={gettext("Enter amount")} />
                <:append>USD</:append>
                <:button>
                  <.button variant="success" class="pa-input-group__button">{gettext("Convert")}</.button>
                </:button>
              </.input_group>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label for="button-append-input">{gettext("Button + Input + Append")}</.form_label>
              <div class="pa-input-group">
                <.button variant="secondary" class="pa-input-group__button">-</.button>
                <.input type="number" id="button-append-input" value="1" />
                <span class="pa-input-group__append">{gettext("items")}</span>
              </div>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label for="full-group">{gettext("Prepend + Input + Append + Button")}</.form_label>
              <.input_group>
                <:prepend>https://</:prepend>
                <.input type="text" id="full-group" placeholder="example.com" />
                <:append>.com</:append>
                <:button>
                  <.button variant="primary" class="pa-input-group__button">{gettext("Visit")}</.button>
                </:button>
              </.input_group>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label for="quantity-input">{gettext("Button + Input + Button (Quantity)")}</.form_label>
              <div class="pa-input-group">
                <.button variant="secondary" class="pa-input-group__button">-</.button>
                <.input type="number" id="quantity-input" value="1" style="text-align: center;" />
                <.button variant="secondary" class="pa-input-group__button">+</.button>
              </div>
            </.form_group>
          </.column>
        </.grid>
      </form>
    </.card>

    <%!-- Form States --%>
    <.card title_text={gettext("Form States")}>
      <form class="pa-form">
        <.grid>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label for="disabled-input">{gettext("Disabled Input")}</.form_label>
              <.input type="text" id="disabled-input" placeholder={gettext("Disabled")} disabled />
            </.form_group>
          </.column>

          <.column size="100" md="1-3">
            <.form_group>
              <.form_label for="readonly-input">{gettext("Readonly Input")}</.form_label>
              <.input type="text" id="readonly-input" value={gettext("Read only value")} readonly />
            </.form_group>
          </.column>

          <.column size="100" md="1-3">
            <.form_group>
              <.form_label for="help-input">{gettext("Input with Help Text")}</.form_label>
              <.input type="text" id="help-input" placeholder={gettext("Username")} />
              <.form_help>{gettext("Must be 3-20 characters long")}</.form_help>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group validation="error">
              <.form_label for="error-input">{gettext("Input with Error")}</.form_label>
              <.input type="text" id="error-input" is_error placeholder={gettext("Invalid input")} />
              <.form_help variant="error">{gettext("This field is required")}</.form_help>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group validation="success">
              <.form_label for="success-input">{gettext("Input with Success")}</.form_label>
              <.input type="text" id="success-input" is_success value={gettext("Valid input")} />
              <.form_help variant="success">{gettext("Looks good!")}</.form_help>
            </.form_group>
          </.column>
        </.grid>
      </form>
    </.card>

    <%!-- Input Sizes --%>
    <.card title_text={gettext("Input Sizes")}>
      <form class="pa-form">
        <.form_group>
          <.form_label for="xs-input">{gettext("Extra Small Input")}</.form_label>
          <.input type="text" id="xs-input" size="xs" placeholder={gettext("Extra small")} />
        </.form_group>
        <.form_group>
          <.form_label for="sm-input">{gettext("Small Input")}</.form_label>
          <.input type="text" id="sm-input" size="sm" placeholder={gettext("Small")} />
        </.form_group>
        <.form_group>
          <.form_label for="normal-input">{gettext("Normal Input (Default)")}</.form_label>
          <.input type="text" id="normal-input" placeholder={gettext("Normal")} />
        </.form_group>
        <.form_group>
          <.form_label for="lg-input">{gettext("Large Input")}</.form_label>
          <.input type="text" id="lg-input" size="lg" placeholder={gettext("Large")} />
        </.form_group>
        <.form_group>
          <.form_label for="xl-input">{gettext("Extra Large Input")}</.form_label>
          <.input type="text" id="xl-input" size="xl" placeholder={gettext("Extra large")} />
        </.form_group>
      </form>
    </.card>

    <%!-- Checkboxes and Radio Buttons — basics + tri-state --%>
    <.card title_text={gettext("Checkboxes & Radio Buttons")}>
      <form class="pa-form">
        <.form_group>
          <.form_label>{gettext("Checkboxes (Custom Tri-State)")}</.form_label>
          <.checkbox_group>
            <.checkbox checked label={gettext("Option 1 (checked)")} />
            <.checkbox label={gettext("Option 2")} />
            <.checkbox disabled label={gettext("Option 3 (disabled)")} />
          </.checkbox_group>
        </.form_group>

        <.form_group>
          <.form_label>{gettext("Radio Buttons")}</.form_label>
          <.radio_group>
            <.radio name="radio-group" value="a" checked label={gettext("Choice A (selected)")} />
            <.radio name="radio-group" value="b" label={gettext("Choice B")} />
            <.radio name="radio-group" value="c" disabled label={gettext("Choice C (disabled)")} />
          </.radio_group>
        </.form_group>

        <.form_group>
          <.form_label>{gettext("Two-state & Three-state (indeterminate)")}</.form_label>
          <.checkbox_group>
            <%!-- Two-state: a normal checkbox --%>
            <.checkbox checked label={gettext("Two-state (checked / unchecked)")} />
            <%!-- Static indeterminate via the PureAdminCheckbox hook --%>
            <.checkbox is_indeterminate label={gettext("Indeterminate (mixed) — static")} />
            <%!-- Three-state cycler: FormsTristate hook cycles unchecked → checked → indeterminate --%>
            <label class="pa-checkbox" id="tristate-cycler" phx-hook="FormsTristate">
              <input type="checkbox" />
              <span class="pa-checkbox__box"></span>
              <span class="pa-checkbox__label">{gettext("Three-state — click to cycle")}</span>
            </label>
          </.checkbox_group>
        </.form_group>
      </form>
    </.card>

    <%!-- Label position --%>
    <.card title_text={gettext("Label Position")}>
      <:description>One position per group. End/start stack; top reads best in an auto-flow grid.</:description>
      <form class="pa-form">
        <.form_group class="mb-2xl">
          <.form_label>{gettext("Checkbox · label end & start")}</.form_label>
          <.grid>
            <.column size="100" md="1-2">
              <.checkbox_group>
                <.checkbox label_position="end" checked label={gettext("End · Option 1")} />
                <.checkbox label_position="end" label={gettext("End · Option 2")} />
                <.checkbox label_position="end" checked label={gettext("End · Option 3")} />
              </.checkbox_group>
            </.column>
            <.column size="100" md="1-2">
              <.checkbox_group>
                <.checkbox label_position="start" checked label={gettext("Start · Option 1")} />
                <.checkbox label_position="start" label={gettext("Start · Option 2")} />
                <.checkbox label_position="start" checked label={gettext("Start · Option 3")} />
              </.checkbox_group>
            </.column>
          </.grid>
        </.form_group>

        <.form_group class="mb-2xl">
          <.form_label>{gettext("Checkbox · label top (auto-flow grid, 6 options)")}</.form_label>
          <.checkbox_group layout="grid">
            <.checkbox label_position="top" checked label={gettext("Top · Option 1")} />
            <.checkbox label_position="top" label={gettext("Top · Option 2")} />
            <.checkbox label_position="top" checked label={gettext("Top · Option 3")} />
            <.checkbox label_position="top" label={gettext("Top · Option 4")} />
            <.checkbox label_position="top" checked label={gettext("Top · Option 5")} />
            <.checkbox label_position="top" label={gettext("Top · Option 6")} />
          </.checkbox_group>
        </.form_group>

        <.form_group class="mb-2xl">
          <.form_label>{gettext("Radio · label end & start")}</.form_label>
          <.grid>
            <.column size="100" md="1-2">
              <.radio_group>
                <.radio name="rl-end" value="1" label_position="end" checked label={gettext("End · Option 1")} />
                <.radio name="rl-end" value="2" label_position="end" label={gettext("End · Option 2")} />
                <.radio name="rl-end" value="3" label_position="end" label={gettext("End · Option 3")} />
              </.radio_group>
            </.column>
            <.column size="100" md="1-2">
              <.radio_group>
                <.radio name="rl-start" value="1" label_position="start" checked label={gettext("Start · Option 1")} />
                <.radio name="rl-start" value="2" label_position="start" label={gettext("Start · Option 2")} />
                <.radio name="rl-start" value="3" label_position="start" label={gettext("Start · Option 3")} />
              </.radio_group>
            </.column>
          </.grid>
        </.form_group>

        <.form_group>
          <.form_label>{gettext("Radio · label top (auto-flow grid, 6 options)")}</.form_label>
          <.radio_group layout="grid">
            <.radio name="rl-top" value="1" label_position="top" checked label={gettext("Top · Option 1")} />
            <.radio name="rl-top" value="2" label_position="top" label={gettext("Top · Option 2")} />
            <.radio name="rl-top" value="3" label_position="top" label={gettext("Top · Option 3")} />
            <.radio name="rl-top" value="4" label_position="top" label={gettext("Top · Option 4")} />
            <.radio name="rl-top" value="5" label_position="top" label={gettext("Top · Option 5")} />
            <.radio name="rl-top" value="6" label_position="top" label={gettext("Top · Option 6")} />
          </.radio_group>
        </.form_group>
      </form>
    </.card>

    <%!-- Orientation & required --%>
    <.card title_text={gettext("Orientation & Required")}>
      <.callout variant="info">
        <:icon>💡</:icon>
        <:title>{gettext("How the required asterisk is placed")}</:title>
        <p>The danger <strong>*</strong> is driven by the native <code>required</code> attribute — no class needed. Where it lands depends on the field's shape:</p>
        <ul>
          <li><strong>Simple fields</strong> (input / select / textarea) → the group's <code>&lt;label&gt;</code>, via <code>.pa-form-group:has(:required) &gt; label</code>.</li>
          <li><strong>Grouped choices</strong> (radios/checkboxes inside a <code>.pa-radio-group</code> / <code>.pa-checkbox-group</code>) → the requirement belongs to the group, so the <strong>*</strong> sits once on the group <strong>heading</strong> and the per-option markers are suppressed. See <em>Priority</em> below.</li>
          <li><strong>Standalone choice</strong> (a lone <code>.pa-checkbox</code> / <code>.pa-radio</code>, e.g. a consent box with no <code>*-group</code> wrapper) → the <strong>*</strong> sits on its <strong>own</strong> option label. See <em>I accept the terms</em> below.</li>
          <li><strong>Complex widgets</strong> with no native control (image browser, dropzone, web component) → add <code>.pa-form-group--required</code> to the group as the explicit trigger.</li>
        </ul>
        <p class="mb-0">The first “Horizontal orientation” group has no <code>required</code>, so it shows no marker.</p>
      </.callout>
      <form class="pa-form">
        <.form_group>
          <.form_label>{gettext("Horizontal orientation")}</.form_label>
          <.checkbox_group layout="horizontal">
            <.checkbox checked label={gettext("Red")} />
            <.checkbox label={gettext("Green")} />
            <.checkbox label={gettext("Blue")} />
          </.checkbox_group>
          <.radio_group layout="horizontal">
            <.radio name="radio-horiz" value="low" checked label={gettext("Low")} />
            <.radio name="radio-horiz" value="medium" label={gettext("Medium")} />
            <.radio name="radio-horiz" value="high" label={gettext("High")} />
          </.radio_group>
        </.form_group>

        <%!-- Grouped choice: the requirement belongs to the group ("pick one"),
             so the asterisk sits once on the GROUP HEADING — the options stay clean. --%>
        <.form_group>
          <.form_label>{gettext("Priority (required group)")}</.form_label>
          <.radio_group layout="horizontal">
            <.radio name="req-priority" value="low" required label={gettext("Low")} />
            <.radio name="req-priority" value="medium" required label={gettext("Medium")} />
            <.radio name="req-priority" value="high" required label={gettext("High")} />
          </.radio_group>
        </.form_group>

        <%!-- Standalone consent checkbox (no *-group wrapper): the requirement IS
             this one control, so the asterisk sits on its OWN option label. --%>
        <.form_group>
          <.checkbox required label={gettext("I accept the terms")} />
        </.form_group>
      </form>
    </.card>

    <%!-- Checkbox and Radio Sizes --%>
    <.card title_text={gettext("Checkbox & Radio Sizes")}>
      <form class="pa-form">
        <.grid>
          <.column size="100" md="50">
            <.form_group>
              <.form_label>{gettext("Checkbox Sizes")}</.form_label>
              <.checkbox_group>
                <.checkbox size="xs" checked label={gettext("Extra Small (12px)")} />
                <.checkbox size="sm" checked label={gettext("Small (14px)")} />
                <.checkbox checked label={gettext("Default (16px)")} />
                <.checkbox size="lg" checked label={gettext("Large (20px)")} />
                <.checkbox size="xl" checked label={gettext("Extra Large (24px)")} />
              </.checkbox_group>
            </.form_group>
          </.column>

          <.column size="100" md="50">
            <.form_group>
              <.form_label>{gettext("Radio Button Sizes")}</.form_label>
              <.radio_group>
                <.radio name="radio-sizes" value="xs" size="xs" checked label={gettext("Extra Small (12px)")} />
                <.radio name="radio-sizes" value="sm" size="sm" label={gettext("Small (14px)")} />
                <.radio name="radio-sizes" value="default" label={gettext("Default (16px)")} />
                <.radio name="radio-sizes" value="lg" size="lg" label={gettext("Large (20px)")} />
                <.radio name="radio-sizes" value="xl" size="xl" label={gettext("Extra Large (24px)")} />
              </.radio_group>
            </.form_group>
          </.column>
        </.grid>
      </form>
    </.card>

    <%!-- Horizontal Form Layout --%>
    <.card title_text={gettext("Horizontal Form Layout")} subtitle_text={gettext("Labels on the left, inputs on the right with varying field widths")}>
      <form class="pa-form">
        <%!-- Line 1: First Name, Last Name, Email (equal widths) --%>
        <.grid>
          <.column size="100" md="1-3">
            <.form_group is_horizontal label={gettext("First Name")}>
              <.input type="text" id="h-fname" placeholder="John" />
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group is_horizontal label={gettext("Last Name")}>
              <.input type="text" id="h-lname" placeholder="Doe" />
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group is_horizontal label={gettext("Email")}>
              <.input type="email" id="h-email" placeholder="john.doe@company.com" />
            </.form_group>
          </.column>
        </.grid>

        <%!-- Line 2: Phone (smaller), Department (larger), Job Title (medium) --%>
        <.grid>
          <.column size="100" md="25">
            <.form_group is_horizontal label={gettext("Phone")}>
              <.input type="tel" id="h-phone" placeholder="+1 555-0123" />
            </.form_group>
          </.column>
          <.column size="100" md="42">
            <.form_group is_horizontal label={gettext("Department")}>
              <.select id="h-dept" prompt={gettext("Select department...")} options={[{"engineering", "Engineering"}, {"marketing", "Marketing"}, {"sales", "Sales"}, {"hr", "Human Resources"}]} />
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group is_horizontal label={gettext("Job Title")}>
              <.input type="text" id="h-title" placeholder="Senior Developer" />
            </.form_group>
          </.column>
        </.grid>

        <%!-- Line 3: Address (larger), City (medium), Zip (small) --%>
        <.grid>
          <.column size="100" md="50">
            <.form_group is_horizontal label={gettext("Address")}>
              <.input type="text" id="h-address" placeholder="123 Main Street" />
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group is_horizontal label={gettext("City")}>
              <.input type="text" id="h-city" placeholder="San Francisco" />
            </.form_group>
          </.column>
          <.column size="100" md="15">
            <.form_group is_horizontal label={gettext("Zip")}>
              <.input type="text" id="h-zip" placeholder="94102" />
            </.form_group>
          </.column>
        </.grid>

        <%!-- Submit Buttons --%>
        <.grid>
          <.column size="100" class="text-end mt-3">
            <.button variant="secondary">{gettext("Cancel")}</.button>
            <.button type="submit" variant="primary">{gettext("Submit")}</.button>
          </.column>
        </.grid>
      </form>
      <:footer>
        <p class="pa-text pa-text--sm pa-text--secondary m-0">
          <strong>Layout pattern:</strong> Each field uses <code>.pa-form-group--horizontal</code> (label left, input right) inside <code>pc-col-*</code> columns.
          Line 1: equal widths (1/3 each).
          Line 2: varying sizes (1/4 + 5/12 + 1/3).
          Line 3: very different sizes (1/2 + 1/3 + 1/6).
        </p>
      </:footer>
    </.card>
    """
  end

  # Rows for the "Input Sizes Reference" table. Heights are measured client-side.
  defp size_rows do
    [
      %{size: "XS", class: "--xs", font: "1.2rem (12px)", padding: "0.6rem / 0.8rem", mod: "xs", placeholder: "Extra small"},
      %{size: "SM", class: "--sm", font: "1.4rem (14px)", padding: "0.8rem / 0.8rem", mod: "sm", placeholder: "Small"},
      %{size: "Default", class: "(none)", font: "1.4rem (14px)", padding: "0.8rem / 0.8rem", mod: nil, placeholder: "Default"},
      %{size: "LG", class: "--lg", font: "1.6rem (16px)", padding: "0.8rem / 0.8rem", mod: "lg", placeholder: "Large"},
      %{size: "XL", class: "--xl", font: "1.8rem (18px)", padding: "0.8rem / 0.8rem", mod: "xl", placeholder: "Extra large"}
    ]
  end
end
