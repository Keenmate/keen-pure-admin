defmodule PureAdmin.Components.Alert do
  @moduledoc """
  Alert components for Pure Admin with JS-command-based dismiss support.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import PureAdmin.Helpers
  import PureAdmin.Translations, only: [t: 1]

  @doc """
  Renders an alert with Pure Admin BEM classes.

  Supports dismissible alerts using `Phoenix.LiveView.JS` commands.

  ## Markup shapes

  Two layouts depending on whether an icon is supplied:

  - **With icon** — the non-icon content is wrapped in `pa-alert__content`
    so the icon and the content sit as the two flex children of the alert.
    Without the wrapper every word/element next to the icon would become
    its own flex item and the layout would break.
  - **Without icon** — structural children (`pa-alert__heading`,
    `pa-alert__list`, `pa-alert__actions`, top-level `<p>`/`<hr>`) are
    emitted as direct children of `pa-alert`. SCSS gives them
    `flex-basis: 100%` so each lands on its own row in the wrap.

  ## Heading sizes

  `pa-alert__heading` defaults to the alert's body font-size + semibold
  weight (compact look — good for status banners). Pass `heading_size="lg"`
  to add the `pa-alert__heading--lg` modifier for the louder,
  deliberate-read presentation (blocking errors, system updates, quota
  warnings).

  ## Multi-line content

  When you have an icon next to multi-line content (heading + body +
  actions inside `pa-alert__content`), pass `is_multiline` to opt back to
  `align-items: flex-start` so the icon stays at the top with the heading
  instead of centring against the whole stack. Not needed for structural
  stacks without an icon.

  ## Examples

      <.alert variant="success">Operation completed successfully.</.alert>

      <.alert variant="danger" is_dismissible id="error-alert">
        <:icon><span class="pa-icon pa-icon--danger" aria-hidden="true"></span></:icon>
        Something went wrong!
      </.alert>

      <.alert variant="info" heading_text="System Update" heading_size="lg" is_multiline>
        <:icon><span class="pa-icon pa-icon--info" aria-hidden="true"></span></:icon>
        New features available.
        <:actions>
          <.button variant="primary" size="sm">Update Now</.button>
        </:actions>
      </.alert>

      <.alert variant="danger" heading_text="Validation failed">
        Please fix the errors below.
      </.alert>
  """
  attr(:id, :string, default: nil)

  attr(:variant, :string,
    default: "info",
    values: ["primary", "secondary", "success", "warning", "danger", "info", "light", "dark"],
    doc: "Color variant"
  )

  attr(:size, :string, default: nil, values: [nil, "sm", "lg"])
  attr(:is_outline, :boolean, default: false, doc: "Outline style")
  attr(:is_dismissible, :boolean, default: false, doc: "Show close button")

  attr(:is_multiline, :boolean,
    default: false,
    doc: "Top-aligns flex children. Pass when an icon sits next to multi-line content."
  )

  attr(:heading_text, :string, default: nil, doc: "Alert heading text (shorthand for :heading slot)")

  attr(:heading_size, :string,
    default: nil,
    values: [nil, "lg"],
    doc: "Heading size — \"lg\" adds pa-alert__heading--lg for the deliberate-read presentation"
  )

  attr(:theme_color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    doc: "Theme color 1-9"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon, doc: "Alert icon (forces pa-alert__content wrapper around the rest)")
  slot(:heading, doc: "Alert heading (h4) - overrides heading_text")
  slot(:list, doc: "Alert list items (wrapped in ul.pa-alert__list)")
  slot(:actions, doc: "Action buttons row (rendered with toast-style separator)")
  slot(:inner_block, required: true)

  def alert(assigns) do
    assigns = assign(assigns, :has_icon, assigns.icon != [])

    ~H"""
    <div id={@id} class={alert_classes(assigns)} role="alert" {@rest}>
      <span :for={icon <- @icon} class="pa-alert__icon"><%= render_slot(icon) %></span>
      <%= if @has_icon do %>
        <div class="pa-alert__content">
          <.alert_body
            heading={@heading}
            heading_text={@heading_text}
            heading_size={@heading_size}
            list={@list}
            actions={@actions}
          ><%= render_slot(@inner_block) %></.alert_body>
        </div>
      <% else %>
        <.alert_body
          heading={@heading}
          heading_text={@heading_text}
          heading_size={@heading_size}
          list={@list}
          actions={@actions}
        ><%= render_slot(@inner_block) %></.alert_body>
      <% end %>
      <button
        :if={@is_dismissible}
        class="pa-alert__close"
        phx-click={dismiss_alert(@id)}
        aria-label={t("pureAdmin.a11y.close")}
      >
        <span class="pa-icon pa-icon--x" aria-hidden="true"></span>
      </button>
    </div>
    """
  end

  attr(:heading, :list, required: true)
  attr(:heading_text, :string, required: true)
  attr(:heading_size, :string, required: true)
  attr(:list, :list, required: true)
  attr(:actions, :list, required: true)
  slot(:inner_block, required: true)

  defp alert_body(assigns) do
    ~H"""
    <%= if @heading != [] do %>
      <h4 :for={heading <- @heading} class={heading_classes(@heading_size)}><%= render_slot(heading) %></h4>
    <% else %>
      <h4 :if={@heading_text} class={heading_classes(@heading_size)}><%= @heading_text %></h4>
    <% end %>
    <%= render_slot(@inner_block) %>
    <ul :if={@list != []} class="pa-alert__list">
      <%= for list <- @list do %><%= render_slot(list) %><% end %>
    </ul>
    <div :for={actions <- @actions} class="pa-alert__actions"><%= render_slot(actions) %></div>
    """
  end

  @doc """
  Returns a JS command that dismisses an alert by hiding it with a fade transition.
  """
  @spec dismiss_alert(String.t()) :: Phoenix.LiveView.JS.t()
  def dismiss_alert(id) do
    JS.hide(to: "##{id}", transition: {"transition-opacity duration-300", "opacity-100", "opacity-0"})
  end

  defp alert_classes(assigns) do
    variant_class =
      cond do
        assigns.theme_color != nil and assigns.is_outline ->
          "pa-alert--outline-color-#{assigns.theme_color}"

        assigns.theme_color != nil ->
          "pa-alert--color-#{assigns.theme_color}"

        assigns.is_outline ->
          "pa-alert--outline-#{assigns.variant}"

        true ->
          "pa-alert--#{assigns.variant}"
      end

    build_classes(
      "pa-alert",
      [
        {variant_class, true},
        {"pa-alert--#{assigns.size}", assigns.size != nil},
        {"pa-alert--multiline", assigns.is_multiline},
        {"pa-alert--dismissible", assigns.is_dismissible}
      ],
      assigns.class
    )
  end

  defp heading_classes(nil), do: "pa-alert__heading"
  defp heading_classes("lg"), do: "pa-alert__heading pa-alert__heading--lg"
end
