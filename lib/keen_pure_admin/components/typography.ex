defmodule PureAdmin.Components.Typography do
  @moduledoc """
  Typography components for Pure Admin. (Phase 2)
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  @doc "Renders a heading (h1-h6)."
  attr(:level, :any,
    default: 2,
    values: [1, 2, 3, 4, 5, 6, "1", "2", "3", "4", "5", "6"],
    doc: "Heading level (1-6)"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def heading(assigns) do
    level = if is_binary(assigns.level), do: assigns.level, else: "#{assigns.level}"
    assigns = assign(assigns, :tag, "h#{level}")

    # Core headings are bare semantic tags (`<h1>`..`<h6>`) with NO class — core
    # defines no `pa-heading` (see snippets/typography.html). Emit the tag
    # unclassed; callers add utilities via `class` (e.g. `pa-text--center`).
    ~H"""
    <.dynamic_tag tag_name={@tag} class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </.dynamic_tag>
    """
  end

  @doc "Renders a paragraph."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def paragraph(assigns) do
    # Core's canonical paragraph is `<p class="pa-text">` (core defines no
    # `pa-paragraph`). Matches keen's own `text/1`, which also uses `pa-text`.
    ~H"""
    <p class={build_classes("pa-text", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc "Renders a text span."
  attr(:variant, :string,
    default: nil,
    values: [nil, "muted", "small", "primary", "secondary", "success", "danger", "warning", "info"]
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def text(assigns) do
    assigns = assign(assigns, :variant_class, text_variant_class(assigns.variant))

    ~H"""
    <span class={build_classes("pa-text", [{@variant_class, @variant_class != nil}], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  # Core ships only `pa-text--primary/--secondary` (+ size/align/style) — there is
  # no `pa-text--muted/--small/--success/--danger/--warning/--info`. Semantic
  # colours live in the `.text-*` utilities. Map keen's friendly variant names to
  # the real classes rather than emitting invented modifiers.
  defp text_variant_class(nil), do: nil
  defp text_variant_class("muted"), do: "pa-text--secondary"
  defp text_variant_class("small"), do: "pa-text--sm"
  defp text_variant_class("primary"), do: "pa-text--primary"
  defp text_variant_class("secondary"), do: "pa-text--secondary"
  defp text_variant_class(color), do: "text-#{color}"

  @doc """
  Renders a styled link.

  Core's `.pa-link` has no colour modifiers — it inherits the accent colour.
  For a dimmed or semantic link, add a `.text-*` utility via `class`
  (e.g. `class="text-color-2"` for muted, or `text-danger`/`text-success`/etc.).
  """
  attr(:href, :string, default: "#")
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(navigate patch target))
  slot(:inner_block, required: true)

  def pa_link(assigns) do
    ~H"""
    <a href={safe_url(@href)} class={build_classes("pa-link", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end
end
