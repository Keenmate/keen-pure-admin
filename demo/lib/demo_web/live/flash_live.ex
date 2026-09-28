defmodule DemoWeb.Live.FlashLive do
  use DemoWeb, :live_view

  alias PureAdmin.Components.Flash, as: PureFlash

  @usage_template ~S"""
  <!-- Place a flash container inside any card or form -->
  <.card title_text="Contact Form">
    <.flash_container id="contact-form" />
    <.simple_form phx-submit="save-contact">
      ...
    </.simple_form>
  </.card>
  """

  @usage_server ~S"""
  # Simple flash
  push_flash(socket, "my-form", "success", "Saved!")

  # With title and auto-dismiss
  push_flash(socket, "my-form", "info", "Gone in 5s",
    title: "Notice", duration: 5000)

  # Markdown body with action buttons
  push_flash(socket, "my-form", "warning", \"""
  Are you sure you want to delete **Invoice #1234**?

  This action cannot be undone.
  \""",
    title: "Confirm Deletion",
    actions: [
      %{label: "Delete", event: "delete-record",
        params: %{id: 1234}, variant: "danger"},
      %{label: "Cancel", dismiss: true, variant: "secondary"}
    ])
  """

  @usage_standard ~S"""
  <!-- Standard Phoenix flash (single @flash map) -->
  <.flash_group flash={@flash} />
  """

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Flash Messages",
       usage_template: @usage_template,
       usage_server: @usage_server,
       usage_standard: @usage_standard
     )}
  end

  # Simple variant flash
  def handle_event("push-flash", %{"container" => container, "variant" => variant}, socket) do
    messages = %{
      "success" => "Operation completed successfully.",
      "danger" => "An error occurred. Please try again.",
      "warning" => "Please review before continuing.",
      "info" => "Here is some useful information."
    }

    {:noreply,
     PureFlash.push_flash(socket, container, variant, messages[variant] || "Flash message.",
       title: String.capitalize(variant)
     )}
  end

  # Auto-dismiss flash
  def handle_event("push-flash-auto", %{"container" => container}, socket) do
    {:noreply,
     PureFlash.push_flash(socket, container, "info", "This message will disappear in 5 seconds.",
       title: "Auto-dismiss",
       duration: 5000
     )}
  end

  # Markdown body flash
  def handle_event("push-flash-markdown", %{"container" => container}, socket) do
    {:noreply,
     PureFlash.push_flash(
       socket,
       container,
       "info",
       """
       A new version of the application is available. This update includes:

       - Performance improvements
       - Bug fixes
       - New **dashboard** features
       """,
       title: "System Update"
     )}
  end

  # Flash with action buttons
  def handle_event("push-flash-actions", %{"container" => container}, socket) do
    {:noreply,
     PureFlash.push_flash(
       socket,
       container,
       "warning",
       """
       Are you sure you want to delete **Invoice #1234**?

       This action cannot be undone.
       """,
       title: "Confirm Deletion",
       actions: [
         %{label: "Delete", event: "confirm-delete", params: %{id: 1234}, variant: "danger"},
         %{label: "Cancel", dismiss: true, variant: "secondary"}
       ]
     )}
  end

  # Action button callback
  def handle_event("confirm-delete", %{"id" => id}, socket) do
    {:noreply,
     PureFlash.push_flash(socket, "advanced", "success", "Record **##{id}** deleted successfully.")}
  end

  # Standard Phoenix flash
  def handle_event("push-standard-flash", %{"kind" => kind}, socket) do
    {:noreply, put_flash(socket, String.to_existing_atom(kind), "Standard #{kind} flash via put_flash/3.")}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>
      Independent inline flash messages using the <code>PureAdminFlash</code> JS hook.
      Multiple containers on the same page receive messages independently.
    </.paragraph>

    <%!-- Independent containers demo --%>
    <.grid>
      <.column size="50">
        <.card title_text={gettext("Card A — Contact Form")} is_header_underlined>
          <.flash_container id="card-a" />
          <.paragraph>Push flash messages to this card only.</.paragraph>
          <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
            <.button variant="success" size="sm" phx-click="push-flash" phx-value-container="card-a" phx-value-variant="success">
              {gettext("Success")}
            </.button>
            <.button variant="danger" size="sm" phx-click="push-flash" phx-value-container="card-a" phx-value-variant="danger">
              {gettext("Danger")}
            </.button>
            <.button variant="warning" size="sm" phx-click="push-flash" phx-value-container="card-a" phx-value-variant="warning">
              {gettext("Warning")}
            </.button>
            <.button variant="info" size="sm" phx-click="push-flash" phx-value-container="card-a" phx-value-variant="info">
              {gettext("Info")}
            </.button>
          </div>
        </.card>
      </.column>
      <.column size="50">
        <.card title_text={gettext("Card B — Profile")} is_header_underlined>
          <.flash_container id="card-b" />
          <.paragraph>Push flash messages to this card only.</.paragraph>
          <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
            <.button variant="success" size="sm" phx-click="push-flash" phx-value-container="card-b" phx-value-variant="success">
              {gettext("Success")}
            </.button>
            <.button variant="danger" size="sm" phx-click="push-flash" phx-value-container="card-b" phx-value-variant="danger">
              {gettext("Danger")}
            </.button>
            <.button variant="info" size="sm" phx-click="push-flash" phx-value-container="card-b" phx-value-variant="info">
              {gettext("Info")}
            </.button>
            <.button variant="secondary" size="sm" phx-click="push-flash-auto" phx-value-container="card-b">
              {gettext("Auto-dismiss (5s)")}
            </.button>
          </div>
        </.card>
      </.column>
    </.grid>

    <%!-- Advanced: markdown + actions --%>
    <.card title_text={gettext("Advanced: Markdown Body & Action Buttons")} is_header_underlined>
      <.flash_container id="advanced" />
      <.paragraph>
        Flash messages support markdown in the body and action buttons that push events back to the server.
      </.paragraph>
      <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
        <.button variant="info" size="sm" phx-click="push-flash-markdown" phx-value-container="advanced">
          {gettext("Markdown with list")}
        </.button>
        <.button variant="warning" size="sm" phx-click="push-flash-actions" phx-value-container="advanced">
          {gettext("Confirm with actions")}
        </.button>
      </div>
    </.card>

    <%!-- Standard flash compat --%>
    <.card title_text={gettext("Standard Phoenix Flash")}>
      <.paragraph>
        The standard <code>flash_group/1</code> still works with Phoenix's built-in <code>put_flash/3</code>.
        This uses the single <code>@flash</code> map on the socket — the alert appears at the top
        of the main content area (placed in <code>app.html.heex</code>).
      </.paragraph>
      <div style="display: flex; gap: 0.5rem;">
        <.button variant="info" size="sm" phx-click="push-standard-flash" phx-value-kind="info">
          put_flash :info
        </.button>
        <.button variant="danger" size="sm" phx-click="push-standard-flash" phx-value-kind="error">
          put_flash :error
        </.button>
      </div>
    </.card>

    <%!-- Usage examples --%>
    <.card title_text={gettext("Usage")}>
      <.heading level="4">{gettext("Template")}</.heading>
      <.code_block language="heex">{@usage_template}</.code_block>

      <.heading level="4">{gettext("Server")}</.heading>
      <.code_block language="elixir">{@usage_server}</.code_block>

      <.heading level="4">{gettext("Standard flash (backwards compatible)")}</.heading>
      <.code_block language="heex">{@usage_standard}</.code_block>
    </.card>
    """
  end
end
