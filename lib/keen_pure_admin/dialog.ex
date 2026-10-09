defmodule PureAdmin.Dialog do
  @moduledoc """
  Server-driven modal dialogs for LiveView.

  Lets a LiveView **open a dialog from the server** and receive the answer as a
  normal `handle_event/3`. Built on the declarative `PureAdmin.Components.Modal`,
  so the dialog is server-rendered HTML — no client bridge, and the user's choice
  is a plain event, not a JS promise shuttled back over the wire.

  This complements the client-only `window.PureAdmin.confirm/alert/prompt` JS API
  (`assets/js/modal_dialogs.js`), which a server process cannot call directly.
  Reach for `PureAdmin.Dialog` whenever the *server* decides to ask something
  ("this document was changed by someone else — reload?") or when the dialog
  hosts a LiveView form.

  ## Setup (once per app)

  1. Add the `on_mount` hook to your `live_session` so every LiveView gets the
     `:pa_dialog` assign and the auto-close handler:

         live_session :default, on_mount: [{PureAdmin.Dialog, :default}] do
           # your live routes
         end

  2. Drop the host once in your app layout (next to the command palette / toasts):

         <PureAdmin.Dialog.host dialog={@pa_dialog} />

  ## Standard dialogs (requirement A)

  Alerts (`info/success/warning/error`) render one acknowledge button; `confirm`
  renders cancel + confirm. Position (`:center` / `:top`) and plain-vs-`banded`
  are options. The answer is whatever event you name on a button:

      def handle_event("delete_clicked", _p, socket) do
        {:noreply,
         PureAdmin.Dialog.confirm(socket,
           title: "Delete item?",
           message: "This can't be undone.",
           variant: "danger",
           position: :top,
           confirm: [label: "Delete", variant: "danger", event: "do_delete", value: %{id: 7}],
           cancel: [label: "Keep"]
         )}
      end

      # The user's choice arrives as an ordinary event; the dialog auto-closes.
      def handle_event("do_delete", %{"id" => id}, socket), do: ...

  `info/3` and friends:

      PureAdmin.Dialog.success(socket, "Saved", "Your changes have been saved.")
      PureAdmin.Dialog.error(socket, "Upload failed", "The file was too large.")

  ## Custom / form dialogs (requirement B)

  Standard dialogs can't express an arbitrary LiveView form, so `open/3` just
  stashes a keyed spec; you render your own `PureAdmin.Components.Modal` keyed on
  it, with a normal `phx-submit`. `close/1` dismisses either kind.

      def handle_event("edit", %{"id" => id}, socket),
        do: {:noreply, PureAdmin.Dialog.open(socket, :edit, %{form: build_form(id)})}

      # in render:
      <.modal :if={@pa_dialog && @pa_dialog.key == :edit} id="edit-modal" show title_text="Edit">
        <.form for={@pa_dialog.form} phx-submit="save">...</.form>
      </.modal>

      def handle_event("save", params, socket) do
        # validate; on success:
        {:noreply, socket |> save(params) |> PureAdmin.Dialog.close()}
      end

  ## How closing works

  Every standard button pushes its own event (if any) **and** a library close
  event `"pa-dialog:close"`; the `on_mount` hook intercepts that event
  and clears `:pa_dialog`, so the dialog dismisses without the consumer writing a
  close handler. Backdrop click, the header ✕, and Escape push the close event
  too — unless the dialog is non-`dismissible` (forced choice: no ✕, no backdrop /
  Escape dismiss, the user must pick a button).

  Pass `on_dismiss: "some_event"` to **also** receive the ✕/backdrop/Escape
  dismissal as an ordinary event (pushed just before the close), e.g. to show a
  toast or treat the dismissal as an implicit cancel:

      PureAdmin.Dialog.confirm(socket, title: "…", on_dismiss: "doc_dismiss",
        confirm: [label: "Reload", event: "doc_reload"], cancel: [label: "Keep", event: "doc_keep"])

      def handle_event("doc_dismiss", _p, socket), do: ...  # fired on ✕ / backdrop / Esc
  """

  use Phoenix.Component
  import PureAdmin.Components.Modal
  import PureAdmin.Components.Button

  alias Phoenix.LiveView.JS

  @close_event "pa-dialog:close"

  # Type → default header variant + leading severity glyph. `info` has no
  # solid-header rule in core (band-only), so it defaults to a banded info strip;
  # the others get a solid coloured header. All overridable per call.
  @type_variant %{
    info: "info",
    success: "success",
    warning: "warning",
    error: "danger",
    confirm: "primary"
  }
  @type_icon %{
    info: "info",
    success: "success",
    warning: "warning",
    error: "danger"
  }

  @doc """
  `on_mount` hook. Add `{PureAdmin.Dialog, :default}` to your `live_session`.

  Seeds the `:pa_dialog` assign (nil = no dialog) and attaches a `:handle_event`
  hook that clears it when a dialog pushes the library close event.
  """
  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> assign_new(:pa_dialog, fn -> nil end)
      |> Phoenix.LiveView.attach_hook(:pa_dialog, :handle_event, fn
        @close_event, _params, socket -> {:halt, assign(socket, :pa_dialog, nil)}
        _event, _params, socket -> {:cont, socket}
      end)

    {:cont, socket}
  end

  @doc "Open a confirm dialog (cancel + confirm buttons). See module docs."
  def confirm(socket, opts) do
    variant = opts[:variant] || "primary"

    buttons = [
      normalize_button(opts[:cancel] || [], "Cancel", "secondary"),
      normalize_button(opts[:confirm] || [], "OK", variant)
    ]

    put(socket, build(:confirm, opts, variant: variant, buttons: buttons))
  end

  @doc "Open an info alert (single acknowledge button)."
  def info(socket, title, message \\ nil, opts \\ []), do: alert(socket, :info, title, message, opts)
  @doc "Open a success alert (single acknowledge button)."
  def success(socket, title, message \\ nil, opts \\ []), do: alert(socket, :success, title, message, opts)
  @doc "Open a warning alert (single acknowledge button)."
  def warning(socket, title, message \\ nil, opts \\ []), do: alert(socket, :warning, title, message, opts)
  @doc "Open an error alert (single acknowledge button)."
  def error(socket, title, message \\ nil, opts \\ []), do: alert(socket, :error, title, message, opts)

  defp alert(socket, type, title, message, opts) do
    variant = opts[:variant] || @type_variant[type]
    opts = Keyword.merge([title: title, message: message], opts)
    button = normalize_button(opts[:ok] || [], "OK", variant)
    put(socket, build(type, opts, variant: variant, buttons: [button]))
  end

  @doc """
  Open a custom dialog: stash a keyed spec (plus any extra assigns) in
  `:pa_dialog`. Render your own `<.modal>` keyed on `@pa_dialog.key`; dismiss with
  `close/1`.
  """
  def open(socket, key, assigns \\ %{}) when is_atom(key) do
    put(socket, Map.merge(%{type: :custom, key: key}, Map.new(assigns)))
  end

  @doc "Dismiss the current dialog (standard or custom)."
  def close(socket), do: put(socket, nil)

  @doc """
  Host component. Mount once in the app layout: `<PureAdmin.Dialog.host dialog={@pa_dialog} />`.
  Renders standard dialogs; custom (`type: :custom`) dialogs are rendered by the
  consumer, so the host no-ops for them.
  """
  attr(:dialog, :map, default: nil)

  def host(assigns) do
    ~H"""
    <div
      :if={@dialog && @dialog.type != :custom}
      phx-window-keydown={@dialog.dismissible && dismiss_js(@dialog)}
      phx-key="Escape"
    >
      <.modal
        id="pa-dialog"
        show
        variant={@dialog.variant}
        is_banded={@dialog.banded}
        is_top={@dialog.position == :top}
        is_static={!@dialog.dismissible}
        size={@dialog.size}
        title_text={@dialog.title}
        title_icon={@dialog.icon}
        should_show_close={@dialog.dismissible}
        on_cancel={(@dialog.dismissible && dismiss_js(@dialog)) || %JS{}}
      >
        <p :if={@dialog.message} class="pa-modal__message">{@dialog.message}</p>
        <:footer>
          <.button :for={b <- @dialog.buttons} variant={b.variant} phx-click={button_js(b)}>
            {b.label}
          </.button>
        </:footer>
      </.modal>
    </div>
    """
  end

  # ---- internals ---------------------------------------------------------

  defp build(type, opts, extra) do
    %{
      type: type,
      key: opts[:key],
      title: opts[:title],
      message: opts[:message],
      variant: extra[:variant],
      banded: Keyword.get(opts, :banded, type == :info),
      position: normalize_position(opts[:position]),
      size: opts[:size],
      icon: Keyword.get(opts, :icon, @type_icon[type]),
      dismissible: Keyword.get(opts, :dismissible, true),
      on_dismiss: opts[:on_dismiss],
      buttons: extra[:buttons]
    }
  end

  defp normalize_button(kw, default_label, default_variant) do
    %{
      label: kw[:label] || default_label,
      variant: kw[:variant] || default_variant,
      event: kw[:event],
      value: kw[:value],
      close?: Keyword.get(kw, :close, true)
    }
  end

  defp normalize_position(:top), do: :top
  defp normalize_position("top"), do: :top
  defp normalize_position(_), do: :center

  # A button pushes its own event (if any) AND the library close event (unless
  # close: false), so the consumer handles only their result and the dialog
  # auto-dismisses via the on_mount hook.
  defp button_js(%{event: nil, close?: true}), do: JS.push(@close_event)
  defp button_js(%{event: nil, close?: false}), do: %JS{}

  defp button_js(%{event: event, value: value, close?: close?}) do
    js = if value, do: JS.push(event, value: value), else: JS.push(event)
    if close?, do: JS.push(js, @close_event), else: js
  end

  # ✕ / backdrop / Escape: push the optional `on_dismiss` event (so the consumer
  # can react to a dismissal that wasn't one of the choice buttons), then always
  # the library close event that the on_mount hook clears state on.
  defp dismiss_js(%{on_dismiss: nil}), do: JS.push(@close_event)
  defp dismiss_js(%{on_dismiss: event}), do: event |> JS.push() |> JS.push(@close_event)

  defp put(socket, dialog), do: assign(socket, :pa_dialog, dialog)
end
