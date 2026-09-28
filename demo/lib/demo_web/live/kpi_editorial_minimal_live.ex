defmodule DemoWeb.Live.KpiEditorialMinimalLive do
  use DemoWeb, :live_view

  # 1:1 port of pure-admin's `demo/views/kpi-editorial-minimal.mustache`.
  # Default auto-fit + --max-N caps + --2col + 1×3 page-grid stress
  # + Usage Guide + CSS Reference.

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "KPI · Editorial minimal")}
  end

  defp tiles do
    [
      %{id: "revenue", label_text: gettext("REVENUE"), prefix_text: "$", value_text: "847", unit_text: "K", delta_text: "+13.3%", delta_variant: "positive", target_text: "$900K",
        detail_title_text: "Revenue · WTD", previous_value_text: "$748K"},
      %{id: "arpu", label_text: gettext("ARPU"), prefix_text: "$", value_text: "34.20", delta_text: "+7.5%", delta_variant: "positive", target_text: "$36"},
      %{id: "active-users", label_text: gettext("ACTIVE USERS"), value_text: "12.3", unit_text: "K", delta_text: "+4.1%", delta_variant: "positive", target_text: "11K"},
      %{id: "conversion", label_text: gettext("CONVERSION"), value_text: "3.92", unit_text: "%", delta_text: "+12.6%", delta_variant: "up_strong", target_text: "3.5%"},
      %{id: "error", label_text: gettext("ERROR RATE"), value_text: "0.18", unit_text: "%", delta_text: "−56%", delta_variant: "up_strong", target_text: "≤ 0.5%"},
      %{id: "churn", label_text: gettext("CHURN"), value_text: "2.4", unit_text: "%", delta_text: "+14%", delta_variant: "negative", target_text: "≤ 2%"}
    ]
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">
      Magazine-cover restraint — light-weight numerals, generous space, hairline rules between cells.
      No charts, no pills — the design's identity is the thin numeral. Default layout is a cell-min
      <code>auto-fit</code> grid; <code>is_2_columns</code> forces 2; <code>grid_layout="max_N"</code>
      caps at N.
    </.paragraph>

    <%!-- 1. Canonical · auto-fit --%>

    <.kpi_editorial title_text={gettext("Executive snapshot · auto-fit (default)")} is_live footer_text="Cell-min driven · cells stay at least 14rem wide">
      <.tile :for={t <- tiles()} {tile_assigns(t, "ed-")} />
    </.kpi_editorial>

    <br />

    <%!-- 2. is_2_columns --%>

    <h3><code>is_2_columns</code> — force exactly 2 columns</h3>

    <.kpi_editorial title_text={gettext("Two-up")} is_2_columns>
      <.tile :for={t <- Enum.take(tiles(), 4)} {tile_assigns(t, "2c-")} />
    </.kpi_editorial>

    <br />

    <%!-- 3. max-3 --%>

    <h3><code>grid_layout="max_3"</code> — cap at 3 columns</h3>
    <p>Tiles never exceed 3 columns even on a wide container, but still collapse below the cell-min × 3 threshold.</p>

    <.kpi_editorial title_text={gettext("Three-up")} grid_layout="max_3">
      <.tile :for={t <- Enum.take(tiles(), 6)} {tile_assigns(t, "m3-")} />
    </.kpi_editorial>

    <br />

    <%!-- 4. cell_min_width override --%>

    <h3><code>cell_min_width="18rem"</code> — wider cells, fewer columns</h3>

    <.kpi_editorial title_text={gettext("Wide cells")} cell_min_width="18rem">
      <.tile :for={t <- Enum.take(tiles(), 6)} {tile_assigns(t, "wc-")} />
    </.kpi_editorial>

    <br />

    <%!-- 5. 1×3 page-grid --%>

    <h3>1×3 · <code>.pc-col-1-3</code> columns</h3>
    <p>Each card holds 4 tiles in 2 columns. Tests how the extra-light numerals scale at narrow widths via the per-tile container query.</p>

    <div class="pc-row">
      <div :for={i <- 1..3} class="pc-col-100 pc-col-md-1-3">
        <.kpi_editorial is_2_columns>
          <.tile :for={t <- Enum.take(tiles(), 4)} {tile_assigns(t, "c13-#{i}-")} />
        </.kpi_editorial>
      </div>
    </div>

    <br />

    <%!-- Usage Guide --%>

    <.card title_text={gettext("Usage Guide")}>
      <h4>When to use</h4>
      <p>
        Executive / weekly-review pages where the operator wants "how are we doing" at a glance and
        reads the supporting context only on hover. Best for printed-style pages, dashboard headers,
        all-hands deck-style summaries. For per-tile depth see Terminal grid; for goal-oriented bars
        see Comparison gauges.
      </p>

      <h4 class="mt-4">Hairline rules</h4>
      <p>
        Dividers are <code>gap: 1px</code> over <code>background: var(--pc-border-color)</code>, with each
        tile painting <code>background: var(--pc-card-bg)</code> on top. The gap shows through, giving
        single-pixel hairlines on every interior boundary regardless of column count.
      </p>

      <h4 class="mt-4">Extra-light numerals</h4>
      <p>
        The value uses <code>var(--base-font-family)</code> at <code>font-weight: 200</code> — explicitly
        NOT mono. Mono fonts rarely ship a true extra-light weight; using the body sans gives proper thin
        glyphs that read as "editorial" rather than "monospace at low contrast". Tabular numerals
        preserved via <code>font-variant-numeric: tabular-nums</code>.
      </p>

      <h4 class="mt-4">Layout modifiers</h4>
      <p>
        Default is a cell-min-driven <code>auto-fit</code> grid: cells stay at least
        <code>cell_min_width</code> wide (default upstream <code>14rem</code>), the grid fits as many
        columns as the container allows. <code>is_2_columns</code> forces exactly 2 columns;
        <code>grid_layout="max_N"</code> caps the column count while still collapsing responsively.
      </p>

      <h4 class="mt-4">Per-tile container query</h4>
      <p>
        Each tile is its own <code>container-type: inline-size</code> so the value's <code>cqi</code>-based
        font-size scales with the tile's actual width — keeps typography legible as the grid packs more
        cells into the same row.
      </p>

      <h4 class="mt-4">Meta row</h4>
      <p>
        Optional <code>delta_text</code> + <code>target_text</code>. The <code>target_text</code> is
        auto-rendered as <code>&lt;em&gt;tgt&lt;/em&gt; &#123;value&#125;</code>. Pass a <code>:meta</code> slot
        for fully-custom markup.
      </p>
    </.card>

    <br />

    <%!-- CSS Classes Reference --%>

    <.card title_text={gettext("CSS Classes Reference")}>
      <h4>Card structure</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-edit</code> — page-namespace class on <code>.pa-card</code>.</li>
        <li><code>pa-kpi-edit__body</code> — <code>padding: 0</code> so hairlines reach the card edges.</li>
        <li><code>pa-kpi-edit__grid</code> — cell-min auto-fit grid.</li>
      </ul>

      <h4 class="mt-4">Grid layout modifiers</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-edit__grid--2col</code> — force exactly 2 columns.</li>
        <li><code>pa-kpi-edit__grid--max-2</code> / <code>--max-3</code> / <code>--max-4</code> / <code>--max-5</code> / <code>--max-6</code> — cap column count.</li>
      </ul>

      <h4 class="mt-4">Layout CSS variables</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>--pa-kpi-edit-cell-min</code> — min cell width for auto-fit (default <code>14rem</code>).</li>
      </ul>

      <h4 class="mt-4">Tile</h4>
      <ul class="pa-list-basic pa-list-basic--compact">
        <li><code>pa-kpi-edit__tile</code> — single cell. Per-tile container query host.</li>
        <li><code>pa-kpi-edit__label</code> — uppercase mono caption.</li>
        <li><code>pa-kpi-edit__value</code> — extra-light focal number.</li>
        <li><code>pa-kpi-edit__num</code> / <code>pa-kpi-edit__unit</code>.</li>
        <li><code>pa-kpi-edit__meta</code> — delta + target row.</li>
        <li><code>pa-kpi-edit__delta--positive</code> / <code>--negative</code> / <code>--neutral</code> / <code>--up-strong</code> / <code>--down-strong</code>.</li>
        <li><code>pa-kpi-edit__target</code> — wraps the "tgt &#123;value&#125;" meta cell.</li>
      </ul>
    </.card>
    """
  end

  defp tile_assigns(t, id_prefix), do: Map.merge(t, %{id: id_prefix <> t.id})

  attr(:id, :string, required: true)
  attr(:label_text, :string, required: true)
  attr(:value_text, :string, required: true)
  attr(:unit_text, :string, default: nil)
  attr(:prefix_text, :string, default: nil)
  attr(:delta_text, :string, default: nil)
  attr(:delta_variant, :string, default: nil)
  attr(:target_text, :string, default: nil)
  attr(:detail_title_text, :string, default: nil)
  attr(:previous_value_text, :string, default: nil)

  defp tile(assigns) do
    ~H"""
    <.kpi_editorial_tile
      id={@id}
      label_text={@label_text}
      value_text={@value_text}
      unit_text={@unit_text}
      prefix_text={@prefix_text}
      delta_text={@delta_text}
      delta_variant={@delta_variant}
      target_text={@target_text}
      detail_title_text={@detail_title_text}
      previous_value_text={@previous_value_text}
    />
    """
  end
end
