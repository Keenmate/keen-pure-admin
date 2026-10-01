defmodule PureAdmin.Components.Toast do
  @moduledoc """
  Toast notification components for Pure Admin.

  Provides `toast/1` for server-rendered toasts, `toast_container/1` for positioning,
  and `push_toast/3` for triggering client-side toasts via `push_event`.

  ## Client-side toasts (recommended)

  Add a hook-enabled container in your layout:

      <.toast_container id="toasts" position="top-end" is_hook />

  Then push toasts from any LiveView:

      socket |> push_toast("success", "Saved!", "Your changes have been saved.")

  The JS hook handles rendering and auto-dismiss — no server round-trips.
  """
  use Phoenix.Component

  import PureAdmin.Helpers
  import PureAdmin.Translations, only: [t: 1]

  @doc """
  Pushes a toast notification to the client via `push_event`.

  The client-side `PureAdminToast` hook renders and auto-dismisses the toast.

  ## Options

  - `:duration` — auto-dismiss in ms (default: 5000, 0 = persistent)
  - `:position` — override container position (default: "top-end")

  ## Examples

      socket |> push_toast("success", "Saved!", "Changes saved successfully.")
      socket |> push_toast("danger", "Error", "Something went wrong.", duration: 0)
      socket |> push_toast("info", "Note", "FYI", position: "bottom-end")
  """
  def push_toast(socket, variant, title, message, opts \\ []) do
    payload = %{
      variant: variant,
      title: title,
      message: message,
      duration: Keyword.get(opts, :duration, 5000),
      position: Keyword.get(opts, :position, "top-end"),
      filled: Keyword.get(opts, :filled, false),
      progress: Keyword.get(opts, :progress, false)
    }

    payload =
      payload
      |> maybe_put(:progress_color, Keyword.get(opts, :progress_color))
      |> maybe_put(:max_width, Keyword.get(opts, :max_width))
      |> maybe_put(:actions, Keyword.get(opts, :actions))

    Phoenix.LiveView.push_event(socket, "toast", payload)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  @doc """
  Renders a toast notification.

  ## Examples

      <.toast variant="success" title_text="Success!" message_text="Changes saved." />

      <.toast variant="danger" title_text="Error" message_text="Save failed." on_close="dismiss_toast" />
  """
  attr(:id, :string, default: nil)

  attr(:variant, :string,
    default: "info",
    values: ["primary", "success", "danger", "warning", "info"]
  )

  attr(:theme_color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    doc: "Theme color slot 1-9 (overrides variant)"
  )

  attr(:is_filled, :boolean,
    default: false,
    doc: "Filled style with full-color background and contrast text"
  )

  attr(:title_text, :string, default: nil, doc: "Toast title")
  attr(:message_text, :string, default: nil, doc: "Toast message")
  attr(:is_visible, :boolean, default: true, doc: "Show/hide the toast")
  attr(:on_close, :string, default: nil, doc: "LiveView event fired on close")
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-click phx-value-id))
  slot(:icon, doc: "Custom icon content")
  slot(:actions, doc: "Action-button row rendered inside pa-toast__content, under a separator")
  slot(:inner_block, doc: "Custom body content (overrides title_text/message_text)")

  def toast(assigns) do
    ~H"""
    <div
      :if={@is_visible}
      id={@id}
      class={build_classes("pa-toast", [
        {toast_variant_class(assigns), true},
        {"pa-toast--show", @is_visible}
      ], @class)}
      {@rest}
    >
      <%!-- Severity chip: the snippet always leads with pa-toast__icon. Use the
           :icon slot if given, else auto-derive the masked glyph from the variant. --%>
      <div class="pa-toast__icon">
        <%= if @icon != [] do %>
          <%= for icon <- @icon do %><%= render_slot(icon) %><% end %>
        <% else %>
          <span class={"pa-icon pa-icon--#{toast_icon_glyph(@variant)}"} aria-hidden="true"></span>
        <% end %>
      </div>
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <div class="pa-toast__content">
          <div :if={@title_text} class="pa-toast__title"><%= @title_text %></div>
          <div :if={@message_text} class="pa-toast__message"><%= @message_text %></div>
          <div :if={@actions != []} class="pa-toast__actions"><%= render_slot(@actions) %></div>
        </div>
      <% end %>
      <button
        :if={@on_close}
        class="pa-toast__close"
        phx-click={@on_close}
        phx-value-id={@id}
        aria-label={t("pureAdmin.a11y.close")}
      >
        <span class="pa-icon pa-icon--x" aria-hidden="true"></span>
      </button>
    </div>
    """
  end

  @doc """
  Renders a toast container for positioning toasts in the viewport.

  ## Positions

  `top-end`, `top-center`, `top-start`, `bottom-end`, `bottom-center`, `bottom-start`

  ## Examples

      <.toast_container position="top-end">
        <.toast :for={t <- @toasts} id={t.id} variant={t.variant} title_text={t.title} message_text={t.message} on_close="dismiss_toast" />
      </.toast_container>
  """
  attr(:id, :string, default: nil, doc: "Required when using phx-hook")

  attr(:position, :string,
    default: "top-end",
    values: ["top-end", "top-center", "top-start", "bottom-end", "bottom-center", "bottom-start"]
  )

  attr(:is_hook, :boolean,
    default: false,
    doc: "Use PureAdminToast JS hook for client-side toast management via push_event"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def toast_container(assigns) do
    ~H"""
    <div
      id={@id}
      class={build_classes("pa-toast-container", [{"pa-toast-container--#{@position}", true}], @class)}
      phx-hook={if @is_hook, do: "PureAdminToast"}
      data-position={@position}
      {@rest}
    >
      <%= if @inner_block != [], do: render_slot(@inner_block) %>
    </div>
    """
  end

  defp toast_variant_class(assigns) do
    cond do
      assigns.theme_color != nil and assigns.is_filled ->
        "pa-toast--filled-color-#{assigns.theme_color}"

      assigns.theme_color != nil ->
        "pa-toast--color-#{assigns.theme_color}"

      assigns.is_filled ->
        "pa-toast--filled-#{assigns.variant}"

      true ->
        "pa-toast--#{assigns.variant}"
    end
  end

  # Severity glyph for the auto-derived toast icon chip (snippet: success/danger/
  # warning/info use their own glyph; primary/other fall back to info).
  defp toast_icon_glyph(variant) when variant in ~w(success danger warning info), do: variant
  defp toast_icon_glyph(_), do: "info"
end
