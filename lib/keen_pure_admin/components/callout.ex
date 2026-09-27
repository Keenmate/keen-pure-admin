defmodule PureAdmin.Components.Callout do
  @moduledoc """
  Callout components for Pure Admin.

  When an icon slot is provided, content is wrapped in `pa-callout__content` div
  for proper layout alongside the icon.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  @doc """
  Renders a callout box.

  ## Examples

      <.callout variant="info">Important note here.</.callout>

      <.callout variant="warning" heading_text="Warning">
        Be careful with this operation.
      </.callout>

      <.callout variant="info" size="sm">
        <:icon><span class="pa-icon pa-icon--info" aria-hidden="true"></span></:icon>
        This is a compact callout with an icon.
      </.callout>
  """
  attr(:variant, :string,
    default: "info",
    values: ["primary", "secondary", "info", "success", "warning", "danger"]
  )

  attr(:size, :string, default: nil, values: [nil, "sm", "lg"], doc: "Callout size")

  attr(:theme_color, :string,
    default: nil,
    values: [nil, "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    doc: "Theme color slot 1-9 (overrides variant)"
  )

  attr(:heading_text, :string, default: nil, doc: "Callout heading text (shorthand for :title slot)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon, doc: "Icon element (wraps content in pa-callout__content)")
  slot(:title, doc: "Optional callout title (overrides heading_text)")
  slot(:inner_block, required: true)

  def callout(assigns) do
    ~H"""
    <div class={callout_classes(assigns)} {@rest}>
      <%= if @icon != [] do %>
        <span class="pa-callout__icon">
          <%= for icon <- @icon do %>
            <%= render_slot(icon) %>
          <% end %>
        </span>
        <div class="pa-callout__content">
          <%= if @title != [] do %>
            <h4 :for={title <- @title} class="pa-callout__heading"><%= render_slot(title) %></h4>
          <% else %>
            <h4 :if={@heading_text} class="pa-callout__heading"><%= @heading_text %></h4>
          <% end %>
          <%= render_slot(@inner_block) %>
        </div>
      <% else %>
        <%!-- No icon: content is a direct child of .pa-callout. The
              pa-callout__content wrapper exists only to clearfix the floated
              icon, so it's icon-only (snippets/callouts.html). --%>
        <%= if @title != [] do %>
          <h4 :for={title <- @title} class="pa-callout__heading"><%= render_slot(title) %></h4>
        <% else %>
          <h4 :if={@heading_text} class="pa-callout__heading"><%= @heading_text %></h4>
        <% end %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </div>
    """
  end

  defp callout_classes(assigns) do
    variant_class =
      if assigns.theme_color != nil,
        do: "pa-callout--color-#{assigns.theme_color}",
        else: "pa-callout--#{assigns.variant}"

    build_classes(
      "pa-callout",
      [
        {variant_class, true},
        {"pa-callout--#{assigns.size}", assigns.size != nil}
      ],
      assigns.class
    )
  end
end
