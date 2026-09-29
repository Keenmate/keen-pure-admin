defmodule PureAdmin.Components.FormTest do
  use PureAdmin.ComponentCase, async: false

  import Phoenix.Component, only: [to_form: 2, sigil_H: 2]
  import PureAdmin.Components.Form

  alias PureAdmin.Components.Form

  # Renders a HEEx template so attr defaults, assign_new, and the `:field`
  # pattern-matched head all behave as they do in real templates.
  defp render(template_fun, assigns) do
    Phoenix.LiveViewTest.render_component(template_fun, assigns)
  end

  describe "form_group/1 + form_label/1 use core-blessed markup" do
    test "form_group label is a bare <label> — no pa-form-label class" do
      html =
        render(
          fn assigns ->
            ~H'<.form_group label="Email"><input /></.form_group>'
          end,
          %{}
        )

      refute_class(html, "pa-form-label")
      assert html =~ "<label>Email</label>"
    end

    test "is_required does not emit pa-form-group--required (no core rule)" do
      html =
        render(
          fn assigns ->
            ~H'<.form_group is_required><input /></.form_group>'
          end,
          %{}
        )

      assert_class(html, "pa-form-group")
      refute_class(html, "pa-form-group--required")
    end

    test "form_label emits a plain <label> — no pa-form-label class, no manual asterisk" do
      html =
        render(
          fn assigns ->
            ~H'<.form_label for="n" is_required>Name</.form_label>'
          end,
          %{}
        )

      refute_class(html, "pa-form-label")
      assert html =~ ~s(for="n")
      # Requiredness is attribute-driven (core's :has(:required) ::after) — keen
      # must NOT hand-render an asterisk, which would double the core marker.
      refute html =~ "text-danger"
    end

    test "required control flows through so core's :has(:required) marker fires" do
      html =
        render(
          fn assigns ->
            ~H"""
            <.form_group>
              <.form_label for="e">Email</.form_label>
              <.input type="email" id="e" name="e" required />
            </.form_group>
            """
          end,
          %{}
        )

      # The group holds a required control and the label is a direct child of
      # .pa-form-group — the two structural preconditions for the core rule.
      assert_class(html, "pa-form-group")
      assert html =~ "required"
    end
  end

  describe "input/1 with :field" do
    test "derives name, id, value from the form field" do
      form = to_form(%{"email" => "jane@example.com"}, as: :user)

      html =
        render(
          fn assigns -> ~H'<.input field={@form[:email]} type="email" />' end,
          %{form: form}
        )

      assert html =~ ~s(name="user[email]")
      assert html =~ ~s(id="user_email")
      assert html =~ ~s(value="jane@example.com")
      assert html =~ ~s(type="email")
    end

    test "explicit name/id/value override field" do
      form = to_form(%{"email" => "jane@example.com"}, as: :user)

      html =
        render(
          fn assigns ->
            ~H'<.input field={@form[:email]} name="custom_name" id="custom_id" value="custom" />'
          end,
          %{form: form}
        )

      assert html =~ ~s(name="custom_name")
      assert html =~ ~s(id="custom_id")
      assert html =~ ~s(value="custom")
    end

    test "renders error class and help text when field has errors" do
      errors = [email: {"is invalid", []}]
      form = to_form(%{"email" => "bad"}, as: :user, errors: errors, action: :validate)

      html =
        render(
          fn assigns -> ~H'<.input field={@form[:email]} />' end,
          %{form: form}
        )

      assert_class(html, "pa-input--error")
      assert_class(html, "pa-form-help--error")
      assert html =~ "is invalid"
    end

    test "show_errors=false suppresses inline help but keeps error class" do
      errors = [email: {"is invalid", []}]
      form = to_form(%{"email" => "bad"}, as: :user, errors: errors, action: :validate)

      html =
        render(
          fn assigns -> ~H'<.input field={@form[:email]} show_errors={false} />' end,
          %{form: form}
        )

      assert_class(html, "pa-input--error")
      refute html =~ "is invalid"
    end

    test "explicit validation beats field-derived error state" do
      errors = [email: {"is invalid", []}]
      form = to_form(%{"email" => "bad"}, as: :user, errors: errors, action: :validate)

      html =
        render(
          fn assigns -> ~H'<.input field={@form[:email]} validation="success" />' end,
          %{form: form}
        )

      assert_class(html, "pa-input--success")
      refute_class(html, "pa-input--error")
    end
  end

  describe "textarea/1 with :field" do
    test "derives name/id/value" do
      form = to_form(%{"bio" => "Hello"}, as: :user)

      html =
        render(
          fn assigns -> ~H'<.textarea field={@form[:bio]} />' end,
          %{form: form}
        )

      assert html =~ ~s(name="user[bio]")
      assert html =~ ~s(id="user_bio")
      assert html =~ ">Hello</textarea>"
    end

    test "surfaces errors via pa-form-help--error, not a border modifier" do
      errors = [bio: {"is too short", []}]
      form = to_form(%{"bio" => ""}, as: :user, errors: errors, action: :validate)

      html =
        render(
          fn assigns -> ~H'<.textarea field={@form[:bio]} />' end,
          %{form: form}
        )

      # Core has no .pa-textarea--{success,warning,error} border styling — the
      # error surfaces through the pa-form-help--error rendered below.
      refute_class(html, "pa-textarea--error")
      assert_class(html, "pa-form-help--error")
      assert html =~ "is too short"
    end
  end

  describe "select/1 with :field" do
    test "derives name/id and selects the matching option" do
      form = to_form(%{"role" => "admin"}, as: :user)

      html =
        render(
          fn assigns ->
            ~H'<.select field={@form[:role]} options={["user", "admin"]} />'
          end,
          %{form: form}
        )

      assert html =~ ~s(name="user[role]")
      assert html =~ ~s(selected) and html =~ ~s(value="admin")
    end
  end

  describe "checkbox/1 with :field" do
    test "derives checked from a truthy field value" do
      form = to_form(%{"agree" => "true"}, as: :user)

      html =
        render(
          fn assigns -> ~H'<.checkbox field={@form[:agree]} label="I agree" />' end,
          %{form: form}
        )

      assert html =~ ~s(name="user[agree]")
      assert html =~ "checked"
    end

    test "no checked attr when field value is falsy" do
      form = to_form(%{"agree" => "false"}, as: :user)

      html =
        render(
          fn assigns -> ~H'<.checkbox field={@form[:agree]} label="I agree" />' end,
          %{form: form}
        )

      refute html =~ ~s( checked)
    end
  end

  describe "radio/1 with :field" do
    test "checked when value matches field value" do
      form = to_form(%{"plan" => "pro"}, as: :user)

      html =
        render(
          fn assigns ->
            ~H"""
            <.radio field={@form[:plan]} value="pro" label="Pro" />
            <.radio field={@form[:plan]} value="basic" label="Basic" />
            """
          end,
          %{form: form}
        )

      inputs = Regex.scan(~r/<input[^>]*>/, html) |> List.flatten()
      assert length(inputs) == 2
      [pro_input, basic_input] = inputs
      assert pro_input =~ "checked"
      refute basic_input =~ "checked"
    end
  end

  describe "form_group/1 with :field" do
    test "auto-sets validation=error when field has errors" do
      errors = [email: {"is required", []}]
      form = to_form(%{"email" => ""}, as: :user, errors: errors, action: :validate)

      html =
        render(
          fn assigns ->
            ~H"""
            <.form_group field={@form[:email]}>
              <span>slot</span>
            </.form_group>
            """
          end,
          %{form: form}
        )

      assert_class(html, "pa-form-group--error")
    end

    test "explicit validation wins over field errors" do
      errors = [email: {"is required", []}]
      form = to_form(%{"email" => ""}, as: :user, errors: errors, action: :validate)

      html =
        render(
          fn assigns ->
            ~H"""
            <.form_group field={@form[:email]} validation="warning">
              <span>slot</span>
            </.form_group>
            """
          end,
          %{form: form}
        )

      assert_class(html, "pa-form-group--warning")
      refute_class(html, "pa-form-group--error")
    end
  end

  describe "translate_error/1" do
    test "default: interpolates %{key} placeholders" do
      assert Form.translate_error({"must be at least %{count} chars", [count: 8]}) ==
               "must be at least 8 chars"
    end

    test "respects app-configured formatter (MFA)" do
      Application.put_env(:keen_pure_admin, :error_formatter, {__MODULE__, :shout_error})

      try do
        assert Form.translate_error({"nope", []}) == "NOPE!"
      after
        Application.delete_env(:keen_pure_admin, :error_formatter)
      end
    end

    test "respects app-configured formatter (1-arity function)" do
      Application.put_env(:keen_pure_admin, :error_formatter, fn {msg, _} ->
        String.upcase(msg)
      end)

      try do
        assert Form.translate_error({"nope", []}) == "NOPE"
      after
        Application.delete_env(:keen_pure_admin, :error_formatter)
      end
    end
  end

  describe "radio/1 canonical label + label_position" do
    test "wraps label text in the canonical pa-radio__label span" do
      html = render(fn assigns -> ~H'<.radio name="p" value="a" label="Option A" />' end, %{})
      assert html =~ ~r/<span class="pa-radio__label">\s*Option A\s*<\/span>/
    end

    test "label_position emits pa-radio--label-{position}" do
      for pos <- ~w(start end top) do
        html = render(fn assigns -> ~H'<.radio name="p" value="a" label="X" label_position={@pos} />' end, %{pos: pos})
        assert_class(html, "pa-radio--label-#{pos}")
      end
    end
  end

  describe "checkbox/1 label_position" do
    test "emits pa-checkbox--label-{position}" do
      for pos <- ~w(start end top) do
        html = render(fn assigns -> ~H'<.checkbox name="c" label="X" label_position={@pos} />' end, %{pos: pos})
        assert_class(html, "pa-checkbox--label-#{pos}")
      end
    end
  end

  describe "checkbox/1 disabled" do
    test "emits pa-checkbox--disabled on the label and disabled on the input" do
      html = render(fn assigns -> ~H'<.checkbox name="c" label="X" disabled />' end, %{})
      assert_class(html, "pa-checkbox--disabled")
      assert html =~ ~r/<input[^>]*disabled/
    end

    test "not disabled by default" do
      html = render(fn assigns -> ~H'<.checkbox name="c" label="X" />' end, %{})
      refute_class(html, "pa-checkbox--disabled")
    end
  end

  describe "checkbox_group/1 + radio_group/1 layout" do
    test "checkbox_group layout emits pa-checkbox-group--{layout}" do
      for layout <- ~w(horizontal grid 2col 3col) do
        html = render(fn assigns -> ~H'<.checkbox_group layout={@l}><span>x</span></.checkbox_group>' end, %{l: layout})
        assert_class(html, "pa-checkbox-group--#{layout}")
      end
    end

    test "radio_group layout emits pa-radio-group--{layout}" do
      for layout <- ~w(horizontal grid 2col 3col) do
        html = render(fn assigns -> ~H'<.radio_group layout={@l}><span>x</span></.radio_group>' end, %{l: layout})
        assert_class(html, "pa-radio-group--#{layout}")
      end
    end

    test "no layout → bare group class (vertical stack)" do
      html = render(fn assigns -> ~H'<.radio_group><span>x</span></.radio_group>' end, %{})
      assert_class(html, "pa-radio-group")
      refute html =~ "pa-radio-group--"
    end
  end

  describe "simple_form/1 actions" do
    test "actions render in the blessed pa-form-actions row, not a grid row" do
      form = to_form(%{}, as: :user)

      html =
        render(
          fn assigns ->
            ~H"""
            <.simple_form for={@form}>
              <:actions><button type="submit">Save</button></:actions>
            </.simple_form>
            """
          end,
          %{form: form}
        )

      assert_class(html, "pa-form-actions")
      refute html =~ "pc-col-100"
    end
  end

  # Used by the configured-formatter test above
  def shout_error({msg, _opts}), do: String.upcase(msg) <> "!"
end
