defmodule DemoWeb.Live.ValidationsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Validations",
      realtime_email: "",
      realtime_touched: false,
      blur_email: "",
      blur_touched: false,
      submit_email: "",
      submit_touched: false,
      password: "",
      password_confirm: "",
      start_date: "",
      end_date: ""
    )}
  end

  def handle_event("realtime_change", %{"realtime_email" => email}, socket) do
    {:noreply, assign(socket, realtime_email: email, realtime_touched: true)}
  end

  def handle_event("blur_validate", %{"value" => email}, socket) do
    {:noreply, assign(socket, blur_email: email, blur_touched: true)}
  end

  def handle_event("submit_validate", %{"submit_email" => email}, socket) do
    {:noreply, assign(socket, submit_email: email, submit_touched: true)}
  end

  def handle_event("password_change", params, socket) do
    {:noreply, assign(socket,
      password: params["password"] || socket.assigns.password,
      password_confirm: params["password_confirm"] || socket.assigns.password_confirm
    )}
  end

  def handle_event("date_change", params, socket) do
    {:noreply, assign(socket,
      start_date: params["start_date"] || socket.assigns.start_date,
      end_date: params["end_date"] || socket.assigns.end_date
    )}
  end

  def handle_event("show_validation_toast", _params, socket) do
    {:noreply,
     PureAdmin.Components.Toast.push_toast(
       socket,
       "danger",
       gettext("Validation Failed"),
       gettext("Invalid credentials. Please check your email and password."),
       duration: 4000
     )}
  end

  defp valid_email?(email) do
    String.length(email) > 0 and String.contains?(email, "@") and String.contains?(email, ".")
  end

  defp email_validation(touched, email) do
    cond do
      !touched -> nil
      !valid_email?(email) -> "error"
      true -> "success"
    end
  end

  defp date_validation(start_date, end_date) do
    case dates_valid?(start_date, end_date) do
      false -> "error"
      true -> "success"
      nil -> nil
    end
  end

  defp password_strength(pw) do
    cond do
      String.length(pw) == 0 -> nil
      String.length(pw) < 8 -> :weak
      String.match?(pw, ~r/[A-Z]/) and String.match?(pw, ~r/[0-9]/) and String.match?(pw, ~r/[^A-Za-z0-9]/) -> :strong
      String.match?(pw, ~r/[A-Z]/) and String.match?(pw, ~r/[0-9]/) -> :medium
      true -> :weak
    end
  end

  defp passwords_match?(pw, confirm) do
    String.length(pw) > 0 and String.length(confirm) > 0 and pw == confirm
  end

  defp dates_valid?(start_date, end_date) do
    cond do
      start_date == "" or end_date == "" -> nil
      start_date < end_date -> true
      true -> false
    end
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Different UI patterns for displaying form validation errors. Choose the pattern that best fits your UX requirements.</.paragraph>

    <%!-- Pattern 1: Inline Field Errors --%>
    <.card title_text={gettext("1. Inline Field Errors")}>
      <.paragraph class="mb-3">The most common pattern. Error messages appear directly below each field. Best for forms where users need immediate field-level feedback.</.paragraph>

      <form class="pa-form">
        <.grid>
          <.column size="100" md="50">
            <.form_group state="error">
              <.form_label>{gettext("Email Address")}</.form_label>
              <.input type="email" value="invalid-email" state="error" required />
              <.form_help variant="error">{gettext("Please enter a valid email address")}</.form_help>
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group state="error">
              <.form_label>{gettext("Password")}</.form_label>
              <.input type="password" value="123" state="error" required />
              <.form_help variant="error">{gettext("Password must be at least 8 characters")}</.form_help>
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group state="success">
              <.form_label>{gettext("Username")}</.form_label>
              <.input type="text" value="johndoe" state="success" required />
              <.form_help variant="success">{gettext("Username is available")}</.form_help>
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group state="warning">
              <.form_label>{gettext("Phone Number")}</.form_label>
              <.input type="tel" value="555-1234" state="warning" />
              <.form_help variant="warning">{gettext("Consider adding country code for international format")}</.form_help>
            </.form_group>
          </.column>
        </.grid>
      </form>

      <.callout variant="info" class="mt-4">
        <strong>Usage:</strong> Add <.code>pa-form-group--error</.code> to the form group and <.code>pa-form-help--error</.code> to the help text.
      </.callout>
    </.card>

    <%!-- Pattern 2: Summary Block --%>
    <.card title_text={gettext("2. Summary Block (Top of Form)")}>
      <.paragraph class="mb-3">All errors collected in a single alert at the top. Good for accessibility and giving users a quick overview of all issues.</.paragraph>

      <form class="pa-form">
        <.alert variant="danger" class="mb-4">
          <strong>{gettext("Please fix the following errors:")}</strong>
          <ul class="mt-0 mb-0">
            <li>{gettext("First name is required")}</li>
            <li>{gettext("Email address is not valid")}</li>
            <li>{gettext("Password must contain at least one uppercase letter")}</li>
            <li>{gettext("Please accept the terms and conditions")}</li>
          </ul>
        </.alert>

        <.grid>
          <.column size="100" md="50">
            <.form_group state="error">
              <.form_label>{gettext("First Name")}</.form_label>
              <.input type="text" placeholder={gettext("Enter first name")} state="error" required />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group>
              <.form_label>{gettext("Last Name")}</.form_label>
              <.input type="text" value="Smith" />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group state="error">
              <.form_label>{gettext("Email")}</.form_label>
              <.input type="email" value="not-an-email" state="error" required />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group state="error">
              <.form_label>{gettext("Password")}</.form_label>
              <.input type="password" value="password" state="error" required />
            </.form_group>
          </.column>
          <.column size="100">
            <.form_group state="error">
              <.checkbox id="terms">
                <:label_content>{gettext("I accept the terms and conditions")} <span class="text-danger">*</span></:label_content>
              </.checkbox>
            </.form_group>
          </.column>
        </.grid>
      </form>

      <.callout variant="info" class="mt-4">
        <strong>Best Practice:</strong> Combine summary block with inline errors for maximum accessibility. Screen readers can announce all errors at once.
      </.callout>
    </.card>

    <%!-- Pattern 3: Inline + Summary Combined — built from the <.form_error_summary>
         and <.form_field> orchestrators (keen equivalents of svelte's
         FormErrorSummary / FormField). --%>
    <.card title_text={gettext("3. Combined: Summary + Inline (Recommended)")}>
      <.paragraph class="mb-3">The best of both worlds. Summary for overview, inline for specific guidance. This section is built with <.code>&lt;.form_error_summary&gt;</.code> and <.code>&lt;.form_field&gt;</.code> — the higher-level orchestrators that mirror svelte's <.code>FormErrorSummary</.code> / <.code>FormField</.code>.</.paragraph>

      <form class="pa-form">
        <.form_error_summary errors={[
          %{field: gettext("Card number"), id: "card-number", message: gettext("Invalid card number format")},
          %{field: gettext("CVV"), id: "cvv", message: gettext("Must be 3 or 4 digits")}
        ]} />

        <.grid>
          <.column size="100" md="50">
            <.form_field label_text={gettext("Card Number")} for="card-number" state="error" help_text={gettext("Invalid card number format. Please use 16 digits.")} :let={f}>
              <.input type="text" id="card-number" value="1234-5678-XXXX" state={f.state} required />
            </.form_field>
          </.column>
          <.column size="100" md="25">
            <.form_field label_text={gettext("Expiry Date")} state="success" help_text={gettext("Valid")} :let={f}>
              <.input type="text" value="12/25" state={f.state} />
            </.form_field>
          </.column>
          <.column size="100" md="25">
            <.form_field label_text={gettext("CVV")} for="cvv" state="error" help_text={gettext("Must be 3 or 4 digits")} :let={f}>
              <.input type="text" id="cvv" value="12" state={f.state} required />
            </.form_field>
          </.column>
        </.grid>
      </form>

      <.callout variant="success" class="mt-4">
        <strong>Tip:</strong> <.code>&lt;.form_error_summary&gt;</.code> renders clickable links that jump to each field via its <.code>id</.code>; <.code>&lt;.form_field&gt;</.code> wires the label, control, and help/error text in one tag.
      </.callout>
    </.card>

    <%!-- Pattern 4: Border + Icon Only --%>
    <.card title_text={gettext("4. Border + Icon Only (Minimal)")}>
      <.paragraph class="mb-3">Space-efficient but less informative. Red border and icon indicate error without text message. User must infer the issue or hover/click for details.</.paragraph>

      <form class="pa-form">
        <.grid>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label>{gettext("Username")}</.form_label>
              <.input_group>
                <.input type="text" value="" state="error" />
                <:append>
                  <span class="text-danger" title={gettext("This field is required")}><span class="pa-icon pa-icon--danger" aria-hidden="true"></span></span>
                </:append>
              </.input_group>
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label>{gettext("Email")}</.form_label>
              <.input_group>
                <.input type="email" value="bad@" state="error" />
                <:append>
                  <span class="text-danger" title={gettext("Invalid email format")}><span class="pa-icon pa-icon--danger" aria-hidden="true"></span></span>
                </:append>
              </.input_group>
            </.form_group>
          </.column>
          <.column size="100" md="1-3">
            <.form_group>
              <.form_label>{gettext("Password")}</.form_label>
              <.input_group>
                <.input type="password" value="securepass123" state="success" />
                <:append>
                  <span class="text-success"><span class="pa-icon pa-icon--success" aria-hidden="true"></span></span>
                </:append>
              </.input_group>
            </.form_group>
          </.column>
        </.grid>
      </form>

      <.callout variant="warning" class="mt-4">
        <strong>Caution:</strong> This pattern provides poor accessibility. Consider using tooltips or aria-describedby for screen readers.
      </.callout>
    </.card>

    <%!-- Pattern 5: Right-side Indicators --%>
    <.card title_text={gettext("5. Right-side Indicators")}>
      <.paragraph class="mb-3">Error text positioned to the right of the input. Works well in horizontal form layouts with more screen real estate.</.paragraph>

      <form class="pa-form">
        <.form_group is_horizontal class="align-items-center">
          <.form_label class="pc-col-md-25" for="company-name">{gettext("Company Name")}</.form_label>
          <div class="pc-col-md-40">
            <.input type="text" id="company-name" value="" state="error" />
          </div>
          <div class="pc-col-md-35">
            <.form_help variant="error" class="mt-0">{gettext("Company name is required")}</.form_help>
          </div>
        </.form_group>
        <.form_group is_horizontal class="align-items-center">
          <.form_label class="pc-col-md-25" for="website-url">{gettext("Website URL")}</.form_label>
          <div class="pc-col-md-40">
            <.input type="url" id="website-url" value="not-a-url" state="error" />
          </div>
          <div class="pc-col-md-35">
            <.form_help variant="error" class="mt-0">{gettext("Please enter a valid URL (e.g., https://example.com)")}</.form_help>
          </div>
        </.form_group>
        <.form_group is_horizontal class="align-items-center">
          <.form_label class="pc-col-md-25" for="industry-select">{gettext("Industry")}</.form_label>
          <div class="pc-col-md-40">
            <.select id="industry-select" state="success" options={["Technology"]} />
          </div>
          <div class="pc-col-md-35">
            <.form_help variant="success" class="mt-0"><span class="pa-icon pa-icon--success" aria-hidden="true"></span> Valid selection</.form_help>
          </div>
        </.form_group>
      </form>
    </.card>

    <%!-- Pattern 6: Helper Text Transforms to Error --%>
    <.card title_text={gettext("6. Helper Text Transforms to Error")}>
      <.paragraph class="mb-3">Helper text below the field transforms into error text when validation fails. Maintains consistent spacing.</.paragraph>

      <form class="pa-form">
        <.grid>
          <.column size="100">
            <.form_group
              id="bio-counter"
              phx-hook="PureAdminCharCounter"
              data-max-chars="100"
              data-msg="Maximum {max} characters ({count}/{max})"
              data-msg-over="Maximum {max} characters exceeded ({count}/{max})"
            >
              <.form_label>{gettext("Bio")}</.form_label>
              <.textarea rows={3} value="This is my bio text that keeps going and going..." />
              <.form_help></.form_help>
            </.form_group>
          </.column>
        </.grid>
      </form>
    </.card>

    <%!-- Pattern 7: Toast Notifications --%>
    <.card title_text={gettext("7. Toast Notifications")}>
      <.paragraph class="mb-3">Validation errors shown as toast notifications. Best for submit-level errors or async validation (e.g., server-side checks).</.paragraph>

      <form class="pa-form">
        <.grid>
          <.column size="100" md="50">
            <.form_group>
              <.form_label>{gettext("Email")}</.form_label>
              <.input type="email" value="user@example.com" />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group>
              <.form_label>{gettext("Password")}</.form_label>
              <.input type="password" value="password123" />
            </.form_group>
          </.column>
          <.column size="100">
            <.button variant="primary" type="button" phx-click="show_validation_toast">{gettext("Submit (Shows Toast)")}</.button>
          </.column>
        </.grid>
      </form>

      <%!-- Static preview of the toast that pops in the corner on submit. --%>
      <.card class="mt-4" has_padding>
        <.paragraph color="secondary" class="mb-2"><em>Toast preview (normally appears in corner):</em></.paragraph>
        <.toast variant="danger" title_text={gettext("Validation Failed")} message_text={gettext("Invalid credentials. Please check your email and password.")} />
      </.card>

      <.callout variant="warning" class="mt-4">
        <strong>Note:</strong> Toasts are ephemeral. Don't use them as the only validation feedback - users may miss them.
      </.callout>
    </.card>

    <%!-- Pattern 8: Validation Timing --%>
    <.card title_text={gettext("8. Validation Timing Strategies")}>
      <.paragraph class="mb-3">When to trigger validation affects user experience significantly.</.paragraph>

      <.grid>
        <%!-- On Input (Real-time) --%>
        <.column size="100" md="1-3">
          <.card variant="warning" title_text={gettext("On Input (Real-time)")}>
            <form phx-change="realtime_change">
              <.form_group state={email_validation(@realtime_touched, @realtime_email)}>
                <.form_label>{gettext("Email")}</.form_label>
                <.input
                  type="email"
                  name="realtime_email"
                  value={@realtime_email}
                  state={email_validation(@realtime_touched, @realtime_email)}
                  placeholder={gettext("Type to see validation...")}
                  phx-debounce="100"
                />
                <.form_help :if={@realtime_touched && !valid_email?(@realtime_email)} variant="error">
                  <%= if @realtime_email == "", do: gettext("Email is required"), else: gettext("Invalid email format") %>
                </.form_help>
                <.form_help :if={@realtime_touched && valid_email?(@realtime_email)} variant="success">{gettext("Valid email")}</.form_help>
                <.form_help :if={!@realtime_touched}>{gettext("Type to see validation")}</.form_help>
              </.form_group>
            </form>
            <small class="mt-2 text-secondary">Validates as user types. Can feel aggressive.</small>
          </.card>
        </.column>

        <%!-- On Blur (Recommended) --%>
        <.column size="100" md="1-3">
          <.card variant="success" title_text={gettext("On Blur (Recommended)")}>
            <.form_group state={email_validation(@blur_touched, @blur_email)}>
              <.form_label>{gettext("Email")}</.form_label>
              <.input
                type="email"
                value={@blur_email}
                state={email_validation(@blur_touched, @blur_email)}
                placeholder={gettext("Tab out to validate...")}
                phx-blur="blur_validate"
              />
              <.form_help :if={@blur_touched && !valid_email?(@blur_email)} variant="error">
                <%= if @blur_email == "", do: gettext("Email is required"), else: gettext("Invalid email format") %>
              </.form_help>
              <.form_help :if={@blur_touched && valid_email?(@blur_email)} variant="success">{gettext("Valid email")}</.form_help>
              <.form_help :if={!@blur_touched}>{gettext("Click away to validate")}</.form_help>
            </.form_group>
            <small class="mt-2 text-secondary">Validates when field loses focus. Good balance.</small>
          </.card>
        </.column>

        <%!-- On Submit --%>
        <.column size="100" md="1-3">
          <.card variant="primary" title_text={gettext("On Submit")}>
            <form phx-submit="submit_validate">
              <.form_group state={email_validation(@submit_touched, @submit_email)}>
                <.form_label>{gettext("Email")}</.form_label>
                <.input
                  type="email"
                  name="submit_email"
                  value={@submit_email}
                  state={email_validation(@submit_touched, @submit_email)}
                  placeholder={gettext("No validation until submit")}
                />
                <.form_help :if={@submit_touched && !valid_email?(@submit_email)} variant="error">
                  <%= if @submit_email == "", do: gettext("Email is required"), else: gettext("Invalid email format") %>
                </.form_help>
                <.form_help :if={@submit_touched && valid_email?(@submit_email)} variant="success">{gettext("Valid email")}</.form_help>
                <.form_help :if={!@submit_touched}>{gettext("Submit to validate")}</.form_help>
              </.form_group>
              <.button variant="info" size="sm" type="submit" class="mt-2">{gettext("Validate")}</.button>
            </form>
            <small class="mt-2 text-secondary">All errors shown at once on submit. Traditional approach.</small>
          </.card>
        </.column>
      </.grid>
    </.card>

    <%!-- Pattern 9: Multi-field Validation --%>
    <.card title_text={gettext("9. Multi-field / Cross-field Validation")}>
      <.paragraph class="mb-3">When validation depends on multiple fields (e.g., password confirmation, date ranges).</.paragraph>

      <%!-- Password confirmation --%>
      <form class="pa-form" phx-change="password_change">
        <.grid>
          <.column size="100" md="50">
            <% pw_state = case password_strength(@password) do
              :strong -> "success"
              :medium -> "warning"
              :weak -> "error"
              nil -> nil
            end %>
            <.form_group state={pw_state}>
              <.form_label>{gettext("New Password")}</.form_label>
              <.input type="password" name="password" value={@password} state={pw_state} placeholder={gettext("Enter password...")} phx-debounce="200" />
              <.form_help :if={password_strength(@password) == :strong} variant="success">{gettext("Strong password")}</.form_help>
              <.form_help :if={password_strength(@password) == :medium} variant="warning">{gettext("Medium — add a special character")}</.form_help>
              <.form_help :if={password_strength(@password) == :weak} variant="error">
                <%= if String.length(@password) < 8, do: gettext("Must be at least 8 characters"), else: gettext("Add uppercase and numbers") %>
              </.form_help>
              <.form_help :if={@password == ""}>{gettext("Min 8 chars, uppercase, number, special char")}</.form_help>
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <% confirm_state = cond do
              @password_confirm == "" -> nil
              passwords_match?(@password, @password_confirm) -> "success"
              true -> "error"
            end %>
            <.form_group state={confirm_state}>
              <.form_label>{gettext("Confirm Password")}</.form_label>
              <.input type="password" name="password_confirm" value={@password_confirm} state={confirm_state} placeholder={gettext("Confirm password...")} phx-debounce="200" />
              <.form_help :if={passwords_match?(@password, @password_confirm)} variant="success">{gettext("Passwords match")}</.form_help>
              <.form_help :if={@password_confirm != "" && !passwords_match?(@password, @password_confirm)} variant="error">{gettext("Passwords do not match")}</.form_help>
              <.form_help :if={@password_confirm == ""}>{gettext("Re-enter your password")}</.form_help>
            </.form_group>
          </.column>
        </.grid>
      </form>

      <.divider />

      <%!-- Date range --%>
      <form class="pa-form" phx-change="date_change">
        <.grid>
          <.column size="100" md="50">
            <.form_group state={date_validation(@start_date, @end_date)}>
              <.form_label>{gettext("Start Date")}</.form_label>
              <.date_input type="date" name="start_date" value={@start_date} state={date_validation(@start_date, @end_date)} />
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group state={date_validation(@start_date, @end_date)}>
              <.form_label>{gettext("End Date")}</.form_label>
              <.date_input type="date" name="end_date" value={@end_date} state={date_validation(@start_date, @end_date)} />
            </.form_group>
          </.column>
          <.column :if={dates_valid?(@start_date, @end_date) == false} size="100">
            <.alert variant="danger">
              {gettext("End date must be after start date")}
            </.alert>
          </.column>
          <.column :if={dates_valid?(@start_date, @end_date) == true} size="100">
            <.alert variant="success">
              {gettext("Valid date range")}
            </.alert>
          </.column>
        </.grid>
      </form>
    </.card>

    <%!-- Pattern 10: Progressive Validation --%>
    <.card title_text={gettext("10. Progressive Validation (Multi-step Forms)")}>
      <.paragraph class="mb-3">Validate each step before allowing progression. Prevents users from reaching the end with invalid data.</.paragraph>

      <%!-- Step indicators --%>
      <.grid class="mb-4">
        <.column size="1-3" class="text-center">
          <.badge variant="success" size="lg">1</.badge>
          <.paragraph class="mt-2 text-success">{gettext("Account")}</.paragraph>
        </.column>
        <.column size="1-3" class="text-center">
          <.badge variant="danger" size="lg">2</.badge>
          <.paragraph class="mt-2 text-danger">{gettext("Profile")}</.paragraph>
        </.column>
        <.column size="1-3" class="text-center">
          <.badge size="lg" class="pa-badge--default">3</.badge>
          <.paragraph color="secondary" class="mt-2">{gettext("Confirm")}</.paragraph>
        </.column>
      </.grid>

      <.alert variant="danger" class="mb-3">
        {gettext("Please complete all required fields in Step 2 before proceeding.")}
      </.alert>

      <form class="pa-form">
        <.grid>
          <.column size="100" md="50">
            <.form_group state="error">
              <.form_label>{gettext("Display Name")}</.form_label>
              <.input type="text" placeholder={gettext("Enter display name")} state="error" required />
              <.form_help variant="error">{gettext("Display name is required")}</.form_help>
            </.form_group>
          </.column>
          <.column size="100" md="50">
            <.form_group state="success">
              <.form_label>{gettext("Avatar URL")}</.form_label>
              <.input type="url" value="https://example.com/avatar.jpg" state="success" />
              <.form_help variant="success">{gettext("Valid URL")}</.form_help>
            </.form_group>
          </.column>
        </.grid>
        <.button_group class="pa-form-actions">
          <.button variant="secondary">{gettext("Back")}</.button>
          <.button variant="primary" disabled>{gettext("Next Step")}</.button>
        </.button_group>
      </form>
    </.card>

    <%!-- CSS Classes Reference --%>
    <.card title_text={gettext("CSS Classes Reference")}>
      <.heading level={4}>{gettext("Form Group States")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-form-group--success</.code> - Success state (green)</li>
        <li><.code>pa-form-group--warning</.code> - Warning state (yellow/orange)</li>
        <li><.code>pa-form-group--error</.code> - Error state (red)</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Input States")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-input--success</.code> - Success border on input</li>
        <li><.code>pa-input--warning</.code> - Warning border on input</li>
        <li><.code>pa-input--error</.code> - Error border on input</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Help/Message Text")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-form-help</.code> - Base help text styling</li>
        <li><.code>pa-form-help--success</.code> - Green help text</li>
        <li><.code>pa-form-help--warning</.code> - Yellow/orange help text</li>
        <li><.code>pa-form-help--error</.code> - Red help text</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Alert Variants (for Summary Blocks)")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-alert pa-alert--danger</.code> - Error summary block</li>
        <li><.code>pa-alert pa-alert--warning</.code> - Warning summary block</li>
        <li><.code>pa-alert pa-alert--success</.code> - Success message block</li>
        <li><.code>pa-alert pa-alert--info</.code> - Info message block</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Text Utility Classes")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>text-danger</.code> - Red text color</li>
        <li><.code>text-warning</.code> - Yellow/orange text color</li>
        <li><.code>text-success</.code> - Green text color</li>
        <li><.code>text-secondary</.code> - Muted/gray text color</li>
      </.basic_list>
    </.card>
    """
  end
end
