defmodule PureAdmin.Components.List do
  @moduledoc """
  List components for Pure Admin.

  Provides basic HTML lists (`basic_list/1`, `ordered_list/1`, `definition_list/1`)
  and complex structured lists (`list/1`, `list_item/1`).
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  # ─── Basic HTML Lists ───

  @doc """
  Renders a styled unordered list.

  ## Examples

      <.basic_list>
        <li>Item one</li>
        <li>Item two</li>
      </.basic_list>

      <.basic_list spacing="compact" has_icon icon_variant="danger">
        <li>Error one</li>
        <li>Error two</li>
      </.basic_list>
  """
  attr(:spacing, :string, default: nil, values: [nil, "compact", "spacious"])
  attr(:is_unstyled, :boolean, default: false, doc: "Remove bullets and padding")
  attr(:is_inline, :boolean, default: false, doc: "Display items inline (horizontal)")
  attr(:is_bordered, :boolean, default: false, doc: "Add borders between items")
  attr(:is_striped, :boolean, default: false, doc: "Zebra striping on even rows")
  attr(:has_icon, :boolean, default: false, doc: "Show icons (checkmarks by default)")

  attr(:icon_variant, :string,
    default: "success",
    values: ["success", "danger", "info", "warning"],
    doc: "Icon variant (when has_icon is true)"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def basic_list(assigns) do
    ~H"""
    <ul class={basic_list_classes(assigns)} {@rest}>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  defp basic_list_classes(assigns) do
    build_classes(
      "pa-list-basic",
      [
        {"pa-list-basic--#{assigns.spacing}", assigns.spacing != nil},
        {"pa-list-basic--unstyled", assigns.is_unstyled},
        {"pa-list-basic--inline", assigns.is_inline},
        {"pa-list-basic--bordered", assigns.is_bordered},
        {"pa-list-basic--striped", assigns.is_striped},
        {"pa-list-basic--icon", assigns.has_icon},
        {"pa-list-basic--#{assigns.icon_variant}", assigns.has_icon && assigns.icon_variant != "success"}
      ],
      assigns.class
    )
  end

  @doc """
  Renders a styled ordered list.

  ## Examples

      <.ordered_list>
        <li>Step one</li>
        <li>Step two</li>
      </.ordered_list>

      <.ordered_list style="roman">
        <li>Chapter I</li>
        <li>Chapter II</li>
      </.ordered_list>
  """
  attr(:style, :string, default: nil, values: [nil, "roman", "alpha"])
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def ordered_list(assigns) do
    ~H"""
    <ol class={build_classes("pa-list-ordered", [{"pa-list-ordered--#{@style}", @style != nil}], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </ol>
    """
  end

  @doc """
  Renders a styled definition list.

  ## Examples

      <.definition_list>
        <dt>Term</dt>
        <dd>Definition</dd>
      </.definition_list>

      <.definition_list is_inline>
        <dt>Status</dt>
        <dd>Active</dd>
      </.definition_list>
  """
  attr(:is_inline, :boolean, default: false, doc: "Horizontal key-value layout")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def definition_list(assigns) do
    ~H"""
    <dl class={build_classes("pa-list-definition", [{"pa-list-definition--inline", @is_inline}], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </dl>
    """
  end

  # ─── Complex Structured Lists ───

  @doc "Renders a styled list container."
  attr(:as, :string,
    default: "div",
    values: ["div", "ul"],
    doc:
      "Container element. `\"div\"` (default) or `\"ul\"` for the semantic list form core " <>
        "recommends (snippets/lists.html) — pair with `list_item as=\"li\"`. `.pa-list` styles " <>
        "the same either way."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def list(assigns) do
    # The interactive `.pa-list` block ships NO bordered modifier in core (only
    # `.pa-list-basic--bordered` exists, on `basic_list/1`). The former
    # `is_bordered` attr emitted a dead `pa-list--bordered` class and was dropped.
    ~H"""
    <.dynamic_tag tag_name={@as} class={build_classes("pa-list", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </.dynamic_tag>
    """
  end

  @doc """
  Renders a list item with optional structured content.

  ## Examples

      <.list_item title_text="John Doe" subtitle_text="Developer" meta_text="Online" />

      <.list_item title_text="Jane Smith" subtitle_text="Designer">
        <:avatar><img src="/avatars/jane.jpg" /></:avatar>
      </.list_item>

      <.list_item>
        Custom content here
      </.list_item>
  """
  attr(:as, :string,
    default: "div",
    values: ["div", "li"],
    doc: "Item element. `\"div\"` (default) or `\"li\"` when the parent list uses `as=\"ul\"`."
  )

  attr(:title_text, :string, default: nil, doc: "Title text")
  attr(:subtitle_text, :string, default: nil, doc: "Subtitle text")
  attr(:meta_text, :string, default: nil, doc: "Meta text (right side)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:avatar, doc: "Avatar content")
  slot(:meta, doc: "Rich meta content (right side, overrides meta_text)")
  slot(:inner_block, doc: "Custom content (overrides title/subtitle/meta)")

  def list_item(assigns) do
    has_structured =
      assigns.title_text != nil || assigns.subtitle_text != nil || assigns.meta_text != nil || assigns.meta != []

    assigns = assign(assigns, :has_structured, has_structured)

    ~H"""
    <.dynamic_tag tag_name={@as} class={build_classes("pa-list__item", [], @class)} {@rest}>
      <div :if={@avatar != []} class="pa-list__avatar">
        <%= for avatar <- @avatar do %>
          <%= render_slot(avatar) %>
        <% end %>
      </div>
      <%= if @inner_block != [] && !@has_structured do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%!-- Canonical order: __meta lives INSIDE __content, stacked under
             title/subtitle (see snippets/lists.html — every example nests it,
             and the reference lists __meta under __content). It is NOT an
             item-level sibling. --%>
        <div class="pa-list__content">
          <div :if={@title_text} class="pa-list__title"><%= @title_text %></div>
          <div :if={@subtitle_text} class="pa-list__subtitle"><%= @subtitle_text %></div>
          <%= if @meta != [] do %>
            <%= for meta <- @meta do %>
              <%= render_slot(meta) %>
            <% end %>
          <% else %>
            <div :if={@meta_text} class="pa-list__meta"><%= @meta_text %></div>
          <% end %>
        </div>
        <%= if @inner_block != [] do %>
          <%= render_slot(@inner_block) %>
        <% end %>
      <% end %>
    </.dynamic_tag>
    """
  end
end
