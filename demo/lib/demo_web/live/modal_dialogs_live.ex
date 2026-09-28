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
  // Push dialog result to LiveView
  async function confirmAndPush(action) {
    const confirmed = await PureAdmin.confirm({
      title: 'Delete Item?',
      message: 'This action cannot be undone.',
      variant: 'danger'
    });

    if (confirmed) {
      // Push event to LiveView server
      const el = document.querySelector('[data-phx-main]');
      const hook = window.liveSocket.getViewByEl(el);
      hook.pushEvent('dialog_result', { action, result: 'confirmed' });
    }
  }
  """

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Modal Dialogs",
      last_result: nil,
      basic_usage_code: @basic_usage_code,
      position_code: @position_code,
      sequential_code: @sequential_code,
      liveview_code: @liveview_code
    )}
  end

  def handle_event("dialog_result", %{"action" => action, "result" => result}, socket) do
    {:noreply, assign(socket, last_result: "#{action}: #{result}")}
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
        Use <code>onclick</code> with <code>liveSocket</code> to push results back to the server:
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
      <.code_block language="javascript" class="mt-4">{@liveview_code}</.code_block>
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
        const view = window.liveSocket.getViewByEl(el);
        if (view) {
          view.pushEvent('dialog_result', { action: action, result: result });
        }
      }
    }
    </script>
    """
  end
end
