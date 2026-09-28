defmodule DemoWeb.Live.ToastsLive do
  use DemoWeb, :live_view

  # push_toast is not a component function, so it's not in `use PureAdmin.Components`
  # Import it directly without conflicting with the bulk component import
  alias PureAdmin.Components.Toast, as: PureToast

  @toast_messages %{
    "primary" => %{title: "Primary", message: "This is a primary toast notification."},
    "success" => %{title: "Success!", message: "Your action was completed successfully."},
    "danger" => %{title: "Error", message: "An error occurred. Please try again."},
    "warning" => %{title: "Warning", message: "Please review this warning message."},
    "info" => %{title: "Information", message: "Here is some useful information for you."}
  }

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: "Toasts",
      task_running: false,
      code_server: ~s"""
      # In your LiveView
      socket |> PureToast.push_toast("success", "Saved!", "Changes saved.")
      socket |> PureToast.push_toast("danger", "Error", "Failed.", duration: 0)
      socket |> PureToast.push_toast("info", "Note", "FYI", position: "bottom-end")\
      """,
      code_template: ~s'<.toast_container id="toasts" position="top-end" is_hook />'
    )}
  end

  def handle_event("show_toast", params, socket) do
    variant = params["variant"] || "info"
    position = params["position"] || "top-end"
    duration = String.to_integer(params["duration"] || "5000")
    filled = params["filled"] == "true"
    title = params["title"] || @toast_messages[variant].title
    message = params["message"] || @toast_messages[variant].message

    progress = params["progress"] == "true"
    {:noreply, PureToast.push_toast(socket, variant, title, message, duration: duration, position: position, filled: filled, progress: progress)}
  end

  def handle_event("show_action_toast", %{"type" => "undo"}, socket) do
    {:noreply,
     PureToast.push_toast(socket, "warning", "Item Deleted", "The item has been moved to trash.",
       duration: 8000,
       progress: true,
       actions: [
         %{label: "Undo", event: "undo_delete", variant: "warning"},
         %{label: "Dismiss", dismiss: true}
       ]
     )}
  end

  def handle_event("show_action_toast", %{"type" => "retry"}, socket) do
    {:noreply,
     PureToast.push_toast(socket, "danger", "Save Failed", "Could not save your changes.",
       duration: 0,
       actions: [
         %{label: "Retry", event: "retry_save", variant: "danger"},
         %{label: "Dismiss", dismiss: true}
       ]
     )}
  end

  def handle_event("show_action_toast", %{"type" => "update"}, socket) do
    {:noreply,
     PureToast.push_toast(socket, "info", "Update Available", "Version 2.3.0 is ready to install.",
       duration: 0,
       actions: [
         %{label: "Update Now", event: "do_update", variant: "primary"},
         %{label: "Later", dismiss: true}
       ]
     )}
  end

  def handle_event("show_action_toast", %{"type" => "filled"}, socket) do
    {:noreply,
     PureToast.push_toast(socket, "success", "Export Ready", "Your report is ready for download.",
       duration: 0,
       filled: true,
       actions: [
         %{label: "Download", event: "download_export", variant: "success"},
         %{label: "Dismiss", dismiss: true}
       ]
     )}
  end

  # Action button callbacks
  def handle_event("undo_delete", _params, socket) do
    {:noreply, PureToast.push_toast(socket, "success", "Restored", "Item has been restored.")}
  end

  def handle_event("retry_save", _params, socket) do
    {:noreply, PureToast.push_toast(socket, "success", "Saved", "Changes saved successfully.")}
  end

  def handle_event("do_update", _params, socket) do
    {:noreply, PureToast.push_toast(socket, "success", "Updating...", "Update started.", duration: 3000)}
  end

  def handle_event("download_export", _params, socket) do
    {:noreply, PureToast.push_toast(socket, "info", "Downloading", "Your download has started.", duration: 3000)}
  end

  def handle_event("show_multiple", _params, socket) do
    socket =
      socket
      |> PureToast.push_toast("success", "First Toast", "This is the first notification")
      |> PureToast.push_toast("warning", "Second Toast", "This is the second notification")
      |> PureToast.push_toast("info", "Third Toast", "This is the third notification")

    {:noreply, socket}
  end

  def handle_event("start_task", _params, socket) do
    # Simulate a long-running background task (3-8 seconds)
    Task.start(fn ->
      duration = Enum.random(3000..8000)
      Process.sleep(duration)
      seconds = Float.round(duration / 1000, 1)

      Phoenix.PubSub.broadcast(
        Demo.PubSub,
        "toasts",
        {:push_toast, "success", "Task Complete!", "Background task finished in #{seconds}s. This toast appeared wherever you are.", duration: 0}
      )
    end)

    {:noreply,
      socket
      |> assign(:task_running, true)
      |> PureToast.push_toast("info", "Task Started", "Processing in background... Navigate away and come back — the toast will appear when done.", duration: 3000)}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>Temporary notification messages that auto-dismiss. Toasts are rendered client-side via JS hook — the server pushes events, no round-trips for display/dismiss.</.paragraph>

    <%!-- Toast containers for each position (hook-based, client-side rendering) --%>
    <%!-- top-end container is already in app.html.heex layout --%>
    <.toast_container id="toasts-top-center" position="top-center" is_hook />
    <.toast_container id="toasts-top-start" position="top-start" is_hook />
    <.toast_container id="toasts-bottom-end" position="bottom-end" is_hook />
    <.toast_container id="toasts-bottom-center" position="bottom-center" is_hook />
    <.toast_container id="toasts-bottom-start" position="bottom-start" is_hook />

    <%!-- Toast Positions --%>
    <.card title_text={gettext("Toast Positions")}>
      <.grid>
        <.column size="100" md="1-3">
          <.button variant="primary" is_block phx-click="show_toast" phx-value-position="top-end" phx-value-variant="success">
            {gettext("Top End")}
          </.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="primary" is_block phx-click="show_toast" phx-value-position="top-center" phx-value-variant="info">
            {gettext("Top Center")}
          </.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="primary" is_block phx-click="show_toast" phx-value-position="top-start" phx-value-variant="warning">
            {gettext("Top Start")}
          </.button>
        </.column>
      </.grid>
      <.grid class="mt-4">
        <.column size="100" md="1-3">
          <.button variant="secondary" is_block phx-click="show_toast" phx-value-position="bottom-end" phx-value-variant="danger">
            {gettext("Bottom End")}
          </.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="secondary" is_block phx-click="show_toast" phx-value-position="bottom-center" phx-value-variant="primary">
            {gettext("Bottom Center")}
          </.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="secondary" is_block phx-click="show_toast" phx-value-position="bottom-start" phx-value-variant="success">
            {gettext("Bottom Start")}
          </.button>
        </.column>
      </.grid>
    </.card>

    <%!-- Toast Variants --%>
    <.card title_text={gettext("Toast Variants")}>
      <.button_group>
        <.button variant="primary" phx-click="show_toast" phx-value-variant="primary">{gettext("Primary")}</.button>
        <.button variant="success" phx-click="show_toast" phx-value-variant="success">{gettext("Success")}</.button>
        <.button variant="danger" phx-click="show_toast" phx-value-variant="danger">{gettext("Danger")}</.button>
        <.button variant="warning" phx-click="show_toast" phx-value-variant="warning">{gettext("Warning")}</.button>
        <.button variant="info" phx-click="show_toast" phx-value-variant="info">{gettext("Info")}</.button>
      </.button_group>
    </.card>

    <%!-- Toast with Progress Bar --%>
    <.card title_text={gettext("Toast with Progress Bar")}>
      <.heading level="5">{gettext("Standard")}</.heading>
      <.button_group>
        <.button :for={v <- ~w(primary success danger warning info)} variant={v} phx-click="show_toast" phx-value-variant={v} phx-value-progress="true" phx-value-title={String.capitalize(v)} phx-value-message={"#{String.capitalize(v)} toast with progress bar."}>
          {String.capitalize(v)}
        </.button>
      </.button_group>

      <.heading level="5">{gettext("Filled")}</.heading>
      <.button_group>
        <.button :for={v <- ~w(primary success danger warning info)} variant={v} phx-click="show_toast" phx-value-variant={v} phx-value-progress="true" phx-value-filled="true" phx-value-title={String.capitalize(v)} phx-value-message={"Filled #{v} toast with progress bar."}>
          {String.capitalize(v)}
        </.button>
      </.button_group>
    </.card>

    <%!-- Persistent Toasts --%>
    <.card title_text={gettext("Persistent Toasts (Manual Dismiss Only)")}>
      <.grid>
        <.column size="100" md="1-3">
          <.button variant="warning" is_block phx-click="show_toast" phx-value-variant="warning" phx-value-duration="0" phx-value-title="Important Warning" phx-value-message="This requires your attention. Click close to dismiss.">
            {gettext("Important Warning")}
          </.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="danger" is_block phx-click="show_toast" phx-value-variant="danger" phx-value-duration="0" phx-value-title="Critical Error" phx-value-message="Critical error detected! Will remain until acknowledged.">
            {gettext("Critical Error")}
          </.button>
        </.column>
        <.column size="100" md="1-3">
          <.button variant="info" is_block phx-click="show_toast" phx-value-variant="info" phx-value-duration="0" phx-value-title="Important Info" phx-value-message="Read carefully before dismissing.">
            {gettext("Important Info")}
          </.button>
        </.column>
      </.grid>
      <.paragraph class="pa-text--secondary mt-4">
        These toasts stay visible until manually dismissed by clicking the close button (duration=0)
      </.paragraph>
    </.card>

    <%!-- Action Toasts --%>
    <.card title_text={gettext("Action Toasts")}>
      <.paragraph>Toasts with action buttons push events back to the server. Toasts with actions are not click-to-dismiss.</.paragraph>
      <.grid>
        <.column size="100" md="50">
          <.button variant="warning" phx-click="show_action_toast" phx-value-type="undo">
            {gettext("Undo Action")}
          </.button>
        </.column>
        <.column size="100" md="50">
          <.button variant="danger" phx-click="show_action_toast" phx-value-type="retry">
            {gettext("Retry Action")}
          </.button>
        </.column>
        <.column size="100" md="50">
          <.button variant="info" phx-click="show_action_toast" phx-value-type="update">
            {gettext("Update Available")}
          </.button>
        </.column>
        <.column size="100" md="50">
          <.button variant="success" phx-click="show_action_toast" phx-value-type="filled">
            {gettext("Filled + Actions")}
          </.button>
        </.column>
      </.grid>
    </.card>

    <%!-- Multiple Toasts --%>
    <.card title_text={gettext("Multiple Toasts (Stacking)")}>
      <.button variant="primary" phx-click="show_multiple">
        {gettext("Show 3 Toasts")}
      </.button>
      <.paragraph class="pa-text--secondary mt-4">
        Toasts automatically stack vertically in the container
      </.paragraph>
    </.card>

    <%!-- How it works --%>
    <%!-- Long Running Task --%>
    <.card title_text={gettext("Long Running Task (Server Push)")}>
      <.callout variant="info" heading_text={gettext("Real-World Pattern")}>
        <.paragraph>Click the button to start a background task (3-8 seconds random). You'll get an info toast immediately, then a success toast when it completes — even if you navigate to another page and come back.</.paragraph>
      </.callout>
      <.button
        variant="primary"
        phx-click="start_task"
        disabled={@task_running}
        is_loading={@task_running}
        class="mt-4"
      >
        <%= if @task_running, do: gettext("Task Running..."), else: gettext("Start Background Task") %>
      </.button>
    </.card>

    <%!-- Filled Toast Variants --%>
    <.card title_text={gettext("Filled Toast Variants")}>
      <.button_group>
        <.button :for={v <- ~w(primary success danger warning info)} variant={v} phx-click="show_toast" phx-value-variant={v} phx-value-title={String.capitalize(v)} phx-value-message={"Filled #{v} toast with full-color background."} phx-value-filled="true">
          {String.capitalize(v)}
        </.button>
      </.button_group>
    </.card>

    <%!-- Theme Color Toasts --%>
    <.card title_text={gettext("Theme Color Toasts")}>
      <.button_group>
        <.button :for={n <- 1..9} theme_color={to_string(n)} phx-click="show_toast" phx-value-variant={"color-#{n}"} phx-value-title={"Color #{n}"} phx-value-message={"Toast with theme color slot #{n}."}>
          Color {n}
        </.button>
      </.button_group>

      <.heading level="5">{gettext("Filled")}</.heading>
      <.button_group>
        <.button :for={n <- 1..9} theme_color={to_string(n)} phx-click="show_toast" phx-value-variant={"color-#{n}"} phx-value-title={"Color #{n}"} phx-value-message={"Filled toast with theme color slot #{n}."} phx-value-filled="true">
          Color {n}
        </.button>
      </.button_group>
    </.card>

    <.card title_text={gettext("How It Works")}>
      <.callout variant="info" heading_text={gettext("Architecture")}>
        <.paragraph>Toasts use a <strong>push_event</strong> pattern — the server decides <em>when</em> to show a toast, the client JS hook handles <em>rendering</em> and <em>auto-dismiss</em>. No server round-trips for display or dismissal.</.paragraph>
      </.callout>

      <.heading level={4} class="mt-4">{gettext("Server (LiveView)")}</.heading>
      <.code_block language="elixir"><%= @code_server %></.code_block>

      <.heading level={4} class="mt-4">{gettext("Template")}</.heading>
      <.code_block language="heex"><%= @code_template %></.code_block>
    </.card>
    """
  end
end
