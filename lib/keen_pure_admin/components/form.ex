defmodule PureAdmin.Components.Form do
  @moduledoc """
  Form components for Pure Admin.

  Provides both low-level HTML components (`input/1`, `select/1`, `textarea/1`,
  `checkbox/1`, `radio/1`) and Phoenix-aware components (`form_group/1`,
  `form_field/1`, `simple_form/1`).
  """
  use Phoenix.Component

  import PureAdmin.Helpers
  # form_error_summary/1 reuses the canonical pa-alert markup (mirrors svelte's
  # FormErrorSummary, which composes its <Alert>). Only alert/1 is imported to
  # avoid pulling in the module's other helpers.
  import PureAdmin.Components.Alert, only: [alert: 1]
  # User-facing summary heading is localized via the Translations bridge.
  import PureAdmin.Translations, only: [t: 2]

  # ─── Prop vocabulary (aligned with svelte-pure-admin) ───
  #
  # The canonical validation-state prop is `state` and the canonical theme-colour
  # prop is `theme_color` — matching svelte's `state` / `themeColor` (keen stays
  # snake_case; that's the sensible cross-stack translation). The older
  # `validation` / `color` props are kept as DEPRECATED ALIASES so existing
  # call-sites keep working; `resolve_state/1` and `resolve_theme_color/1`
  # coalesce old→new. Prefer `state` / `theme_color` in new markup.

  # Validation state: `state` wins; `validation` is the deprecated alias.
  defp resolve_state(assigns),
    do: Map.get(assigns, :state) || Map.get(assigns, :validation)

  # Theme colour (1-9): `theme_color` wins; `color` is the deprecated alias.
  # Accepts an integer or string and renders to the class as-is.
  defp resolve_theme_color(assigns),
    do: Map.get(assigns, :theme_color) || Map.get(assigns, :color)

  # ─── Phoenix.HTML.FormField integration ───

  @doc """
  Translates a Phoenix `{msg, opts}` error tuple into a plain string.

  Apps with Gettext-based error translation should configure their own formatter:

      config :keen_pure_admin,
        error_formatter: {MyAppWeb.CoreComponents, :translate_error}

  The formatter receives the raw `{msg, opts}` tuple and must return a string.
  The built-in default performs the same `%{key}` interpolation used by
  Ecto.Changeset's default error messages.
  """
  @spec translate_error({String.t(), keyword()}) :: String.t()
  def translate_error({msg, opts}) do
    case Application.get_env(:keen_pure_admin, :error_formatter) do
      {mod, fun} -> apply(mod, fun, [{msg, opts}])
      fun when is_function(fun, 1) -> fun.({msg, opts})
      _ -> default_translate_error({msg, opts})
    end
  end

  defp default_translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  # Pulls errors off a field, respecting `used_input?/1` so unsubmitted
  # fields don't show stale errors on initial render.
  defp field_errors(%Phoenix.HTML.FormField{} = field) do
    if Phoenix.Component.used_input?(field), do: field.errors, else: []
  end

  # ─── Low-level components ───

  @doc """
  Renders a **text-like** input (`text`, `email`, `password`, `tel`, `url`,
  `search`) with Pure Admin BEM classes. Mirrors svelte's `<Input>`.

  For other HTML input types use the dedicated typed components —
  `number_input/1`, `date_input/1`, `color_input/1`, `file_input/1`,
  `range_input/1` — each of which declares only the native attributes relevant to
  its type (so this component no longer carries the union of every type's attrs).

  Accepts either manual `name`/`value` attrs or a Phoenix `:field` for automatic
  binding. When `field` is given, `name`, `id`, and `value` are derived from it
  (explicit attrs win), and field errors automatically flip the input into the
  error state plus render a `form_help` below it (opt out with `show_errors={false}`).

  ## Examples

      <.input type="text" name="username" placeholder="Enter username" />
      <.input type="email" size="lg" state="error" />
      <.input field={@form[:email]} type="email" />
  """
  attr(:field, Phoenix.HTML.FormField,
    default: nil,
    doc: "A Phoenix form field, e.g. `@form[:email]`. When set, derives name/id/value and errors."
  )

  attr(:type, :string,
    default: "text",
    values: ~w(text email password tel url search),
    doc: "Text-like input type. Other types have dedicated components (number_input/1, date_input/1, …)."
  )

  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:value, :any, default: nil)

  attr(:errors, :list,
    default: nil,
    doc: "Raw `{msg, opts}` tuples or strings. Defaults to field errors when `:field` is set."
  )

  attr(:show_errors, :boolean,
    default: true,
    doc: "Render field errors as a form_help below the input. No effect without `:field`."
  )

  attr(:touched, :boolean,
    default: true,
    doc:
      "When false, suppresses the error state + inline help even if errors are present " <>
        "(mirrors svelte's `touched` gate). The `:field` path derives this from `used_input?/1`."
  )

  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning", "error"],
    doc: "Validation state (canonical; aligns with svelte `state`)."
  )

  attr(:validation, :string,
    default: nil,
    values: [nil, "success", "warning", "error"],
    doc: "Deprecated alias for `state`."
  )

  attr(:is_error, :boolean, default: false, doc: "Shorthand for state=\"error\"")
  attr(:is_success, :boolean, default: false, doc: "Shorthand for state=\"success\"")

  attr(:theme_color, :any,
    default: nil,
    doc: "Theme color 1-9 (int or string). Canonical; aligns with svelte `themeColor`."
  )

  attr(:color, :any, default: nil, doc: "Deprecated alias for `theme_color`.")

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(placeholder disabled readonly required autocomplete autofocus
    pattern maxlength minlength form phx-change phx-blur phx-focus phx-debounce))

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = assigns.errors || field_errors(field)

    assigns
    |> assign(
      field: nil,
      errors: errors,
      id: assigns.id || field.id,
      name: assigns.name || field.name,
      value: if(is_nil(assigns.value), do: field.value, else: assigns.value),
      state: assigns.state || assigns.validation || if(errors != [], do: "error")
    )
    |> input()
  end

  def input(assigns) do
    assigns =
      assigns
      |> assign_new(:errors, fn -> nil end)
      |> assign(:resolved_state, input_state(assigns))

    ~H"""
    <input
      type={@type}
      name={@name}
      id={@id}
      value={@value}
      class={input_classes(assigns)}
      aria-invalid={if @resolved_state == "error", do: "true"}
      {@rest}
    />
    <.form_help :if={@show_errors and @touched and has_errors?(@errors)} variant="error">
      {error_messages(@errors)}
    </.form_help>
    """
  end

  # Resolved validation state for input: explicit shorthands win, then
  # `state`/`validation`. `touched=false` cannot clear an explicitly-set state
  # (manual override), it only gates the error-from-errors derivation done above.
  defp input_state(assigns) do
    cond do
      assigns.is_error -> "error"
      assigns.is_success -> "success"
      true -> resolve_state(assigns)
    end
  end

  # -- error helpers shared by input/textarea/select --

  defp has_errors?(nil), do: false
  defp has_errors?([]), do: false
  defp has_errors?(_), do: true

  defp error_messages(errors) do
    errors
    |> Enum.map(fn
      {_msg, _opts} = tuple -> translate_error(tuple)
      str when is_binary(str) -> str
    end)
    |> Enum.join(". ")
  end

  defp input_classes(assigns) do
    state = Map.get(assigns, :resolved_state) || input_state(assigns)
    pa_input_classes(assigns.size, state, resolve_theme_color(assigns), assigns.class)
  end

  # Shared `.pa-input` class builder for every native-input component
  # (input/number_input/date_input/color_input/file_input/range_input). Keeps the
  # size/state/theme-colour modifier logic in one place now that the inputs are split.
  defp pa_input_classes(size, state, theme_color, extra) do
    build_classes(
      "pa-input",
      [
        {"pa-input--#{size}", size != nil},
        {"pa-input--#{state}", state != nil},
        {"pa-input--color-#{theme_color}", theme_color != nil}
      ],
      extra
    )
  end

  # Inline error help shared by the typed inputs that carry `errors`.
  attr(:errors, :list, default: nil)
  attr(:show_errors, :boolean, default: true)
  attr(:touched, :boolean, default: true)

  defp input_error(assigns) do
    ~H"""
    <.form_help :if={@show_errors and @touched and has_errors?(@errors)} variant="error">
      {error_messages(@errors)}
    </.form_help>
    """
  end

  @doc """
  Renders a numeric input (`type="number"`). Mirrors svelte's `<NumberInput>` —
  declares only the numeric native attrs (`min`/`max`/`step`). Accepts a Phoenix
  `:field` for automatic binding, same as `input/1`.

  ## Examples

      <.number_input name="qty" value={1} min="0" step="1" />
      <.number_input field={@form[:age]} min="0" max="120" />
  """
  attr(:field, Phoenix.HTML.FormField, default: nil, doc: "A Phoenix form field; derives name/id/value and errors.")
  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:value, :any, default: nil, doc: "Numeric value.")
  attr(:errors, :list, default: nil)
  attr(:show_errors, :boolean, default: true)
  attr(:touched, :boolean, default: true, doc: "When false, suppresses the error state + inline help.")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:state, :string, default: nil, values: [nil, "success", "warning", "error"], doc: "Validation state.")
  attr(:theme_color, :any, default: nil, doc: "Theme color 1-9 (int or string).")
  attr(:class, :string, default: nil)
  attr(:rest, :global,
    include: ~w(min max step placeholder disabled readonly required autofocus
      form phx-change phx-blur phx-focus phx-debounce)
  )

  def number_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = assigns.errors || field_errors(field)

    assigns
    |> assign(
      field: nil,
      errors: errors,
      id: assigns.id || field.id,
      name: assigns.name || field.name,
      value: if(is_nil(assigns.value), do: field.value, else: assigns.value),
      state: assigns.state || if(errors != [], do: "error")
    )
    |> number_input()
  end

  def number_input(assigns) do
    assigns =
      assigns
      |> assign_new(:errors, fn -> nil end)
      |> assign(resolved_state: assigns.state, resolved_theme_color: assigns.theme_color)

    ~H"""
    <input
      type="number"
      name={@name}
      id={@id}
      value={@value}
      class={pa_input_classes(@size, @resolved_state, @resolved_theme_color, @class)}
      aria-invalid={if @resolved_state == "error", do: "true"}
      {@rest}
    />
    <.input_error errors={@errors} show_errors={@show_errors} touched={@touched} />
    """
  end

  @doc """
  Renders a date/time input. Mirrors svelte's `<DateInput>` — `type` selects the
  flavour (`date`, `time`, `datetime-local`, `month`, `week`) and only the
  date/time native attrs (`min`/`max`/`step`) are declared. Accepts a Phoenix
  `:field`, same as `input/1`.

  ## Examples

      <.date_input name="due" value="2026-01-01" />
      <.date_input type="time" name="at" />
      <.date_input field={@form[:start_date]} />
  """
  attr(:field, Phoenix.HTML.FormField, default: nil, doc: "A Phoenix form field; derives name/id/value and errors.")

  attr(:type, :string,
    default: "date",
    values: ~w(date time datetime-local month week),
    doc: "Date/time flavour."
  )

  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:value, :any, default: nil, doc: "Date/time value as a string (format depends on `type`).")
  attr(:errors, :list, default: nil)
  attr(:show_errors, :boolean, default: true)
  attr(:touched, :boolean, default: true, doc: "When false, suppresses the error state + inline help.")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:state, :string, default: nil, values: [nil, "success", "warning", "error"], doc: "Validation state.")
  attr(:theme_color, :any, default: nil, doc: "Theme color 1-9 (int or string).")
  attr(:class, :string, default: nil)
  attr(:rest, :global,
    include: ~w(min max step disabled readonly required autofocus
      form phx-change phx-blur phx-focus phx-debounce)
  )

  def date_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = assigns.errors || field_errors(field)

    assigns
    |> assign(
      field: nil,
      errors: errors,
      id: assigns.id || field.id,
      name: assigns.name || field.name,
      value: if(is_nil(assigns.value), do: field.value, else: assigns.value),
      state: assigns.state || if(errors != [], do: "error")
    )
    |> date_input()
  end

  def date_input(assigns) do
    assigns =
      assigns
      |> assign_new(:errors, fn -> nil end)
      |> assign(resolved_state: assigns.state, resolved_theme_color: assigns.theme_color)

    ~H"""
    <input
      type={@type}
      name={@name}
      id={@id}
      value={@value}
      class={pa_input_classes(@size, @resolved_state, @resolved_theme_color, @class)}
      aria-invalid={if @resolved_state == "error", do: "true"}
      {@rest}
    />
    <.input_error errors={@errors} show_errors={@show_errors} touched={@touched} />
    """
  end

  @doc """
  Renders a range slider (`type="range"`). Mirrors svelte's `<RangeInput>` —
  declares the slider native attrs (`min`/`max`/`step`) and an optional value
  readout. No Phoenix `:field` binding (sliders bind their value directly).

  ## Examples

      <.range_input name="volume" value={50} min="0" max="100" />
      <.range_input value={30} show_value />
  """
  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:value, :any, default: nil, doc: "Numeric value.")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:state, :string, default: nil, values: [nil, "success", "warning", "error"], doc: "Validation state.")
  attr(:theme_color, :any, default: nil, doc: "Theme color 1-9 (int or string).")
  attr(:show_value, :boolean, default: false, doc: "Append the current value as an input-group addon.")
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(min max step disabled form phx-change phx-blur phx-debounce))

  def range_input(assigns) do
    assigns = assign(assigns, resolved_state: assigns.state, resolved_theme_color: assigns.theme_color)

    ~H"""
    <%= if @show_value do %>
      <div class="pa-input-group">
        <input
          type="range"
          name={@name}
          id={@id}
          value={@value}
          class={pa_input_classes(@size, @resolved_state, @resolved_theme_color, @class)}
          aria-invalid={if @resolved_state == "error", do: "true"}
          {@rest}
        />
        <span class="pa-input-group__append"><%= @value %></span>
      </div>
    <% else %>
      <input
        type="range"
        name={@name}
        id={@id}
        value={@value}
        class={pa_input_classes(@size, @resolved_state, @resolved_theme_color, @class)}
        aria-invalid={if @resolved_state == "error", do: "true"}
        {@rest}
      />
    <% end %>
    """
  end

  @doc """
  Renders a file input (`type="file"`). Mirrors svelte's `<FileInput>` — declares
  the file-specific native attrs (`accept`/`multiple`/`capture`). The browser owns
  the selected files, so there is no `value`/`:field` binding.

  ## Examples

      <.file_input name="avatar" accept="image/*" />
      <.file_input name="docs" accept=".pdf,.doc" multiple />
  """
  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:state, :string, default: nil, values: [nil, "success", "warning", "error"], doc: "Validation state.")
  attr(:theme_color, :any, default: nil, doc: "Theme color 1-9 (int or string).")
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(accept multiple capture disabled required form phx-change))

  def file_input(assigns) do
    assigns = assign(assigns, resolved_state: assigns.state, resolved_theme_color: assigns.theme_color)

    ~H"""
    <input
      type="file"
      name={@name}
      id={@id}
      class={pa_input_classes(@size, @resolved_state, @resolved_theme_color, @class)}
      aria-invalid={if @resolved_state == "error", do: "true"}
      {@rest}
    />
    """
  end

  @doc """
  Renders a colour picker (`type="color"`). Mirrors svelte's `<ColorInput>` —
  the native colour input is styled by the base `.pa-input` (no state/theme-colour
  modifiers apply to it), with an optional hex readout.

  ## Examples

      <.color_input name="brand" value="#3b82f6" />
      <.color_input value="#ff0000" show_value />
  """
  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:value, :string, default: "#000000", doc: "Colour value as a hex string.")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:show_value, :boolean, default: false, doc: "Append the hex value as an input-group addon.")
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form phx-change phx-blur))

  def color_input(assigns) do
    ~H"""
    <%= if @show_value do %>
      <div class="pa-input-group">
        <input
          type="color"
          name={@name}
          id={@id}
          value={@value}
          class={pa_input_classes(@size, nil, nil, @class)}
          {@rest}
        />
        <span class="pa-input-group__append"><%= @value %></span>
      </div>
    <% else %>
      <input
        type="color"
        name={@name}
        id={@id}
        value={@value}
        class={pa_input_classes(@size, nil, nil, @class)}
        {@rest}
      />
    <% end %>
    """
  end

  @doc """
  Renders a textarea with Pure Admin BEM classes.

  Accepts a Phoenix `:field` for automatic binding, same as `input/1`.

  ## Examples

      <.textarea name="message" rows={4} placeholder="Enter message" />
      <.textarea field={@form[:bio]} rows={4} />
  """
  attr(:field, Phoenix.HTML.FormField,
    default: nil,
    doc: "A Phoenix form field, e.g. `@form[:bio]`. When set, derives name/id/value and errors."
  )

  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:errors, :list, default: nil)
  attr(:show_errors, :boolean, default: true)

  attr(:touched, :boolean,
    default: true,
    doc: "When false, suppresses error state + inline help (mirrors svelte's `touched` gate)."
  )

  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning", "error"],
    doc: "Validation state (canonical; aligns with svelte `state`)."
  )

  attr(:validation, :string,
    default: nil,
    values: [nil, "success", "warning", "error"],
    doc: "Deprecated alias for `state`."
  )

  attr(:theme_color, :any,
    default: nil,
    doc: "Theme color 1-9 (int or string). Canonical; aligns with svelte `themeColor`."
  )

  attr(:color, :any, default: nil, doc: "Deprecated alias for `theme_color`.")

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(placeholder disabled readonly required rows cols
    form phx-change phx-blur phx-debounce))

  def textarea(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = assigns.errors || field_errors(field)

    assigns
    |> assign(
      field: nil,
      errors: errors,
      id: assigns.id || field.id,
      name: assigns.name || field.name,
      value: if(is_nil(assigns.value), do: field.value, else: assigns.value),
      state: assigns.state || assigns.validation || if(errors != [], do: "error")
    )
    |> textarea()
  end

  def textarea(assigns) do
    assigns =
      assigns
      |> assign_new(:errors, fn -> nil end)
      |> assign(:resolved_state, resolve_state(assigns))

    ~H"""
    <textarea
      name={@name}
      id={@id}
      class={textarea_classes(assigns)}
      aria-invalid={if @resolved_state == "error", do: "true"}
      {@rest}
    ><%= @value %></textarea>
    <.form_help :if={@show_errors and @touched and has_errors?(@errors)} variant="error">
      {error_messages(@errors)}
    </.form_help>
    """
  end

  defp textarea_classes(assigns) do
    # Core has NO `.pa-textarea--success/--warning/--error` border styling
    # (unlike .pa-input/.pa-select). Textarea errors surface through the
    # `pa-form-help--error` rendered below (and `aria-invalid`), not a border
    # modifier (snippets/forms.html). `state` stays declared for the shared
    # field-binding path but emits no textarea class.
    theme_color = resolve_theme_color(assigns)

    build_classes(
      "pa-textarea",
      [
        {"pa-textarea--#{assigns.size}", assigns.size != nil},
        {"pa-textarea--color-#{theme_color}", theme_color != nil}
      ],
      assigns.class
    )
  end

  @doc """
  Renders a select dropdown with Pure Admin BEM classes.

  Accepts a Phoenix `:field` for automatic binding, same as `input/1`.

  ## Examples

      <.select name="country" options={[{"US", "United States"}, {"UK", "United Kingdom"}]} />
      <.select field={@form[:department]} options={["Engineering", "Sales"]} />
  """
  attr(:field, Phoenix.HTML.FormField,
    default: nil,
    doc: "A Phoenix form field, e.g. `@form[:role]`. When set, derives name/id/value and errors."
  )

  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:errors, :list, default: nil)
  attr(:show_errors, :boolean, default: true)
  attr(:touched, :boolean,
    default: true,
    doc: "When false, suppresses error state + inline help (mirrors svelte's `touched` gate)."
  )

  attr(:options, :list, default: [], doc: "List of {value, label} tuples or strings")
  attr(:prompt, :string, default: nil, doc: "Placeholder option")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning", "error"],
    doc: "Validation state (canonical; aligns with svelte `state`)."
  )

  attr(:validation, :string,
    default: nil,
    values: [nil, "success", "warning", "error"],
    doc: "Deprecated alias for `state`."
  )

  attr(:theme_color, :any,
    default: nil,
    doc: "Theme color 1-9 (int or string). Canonical; aligns with svelte `themeColor`."
  )

  attr(:color, :any, default: nil, doc: "Deprecated alias for `theme_color`.")

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled required multiple form phx-change phx-blur phx-debounce))

  def select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = assigns.errors || field_errors(field)

    assigns
    |> assign(
      field: nil,
      errors: errors,
      id: assigns.id || field.id,
      name: assigns.name || field.name,
      value: if(is_nil(assigns.value), do: field.value, else: assigns.value),
      state: assigns.state || assigns.validation || if(errors != [], do: "error")
    )
    |> select()
  end

  def select(assigns) do
    assigns =
      assigns
      |> assign_new(:errors, fn -> nil end)
      |> assign(:resolved_state, resolve_state(assigns))

    ~H"""
    <select
      name={@name}
      id={@id}
      class={select_classes(assigns)}
      aria-invalid={if @resolved_state == "error", do: "true"}
      {@rest}
    >
      <option :if={@prompt} value=""><%= @prompt %></option>
      <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
    </select>
    <.form_help :if={@show_errors and @touched and has_errors?(@errors)} variant="error">
      {error_messages(@errors)}
    </.form_help>
    """
  end

  defp select_classes(assigns) do
    state = Map.get(assigns, :resolved_state) || resolve_state(assigns)
    theme_color = resolve_theme_color(assigns)

    build_classes(
      "pa-select",
      [
        {"pa-select--#{assigns.size}", assigns.size != nil},
        {"pa-select--#{state}", state != nil},
        {"pa-select--color-#{theme_color}", theme_color != nil}
      ],
      assigns.class
    )
  end

  @doc """
  Renders a custom tri-state checkbox with Pure Admin BEM classes.

  Accepts a Phoenix `:field` for automatic binding. When `field` is given,
  `name`, `id`, and `checked` are derived (checked when the field value is
  truthy — specifically `true`, `"true"`, or `"on"`). Errors are available via
  the field struct but not rendered inline — place them on the enclosing
  `form_group` or `form_help` instead.

  ## Examples

      <.checkbox name="agree" label="I agree to the terms" />
      <.checkbox name="option" label="Option A" checked size="lg" />
      <.checkbox field={@form[:agree]} label="I agree to the terms" />
  """
  attr(:field, Phoenix.HTML.FormField,
    default: nil,
    doc: "A Phoenix form field, e.g. `@form[:agree]`. When set, derives name/id/checked."
  )

  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:value, :string, default: "true")
  attr(:checked, :boolean, default: false)

  attr(:is_indeterminate, :boolean,
    default: false,
    doc: "Indeterminate/partial state (requires PureAdminCheckbox hook)"
  )

  attr(:is_x_mark, :boolean, default: false, doc: "X mark instead of checkmark")

  attr(:label_text, :string,
    default: nil,
    doc: "Plain text label (canonical; aligns with svelte `labelText`)."
  )

  attr(:label, :string, default: nil, doc: "Deprecated alias for `label_text`.")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])

  attr(:label_position, :string,
    default: nil,
    values: [nil, "start", "end", "top"],
    doc:
      "Label placement relative to the box (emits `pa-checkbox--label-{position}`). " <>
        "`end` (default look) puts the label after the box; `start` before; `top` above."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Disabled state — emits `pa-checkbox--disabled` on the label and `disabled` on the input."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(required form phx-change phx-click phx-debounce))
  slot(:label_content, doc: "Rich HTML label content (alternative to label attr)")

  def checkbox(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(
      field: nil,
      id: assigns.id || field.id,
      name: assigns.name || field.name,
      checked: assigns.checked || checked_from_value(field.value, assigns.value)
    )
    |> checkbox()
  end

  def checkbox(assigns) do
    # Generate a stable hook id when indeterminate is used
    hook_id = if assigns.is_indeterminate, do: assigns.id || "cb-#{:erlang.phash2(assigns)}"
    assigns = assign(assigns, :hook_id, hook_id)

    ~H"""
    <label
      class={checkbox_classes(assigns)}
      id={@hook_id}
      phx-hook={if @is_indeterminate, do: "PureAdminCheckbox"}
      data-indeterminate={if @is_indeterminate, do: "true"}
    >
      <input type="checkbox" name={@name} id={@id} value={@value} checked={@checked} disabled={@disabled} {@rest} />
      <span class="pa-checkbox__box"></span>
      <span :if={(@label_text || @label) && @label_content == []} class="pa-checkbox__label"><%= @label_text || @label %></span>
      <span :if={@label_content != []} class="pa-checkbox__label"><%= render_slot(@label_content) %></span>
    </label>
    """
  end

  # Checkbox checked state from a form value. Matches Phoenix/Ecto conventions:
  # booleans, "true"/"on" strings, and exact `value` matches all count as checked.
  defp checked_from_value(true, _), do: true
  defp checked_from_value(false, _), do: false
  defp checked_from_value(nil, _), do: false
  defp checked_from_value("true", _), do: true
  defp checked_from_value("on", _), do: true
  defp checked_from_value(str, value) when is_binary(str), do: str == value
  defp checked_from_value(_, _), do: false

  defp checkbox_classes(assigns) do
    build_classes(
      "pa-checkbox",
      [
        {"pa-checkbox--#{assigns.size}", assigns.size != nil},
        {"pa-checkbox--label-#{assigns.label_position}", assigns.label_position != nil},
        {"pa-checkbox--x", assigns.is_x_mark},
        {"pa-checkbox--disabled", assigns.disabled}
      ],
      assigns.class
    )
  end

  @doc """
  Renders a radio button with Pure Admin BEM classes.

  Accepts a Phoenix `:field` for automatic binding. `checked` is derived from
  `to_string(field.value) == value`. Render a set of radios over the same
  `@form[:role]` field by giving each a distinct `value`.

  ## Examples

      <.radio name="plan" value="basic" label="Basic Plan" />
      <.radio field={@form[:plan]} value="basic" label="Basic Plan" />
      <.radio field={@form[:plan]} value="pro" label="Pro Plan" />
  """
  attr(:field, Phoenix.HTML.FormField,
    default: nil,
    doc: "A Phoenix form field, e.g. `@form[:plan]`. When set, derives name/checked."
  )

  attr(:name, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:value, :string, required: true)
  attr(:checked, :boolean, default: false)

  attr(:label_text, :string,
    default: nil,
    doc: "Plain text label (canonical; aligns with svelte `labelText`)."
  )

  attr(:label, :string, default: nil, doc: "Deprecated alias for `label_text`.")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"], doc: "Scales the native radio (emits pa-radio--{size})")

  attr(:label_position, :string,
    default: nil,
    values: [nil, "start", "end", "top"],
    doc:
      "Label placement relative to the control (emits `pa-radio--label-{position}`; requires the " <>
        "`pa-radio__label` wrapper, which this component always emits). `end` (default look) after, " <>
        "`start` before, `top` above."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled required form phx-change phx-click phx-debounce))
  slot(:label_content, doc: "Rich HTML label content (alternative to label attr)")

  def radio(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(
      field: nil,
      name: assigns.name || field.name,
      checked: assigns.checked || to_string(field.value) == assigns.value
    )
    |> radio()
  end

  def radio(assigns) do
    ~H"""
    <label class={radio_classes(assigns)}>
      <input type="radio" name={@name} id={@id} value={@value} checked={@checked} {@rest} />
      <span :if={(@label_text || @label) && @label_content == []} class="pa-radio__label"><%= @label_text || @label %></span>
      <span :if={@label_content != []} class="pa-radio__label"><%= render_slot(@label_content) %></span>
    </label>
    """
  end

  # Canonical radio wraps its label text in `.pa-radio__label` (snippets/forms.html:257).
  # The span is required for label positioning and the required-asterisk `::after`.
  defp radio_classes(assigns) do
    build_classes(
      "pa-radio",
      [
        {"pa-radio--#{assigns.size}", assigns.size != nil},
        {"pa-radio--label-#{assigns.label_position}", assigns.label_position != nil}
      ],
      assigns.class
    )
  end

  # ─── Form structure components ───

  @doc """
  Renders a form group wrapper with optional validation state.

  ## Examples

      <.form_group>
        <.form_label for="email">Email</.form_label>
        <.input type="email" name="email" id="email" />
      </.form_group>

      <.form_group validation="error">
        <.form_label for="name">Name</.form_label>
        <.input type="text" name="name" id="name" required />
        <.form_help variant="error">Name is required</.form_help>
      </.form_group>
  """
  attr(:field, Phoenix.HTML.FormField,
    default: nil,
    doc: "A Phoenix form field. When set, `validation` auto-switches to `\"error\"` if the field has errors."
  )

  attr(:label, :string, default: nil, doc: "Shorthand for a simple text label")

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning", "error"],
    doc: "Validation state (canonical; aligns with svelte `state`)."
  )

  attr(:validation, :string,
    default: nil,
    values: [nil, "success", "warning", "error"],
    doc: "Deprecated alias for `state`."
  )

  attr(:is_required, :boolean,
    default: false,
    doc:
      "Emits `pa-form-group--required` — the escape hatch for NON-native widgets " <>
        "(custom selects, image browsers, web components) that have no `:required` " <>
        "descendant for core's `:has(:required) > label::after` auto-asterisk. For a " <>
        "native control, prefer the native `required` attribute on the input instead " <>
        "(the marker then appears for free)."
  )

  attr(:is_horizontal, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def form_group(%{field: %Phoenix.HTML.FormField{} = field, state: nil, validation: nil} = assigns) do
    assigns
    |> assign(
      field: nil,
      state: if(field_errors(field) != [], do: "error")
    )
    |> form_group()
  end

  def form_group(assigns) do
    ~H"""
    <div class={form_group_classes(assigns)} {@rest}>
      <label :if={@label}><%= @label %></label>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp form_group_classes(assigns) do
    # A <label> inside `.pa-form .pa-form-group` is auto-styled by core — there
    # is NO `.pa-form-label` class (snippets/forms.html). `pa-form-group--required`
    # IS a live core rule (the escape hatch for non-native widgets — forms.html:
    # REQUIRED FIELDS §2); emit it when `is_required` is set. Native controls
    # should still prefer the native `required` attr so the auto-asterisk fires
    # without the class.
    state = resolve_state(assigns)

    build_classes(
      "pa-form-group",
      [
        {"pa-form-group--#{state}", state != nil},
        {"pa-form-group--required", assigns.is_required},
        {"pa-form-group--horizontal", assigns.is_horizontal}
      ],
      assigns.class
    )
  end

  @doc """
  Renders a form label.

  The required asterisk is **attribute-driven**: mark the associated control with
  the native `required` attribute and core renders the marker via
  `.pa-form-group:has(:required) > label:not(.pa-checkbox):not(.pa-radio)::after`
  (core 2.9.0+). The label needs no class and no manual asterisk.
  """
  attr(:for, :string, default: nil)

  attr(:is_required, :boolean,
    default: false,
    doc:
      "Deprecated no-op. Requiredness is now driven by the native `required` attribute " <>
        "on the control (core auto-renders the asterisk). Pass `required` to the input/select/textarea."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def form_label(assigns) do
    # Core auto-styles a bare `<label>` inside `.pa-form-group` (no
    # `.pa-form-label` class) and adds the required asterisk itself when the
    # group holds a `:required` control — so keen emits a plain label with no
    # manual asterisk (which would otherwise double up).
    ~H"""
    <label for={@for} class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Renders help/hint text below inputs.
  """
  attr(:variant, :string, default: nil, values: [nil, "success", "warning", "error"])

  attr(:theme_color, :any,
    default: nil,
    doc: "Theme color 1-9 (int or string). Canonical; aligns with svelte `themeColor`."
  )

  attr(:color, :any, default: nil, doc: "Deprecated alias for `theme_color`.")

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def form_help(assigns) do
    assigns = assign(assigns, :theme_color, resolve_theme_color(assigns))

    ~H"""
    <small
      class={build_classes("pa-form-help", [
        {"pa-form-help--#{@variant}", @variant != nil},
        {"pa-form-help--color-#{@theme_color}", @theme_color != nil}
      ], @class)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </small>
    """
  end

  @doc """
  Renders an input group (input with prepend/append elements).

  ## Examples

      <.input_group>
        <:prepend>@</:prepend>
        <.input type="text" name="username" placeholder="Username" />
      </.input_group>

      <.input_group>
        <.input type="text" name="search" placeholder="Search..." />
        <:button>
          <%!-- The button addon MUST carry pa-input-group__button so it keeps
               the group's joined border-radius (see snippets/forms.html). --%>
          <.button variant="primary" class="pa-input-group__button">Search</.button>
        </:button>
      </.input_group>
  """
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"], doc: "Matches prepend/append height (emits pa-input-group--{size})")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:prepend, doc: "Left addon text")
  slot(:append, doc: "Right addon text")
  slot(:button, doc: "Button addon — pass class=\"pa-input-group__button\" on the button so it keeps the group's joined radius")
  slot(:inner_block, required: true)

  def input_group(assigns) do
    ~H"""
    <div class={build_classes("pa-input-group", [{"pa-input-group--#{@size}", @size != nil}], @class)} {@rest}>
      <span :for={prepend <- @prepend} class="pa-input-group__prepend"><%= render_slot(prepend) %></span>
      <%= render_slot(@inner_block) %>
      <span :for={append <- @append} class="pa-input-group__append"><%= render_slot(append) %></span>
      <%= for button <- @button do %>
        <%= render_slot(button) %>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a checkbox group (vertical stack by default).
  """
  attr(:layout, :string,
    default: nil,
    values: [nil, "horizontal", "grid", "2col", "3col"],
    doc:
      "Group layout (emits `pa-checkbox-group--{layout}`). Default (nil) is a vertical stack; " <>
        "`horizontal` inlines, `grid`/`2col`/`3col` arrange in columns."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def checkbox_group(assigns) do
    ~H"""
    <div class={build_classes("pa-checkbox-group", [{"pa-checkbox-group--#{@layout}", @layout != nil}], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a radio button group (vertical stack by default).
  """
  attr(:layout, :string,
    default: nil,
    values: [nil, "horizontal", "grid", "2col", "3col"],
    doc:
      "Group layout (emits `pa-radio-group--{layout}`). Default (nil) is a vertical stack; " <>
        "`horizontal` inlines, `grid`/`2col`/`3col` arrange in columns."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def radio_group(assigns) do
    ~H"""
    <div class={build_classes("pa-radio-group", [{"pa-radio-group--#{@layout}", @layout != nil}], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a Phoenix-aware form with Pure Admin classes.

  Wraps `Phoenix.Component.form/1` with Pure Admin styling.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.form_group>
          <.form_label for="name">Name</.form_label>
          <.input type="text" name={@form[:name].name} value={@form[:name].value} required />
        </.form_group>
        <:actions>
          <.button variant="primary" type="submit">Save</.button>
        </:actions>
      </.simple_form>
  """
  attr(:for, :any, required: true, doc: "Phoenix form struct or changeset")
  attr(:as, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-change phx-submit phx-target autocomplete))
  slot(:inner_block, required: true)
  slot(:actions, doc: "Form action buttons")

  def simple_form(assigns) do
    # Note: former `is_inline` attr emitted `pa-form--inline`, which has no core
    # CSS (core has no inline-form modifier) — dropped as a dead class.
    ~H"""
    <.form
      for={@for}
      as={@as}
      class={build_classes("pa-form", [], @class)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <%!-- Blessed actions row: pa-form-actions (forms.html:57-60), not a grid row.
           justify-content-end keeps the buttons right-aligned. --%>
      <div :for={actions <- @actions} class="pa-form-actions justify-content-end">
        <%= render_slot(actions) %>
      </div>
    </.form>
    """
  end

  # ─── Input wrapper ───

  @doc """
  Wraps an input or select with an optional clear button.

  The clear button emits a `phx-click` event when clicked (defaults to the
  `on_clear` attr value) so the parent LiveView can reset the field.

  ## Examples

      <.input_wrapper>
        <.input type="text" placeholder="Search..." />
      </.input_wrapper>

      <.input_wrapper on_clear="clear-search">
        <.input type="text" placeholder="Search..." />
      </.input_wrapper>

      <.input_wrapper has_clear={false}>
        <.input type="text" placeholder="No clear button" />
      </.input_wrapper>
  """
  attr(:has_clear, :boolean, default: true, doc: "Show the clear (×) button")
  attr(:on_clear, :string, default: nil, doc: "phx-click event for the clear button")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def input_wrapper(assigns) do
    ~H"""
    <div class={build_classes("pa-input-wrapper", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
      <button :if={@has_clear} class="pa-input-wrapper__clear" type="button" phx-click={@on_clear} aria-label="Clear">
        <span class="pa-icon pa-icon--x" aria-hidden="true"></span>
      </button>
    </div>
    """
  end

  # ─── High-level orchestrators (mirror svelte FormField / FormErrorSummary) ───

  @doc """
  Renders a complete field — `form_group` + label + control + help/error/success
  text — with automatic state derivation. Mirrors svelte's `<FormField>`.

  The control is the inner block; it receives `%{errors, touched, state}` via
  `:let` so you can forward the derived state into the input:

      <.form_field label_text="Email" errors={@errors} touched={@touched} :let={f}>
        <.input type="email" name="email" state={f.state} touched={f.touched} show_errors={false} />
      </.form_field>

  Pass a Phoenix `:field` instead to derive `errors`/`touched` automatically
  (touched follows `used_input?/1`):

      <.form_field field={@form[:email]} label_text="Email" :let={f}>
        <.input field={@form[:email]} type="email" show_errors={false} />
      </.form_field>

  State precedence matches svelte: an explicit `state` always wins; otherwise the
  error state only shows once `touched`, and the success message only shows when
  touched, error-free, and `has_value`.
  """
  attr(:field, Phoenix.HTML.FormField,
    default: nil,
    doc: "Optional Phoenix field; derives `errors` + `touched` (via `used_input?/1`) and `has_value`."
  )

  attr(:label_text, :string, default: nil, doc: "Field label (aligns with svelte `labelText`).")
  attr(:help_text, :string, default: nil, doc: "Default hint shown when there is no error/success.")

  attr(:success_message, :string,
    default: nil,
    doc: "Shown when touched, error-free, and `has_value` (aligns with svelte `successMessage`)."
  )

  attr(:errors, :list, default: nil, doc: "Raw `{msg, opts}` tuples or strings.")

  attr(:touched, :boolean,
    default: false,
    doc: "Whether the field has been interacted with. Gates the error/success display."
  )

  attr(:has_value, :boolean, default: false, doc: "Whether the field has a value (for success display).")

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning", "error"],
    doc: "Manual state override — takes precedence over error derivation."
  )

  attr(:for, :string, default: nil, doc: "`for=` on the label / id of the control.")
  attr(:is_horizontal, :boolean, default: false)
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  def form_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(
      field: nil,
      errors: assigns.errors || field_errors(field),
      touched: assigns.touched || Phoenix.Component.used_input?(field),
      has_value: assigns.has_value || present?(field.value)
    )
    |> form_field()
  end

  def form_field(assigns) do
    errors = assigns.errors || []
    has_errors = errors != []

    show_error = is_nil(assigns.state) and assigns.touched and has_errors

    show_success =
      is_nil(assigns.state) and assigns.touched and not has_errors and
        assigns.has_value and assigns.success_message != nil

    # Which help text to render (one of error / success / hint), and its variant.
    {help_content, help_variant} =
      cond do
        show_error -> {error_messages(errors), "error"}
        show_success -> {assigns.success_message, "success"}
        assigns.help_text != nil -> {assigns.help_text, assigns.state}
        true -> {nil, nil}
      end

    # Resolved state handed to the control + used for the group border.
    resolved_state = assigns.state || if(show_error, do: "error")

    assigns =
      assign(assigns,
        errors: errors,
        resolved_state: resolved_state,
        help_content: help_content,
        help_variant: help_variant
      )

    ~H"""
    <.form_group state={@resolved_state} is_horizontal={@is_horizontal} class={@class}>
      <.form_label :if={@label_text} for={@for}><%= @label_text %></.form_label>
      <%= render_slot(@inner_block, %{errors: @errors, touched: @touched, state: @resolved_state}) %>
      <.form_help :if={@help_content} variant={@help_variant}><%= @help_content %></.form_help>
    </.form_group>
    """
  end

  defp present?(nil), do: false
  defp present?(""), do: false
  defp present?([]), do: false
  defp present?(_), do: true

  @doc """
  Renders a dismissible-free summary of form errors with anchor links to each
  field. Mirrors svelte's `<FormErrorSummary>` — a danger alert with a count
  heading and a linked list.

  ## Example

      <.form_error_summary
        show={@submitted and @errors != []}
        errors={[
          %{field: "Email", id: "user_email", message: "can't be blank"},
          %{field: "Name", id: "user_name", message: "is too short"}
        ]}
      />
  """
  attr(:errors, :list,
    required: true,
    doc: "List of `%{field:, id:, message:}` maps. `id` is the target control's id (anchor target)."
  )

  attr(:show, :boolean, default: true, doc: "Gate rendering (typically `submitted and errors != []`).")
  attr(:class, :string, default: nil)

  def form_error_summary(assigns) do
    assigns = assign(assigns, :count, length(assigns.errors))

    ~H"""
    <.alert
      :if={@show and @count > 0}
      variant="danger"
      class={build_classes("mb-4", [], @class)}
      heading_text={t(if(@count == 1, do: "pureAdmin.form.errorFound", else: "pureAdmin.form.errorsFound"), %{count: @count})}
    >
      <:list>
        <li :for={e <- @errors}>
          <a href={"#" <> e.id}><%= e.field %></a> - <%= e.message %>
        </li>
      </:list>
    </.alert>
    """
  end
end
