defmodule PureAdmin.Components.Sheet do
  @moduledoc """
  Printable A4 "paper" document shell (`pa-sheet`) for invoices, orders, quotes,
  receipts, delivery notes and payment reminders.

  `sheet/1` is a centred, A4-width white page with a screen-only drop shadow and a
  built-in `@media print` layer (strips the shadow/margins, keeps rows / party
  cards / total lines from breaking across pages, emits `@page { size: A4 }`, and
  prints ink-on-white by default). It deliberately composes the framework's other
  blocks — line items use `pa-table` (wrap it in `.pa-table-container`), label/value
  metadata can use `pa-fields` — and adds the invoice-shaped regions via the
  sub-components here: `sheet_masthead/1`, `sheet_parties/1` + `sheet_party/1`,
  `sheet_meta/1` + `sheet_meta_row/1`, `sheet_title/1`, `sheet_totals/1` +
  `sheet_total_row/1`, `sheet_notes/1`, and `sheet_footer/1` + `sheet_signatures/1`
  + `sheet_sign/1`.

  Print a single sheet in isolation with `sheet_print_button/1` (wires the
  `PureAdminSheetPrint` hook) or call `pureAdmin.printSheet(el)` directly.
  """
  use Phoenix.Component

  import PureAdmin.Helpers

  # ── sheet/1 — the A4 page container ──────────────────────────────────────────

  @doc """
  The A4 page container.

  ## Examples

      <.sheet id="inv-142">
        <.sheet_masthead is_ruled doctitle="INVOICE No. 2026-0142" docmeta="Tax invoice">
          <:brand>Twin Peaks Ltd.</:brand>
        </.sheet_masthead>

        <.sheet_parties>
          <.sheet_party label="Supplier" name="Twin Peaks Ltd.">
            221B Baker Street<br/>London
          </.sheet_party>
          <.sheet_party label="Bill to" name="Northwind GmbH" variant="boxed">
            Musterstraße 1<br/>Berlin
          </.sheet_party>
        </.sheet_parties>

        <.sheet_meta is_boxed>
          <.sheet_meta_row label="Reference No.">2071845390</.sheet_meta_row>
          <.sheet_meta_row label="Issue date">Sep 9, 2026</.sheet_meta_row>
        </.sheet_meta>

        <div class="pa-table-container">
          <table class="pa-table pa-table--bordered">…</table>
        </div>

        <.sheet_totals>
          <.sheet_total_row label="Subtotal">80,000.00</.sheet_total_row>
          <.sheet_total_row label="Total due" is_grand>€80,000.00</.sheet_total_row>
        </.sheet_totals>

        <.sheet_footer>
          <.sheet_signatures>
            <.sheet_sign label="Issued by" />
            <.sheet_sign label="Received by" />
          </.sheet_signatures>
        </.sheet_footer>

        <.sheet_print_button id="inv-142-print" title="Invoice 2026-0142" />
      </.sheet>
  """
  attr(:density, :string,
    default: nil,
    values: [nil, "compact", "spacious"],
    doc: "Page density (`pa-sheet--compact` / `--spacious`)."
  )

  attr(:is_framed, :boolean, default: false, doc: "Hairline outer border (`pa-sheet--framed`).")

  attr(:is_fluid, :boolean,
    default: false,
    doc: "Drop the A4 max-width so the sheet fills its container (`pa-sheet--fluid`) — for embedded previews."
  )

  attr(:is_fill, :boolean,
    default: false,
    doc:
      "Full A4-height page; the footer sinks to the page bottom (`pa-sheet--fill`). SHORT single-page documents only — a fixed footer repeats on multi-page content."
  )

  attr(:is_landscape, :boolean,
    default: false,
    doc: "A4 landscape 297×210mm (`pa-sheet--landscape`) for wide many-column tables. Print it individually."
  )

  attr(:print_mode, :string,
    default: nil,
    values: [nil, "color", "grayscale"],
    doc:
      "Print colour policy. Default (nil) = ink on white. `\"color\"` keeps theme colours (`--print-color`); `\"grayscale\"` desaturates them (`--print-grayscale`)."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global, doc: "Arbitrary attributes on the sheet root, e.g. `id` (needed to target it for printing).")
  slot(:inner_block, required: true)

  def sheet(assigns) do
    ~H"""
    <div class={sheet_classes(assigns)} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp sheet_classes(assigns) do
    build_classes(
      "pa-sheet",
      [
        {"pa-sheet--#{assigns.density}", assigns.density != nil},
        {"pa-sheet--framed", assigns.is_framed},
        {"pa-sheet--fluid", assigns.is_fluid},
        {"pa-sheet--fill", assigns.is_fill},
        {"pa-sheet--landscape", assigns.is_landscape},
        {"pa-sheet--print-#{assigns.print_mode}", assigns.print_mode != nil}
      ],
      assigns.class
    )
  end

  # ── masthead ─────────────────────────────────────────────────────────────────

  @doc """
  Top band: brand cluster on the start edge, document title/meta on the end edge.
  """
  attr(:is_ruled, :boolean, default: false, doc: "2px rule under the masthead (`--ruled`).")
  attr(:doctitle, :string, default: nil, doc: "Document title (INVOICE, RECEIPT…), rendered in `.pa-sheet__doctitle`.")
  attr(:docmeta, :string, default: nil, doc: "Sub-title / tagline under the title (`.pa-sheet__docmeta`).")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:brand, doc: "Brand cluster (logo + company name) shown on the start edge.")

  def sheet_masthead(assigns) do
    ~H"""
    <header
      class={build_classes("pa-sheet__masthead", [{"pa-sheet__masthead--ruled", @is_ruled}], @class)}
      {@rest}
    >
      <div class="pa-sheet__brand">{render_slot(@brand)}</div>
      <div>
        <h1 :if={@doctitle} class="pa-sheet__doctitle">{@doctitle}</h1>
        <div :if={@docmeta} class="pa-sheet__docmeta">{@docmeta}</div>
      </div>
    </header>
    """
  end

  @doc "Optional logo image for use inside a masthead `:brand` slot."
  attr(:src, :string, required: true)
  attr(:alt, :string, default: "")
  attr(:rest, :global)

  def sheet_logo(assigns) do
    ~H"""
    <img class="pa-sheet__logo" src={@src} alt={@alt} {@rest} />
    """
  end

  # ── parties ──────────────────────────────────────────────────────────────────

  @doc "Grid of party cards (supplier, bill-to, ship-to). Two columns by default."
  attr(:cols, :integer, default: 2, values: [2, 3], doc: "Column count (3 emits `--cols-3`).")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_parties(assigns) do
    ~H"""
    <section
      class={build_classes("pa-sheet__parties", [{"pa-sheet__parties--cols-3", @cols == 3}], @class)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </section>
    """
  end

  @doc "A single party card. Body content goes in the default slot (`.pa-sheet__party-body`)."
  attr(:label, :string, default: nil, doc: "Role label (Supplier, Bill to…), `.pa-sheet__party-label`.")
  attr(:name, :string, default: nil, doc: "Party name, `.pa-sheet__party-name`.")

  attr(:variant, :string,
    default: nil,
    values: [nil, "boxed", "strong"],
    doc: "`boxed` = grey rounded panel; `strong` = hard border."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_party(assigns) do
    ~H"""
    <div
      class={build_classes("pa-sheet__party", [{"pa-sheet__party--#{assigns.variant}", assigns.variant != nil}], @class)}
      {@rest}
    >
      <span :if={@label} class="pa-sheet__party-label">{@label}</span>
      <span :if={@name} class="pa-sheet__party-name">{@name}</span>
      <div class="pa-sheet__party-body">{render_slot(@inner_block)}</div>
    </div>
    """
  end

  # ── meta ─────────────────────────────────────────────────────────────────────

  @doc "Right-aligned label/value metadata grid. Rows via `sheet_meta_row/1`."
  attr(:is_boxed, :boolean, default: false, doc: "Bordered rounded box (`--boxed`).")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_meta(assigns) do
    ~H"""
    <section
      class={build_classes("pa-sheet__meta", [{"pa-sheet__meta--boxed", @is_boxed}], @class)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </section>
    """
  end

  @doc "One metadata label/value pair (two grid cells)."
  attr(:label, :string, required: true)
  slot(:inner_block, required: true, doc: "The value.")

  def sheet_meta_row(assigns) do
    ~H"""
    <span class="pa-sheet__meta-label">{@label}</span><span class="pa-sheet__meta-value">{render_slot(@inner_block)}</span>
    """
  end

  # ── title ────────────────────────────────────────────────────────────────────

  @doc "A titled-section heading inside the sheet (`.pa-sheet__title`)."
  attr(:level, :integer, default: 2, values: [2, 3, 4], doc: "Heading tag level.")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_title(assigns) do
    ~H"""
    <.dynamic_tag tag_name={"h#{@level}"} class={build_classes("pa-sheet__title", [], @class)} {@rest}>{render_slot(@inner_block)}</.dynamic_tag>
    """
  end

  # ── totals ───────────────────────────────────────────────────────────────────

  @doc "End-aligned summary column beside the line items. Rows via `sheet_total_row/1`."
  attr(:is_start, :boolean, default: false, doc: "Left-align the column (`--start`); default is end-aligned.")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_totals(assigns) do
    ~H"""
    <section
      class={build_classes("pa-sheet__totals", [{"pa-sheet__totals--start", @is_start}], @class)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </section>
    """
  end

  @doc "One summary line (subtotal, tax, total). Value goes in the default slot."
  attr(:label, :string, required: true)
  attr(:is_grand, :boolean, default: false, doc: "Grand-total line: ruled top border + larger bold (`--grand`).")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_total_row(assigns) do
    ~H"""
    <div
      class={build_classes("pa-sheet__total-row", [{"pa-sheet__total-row--grand", @is_grand}], @class)}
      {@rest}
    >
      <span class="pa-sheet__total-label">{@label}</span>
      <span class="pa-sheet__total-value">{render_slot(@inner_block)}</span>
    </div>
    """
  end

  # ── notes ────────────────────────────────────────────────────────────────────

  @doc "Prose block (terms, reminder copy, thank-you text) — `.pa-sheet__notes`."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_notes(assigns) do
    ~H"""
    <section class={build_classes("pa-sheet__notes", [], @class)} {@rest}>
      {render_slot(@inner_block)}
    </section>
    """
  end

  # ── footer ───────────────────────────────────────────────────────────────────

  @doc "Bottom band: signatures, legal imprint, page number (`.pa-sheet__footer`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_footer(assigns) do
    ~H"""
    <footer class={build_classes("pa-sheet__footer", [], @class)} {@rest}>
      {render_slot(@inner_block)}
    </footer>
    """
  end

  @doc "Responsive grid of signature slots. Children: `sheet_sign/1`."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_signatures(assigns) do
    ~H"""
    <div class={build_classes("pa-sheet__signatures", [], @class)} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc "One signature slot: a label above a blank ruled line to sign on."
  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, doc: "Optional custom label content (overrides `label`).")

  def sheet_sign(assigns) do
    ~H"""
    <div class={build_classes("pa-sheet__sign", [], @class)} {@rest}>
      <span :if={@inner_block != []}>{render_slot(@inner_block)}</span>
      <span :if={@inner_block == [] && @label}>{@label}</span>
    </div>
    """
  end

  @doc "Small-print legal imprint (`.pa-sheet__legal`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_legal(assigns) do
    ~H"""
    <div class={build_classes("pa-sheet__legal", [], @class)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  @doc "Page number, end-aligned (`.pa-sheet__pageno`)."
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sheet_pageno(assigns) do
    ~H"""
    <div class={build_classes("pa-sheet__pageno", [], @class)} {@rest}>{render_slot(@inner_block)}</div>
    """
  end

  # ── print button ─────────────────────────────────────────────────────────────

  @doc """
  A print button that prints its enclosing `.pa-sheet` in isolation (wires the
  `PureAdminSheetPrint` hook). Carries `data-print-omit` so it never prints itself.

  Place it INSIDE the sheet. Requires a unique `id` (for the LiveView hook).
  """
  attr(:id, :string, required: true)
  attr(:title, :string, default: nil, doc: "Print-document title (the \"Save as PDF\" filename).")

  attr(:target, :string,
    default: nil,
    doc: "CSS selector overriding which element is printed (defaults to the enclosing `.pa-sheet`)."
  )

  attr(:variant, :string, default: "primary", doc: "Button colour variant.")
  attr(:size, :string, default: nil, values: [nil, "xs", "sm", "lg", "xl"])
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, doc: "Button label (defaults to \"Print\").")

  def sheet_print_button(assigns) do
    ~H"""
    <button
      type="button"
      id={@id}
      phx-hook="PureAdminSheetPrint"
      data-print-title={@title}
      data-print-target={@target}
      data-print-omit
      class={
        build_classes(
          "pa-btn",
          [{"pa-btn--#{@variant}", true}, {"pa-btn--#{@size}", @size != nil}],
          @class
        )
      }
      {@rest}
    >{if @inner_block != [], do: render_slot(@inner_block), else: "Print"}</button>
    """
  end
end
