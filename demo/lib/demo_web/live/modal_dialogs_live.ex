defmodule DemoWeb.Live.ModalDialogsLive do
  use DemoWeb, :live_view

  @basic_usage_code """
  // Confirm dialog
  const confirmed = await PureAdmin.confirm({
    title: 'Delete Item?',
    message: 'This action cannot be undone.',
    variant: 'danger'
  });

  if (confirmed) {
    // User clicked OK
  }

  // Alert dialog
  await PureAdmin.alert({
    title: 'Success!',
    message: 'Your changes have been saved.',
    variant: 'success'
  });

  // Prompt dialog
  const name = await PureAdmin.prompt({
    title: 'Enter Name',
    message: 'Please enter your name:',
    defaultValue: 'John Doe'
  });

  if (name !== null) {
    console.log('User entered:', name);
  }
  """

  @position_code """
  // Center position (default)
  await PureAdmin.alert({
    title: 'Centered',
    message: 'This dialog is centered.',
    position: 'center'  // default
  });

  // Top position
  await PureAdmin.prompt({
    title: 'Top Position',
    message: 'This dialog appears near the top.',
    position: 'top'
  });
  """

  @sequential_code """
  async function sequentialDialogs() {
    const name = await PureAdmin.prompt({
      title: 'Step 1 of 3',
      message: 'Enter your name:'
    });

    if (name === null) return;

    const email = await PureAdmin.prompt({
      title: 'Step 2 of 3',
      message: 'Enter your email:'
    });

    if (email === null) return;

    const confirmed = await PureAdmin.confirm({
      title: 'Step 3 of 3',
      message: `Confirm: ${name} <${email}>`,
      variant: 'success'
    });

    if (confirmed) {
      await PureAdmin.alert({
        title: 'Complete!',
        message: 'Registration successful.',
        variant: 'success'
      });
    }
  }
  """

  @liveview_code """
  // Push a dialog result to LiveView from plain JS (outside a hook).
  async function confirmAndPush(action) {
    const confirmed = await PureAdmin.confirm({
      title: 'Delete Item?',
      message: 'This action cannot be undone.',
      variant: 'danger'
    });

    if (confirmed) {
      // Use the public execJS API with the same encoded command phx-click uses.
      // `value` becomes the event params on the server.
      const el = document.querySelector('[data-phx-main]');
      window.liveSocket.execJS(el, JSON.stringify(
        [["push", { event: "dialog_result", value: { action, result: "confirmed" } }]]
      ));
    }
  }
  """

  @liveview_server_code """
  # The LiveView receives the pushed event and sends a toast back — no reload,
  # the PureAdminToast hook just renders it wherever the user is.
  def handle_event("dialog_result", %{"action" => action, "result" => result}, socket) do
    {:noreply,
     socket
     |> assign(last_result: "\#{action}: \#{result}")
     |> push_toast("success", "Server received your action",
          "You just performed \#{action} (\#{result}) in the dialog.")}
  end
  """

  @server_dialog_code """
  # 1. Setup once. on_mount seeds :pa_dialog + auto-close; the host renders it.
  live_session :default, on_mount: [{PureAdmin.Dialog, :default}] do
    # ...your live routes...
  end
  # app.html.heex, mounted once:
  #   <PureAdmin.Dialog.host dialog={@pa_dialog} />

  # 2. A real phx-click handler opens the dialog FROM THE SERVER. `on_dismiss`
  #    makes the ✕/backdrop/Esc dismiss a first-class event too.
  def handle_event("simulate_external_edit", _params, socket) do
    {:noreply,
     PureAdmin.Dialog.confirm(socket,
       title: "Document changed",
       message: "Someone else updated this document. Reload their version?",
       variant: "warning", banded: true, position: :top,
       confirm: [label: "Reload theirs", variant: "warning", event: "doc_reload"],
       cancel: [label: "Keep mine", event: "doc_keep"],
       on_dismiss: "doc_dismiss"
     )}
  end

  # 3. Every outcome is an ORDINARY event; the dialog auto-closes. Push a toast
  #    straight back from the server (PureAdmin.Components.Toast.push_toast/4).
  def handle_event("doc_reload", _p, socket), do:
    {:noreply, push_toast(socket, "warning", "Document reloaded", "Server version loaded.")}

  def handle_event("doc_keep", _p, socket), do:
    {:noreply, push_toast(socket, "success", "Kept your version", "Local changes preserved.")}

  def handle_event("doc_dismiss", _p, socket), do:   # ✕ / backdrop / Escape
    {:noreply, push_toast(socket, "info", "Dialog dismissed", "Nothing was changed.")}
  """

  @custom_dialog_code """
  # Custom/form dialog (requirement B): open/3 stashes a keyed spec — YOU render
  # your own <.modal> with a real LiveView form. close/1 dismisses it.
  def handle_event("edit_profile", _p, socket) do
    form = to_form(%{"name" => "Ada Lovelace", "email" => "ada@example.com"}, as: :profile)
    {:noreply, socket |> assign(profile_form: form) |> PureAdmin.Dialog.open(:edit_profile)}
  end

  def handle_event("validate_profile", %{"profile" => params}, socket) do
    {:noreply, assign(socket, profile_form: to_form(params, as: :profile, errors: errors(params)))}
  end

  def handle_event("save_profile", %{"profile" => params}, socket) do
    case errors(params) do
      []   -> {:noreply, socket |> PureAdmin.Dialog.close() |> assign(profile_result: "Saved.")}
      errs -> {:noreply, assign(socket, profile_form: to_form(params, as: :profile, errors: errs))}
    end
  end

  # render — your OWN modal + form, keyed on @pa_dialog:
  <.modal :if={@pa_dialog && @pa_dialog.key == :edit_profile} id="edit-profile" show
          title_text="Edit profile" on_cancel={JS.push("pa-dialog:close")}>
    <.form for={@profile_form} class="pa-form"
           phx-change="validate_profile" phx-submit="save_profile">
      <div class="pa-form-group"><label>Name</label><.input field={@profile_form[:name]} /></div>
      <div class="pa-form-group"><label>Email</label><.input field={@profile_form[:email]} type="email" /></div>
      <div class="pa-modal__footer">
        <button type="button" class="pa-btn pa-btn--secondary" phx-click="pa-dialog:close">Cancel</button>
        <button type="submit" class="pa-btn pa-btn--primary">Save</button>
      </div>
    </.form>
  </.modal>
  """

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Modal Dialogs",
      last_result: nil,
      server_dialog_result: nil,
      basic_usage_code: @basic_usage_code,
      position_code: @position_code,
      sequential_code: @sequential_code,
      liveview_code: @liveview_code,
      liveview_server_code: @liveview_server_code,
      server_dialog_code: @server_dialog_code,
      custom_dialog_code: @custom_dialog_code,
      profile_form: nil,
      profile_result: nil
    )}
  end

  # The client dialog pushed its outcome here. Besides recording it for the
  # inline alert, push a toast straight back from the server — the PureAdminToast
  # hook renders it with no reload, so the user sees confirmation of what they
  # just did in the dialog. The toast variant mirrors the button that triggered
  # it (delete → danger, rename → primary, notify → success).
  def handle_event("dialog_result", %{"action" => action, "result" => result}, socket) do
    {:noreply,
     socket
     |> assign(last_result: "#{action}: #{result}")
     |> PureAdmin.Components.Toast.push_toast(
       toast_variant(action),
       gettext("Server received your action"),
       gettext("You just performed “%{action}” (%{result}) in the dialog.",
         action: action,
         result: result
       )
     )}
  end

  # Server-initiated dialog via PureAdmin.Dialog: a real phx-click opens the
  # server-rendered dialog; every outcome — the two choices AND an ✕/backdrop/Esc
  # dismiss (wired via `on_dismiss`) — returns as an ordinary event, and each one
  # pushes a toast straight back from the server (no reload). The dialog
  # auto-closes through the on_mount hook.
  def handle_event("simulate_external_edit", _params, socket) do
    {:noreply,
     PureAdmin.Dialog.confirm(socket,
       title: gettext("Document changed"),
       message:
         gettext(
           "Someone else updated this document while you were editing. Reload their version? Your unsaved changes will be lost."
         ),
       variant: "warning",
       banded: true,
       position: :top,
       confirm: [label: gettext("Reload theirs"), variant: "warning", event: "doc_reload"],
       cancel: [label: gettext("Keep mine"), event: "doc_keep"],
       on_dismiss: "doc_dismiss"
     )}
  end

  def handle_event("doc_reload", _params, socket) do
    {:noreply,
     socket
     |> assign(server_dialog_result: gettext("Reloaded the server's version."))
     |> PureAdmin.Components.Toast.push_toast(
       "warning",
       gettext("Document reloaded"),
       gettext("Loaded the latest version from the server; your edits were discarded.")
     )}
  end

  def handle_event("doc_keep", _params, socket) do
    {:noreply,
     socket
     |> assign(server_dialog_result: gettext("Kept your local changes."))
     |> PureAdmin.Components.Toast.push_toast(
       "success",
       gettext("Kept your version"),
       gettext("Your local changes were preserved.")
     )}
  end

  # Fired by ✕ / backdrop / Escape (wired via `on_dismiss` above) — the dismiss is
  # a first-class event too, so the server can react instead of silently closing.
  def handle_event("doc_dismiss", _params, socket) do
    {:noreply,
     socket
     |> assign(server_dialog_result: gettext("Dismissed — no change made."))
     |> PureAdmin.Components.Toast.push_toast(
       "info",
       gettext("Dialog dismissed"),
       gettext("You closed the dialog without choosing; nothing was changed.")
     )}
  end

  # Custom/form dialog (requirement B): open/3 stashes a keyed spec; the LiveView
  # renders its OWN <.modal> + form (below) keyed on @pa_dialog. Full phx-change
  # validation + phx-submit; close/1 dismisses on success.
  def handle_event("edit_profile", _params, socket) do
    form = to_form(%{"name" => "Ada Lovelace", "email" => "ada@example.com"}, as: :profile)
    {:noreply, socket |> assign(profile_form: form) |> PureAdmin.Dialog.open(:edit_profile)}
  end

  def handle_event("validate_profile", %{"profile" => params}, socket) do
    {:noreply, assign(socket, profile_form: to_form(params, as: :profile, errors: profile_errors(params)))}
  end

  def handle_event("save_profile", %{"profile" => params}, socket) do
    case profile_errors(params) do
      [] ->
        {:noreply,
         socket
         |> PureAdmin.Dialog.close()
         |> assign(profile_result: gettext("Profile saved."))}

      errors ->
        {:noreply, assign(socket, profile_form: to_form(params, as: :profile, errors: errors))}
    end
  end

  # Toast variant mirrors the dialog button that triggered the result.
  defp toast_variant("delete"), do: "danger"
  defp toast_variant("rename"), do: "primary"
  defp toast_variant(_), do: "success"

  defp profile_errors(params) do
    []
    |> then(fn acc ->
      if String.trim(to_string(params["name"])) == "",
        do: [{:name, {"can't be blank", []}} | acc],
        else: acc
    end)
    |> then(fn acc ->
      if String.contains?(to_string(params["email"]), "@"),
        do: acc,
        else: [{:email, {"must be a valid email", []}} | acc]
    end)
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Promise-based programmatic dialogs. No HTML boilerplate — created on-demand via JavaScript.</.paragraph>

    <%!-- Basic Usage --%>
    <.card title_text={gettext("Basic Usage")}>
      <.paragraph class="mb-3">
        All dialog functions return Promises, so you can use <code>async/await</code> for clean, synchronous-looking code:
      </.paragraph>
      <.code_block language="javascript">{@basic_usage_code}</.code_block>
    </.card>

    <%!-- Confirm Dialogs --%>
    <.card title_text={gettext("Confirm Dialogs")}>
      <.paragraph class="mb-3">Two-button dialogs that return <code>true</code> (confirmed) or <code>false</code> (cancelled).</.paragraph>
      <.grid>
        <.column size="100" md="1-3">
          <.button variant="primary" class="wr-100" onclick="confirmPrimary()">{gettext("Primary Confirm")}</.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="success" class="wr-100" onclick="confirmSuccess()">{gettext("Success Confirm")}</.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="warning" class="wr-100" onclick="confirmWarning()">{gettext("Warning Confirm")}</.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="danger" class="wr-100" onclick="confirmDanger()">{gettext("Danger Confirm")}</.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="secondary" class="wr-100" onclick="confirmCustomText()">{gettext("Custom Button Text")}</.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="secondary" class="wr-100" onclick="confirmLarge()">{gettext("Large Size")}</.button>
        </.column>
      </.grid>
      <div id="confirm-result" class="pa-alert pa-alert--primary mt-4" style="display: none;">
        <strong>Result:</strong> <span id="confirm-result-text"></span>
      </div>
    </.card>

    <%!-- Position Options --%>
    <.card title_text={gettext("Position Options")}>
      <.paragraph class="mb-3">Dialogs can be positioned in the <strong>center</strong> (default) or at the <strong>top</strong> of the viewport.</.paragraph>
      <.grid>
        <.column size="100" md="25">
          <.button variant="primary" class="wr-100" onclick="positionCenter()">{gettext("Center (Default)")}</.button>
        </.column>
        <.column size="100" md="25">
          <.button variant="primary" class="wr-100" onclick="positionTop()">{gettext("Top Position")}</.button>
        </.column>
        <.column size="100" md="25">
          <.button variant="success" class="wr-100" onclick="promptTop()">{gettext("Prompt (Top)")}</.button>
        </.column>
        <.column size="100" md="25">
          <.button variant="danger" class="wr-100" onclick="confirmTop()">{gettext("Confirm (Top)")}</.button>
        </.column>
      </.grid>
      <.code_block language="javascript" class="mt-4">{@position_code}</.code_block>
    </.card>

    <%!-- Alert Dialogs --%>
    <.card title_text={gettext("Alert Dialogs")}>
      <.paragraph class="mb-3">Single-button dialogs for notifications. Just wait for the user to acknowledge.</.paragraph>
      <.grid>
        <.column size="100" md="25">
          <.button variant="primary" class="wr-100" onclick="alertPrimary()">{gettext("Primary Alert")}</.button>
        </.column>
        <.column size="100" md="25">
          <.button variant="success" class="wr-100" onclick="alertSuccess()">{gettext("Success Alert")}</.button>
        </.column>
        <.column size="100" md="25">
          <.button variant="warning" class="wr-100" onclick="alertWarning()">{gettext("Warning Alert")}</.button>
        </.column>
        <.column size="100" md="25">
          <.button variant="danger" class="wr-100" onclick="alertDanger()">{gettext("Danger Alert")}</.button>
        </.column>
      </.grid>
    </.card>

    <%!-- Prompt Dialogs --%>
    <.card title_text={gettext("Prompt Dialogs")}>
      <.paragraph class="mb-3">Text input dialogs that return the entered value (or <code>null</code> if cancelled).</.paragraph>
      <.grid>
        <.column size="100" md="1-3">
          <.button variant="primary" class="wr-100" onclick="promptBasic()">{gettext("Basic Prompt")}</.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="primary" class="wr-100" onclick="promptWithDefault()">{gettext("With Default Value")}</.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="primary" class="wr-100" onclick="promptWithValidation()">{gettext("With Validation")}</.button>
        </.column>
      </.grid>
      <div id="prompt-result" class="pa-alert pa-alert--success mt-4" style="display: none;">
        <strong>You entered:</strong> <span id="prompt-result-text"></span>
      </div>
    </.card>

    <%!-- Sequential Dialogs --%>
    <.card title_text={gettext("Sequential Dialogs")}>
      <.paragraph class="mb-3">Chain multiple dialogs together using async/await:</.paragraph>
      <.button variant="primary" onclick="sequentialDialogs()">{gettext("Run Sequential Flow")}</.button>
      <.code_block language="javascript" class="mt-4">{@sequential_code}</.code_block>
    </.card>

    <%!-- LiveView Integration --%>
    <.card title_text={gettext("LiveView Integration")}>
      <.paragraph class="mb-3">
        Use <code>onclick</code> with <code>liveSocket</code> to push results back to the server.
        The server records the outcome <em>and</em> pushes a toast straight back — try the buttons:
      </.paragraph>
      <.grid>
        <.column size="100" md="1-3">
          <.button variant="danger" class="wr-100" onclick="confirmAndPush('delete')">{gettext("Confirm Delete (Server)")}</.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="primary" class="wr-100" onclick="promptAndPush('rename')">{gettext("Prompt Rename (Server)")}</.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="success" class="wr-100" onclick="alertAndPush('notify')">{gettext("Alert + Notify (Server)")}</.button>
        </.column>
      </.grid>
      <.alert :if={@last_result} variant="info" class="mt-3">
        <strong>Server received:</strong> {@last_result}
      </.alert>
      <.paragraph class="mt-4 mb-2"><strong>{gettext("Client")}</strong> — push the result to the server:</.paragraph>
      <.code_block language="javascript">{@liveview_code}</.code_block>
      <.paragraph class="mt-4 mb-2"><strong>{gettext("Server")}</strong> — reply with a toast, no reload:</.paragraph>
      <.code_block language="elixir">{@liveview_server_code}</.code_block>
    </.card>

    <%!-- Server-Initiated Dialog (PureAdmin.Dialog) --%>
    <.card title_text={gettext("Server-Initiated Dialog")} variant="warning">
      <.paragraph class="mb-3">
        The opposite direction, and a <strong>first-class keen feature</strong>: the button below is a
        <strong>real</strong> <code>phx-click</code> that hits the <strong>server first</strong>. The server opens a
        server-rendered dialog with <code>PureAdmin.Dialog.confirm/2</code>; each button is an ordinary event, so the
        user's choice arrives as a normal <code>handle_event</code> and the dialog auto-closes — no client bridge, no
        promise plumbing. Every outcome <strong>pushes a toast back from the server</strong>, and the ✕/backdrop/Escape
        dismiss is a first-class event too (<code>on_dismiss</code>), so nothing closes silently. Classic use:
        <em>"this document was changed by someone else."</em>
      </.paragraph>
      <.button variant="warning" phx-click="simulate_external_edit">
        {gettext("Someone edited this document…")}
      </.button>
      <.paragraph class="mt-2 text-sm text-secondary">
        {gettext("Pick a button, or dismiss with ✕ / click-outside / Escape — each pushes a different toast.")}
      </.paragraph>
      <.alert :if={@server_dialog_result} variant="info" class="mt-3">
        <strong>{gettext("Server outcome")}:</strong> {@server_dialog_result}
      </.alert>
      <.code_block language="elixir" class="mt-4">{@server_dialog_code}</.code_block>
    </.card>

    <%!-- Custom / Form Dialog (requirement B) --%>
    <.card title_text={gettext("Custom / Form Dialog")}>
      <.paragraph class="mb-3">
        Standard dialogs can't express an arbitrary form, so <code>PureAdmin.Dialog.open/3</code> just stashes a keyed
        spec and you render your <strong>own</strong> <code>&lt;.modal&gt;</code> with a real LiveView form — full
        <code>phx-change</code> validation and <code>phx-submit</code>. <code>close/1</code> dismisses it. The server
        opens it the same way (a <code>phx-click</code> handler), but owns the content.
      </.paragraph>
      <.button variant="primary" phx-click="edit_profile">{gettext("Edit profile…")}</.button>
      <.alert :if={@profile_result} variant="success" class="mt-3">
        <strong>{gettext("Server outcome")}:</strong> {@profile_result}
      </.alert>

      <.modal
        :if={@pa_dialog && @pa_dialog.key == :edit_profile}
        id="edit-profile"
        show
        title_text={gettext("Edit profile")}
        on_cancel={JS.push("pa-dialog:close")}
      >
        <.form for={@profile_form} class="pa-form" phx-change="validate_profile" phx-submit="save_profile">
          <div class="pa-form-group">
            <label>{gettext("Name")}</label>
            <.input field={@profile_form[:name]} />
          </div>
          <div class="pa-form-group">
            <label>{gettext("Email")}</label>
            <.input field={@profile_form[:email]} type="email" />
          </div>
          <div class="pa-modal__footer">
            <button type="button" class="pa-btn pa-btn--secondary" phx-click="pa-dialog:close">
              {gettext("Cancel")}
            </button>
            <button type="submit" class="pa-btn pa-btn--primary">{gettext("Save")}</button>
          </div>
        </.form>
      </.modal>

      <.code_block language="elixir" class="mt-4">{@custom_dialog_code}</.code_block>
    </.card>

    <%!-- API Reference --%>
    <.card title_text={gettext("API Reference")}>
      <.heading level={3} style="margin-top: 0;">PureAdmin.confirm(options)</.heading>
      <.paragraph class="mb-2">Returns <code>Promise&lt;boolean&gt;</code></.paragraph>
      <.table rows={[
        %{option: "title", type: "string", default: "'Confirm'", desc: "Dialog title"},
        %{option: "message", type: "string", default: "'Are you sure?'", desc: "Dialog message"},
        %{option: "confirmText", type: "string", default: "'OK'", desc: "Confirm button text"},
        %{option: "cancelText", type: "string", default: "'Cancel'", desc: "Cancel button text"},
        %{option: "variant", type: "string", default: "'primary'", desc: "Header theme: primary, success, warning, danger"},
        %{option: "confirmVariant", type: "string", default: "(same as variant)", desc: "Confirm button style"},
        %{option: "size", type: "string", default: "'sm'", desc: "Modal size: sm, md, lg, xl"},
        %{option: "position", type: "string", default: "'center'", desc: "Vertical position: center, top"},
        %{option: "closeOnBackdrop", type: "boolean", default: "true", desc: "Close when clicking outside"}
      ]} size="sm">
        <:col :let={row} label={gettext("Option")}><code>{row.option}</code></:col>
        <:col :let={row} label={gettext("Type")}>{row.type}</:col>
        <:col :let={row} label={gettext("Default")}>{row.default}</:col>
        <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
      </.table>

      <.heading level={3} class="mt-4">PureAdmin.alert(options)</.heading>
      <.paragraph class="mb-2">Returns <code>Promise&lt;void&gt;</code></.paragraph>
      <.table rows={[
        %{option: "title", type: "string", default: "'Alert'", desc: "Dialog title"},
        %{option: "message", type: "string", default: "''", desc: "Dialog message"},
        %{option: "okText", type: "string", default: "'OK'", desc: "Button text"},
        %{option: "variant", type: "string", default: "'primary'", desc: "Header and button theme"},
        %{option: "size", type: "string", default: "'sm'", desc: "Modal size"},
        %{option: "position", type: "string", default: "'center'", desc: "Vertical position: center, top"}
      ]} size="sm">
        <:col :let={row} label={gettext("Option")}><code>{row.option}</code></:col>
        <:col :let={row} label={gettext("Type")}>{row.type}</:col>
        <:col :let={row} label={gettext("Default")}>{row.default}</:col>
        <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
      </.table>

      <.heading level={3} class="mt-4">PureAdmin.prompt(options)</.heading>
      <.paragraph class="mb-2">Returns <code>Promise&lt;string | null&gt;</code></.paragraph>
      <.table rows={[
        %{option: "title", type: "string", default: "'Input'", desc: "Dialog title"},
        %{option: "message", type: "string", default: "'Enter value:'", desc: "Dialog message"},
        %{option: "defaultValue", type: "string", default: "''", desc: "Initial input value"},
        %{option: "placeholder", type: "string", default: "''", desc: "Input placeholder"},
        %{option: "confirmText", type: "string", default: "'OK'", desc: "Confirm button text"},
        %{option: "cancelText", type: "string", default: "'Cancel'", desc: "Cancel button text"},
        %{option: "validator", type: "function", default: "null", desc: "Validation: (value) => true | string"},
        %{option: "variant", type: "string", default: "'primary'", desc: "Header theme"},
        %{option: "size", type: "string", default: "'sm'", desc: "Modal size"},
        %{option: "position", type: "string", default: "'center'", desc: "Vertical position: center, top"}
      ]} size="sm">
        <:col :let={row} label={gettext("Option")}><code>{row.option}</code></:col>
        <:col :let={row} label={gettext("Type")}>{row.type}</:col>
        <:col :let={row} label={gettext("Default")}>{row.default}</:col>
        <:col :let={row} label={gettext("Description")}>{row.desc}</:col>
      </.table>
    </.card>

    <script>
    // Confirm examples
    async function confirmPrimary() {
      const result = await PureAdmin.confirm({
        title: 'Primary Confirm',
        message: 'This is a primary styled confirmation dialog.',
        variant: 'primary'
      });
      showConfirmResult(result);
    }

    async function confirmSuccess() {
      const result = await PureAdmin.confirm({
        title: 'Success Confirm',
        message: 'Do you want to proceed with this action?',
        variant: 'success'
      });
      showConfirmResult(result);
    }

    async function confirmWarning() {
      const result = await PureAdmin.confirm({
        title: 'Warning',
        message: 'This action may have unintended consequences.',
        variant: 'warning'
      });
      showConfirmResult(result);
    }

    async function confirmDanger() {
      const result = await PureAdmin.confirm({
        title: 'Delete Item',
        message: 'This action cannot be undone. Are you sure?',
        variant: 'danger',
        confirmText: 'Delete',
        cancelText: 'Keep It'
      });
      showConfirmResult(result);
    }

    async function confirmCustomText() {
      const result = await PureAdmin.confirm({
        title: 'Save Changes?',
        message: 'You have unsaved changes. What would you like to do?',
        confirmText: 'Save Changes',
        cancelText: 'Discard',
        variant: 'primary'
      });
      showConfirmResult(result);
    }

    async function confirmLarge() {
      const result = await PureAdmin.confirm({
        title: 'Large Dialog',
        message: 'This is a larger modal dialog. You can use different sizes: sm, md, lg, xl.',
        size: 'lg',
        variant: 'primary'
      });
      showConfirmResult(result);
    }

    function showConfirmResult(result) {
      const resultDiv = document.getElementById('confirm-result');
      const resultText = document.getElementById('confirm-result-text');
      resultText.textContent = result ? 'User clicked OK (true)' : 'User clicked Cancel (false)';
      resultDiv.className = result ? 'pa-alert pa-alert--success mt-4' : 'pa-alert pa-alert--secondary mt-4';
      resultDiv.style.display = 'block';
    }

    // Position examples
    async function positionCenter() {
      await PureAdmin.alert({
        title: 'Centered Dialog',
        message: 'This dialog is centered in the viewport (default behavior).',
        variant: 'primary',
        position: 'center'
      });
    }

    async function positionTop() {
      await PureAdmin.alert({
        title: 'Top Position',
        message: 'This dialog appears near the top of the viewport. Useful for less intrusive notifications.',
        variant: 'primary',
        position: 'top'
      });
    }

    async function promptTop() {
      const result = await PureAdmin.prompt({
        title: 'Quick Input',
        message: 'Enter a value:',
        placeholder: 'Type here...',
        variant: 'success',
        position: 'top'
      });
      if (result !== null) {
        await PureAdmin.alert({
          title: 'You entered',
          message: result || '(empty)',
          variant: 'success',
          position: 'top'
        });
      }
    }

    async function confirmTop() {
      const result = await PureAdmin.confirm({
        title: 'Delete Item?',
        message: 'This action cannot be undone.',
        variant: 'danger',
        position: 'top',
        confirmText: 'Delete',
        cancelText: 'Cancel'
      });
      showConfirmResult(result);
    }

    // Alert examples
    async function alertPrimary() {
      await PureAdmin.alert({
        title: 'Information',
        message: 'This is a primary alert dialog.',
        variant: 'primary'
      });
    }

    async function alertSuccess() {
      await PureAdmin.alert({
        title: 'Success!',
        message: 'Your changes have been saved successfully.',
        variant: 'success',
        okText: 'Great!'
      });
    }

    async function alertWarning() {
      await PureAdmin.alert({
        title: 'Warning',
        message: 'Your session will expire in 5 minutes.',
        variant: 'warning',
        okText: 'Got It'
      });
    }

    async function alertDanger() {
      await PureAdmin.alert({
        title: 'Error',
        message: 'An error occurred while processing your request.',
        variant: 'danger',
        okText: 'Close'
      });
    }

    // Prompt examples
    async function promptBasic() {
      const result = await PureAdmin.prompt({
        title: 'Enter Your Name',
        message: 'Please enter your full name:',
        placeholder: 'John Doe'
      });
      showPromptResult(result);
    }

    async function promptWithDefault() {
      const result = await PureAdmin.prompt({
        title: 'Edit Username',
        message: 'Enter a new username:',
        defaultValue: 'johndoe123',
        placeholder: 'username'
      });
      showPromptResult(result);
    }

    async function promptWithValidation() {
      const result = await PureAdmin.prompt({
        title: 'Enter Email',
        message: 'Please enter a valid email address:',
        placeholder: 'user@example.com',
        validator: (value) => {
          if (!value) return 'Email is required';
          if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
            return 'Please enter a valid email address';
          }
          return true;
        }
      });
      showPromptResult(result);
    }

    function showPromptResult(result) {
      const resultDiv = document.getElementById('prompt-result');
      const resultText = document.getElementById('prompt-result-text');

      if (result !== null) {
        resultText.textContent = result || '(empty string)';
        resultDiv.className = 'pa-alert pa-alert--success mt-4';
      } else {
        resultText.textContent = 'User cancelled (returned null)';
        resultDiv.className = 'pa-alert pa-alert--secondary mt-4';
      }

      resultDiv.style.display = 'block';
    }

    // Sequential dialogs
    async function sequentialDialogs() {
      const name = await PureAdmin.prompt({
        title: 'Step 1 of 3',
        message: 'Enter your name:',
        placeholder: 'John Doe',
        variant: 'primary'
      });

      if (name === null) return;

      const email = await PureAdmin.prompt({
        title: 'Step 2 of 3',
        message: 'Enter your email:',
        placeholder: 'john@example.com',
        variant: 'primary',
        validator: (value) => {
          if (!value) return 'Email is required';
          if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
            return 'Please enter a valid email address';
          }
          return true;
        }
      });

      if (email === null) return;

      const confirmed = await PureAdmin.confirm({
        title: 'Step 3 of 3 - Confirm',
        message: 'Please confirm your details:\n\nName: ' + name + '\nEmail: ' + email,
        confirmText: 'Register',
        variant: 'success'
      });

      if (confirmed) {
        await PureAdmin.alert({
          title: 'Registration Complete!',
          message: 'Welcome, ' + name + '! A confirmation email has been sent to ' + email + '.',
          variant: 'success',
          okText: 'Get Started'
        });
      }
    }

    // LiveView integration
    async function confirmAndPush(action) {
      const confirmed = await PureAdmin.confirm({
        title: 'Delete Item?',
        message: 'This action cannot be undone.',
        variant: 'danger',
        confirmText: 'Delete'
      });

      if (confirmed) {
        pushToLiveView(action, 'confirmed');
      }
    }

    async function promptAndPush(action) {
      const name = await PureAdmin.prompt({
        title: 'Rename Item',
        message: 'Enter a new name:',
        placeholder: 'New name...',
        variant: 'primary'
      });

      if (name !== null) {
        pushToLiveView(action, name);
      }
    }

    async function alertAndPush(action) {
      await PureAdmin.alert({
        title: 'Task Complete',
        message: 'The operation finished successfully.',
        variant: 'success'
      });
      pushToLiveView(action, 'acknowledged');
    }

    function pushToLiveView(action, result) {
      const el = document.querySelector('[data-phx-main]');
      if (el && window.liveSocket) {
        // Push from plain JS (outside a hook) via the public execJS API with the
        // same encoded command phx-click uses — `value` becomes the event params.
        // (Don't call View.pushEvent directly: that's an internal method whose
        // signature is (type, el, targetCtx, phxEvent, meta), not (event, payload).)
        window.liveSocket.execJS(
          el,
          JSON.stringify([["push", { event: "dialog_result", value: { action: action, result: result } }]])
        );
      }
    }
    </script>
    """
  end
end
