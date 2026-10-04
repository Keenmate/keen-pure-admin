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
    # unclassed; callers add utilities via `class` (e.g. `text-center`).
    ~H"""
    <.dynamic_tag tag_name={@tag} class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </.dynamic_tag>
    """
  end

  @doc """
  Renders a paragraph.

  Emits the flat `text-*` typography utilities (core's `_utilities.scss`). With
  no `size`, a paragraph is a plain `<p>` at the body default (16px = `text-base`,
  matching a bare `<p>`). The `size` prop maps DIRECTLY to the same-named flat
  utility: `xs`→`text-xs` (12), `sm`→`text-sm` (14), `lg`→`text-lg` (18),
  `xl`→`text-xl` (20). Colour / alignment / semantic props tune it further.
  """
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"], doc: "Size → the same-named flat text-* utility; omit for the body default (16px).")

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary"],
    doc: "Colour: \"secondary\" → text-secondary (muted/subdued); \"primary\" → text-body (= default)."
  )

  attr(:align, :string,
    default: nil,
    values: [nil, "start", "center", "end"],
    doc: "Logical text alignment (text-{align}); RTL-aware."
  )

  attr(:semantic, :string,
    default: nil,
    values: [nil, "caption", "lead"],
    doc: "Compound semantic style (text-{semantic})."
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
    # No size → a plain <p> at the body default (16px); don't force a size class.
    [
      paragraph_size_class(assigns.size),
      paragraph_color_class(assigns.color),
      assigns.align && "text-#{assigns.align}",
      assigns.semantic && "text-#{assigns.semantic}",
      assigns.class
    ]
    |> Enum.reject(&(&1 in [nil, false, ""]))
    |> Enum.join(" ")
    |> case do
      "" -> nil
      s -> s
    end
  end

  # Direct map to the same-named flat text-* utility; no size → plain <p> (body 16px).
  defp paragraph_size_class(nil), do: nil
  defp paragraph_size_class("xs"), do: "text-xs"
  defp paragraph_size_class("sm"), do: "text-sm"
  defp paragraph_size_class("lg"), do: "text-lg"
  defp paragraph_size_class("xl"), do: "text-xl"

  defp paragraph_color_class("secondary"), do: "text-secondary"
  defp paragraph_color_class("primary"), do: "text-body"
  defp paragraph_color_class(_), do: nil

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
    values: [nil, "primary", "secondary", "success", "danger", "warning", "info"],
    doc:
      "Semantic colour → `.text-{variant}`. \"secondary\" → `.text-secondary` is the " <>
        "muted/subdued text colour."
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

  # All semantic colours are flat `.text-*` utilities; "secondary" →
  # `.text-secondary` is the muted/subdued colour (colour-only, so inline-safe).
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
  (e.g. `class="text-secondary"` for muted, or `text-danger`/`text-success`/etc.).
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
