defmodule PureAdmin.Components.Form do
  @moduledoc """
  Form components for Pure Admin.

  Provides both low-level HTML components (`input/1`, `select/1`, `textarea/1`,
  `checkbox/1`, `radio/1`) and Phoenix-aware components (`form_group/1`,
  `form_field/1`, `simple_form/1`).
  """
  use Phoenix.Component

  import PureAdmin.Helpers

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
  Renders a text input with Pure Admin BEM classes.

  Accepts either manual `name`/`value` attrs or a Phoenix `:field` for automatic
  binding. When `field` is given, `name`, `id`, and `value` are derived from it
  (explicit attrs win), and field errors automatically flip the input into the
  error state plus render a `form_help` below it (opt out with `show_errors={false}`).

  ## Examples

      <.input type="text" name="username" placeholder="Enter username" />
      <.input type="email" size="lg" validation="error" />
      <.input field={@form[:email]} type="email" />
  """
  attr(:field, Phoenix.HTML.FormField,
    default: nil,
    doc: "A Phoenix form field, e.g. `@form[:email]`. When set, derives name/id/value and errors."
  )

  attr(:type, :string, default: "text")
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

  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:validation, :string, default: nil, values: [nil, "success", "warning", "error"])
  attr(:is_error, :boolean, default: false, doc: "Shorthand for validation=\"error\"")
  attr(:is_success, :boolean, default: false, doc: "Shorthand for validation=\"success\"")

  attr(:color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    doc: "Theme color (1-9)"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(placeholder disabled readonly required autocomplete autofocus
    min max step pattern maxlength minlength form phx-change phx-blur phx-focus phx-debounce))

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = assigns.errors || field_errors(field)

    assigns
    |> assign(
      field: nil,
      errors: errors,
      id: assigns.id || field.id,
      name: assigns.name || field.name,
      value: if(is_nil(assigns.value), do: field.value, else: assigns.value),
      validation: assigns.validation || if(errors != [], do: "error")
    )
    |> input()
  end

  def input(assigns) do
    assigns = assign_new(assigns, :errors, fn -> nil end)

    ~H"""
    <input
      type={@type}
      name={@name}
      id={@id}
      value={@value}
      class={input_classes(assigns)}
      {@rest}
    />
    <.form_help :if={@show_errors and has_errors?(@errors)} variant="error">
      {error_messages(@errors)}
    </.form_help>
    """
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
    validation =
      cond do
        assigns.is_error -> "error"
        assigns.is_success -> "success"
        true -> assigns.validation
      end

    build_classes(
      "pa-input",
      [
        {"pa-input--#{assigns.size}", assigns.size != nil},
        {"pa-input--#{validation}", validation != nil},
        {"pa-input--color-#{assigns.color}", assigns.color != nil}
      ],
      assigns.class
    )
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
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:validation, :string, default: nil, values: [nil, "success", "warning", "error"])

  attr(:color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  )

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
      validation: assigns.validation || if(errors != [], do: "error")
    )
    |> textarea()
  end

  def textarea(assigns) do
    assigns = assign_new(assigns, :errors, fn -> nil end)

    ~H"""
    <textarea
      name={@name}
      id={@id}
      class={textarea_classes(assigns)}
      {@rest}
    ><%= @value %></textarea>
    <.form_help :if={@show_errors and has_errors?(@errors)} variant="error">
      {error_messages(@errors)}
    </.form_help>
    """
  end

  defp textarea_classes(assigns) do
    # Core has NO `.pa-textarea--success/--warning/--error` border styling
    # (unlike .pa-input/.pa-select). Textarea errors surface through the
    # `pa-form-help--error` rendered below, not a border modifier
    # (snippets/forms.html). `validation` stays declared for the shared
    # field-binding path but emits no textarea class.
    build_classes(
      "pa-textarea",
      [
        {"pa-textarea--#{assigns.size}", assigns.size != nil},
        {"pa-textarea--color-#{assigns.color}", assigns.color != nil}
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
  attr(:options, :list, default: [], doc: "List of {value, label} tuples or strings")
  attr(:prompt, :string, default: nil, doc: "Placeholder option")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:validation, :string, default: nil, values: [nil, "success", "warning", "error"])

  attr(:color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  )

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
      validation: assigns.validation || if(errors != [], do: "error")
    )
    |> select()
  end

  def select(assigns) do
    assigns = assign_new(assigns, :errors, fn -> nil end)

    ~H"""
    <select name={@name} id={@id} class={select_classes(assigns)} {@rest}>
      <option :if={@prompt} value=""><%= @prompt %></option>
      <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
    </select>
    <.form_help :if={@show_errors and has_errors?(@errors)} variant="error">
      {error_messages(@errors)}
    </.form_help>
    """
  end

  defp select_classes(assigns) do
    build_classes(
      "pa-select",
      [
        {"pa-select--#{assigns.size}", assigns.size != nil},
        {"pa-select--#{assigns.validation}", assigns.validation != nil},
        {"pa-select--color-#{assigns.color}", assigns.color != nil}
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
  attr(:label, :string, default: nil, doc: "Plain text label")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])

  attr(:label_position, :string,
    default: nil,
    values: [nil, "start", "end", "top"],
    doc:
      "Label placement relative to the box (emits `pa-checkbox--label-{position}`). " <>
        "`end` (default look) puts the label after the box; `start` before; `top` above."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled required form phx-change phx-click phx-debounce))
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
      data-indeterminate={to_string(@is_indeterminate)}
    >
      <input type="checkbox" name={@name} id={@id} value={@value} checked={@checked} {@rest} />
      <span class="pa-checkbox__box"></span>
      <span :if={@label && @label_content == []} class="pa-checkbox__label"><%= @label %></span>
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
        {"pa-checkbox--disabled", Map.get(assigns, :disabled, false)}
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
  attr(:label, :string, default: nil)
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
      <span :if={@label && @label_content == []} class="pa-radio__label"><%= @label %></span>
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
  attr(:validation, :string, default: nil, values: [nil, "success", "warning", "error"])

  attr(:is_required, :boolean,
    default: false,
    doc:
      "Deprecated no-op. Mark the control with the native `required` attribute instead — " <>
        "core renders the required asterisk on the group's label automatically."
  )

  attr(:is_horizontal, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def form_group(%{field: %Phoenix.HTML.FormField{} = field, validation: nil} = assigns) do
    assigns
    |> assign(
      field: nil,
      validation: if(field_errors(field) != [], do: "error")
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
    # is NO `.pa-form-label` class (snippets/forms.html). And core defines no
    # `.pa-form-group--required` rule; use the native `required` attr on the
    # control instead. Only validation + horizontal are real modifiers.
    build_classes(
      "pa-form-group",
      [
        {"pa-form-group--#{assigns.validation}", assigns.validation != nil},
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

  attr(:color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    doc: "Theme color (1-9)"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def form_help(assigns) do
    ~H"""
    <small
      class={build_classes("pa-form-help", [
        {"pa-form-help--#{@variant}", @variant != nil},
        {"pa-form-help--color-#{@color}", @color != nil}
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
      <div :for={actions <- @actions} class="pc-row">
        <div class="pc-col-100 text-end">
          <%= render_slot(actions) %>
        </div>
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
end
