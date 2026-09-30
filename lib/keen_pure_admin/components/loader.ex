defmodule PureAdmin.Components.Loader do
  @moduledoc """
  Loader and spinner components for Pure Admin.

  Provides `spinner/1` for rotating spinners and `loader/1` for animated loaders
  with multiple types (dots, bars, pulse, ring, wave).
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  @doc """
  Renders a spinner.

  ## Examples

      <.spinner />
      <.spinner size="lg" variant="primary" />
  """
  attr(:size, :string,
    default: nil,
    values: [nil, "xs"],
    doc: "Spinner size — the core framework currently only ships `--xs`. Larger sizes use the default."
  )

  attr(:variant, :string,
    default: nil,
    values: [nil, "primary", "secondary", "success", "danger", "warning", "info"],
    doc: "Spinner color variant"
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def spinner(assigns) do
    ~H"""
    <div
      class={build_classes("pa-spinner", [
        {"pa-spinner--#{@size}", @size != nil},
        {"pa-spinner--#{@variant}", @variant != nil}
      ], @class)}
      {@rest}
    ></div>
    """
  end

  @doc """
  Renders an animated loader.

  ## Types

  - `"dots"` (default): Three bouncing dots
  - `"bars"` / `"wave"`: Five animated bars
  - `"pulse"`: Pulsing circle
  - `"ring"`: Spinning ring

  ## Examples

      <.loader />
      <.loader type="bars" color="primary" />
      <.loader type="pulse" size="lg" />
  """
  attr(:type, :string, default: "dots", values: ["dots", "bars", "pulse", "ring", "wave"], doc: "Loader animation type")
  attr(:size, :string, default: nil, values: [nil, "lg"], doc: "Loader size")

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "success", "danger", "warning", "info"],
    doc:
      "Loader color. Loaders paint from `currentColor`, so this emits an inline " <>
        "`style=\"color: var(--pc-…)\"` on the wrapper (there is no `pa-loader-{type}--{color}` " <>
        "class in core). Pass your own `style` via `class`/a wrapper instead of combining with `color`."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def loader(assigns) do
    # Colour is an inline `color:` on the wrapper (currentColor), never a modifier
    # class. Route it through @rest so the attribute is OMITTED when there is no
    # colour — binding `style={nil}` directly still renders `style=""` in HEEx,
    # which is a phantom attribute vs the core golden.
    assigns = assign(assigns, :rest, maybe_put_style(assigns.rest, color_style(assigns.color)))

    ~H"""
    <div class={loader_classes(assigns)} {@rest}>
      <%= cond do %>
        <% @type == "dots" -> %>
          <span></span><span></span><span></span>
        <% @type in ["bars", "wave"] -> %>
          <span></span><span></span><span></span><span></span><span></span>
        <% true -> %>
      <% end %>
    </div>
    """
  end

  defp maybe_put_style(rest, nil), do: rest
  defp maybe_put_style(rest, style), do: Map.put(rest, :style, style)

  # Core themes loaders via `currentColor` on the wrapper, not a modifier class.
  # Map the semantic color name to the matching --pc-* custom property.
  defp color_style(nil), do: nil
  defp color_style("primary"), do: "color: var(--pc-accent)"
  defp color_style("secondary"), do: "color: var(--pc-text-color-2)"
  defp color_style(color), do: "color: var(--pa-#{color}-bg)"

  @doc "Renders a centered loader container (flexbox centering)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def loader_center(assigns) do
    ~H"""
    <div class={build_classes("pa-loader-center", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc "Renders a centered loader overlay with backdrop."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def loader_overlay(assigns) do
    ~H"""
    <div class={build_classes("pa-loader-overlay", [], @class)} {@rest}>
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <.spinner />
      <% end %>
    </div>
    """
  end

  defp loader_classes(assigns) do
    # Only `--lg` size modifiers exist per loader type; color is handled by the
    # inline `color:` style (see color_style/1), never a `--{color}` class.
    build_classes(
      "pa-loader-#{assigns.type}",
      [
        {"pa-loader-#{assigns.type}--#{assigns.size}", assigns.size != nil}
      ],
      assigns.class
    )
  end
end
