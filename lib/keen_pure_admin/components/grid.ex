defmodule PureAdmin.Components.Grid do
  @moduledoc """
  Grid system components for Pure Admin.

  Provides `grid/1` (row) and `column/1` wrapping the `pc-row` and `pc-col-*` classes.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  @doc """
  Renders a grid row container.

  ## Examples

      <.grid>
        <.column size="50" md="1-3">Content</.column>
        <.column size="50" md="2-3">Content</.column>
      </.grid>

      <.grid is_same_height is_no_gutter>
        <.column size="1-3">Card 1</.column>
        <.column size="1-3">Card 2</.column>
        <.column size="1-3">Card 3</.column>
      </.grid>
  """
  attr(:is_no_gutter, :boolean, default: false)
  attr(:is_same_height, :boolean, default: false)
  attr(:align, :string, default: nil, values: [nil, "center", "end", "between", "around", "stretch"])
  attr(:valign, :string, default: nil, values: [nil, "top", "middle", "bottom"])
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def grid(assigns) do
    ~H"""
    <div class={row_classes(assigns)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp row_classes(assigns) do
    build_classes(
      "pc-row",
      [
        {"pc-row--no-gutter", assigns.is_no_gutter},
        {"pc-row--same-height", assigns.is_same_height},
        {"pc-row--#{assigns.align}", assigns.align != nil},
        {"pc-row--#{assigns.valign}", assigns.valign != nil}
      ],
      assigns.class
    )
  end

  @doc """
  Renders a grid column.

  Column sizes use Pure Admin's naming: percentage (5-100 in 5% increments)
  or fractions (1-2, 1-3, 2-3, 1-4, 3-4, 1-5, 2-5, 3-5, 4-5, 1-6, 5-6, 1-12, 5-12, 7-12, 11-12).

  Note: Only multiples of 5 are valid for percentage widths (e.g. 25, 50, 75).
  For thirds use fractions: `1-3`, `2-3`. There is no `33` or `66`.

  ## Examples

      <.column size="100" md="50" lg="1-3">Responsive column</.column>
      <.column size="1-2" offset="25">Offset column</.column>
  """
  attr(:size, :string, default: nil, doc: "Base column size (e.g. '50', '1-3', '100')")
  attr(:sm, :string, default: nil, doc: "Size at sm breakpoint (>=576px)")
  attr(:md, :string, default: nil, doc: "Size at md breakpoint (>=768px)")
  attr(:lg, :string, default: nil, doc: "Size at lg breakpoint (>=992px)")
  attr(:xl, :string, default: nil, doc: "Size at xl breakpoint (>=1200px)")
  attr(:offset, :string, default: nil, doc: "Offset from left (e.g. '25', '35')")
  attr(:is_no_padding, :boolean, default: false, doc: "Remove column padding")
  attr(:is_grow, :boolean, default: false, doc: "Flex grow to fill available space")
  attr(:is_shrink, :boolean, default: false, doc: "Flex shrink to fit content")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def column(assigns) do
    ~H"""
    <div class={col_classes(assigns)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp col_classes(assigns) do
    classes =
      [
        assigns.size && "pc-col-#{assigns.size}",
        assigns.sm && "pc-col-sm-#{assigns.sm}",
        assigns.md && "pc-col-md-#{assigns.md}",
        assigns.lg && "pc-col-lg-#{assigns.lg}",
        assigns.xl && "pc-col-xl-#{assigns.xl}",
        assigns.offset && "pc-offset-#{assigns.offset}",
        assigns.is_no_padding && "pc-col--no-padding",
        assigns.is_grow && "pc-col--grow",
        assigns.is_shrink && "pc-col--shrink",
        assigns.class
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    if classes == "", do: "pc-col", else: classes
  end

  # ── pc-grid — CSS-Grid layout primitive (dense, ruled forms) ─────────────────
  #
  # A companion to the flex `grid/1`/`column/1` (pc-row/pc-col): where those do
  # responsive columns, `pc_grid/1` co-aligns cells in two dimensions and can draw
  # a ruled box-matrix — for dense paper forms (e.g. a customs declaration).
  # (Prototyped in core alongside `font-size` utilities; candidate to graduate into
  # `@keenmate/pure-css` next to pc-row/pc-col.)

  @doc """
  CSS-Grid container (`pc-grid`).

  ## Examples

      <.pc_grid cols={3} is_ruled>
        <.pc_grid_cell col_span={2}>Wide cell</.pc_grid_cell>
        <.pc_grid_cell>Cell</.pc_grid_cell>
        <.pc_grid_cell>Cell</.pc_grid_cell>
        <.pc_grid_cell>Cell</.pc_grid_cell>
      </.pc_grid>
  """
  attr(:cols, :integer,
    default: nil,
    doc: "Column count 1–12 (`pc-grid--cols-N`). Or set `--pc-grid-cols` via `class`/style for a custom track."
  )

  attr(:is_flush, :boolean, default: false, doc: "Gutterless (`pc-grid--flush`).")

  attr(:is_ruled, :boolean,
    default: false,
    doc: "Hairlines between every cell + an outer frame (`pc-grid--ruled`); implies flush. Prints reliably (real borders)."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def pc_grid(assigns) do
    ~H"""
    <div class={pc_grid_classes(assigns)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp pc_grid_classes(assigns) do
    build_classes(
      "pc-grid",
      [
        {"pc-grid--cols-#{assigns.cols}", assigns.cols != nil},
        {"pc-grid--flush", assigns.is_flush},
        {"pc-grid--ruled", assigns.is_ruled}
      ],
      assigns.class
    )
  end

  @doc """
  A `pc_grid/1` cell that can span multiple columns/rows
  (`pc-col-span-N` / `pc-row-span-N`). Plain elements without a span also work as
  single cells — this is just the convenience wrapper.
  """
  attr(:col_span, :integer, default: nil, doc: "Columns to span, 1–12 (`pc-col-span-N`).")
  attr(:row_span, :integer, default: nil, doc: "Rows to span, 1–6 (`pc-row-span-N`).")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def pc_grid_cell(assigns) do
    ~H"""
    <div class={pc_grid_cell_classes(assigns)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp pc_grid_cell_classes(assigns) do
    classes =
      [
        assigns.col_span && "pc-col-span-#{assigns.col_span}",
        assigns.row_span && "pc-row-span-#{assigns.row_span}",
        assigns.class
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    if classes == "", do: nil, else: classes
  end
end
