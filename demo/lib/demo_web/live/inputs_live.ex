defmodule DemoWeb.Live.InputsLive do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Inputs", is_search_mode: false)}
  end

  def handle_event("toggle_mode", _params, socket) do
    {:noreply, assign(socket, :is_search_mode, !socket.assigns.is_search_mode)}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Comprehensive showcase of all input types, states, sizes, and variations available in the framework.</.paragraph>

    <%!-- Text Inputs --%>
    <.card title_text={gettext("Text Inputs")}>
      <.grid>
        <%!-- States --%>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Normal")}</.form_label>
            <.input placeholder={gettext("Enter text")} />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Disabled")}</.form_label>
            <.input placeholder={gettext("Disabled")} disabled />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Readonly")}</.form_label>
            <.input value={gettext("Read only value")} readonly />
          </.form_group>
        </.column>

        <%!-- Sizes --%>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Extra Small")}</.form_label>
            <.input size="xs" placeholder="XS" />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Small")}</.form_label>
            <.input size="sm" placeholder={gettext("Small")} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Default")}</.form_label>
            <.input placeholder={gettext("Default")} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Large")}</.form_label>
            <.input size="lg" placeholder={gettext("Large")} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Extra Large")}</.form_label>
            <.input size="xl" placeholder="XL" />
          </.form_group>
        </.column>

        <%!-- Validation States --%>
        <.column size="100" md="1-3">
          <.form_group state="success">
            <.form_label>{gettext("Success")}</.form_label>
            <.input value={gettext("Valid input")} />
            <.form_help variant="success">{gettext("Looks good!")}</.form_help>
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group state="warning">
            <.form_label>{gettext("Warning")}</.form_label>
            <.input value={gettext("Warning input")} />
            <.form_help variant="warning">{gettext("Please check this field")}</.form_help>
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group state="error">
            <.form_label>{gettext("Error")}</.form_label>
            <.input value={gettext("Invalid input")} />
            <.form_help variant="error">{gettext("This field is required")}</.form_help>
          </.form_group>
        </.column>

        <%!-- Theme Color Variants --%>
        <.column size="100" class="mt-4">
          <.form_label class="mb-2"><strong>Theme Color Variants</strong> (using --pc-color-* CSS variables)</.form_label>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Color 1")}</.form_label>
            <.input theme_color="1" value={gettext("Color 1 input")} />
            <.form_help theme_color="1">{gettext("Colored help text")}</.form_help>
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Color 2")}</.form_label>
            <.input theme_color="2" value={gettext("Color 2 input")} />
            <.form_help theme_color="2">{gettext("Colored help text")}</.form_help>
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Color 3")}</.form_label>
            <.input theme_color="3" value={gettext("Color 3 input")} />
            <.form_help>{gettext("Gray help text (no color class)")}</.form_help>
          </.form_group>
        </.column>
      </.grid>
    </.card>

    <%!-- Input Groups --%>
    <.card title_text={gettext("Input Groups (Prepend/Append)")}>
      <.grid>
        <.column size="100" md="50">
          <.form_group>
            <.form_label>{gettext("With Prepend")}</.form_label>
            <.input_group>
              <:prepend>@</:prepend>
              <.input placeholder={gettext("username")} />
            </.input_group>
          </.form_group>
        </.column>

        <.column size="100" md="50">
          <.form_group>
            <.form_label>{gettext("With Append")}</.form_label>
            <.input_group>
              <.input placeholder="0.00" />
              <:append>.00</:append>
            </.input_group>
          </.form_group>
        </.column>

        <.column size="100" md="50">
          <.form_group>
            <.form_label>With Both (prepend uses <.code>wr-3</.code> for fixed width)</.form_label>
            <.input_group>
              <:prepend><span class="wr-3">$</span></:prepend>
              <.input placeholder="0.00" />
              <:append>.00</:append>
            </.input_group>
          </.form_group>
        </.column>

        <.column size="100" md="50">
          <.form_group>
            <.form_label>{gettext("With Button")}</.form_label>
            <.input_group>
              <.input placeholder={gettext("Search...")} />
              <:button>
                <.button variant="primary" class="pa-input-group__button">{gettext("Go")}</.button>
              </:button>
            </.input_group>
          </.form_group>
        </.column>

        <.column size="100">
          <.form_group>
            <.form_label>{gettext("Multiple Prepends & Appends")}</.form_label>
            <.input_group>
              <:prepend>https://</:prepend>
              <:prepend>www.</:prepend>
              <.input placeholder="example" />
              <:append>.com</:append>
              <:append>🔗</:append>
            </.input_group>
          </.form_group>
        </.column>

        <.column size="100">
          <.form_group>
            <.form_label>{gettext("Toggle Mode Button (Filter / Search) + Go")}</.form_label>
            <.input_group>
              <:button>
                <.button
                  variant="primary"
                  class="pa-input-group__button"
                  title={if @is_search_mode, do: gettext("Search mode — click to switch to Filter"), else: gettext("Filter mode — click to switch to Search")}
                  phx-click="toggle_mode"
                >
                  <span class={if @is_search_mode, do: "pa-icon pa-icon--search", else: "pa-icon pa-icon--filter"} aria-hidden="true"></span>
                </.button>
              </:button>
              <.input placeholder={if @is_search_mode, do: gettext("Search..."), else: gettext("Filter...")} />
              <:button>
                <.button variant="primary" class="pa-input-group__button">{gettext("Go")}</.button>
              </:button>
            </.input_group>
            <.form_help>{gettext("Click the icon button to switch between Filter and Search modes")}</.form_help>
          </.form_group>
        </.column>

        <.column size="100" class="mt-3">
          <.text variant="secondary" class="text-sm"><strong>Tip:</strong> Use width utilities (<.code>wr-*</.code> for rem-based, <.code>w-*</.code> for percentage-based) on prepend/append elements to control their width.</.text>
        </.column>
      </.grid>
    </.card>

    <%!-- Input Types --%>
    <.card title_text={gettext("Input Types")}>
      <.grid>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Email")}</.form_label>
            <.input type="email" placeholder="user@example.com" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Password")}</.form_label>
            <.input type="password" placeholder="••••••••" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Number")}</.form_label>
            <.number_input placeholder="0" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Tel")}</.form_label>
            <.input type="tel" placeholder="+1 (555) 123-4567" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("URL")}</.form_label>
            <.input type="url" placeholder="https://example.com" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Search")}</.form_label>
            <.input type="search" placeholder={gettext("Search...")} />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Date")}</.form_label>
            <.date_input type="date" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Time")}</.form_label>
            <.date_input type="time" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("DateTime")}</.form_label>
            <.date_input type="datetime-local" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Month")}</.form_label>
            <.date_input type="month" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Week")}</.form_label>
            <.date_input type="week" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Color")}</.form_label>
            <.color_input value="#ff0000" />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("File")}</.form_label>
            <.file_input />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Range")}</.form_label>
            <.range_input />
          </.form_group>
        </.column>
      </.grid>
    </.card>

    <%!-- Select Dropdowns --%>
    <.card title_text={gettext("Select Dropdowns")}>
      <.grid>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Normal")}</.form_label>
            <.select options={["Option 1", "Option 2", "Option 3"]} prompt={gettext("Choose option...")} />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Disabled")}</.form_label>
            <.select options={["Disabled"]} disabled />
          </.form_group>
        </.column>
        <.column size="100" md="1-3">
          <.form_group>
            <.form_label>{gettext("Multiple")}</.form_label>
            <select class="pa-select" multiple>
              <option>Option 1</option>
              <option>Option 2</option>
              <option>Option 3</option>
              <option>Option 4</option>
            </select>
          </.form_group>
        </.column>

        <%!-- Sizes --%>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Extra Small")}</.form_label>
            <.select size="xs" options={["XS"]} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Small")}</.form_label>
            <.select size="sm" options={["Small"]} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Default")}</.form_label>
            <.select options={["Default"]} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Large")}</.form_label>
            <.select size="lg" options={["Large"]} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Extra Large")}</.form_label>
            <.select size="xl" options={["XL"]} />
          </.form_group>
        </.column>
      </.grid>
    </.card>

    <%!-- Textareas --%>
    <.card title_text={gettext("Textareas")}>
      <.grid>
        <.column size="100" md="50">
          <.form_group>
            <.form_label>{gettext("Normal")}</.form_label>
            <.textarea placeholder={gettext("Enter your message...")} />
          </.form_group>
        </.column>
        <.column size="100" md="50">
          <.form_group>
            <.form_label>{gettext("Disabled")}</.form_label>
            <.textarea placeholder={gettext("Disabled")} disabled />
          </.form_group>
        </.column>

        <%!-- Sizes --%>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Extra Small")}</.form_label>
            <.textarea size="xs" placeholder="XS" />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Small")}</.form_label>
            <.textarea size="sm" placeholder={gettext("Small")} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Default")}</.form_label>
            <.textarea placeholder={gettext("Default")} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Large")}</.form_label>
            <.textarea size="lg" placeholder={gettext("Large")} />
          </.form_group>
        </.column>
        <.column size="100" md="20">
          <.form_group>
            <.form_label>{gettext("Extra Large")}</.form_label>
            <.textarea size="xl" placeholder="XL" />
          </.form_group>
        </.column>
      </.grid>
    </.card>

    <%!-- Checkboxes & Radios --%>
    <.card title_text={gettext("Checkboxes & Radios")}>
      <.grid>
        <.column size="100" md="50">
          <.form_group>
            <.form_label>{gettext("Checkboxes")}</.form_label>
            <.checkbox_group>
              <.checkbox id="input-check1" checked label_text={gettext("Option 1 (checked)")} />
              <.checkbox id="input-check2" label_text={gettext("Option 2")} />
              <.checkbox id="input-check3" disabled label_text={gettext("Option 3 (disabled)")} />
            </.checkbox_group>
          </.form_group>
        </.column>

        <.column size="100" md="50">
          <.form_group>
            <.form_label>{gettext("Radio Buttons")}</.form_label>
            <.radio_group>
              <.radio name="radio-demo" value="a" label_text={gettext("Option A (selected)")} />
              <.radio name="radio-demo" value="b" label_text={gettext("Option B")} />
              <.radio name="radio-demo" value="c" disabled label_text={gettext("Option C (disabled)")} />
            </.radio_group>
          </.form_group>
        </.column>

        <.column size="100">
          <.form_group>
            <.form_label>{gettext("Checkbox Sizes")}</.form_label>
            <.checkbox_group>
              <.checkbox id="size-check-xs" size="xs" checked label_text={gettext("Extra Small")} />
              <.checkbox id="size-check-sm" size="sm" checked label_text={gettext("Small")} />
              <.checkbox id="size-check-default" checked label_text={gettext("Default")} />
              <.checkbox id="size-check-lg" size="lg" checked label_text={gettext("Large")} />
              <.checkbox id="size-check-xl" size="xl" checked label_text={gettext("Extra Large")} />
            </.checkbox_group>
          </.form_group>
        </.column>

        <.column size="100">
          <.form_group>
            <.form_label>{gettext("Radio Sizes")}</.form_label>
            <.radio_group>
              <.radio name="size-demo" value="xs" label_text={gettext("Extra Small")} />
              <.radio name="size-demo" value="sm" label_text={gettext("Small")} />
              <.radio name="size-demo" value="default" label_text={gettext("Default")} />
              <.radio name="size-demo" value="lg" label_text={gettext("Large")} />
              <.radio name="size-demo" value="xl" label_text={gettext("Extra Large")} />
            </.radio_group>
          </.form_group>
        </.column>
      </.grid>
    </.card>

    <%!-- Width Variations --%>
    <.card title_text={gettext("Width Variations")}>
      <.form_group>
        <.form_label>{gettext("Auto Width (inline)")}</.form_label>
        <.input class="w-auto d-inline-block" placeholder={gettext("Auto width")} />
      </.form_group>
      <.form_group>
        <.form_label>{gettext("25% Width")}</.form_label>
        <.input class="w-25" placeholder="25%" />
      </.form_group>
      <.form_group>
        <.form_label>{gettext("50% Width")}</.form_label>
        <.input class="w-50" placeholder="50%" />
      </.form_group>
      <.form_group>
        <.form_label>{gettext("75% Width")}</.form_label>
        <.input class="w-75" placeholder="75%" />
      </.form_group>
      <.form_group>
        <.form_label>{gettext("100% Width (full width)")}</.form_label>
        <.input class="w-100" placeholder="100%" />
      </.form_group>
    </.card>

    <%!-- CSS Classes Reference --%>
    <.card title_text={gettext("CSS Classes Reference")}>
      <.heading level={4}>{gettext("Text Inputs")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-input</.code> - Base input styling</li>
        <li><.code>pa-input--xs</.code> - Extra small input</li>
        <li><.code>pa-input--sm</.code> - Small input</li>
        <li><.code>pa-input--lg</.code> - Large input</li>
        <li><.code>pa-input--xl</.code> - Extra large input</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Select Dropdowns")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-select</.code> - Base select styling</li>
        <li><.code>pa-select--xs</.code> - Extra small select</li>
        <li><.code>pa-select--sm</.code> - Small select</li>
        <li><.code>pa-select--lg</.code> - Large select</li>
        <li><.code>pa-select--xl</.code> - Extra large select</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Textareas")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-textarea</.code> - Base textarea styling</li>
        <li><.code>pa-textarea--xs</.code> - Extra small textarea</li>
        <li><.code>pa-textarea--sm</.code> - Small textarea</li>
        <li><.code>pa-textarea--lg</.code> - Large textarea</li>
        <li><.code>pa-textarea--xl</.code> - Extra large textarea</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Input Groups")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-input-group</.code> - Container for input with addons</li>
        <li><.code>pa-input-group__prepend</.code> - Addon before input</li>
        <li><.code>pa-input-group__append</.code> - Addon after input</li>
        <li><.code>pa-input-group__button</.code> - Button addon</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Form Layout")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-form</.code> - Form container with label styling</li>
        <li><.code>pa-form-group</.code> - Form field container with spacing</li>
        <li><.code>pa-form-group--horizontal</.code> - Horizontal label/input layout</li>
        <li><.code>pa-form-actions</.code> - Container for form buttons</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Validation States (on form-group)")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-form-group--success</.code> - Success state (green border)</li>
        <li><.code>pa-form-group--warning</.code> - Warning state (yellow border)</li>
        <li><.code>pa-form-group--error</.code> - Error state (red border)</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Validation States (on input)")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-input--success</.code>, <.code>pa-select--success</.code>, <.code>pa-textarea--success</.code> - Success state</li>
        <li><.code>pa-input--warning</.code>, <.code>pa-select--warning</.code>, <.code>pa-textarea--warning</.code> - Warning state</li>
        <li><.code>pa-input--error</.code>, <.code>pa-select--error</.code>, <.code>pa-textarea--error</.code> - Error state</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Theme Color Variants (on input)")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-input--color-1</.code> through <.code>pa-input--color-9</.code> - Theme color slots</li>
        <li><.code>pa-select--color-1</.code> through <.code>pa-select--color-9</.code> - Theme color slots</li>
        <li><.code>pa-textarea--color-1</.code> through <.code>pa-textarea--color-9</.code> - Theme color slots</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Help Text")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-form-help</.code> - Help text below input</li>
        <li><.code>pa-form-help--success</.code> - Success colored help text</li>
        <li><.code>pa-form-help--warning</.code> - Warning colored help text</li>
        <li><.code>pa-form-help--error</.code> - Error colored help text</li>
        <li><.code>pa-form-help--color-1</.code> through <.code>pa-form-help--color-9</.code> - Theme color slots</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Checkboxes")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-checkbox-group</.code> - Container for multiple checkboxes</li>
        <li><.code>pa-checkbox</.code> - Checkbox wrapper (label element)</li>
        <li><.code>pa-checkbox__box</.code> - Custom checkbox visual</li>
        <li><.code>pa-checkbox__label</.code> - Checkbox label text</li>
        <li><.code>pa-checkbox--xs</.code> through <.code>pa-checkbox--xl</.code> - Size variants</li>
        <li><.code>pa-checkbox--disabled</.code> - Disabled state</li>
      </.basic_list>

      <.heading level={4} class="mt-4">{gettext("Radio Buttons")}</.heading>
      <.basic_list spacing="compact">
        <li><.code>pa-radio-group</.code> - Container for multiple radios</li>
        <li><.code>pa-radio</.code> - Radio button wrapper (label element)</li>
        <li><.code>pa-radio__label</.code> - Radio label text</li>
        <li><.code>pa-radio--xs</.code> through <.code>pa-radio--xl</.code> - Size variants</li>
      </.basic_list>
    </.card>
    """
  end
end
