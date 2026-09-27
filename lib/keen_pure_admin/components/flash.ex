defmodule PureAdmin.Components.Flash do
  @moduledoc """
  Flash message components for Pure Admin.

  Provides two approaches:

  ## Standard Phoenix flash (single `@flash` map)

  Drop-in replacements for `CoreComponents` — works with `put_flash/3`:

      <.flash_group flash={@flash} />
      <.flash kind={:info} flash={@flash} />

  ## Independent flash containers (multiple per page)

  For forms/cards that need their own flash messages, use `flash_container/1`
  with the `PureAdminFlash` JS hook and `push_flash/5`:

      <!-- In your template -->
      <.card title_text="Contact Form">
        <.flash_container id="contact-form" />
        <.simple_form phx-submit="save-contact">...</.simple_form>
      </.card>

      <.card title_text="Profile">
        <.flash_container id="profile" />
        <.simple_form phx-submit="save-profile">...</.simple_form>
      </.card>

      # In your LiveView
      def handle_event("save-contact", _params, socket) do
        {:noreply, push_flash(socket, "contact-form", "success", "Contact saved!")}
      end

  Each container receives messages independently — pushing to `"contact-form"`
  does not affect `"profile"`.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import PureAdmin.Helpers
  import PureAdmin.Translations, only: [t: 1]

  @flash_variant_map %{
    info: "info",
    error: "danger",
    warning: "warning",
    success: "success"
  }

  @doc """
  Renders a single flash message as a Pure Admin alert.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} title="Oops!" flash={@flash} />
      <.flash kind={:info}>Custom inline message</.flash>
  """
  attr(:id, :string, default: nil, doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil, doc: "optional title above the flash message")
  attr(:kind, :atom, values: [:info, :error, :warning, :success], doc: "used for styling and flash lookup")
  attr(:is_dismissible, :boolean, default: true, doc: "show close button")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "flash-#{assigns.kind}" end)
      |> assign(:variant, Map.get(@flash_variant_map, assigns.kind, "info"))

    dismiss_cmd =
      JS.push("lv:clear-flash", value: %{key: assigns.kind})
      |> JS.hide(to: "##{assigns.id}", transition: {"transition-opacity duration-300", "opacity-100", "opacity-0"})

    assigns = assign(assigns, :dismiss_cmd, dismiss_cmd)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      role="alert"
      class={build_classes("pa-alert", [{"pa-alert--#{@variant}", true}, {"pa-alert--dismissible", @is_dismissible}], @class)}
      {@rest}
    >
      <span class="pa-alert__icon"><span class={"pa-icon pa-icon--#{@variant}"} aria-hidden="true"></span></span>
      <div class="pa-alert__content">
        <h4 :if={@title} class="pa-alert__heading">{@title}</h4>
        {msg}
      </div>
      <button
        :if={@is_dismissible}
        class="pa-alert__close"
        phx-click={@dismiss_cmd}
        aria-label={t("pureAdmin.a11y.close")}
      >
        <span class="pa-icon pa-icon--x" aria-hidden="true"></span>
      </button>
    </div>
    """
  end

  @doc """
  Renders a group of flash messages (info + error by default).

  Drop-in replacement for the `flash_group/1` from CoreComponents.

  ## Examples

      <.flash_group flash={@flash} />

      <.flash_group flash={@flash} kinds={[:info, :error, :warning, :success]} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")
  attr(:kinds, :list, default: [:info, :error], doc: "which flash kinds to render")

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash :for={kind <- @kinds} kind={kind} flash={@flash} />
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Independent flash containers (hook-based)
  # ---------------------------------------------------------------------------

  @doc """
  Pushes a flash message to a specific container via `push_event`.

  The target `flash_container/1` with the matching `id` renders the message
  client-side using the `PureAdminFlash` JS hook. Multiple containers on the
  same page work independently.

  The message body supports basic markdown: **bold**, *italic*, `[links](url)`,
  unordered lists (`- item`), ordered lists (`1. item`), and paragraphs.

  ## Options

  - `:title` — optional heading above the message
  - `:duration` — auto-dismiss in ms (default: `0` = persistent)
  - `:dismissible` — show close button (default: `true`)
  - `:actions` — list of action button maps (see below)

  ## Action buttons

  Each action is a map with:

  - `:label` — button text (required)
  - `:variant` — button style, e.g. `"primary"`, `"danger"`, `"secondary"` (default: `"secondary"`)
  - `:event` — LiveView event name to push when clicked
  - `:params` — map of params sent with the event
  - `:dismiss` — if `true`, dismisses the flash on click

  ## Examples

      socket |> push_flash("my-form", "success", "Saved!")

      socket |> push_flash("my-form", "danger", "Failed.", title: "Error")

      socket |> push_flash("my-form", "info", "Gone in 5s", duration: 5000)

      socket |> push_flash("my-form", "warning", \"""
      Are you sure you want to delete **Invoice #1234**?

      This action cannot be undone.
      \""",
        title: "Confirm Deletion",
        actions: [
          %{label: "Delete", event: "delete-record", params: %{id: 1234}, variant: "danger"},
          %{label: "Cancel", dismiss: true, variant: "secondary"}
        ])
  """
  def push_flash(socket, container_id, variant, message, opts \\ []) do
    payload = %{
      container: container_id,
      variant: variant,
      message: message,
      title: Keyword.get(opts, :title),
      duration: Keyword.get(opts, :duration, 0),
      dismissible: Keyword.get(opts, :dismissible, true),
      replace: Keyword.get(opts, :replace, false)
    }

    payload =
      case Keyword.get(opts, :actions) do
        nil -> payload
        actions when is_list(actions) -> Map.put(payload, :actions, actions)
      end

    Phoenix.LiveView.push_event(socket, "pa:flash", payload)
  end

  @doc """
  Removes every flash currently rendered in `container_id`.

  Useful when a form result should replace (rather than stack on top of) a
  prior status — e.g. clear an old "Validation failed" banner before pushing
  a new "Saved" one.

      push_flash(socket, "my-form", "success", "Saved!", replace: true)

  …is the one-call equivalent. Use `clear_flash/2` when you want to clear
  without immediately pushing a new message.
  """
  @spec clear_flash(Phoenix.LiveView.Socket.t(), String.t()) :: Phoenix.LiveView.Socket.t()
  def clear_flash(socket, container_id) do
    Phoenix.LiveView.push_event(socket, "pa:flash-clear", %{container: container_id})
  end

  @doc """
  Renders a flash container that receives messages from `push_flash/5`.

  Place this wherever you want inline flash alerts to appear — inside cards,
  forms, or any other container. Each container operates independently.

  Requires the `PureAdminFlash` JS hook (included in `PureAdminHooks`).

  ## Examples

      <.flash_container id="contact-form" />
      <.flash_container id="profile-card" class="my-custom-class" />
  """
  attr(:id, :string, required: true, doc: "unique ID, also used as the target for push_flash")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def flash_container(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PureAdminFlash"
      data-container-id={@id}
      class={@class}
      aria-live="polite"
      {@rest}
    >
    </div>
    """
  end
end
