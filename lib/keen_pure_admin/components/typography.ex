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

  @doc """
  Renders a paragraph.

  Core's canonical paragraph is the `.pa-text` BEM typography component. The
  base carries 14px + primary colour; the optional modifiers tune size,
  colour, logical alignment, and compound semantic styles — all real
  `pa-text--*` classes from core's `_utilities.scss` (see
  `snippets/typography.html`).
  """
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"], doc: "Size modifier (pa-text--{size}).")
  attr(:color, :string, default: nil, values: [nil, "primary", "secondary"], doc: "Colour modifier (pa-text--{color}).")

  attr(:align, :string,
    default: nil,
    values: [nil, "start", "center", "end"],
    doc: "Logical text alignment (pa-text--{align}); RTL-aware."
  )

  attr(:semantic, :string,
    default: nil,
    values: [nil, "caption", "lead"],
    doc: "Compound semantic style (pa-text--{semantic})."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def paragraph(assigns) do
    ~H"""
    <p class={paragraph_classes(assigns)} {@rest}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  defp paragraph_classes(assigns) do
    build_classes(
      "pa-text",
      [
        {"pa-text--#{assigns.size}", assigns.size != nil},
        {"pa-text--#{assigns.color}", assigns.color != nil},
        {"pa-text--#{assigns.align}", assigns.align != nil},
        {"pa-text--#{assigns.semantic}", assigns.semantic != nil}
      ],
      assigns.class
    )
  end

  @doc """
  Renders an inline coloured-text span.

  Core's blessed inline-colour shape is a bare `<span>` carrying a semantic
  `.text-{variant}` colour utility (see `snippets/typography.html`). Core ships
  exactly five: `primary`, `success`, `danger`, `warning`, `info`. With no
  variant the span is class-less. (For sized/aligned paragraph text use
  `paragraph/1`, the `.pa-text` component.)
  """
  attr(:variant, :string,
    default: nil,
    values: [nil, "primary", "success", "danger", "warning", "info"],
    doc: "Semantic colour → `.text-{variant}`."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def text(assigns) do
    assigns = assign(assigns, :variant_class, text_variant_class(assigns.variant))

    ~H"""
    <span class={text_classes(@variant_class, @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  # Semantic colours live in the flat `.text-*` utilities (not pa-text--*).
  defp text_variant_class(nil), do: nil
  defp text_variant_class(color), do: "text-#{color}"

  # No variant and no extra class → a class-less bare <span> (nil, not "").
  defp text_classes(nil, nil), do: nil
  defp text_classes(nil, ""), do: nil

  defp text_classes(variant_class, extra) do
    [variant_class, extra]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join(" ")
    |> case do
      "" -> nil
      s -> s
    end
  end

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
