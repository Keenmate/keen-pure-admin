defmodule DemoWeb.Live.FitToSizeLive do
  @moduledoc """
  "Fit to Size": four worked, slider-driven examples of the two responsive
  engines — the Fit engine folding a real toolbar (example 1), a CSS container
  query swapping chart ↔ KPI (example 2), one container query restyling a card on
  three levels (example 3), and the Container Breakpoint ENGINE driving the same
  multi-level card while building/destroying a Chart.js instance on demand and
  logging every flip (example 4).

  Port of the pure-admin demo `fit-to-size.mustache`, rebuilt with the keen (kpa)
  Phoenix components. Interactivity is wired through demo hooks:
  `StageWidth` (sliders), `PureAdminNavFit` (fit init on the toolbar),
  `FitSparkline` (the example-2 Chart.js sparklines), `CardTabs` (example-3 tab
  switching) and `FitToSizeEx4` (the engine + chart-on-demand + log).
  """
  use DemoWeb, :live_view

  @breakpoints Jason.encode!(%{icons: 0, tabs: 34, grid: 64})

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Fit to Size")
     |> assign(breakpoints: @breakpoints)}
  end

  def render(assigns) do
    ~H"""
    <style>
      /* Demo-only scaffolding. Every VISIBLE piece is a real pa-* component; the
         fit-* / prod* classes are the stage frames + the CSS container-query
         layouts the examples demonstrate. Root font is 10px → 1rem = 10px. */
      .fit-stage { max-width: 100%; margin-block: 0.75rem; border: 1px dashed var(--pc-border-color); border-radius: 8px; transition: max-width 0.08s ease; }
      .fit-slider-row { display: flex; align-items: center; gap: 0.75rem; margin-top: 1rem; font-size: var(--pc-font-size-sm, 1.4rem); color: var(--pc-text-color-2); }
      .fit-slider-row input[type="range"] { flex: 1; min-width: 0; }
      .fit-slider-row output { font-variant-numeric: tabular-nums; min-width: 4.5ch; text-align: end; }

      /* Example 1 — fit engine row. Children don't shrink + never wrap, so the
         engine folds them instead of the browser squishing. */
      .fit-toolbar { display: flex; align-items: center; gap: 0.5rem; width: 100%; }
      .fit-toolbar > * { flex: 0 0 auto; white-space: nowrap; }
      .fit-toolbar [data-pc-fit-step] { display: inline-flex; align-items: center; gap: 0.4rem; white-space: nowrap; }

      /* Example 2 — CSS container query: card width swaps the chart for KPIs. */
      .fit-cq { container-type: inline-size; }
      .fit-cq__chart { width: 20rem; height: 10rem; display: none; }
      .fit-cq__kpi { display: flex; flex-direction: column; align-items: flex-start; gap: 0.6rem; }
      @container (min-width: 45rem) {
        .fit-cq__chart { display: block; }
        .fit-cq__kpi { display: none; }
      }

      /* Example 3 — one CSS container query restyling a card on three levels. */
      .prod { container-type: inline-size; }
      .prod__header { display: flex; justify-content: space-between; align-items: flex-start; gap: 1.5rem; }
      .prod__title { margin: 0.4rem 0 0.3rem; }
      .prod__meta { color: var(--pc-text-color-2); font-size: var(--pc-font-size-sm, 1.4rem); }
      .prod__price { flex: 0 0 auto; text-align: end; }
      .prod__price-num { font-size: 2rem; font-weight: 700; font-variant-numeric: tabular-nums; }
      .prod__price-trend { margin-top: 0.4rem; }
      .prod__meta-pkg, .prod__meta-sup, .prod__price-trend { display: none; }
      .prod__tabs { margin-top: 1.2rem; }
      .prod__tabs .pa-tabs__item { display: flex; align-items: center; justify-content: center; gap: 0.5rem; }
      .prod__tabs .pa-tabs__item span { display: none; }
      .prod__panels { margin-top: 1.2rem; }
      .prod__panel { display: none; }
      .prod__panel--active { display: block; }
      .prod__panel-title { display: none; }
      @container (min-width: 34rem) {
        .prod__tabs .pa-tabs__item span { display: inline; }
        .prod__meta-pkg { display: inline; }
        .prod__price-trend { display: inline-flex; }
      }
      @container (min-width: 64rem) {
        .prod__tabs { display: none; }
        .prod__panels { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.6rem; }
        .prod__panel { display: block; }
        .prod__panel + .prod__panel { padding-inline-start: 1.6rem; border-inline-start: 1px solid var(--pc-border-color); }
        .prod__panel-title { display: block; }
        .prod__meta-sup { display: inline; }
      }

      /* Example 4 — the SAME multi-level card, but ENGINE-driven. .prodx does NOT
         set container-type: the swaps are driven by the engine (data-pc-show
         toggles the shared .d-none; [data-mode="grid"] does the one real 2-D
         layout change). Swappable pieces are visible by default. */
      .prodx__header { display: flex; justify-content: space-between; align-items: flex-start; gap: 1.5rem; }
      .prodx__title { margin: 0.4rem 0 0.3rem; }
      .prodx__meta { color: var(--pc-text-color-2); font-size: var(--pc-font-size-sm, 1.4rem); }
      .prodx__price { flex: 0 0 auto; text-align: end; }
      .prodx__price-num { font-size: 2rem; font-weight: 700; font-variant-numeric: tabular-nums; }
      .prodx__chart { height: 8rem; margin-top: 1.2rem; }
      .prodx__tabs { margin-top: 1.2rem; }
      .prodx__tabs .pa-tabs__item { display: flex; align-items: center; justify-content: center; gap: 0.5rem; }
      .prodx__panels { margin-top: 1.2rem; }
      .prodx__panel { display: none; }
      .prodx__panel--active { display: block; }
      .prodx[data-mode="grid"] .prodx__panels { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.6rem; }
      .prodx[data-mode="grid"] .prodx__panel { display: block; }
      .prodx[data-mode="grid"] .prodx__panel + .prodx__panel { padding-inline-start: 1.6rem; border-inline-start: 1px solid var(--pc-border-color); }
      .ex4-log { margin-top: 0.8rem; max-height: 9rem; overflow: auto; font-size: var(--pc-font-size-xs, 1.2rem); font-family: var(--pc-font-family-mono, ui-monospace, monospace); color: var(--pc-text-color-2); }
      .ex4-log > div { padding: 0.15rem 0; border-bottom: 1px dashed var(--pc-border-color); }
    </style>

    <div class="pa-page-content">
      <.heading level={1} class="mb-2">{gettext("Fit to Size")}</.heading>
      <.paragraph>
        The Fit engine (<code>fit.js</code>) shrinks a horizontal row to fit its
        container — degrading the least-important slots first, lowest priority first,
        and restoring them as space returns. It powers the navbar, but it's not
        navbar-only: call <code>pureAdmin.components.fit.init(el)</code> (or attach
        the <code>PureAdminNavFit</code> hook) on any flex row.
      </.paragraph>

      <.callout variant="info" class="mb-4">
        <strong>The vocabulary.</strong>
        <code>data-pc-fit="hide|steps|sidebar"</code> makes an element a slot;
        <code>data-pc-fit-priority</code> orders them (lower goes first);
        <code>data-pc-fit-auto</code> on a container folds in <em>every</em> child
        without tagging each; <code>data-pc-fit-ignore</code> pins one out entirely.
        <strong>Drag the sliders</strong> — or open this page on a narrow phone — to
        watch each row fold.
      </.callout>

      <%!-- ── Example 1 — fit engine toolbar ──────────────────────────────── --%>
      <.heading level={3} class="mt-4 mb-2">1 · Card toolbar — shrink, don't lose</.heading>
      <.paragraph>
        A <code>steps</code> slot degrades <strong>full label → icon-only → gone</strong>
        instead of vanishing outright. Here <strong>Save</strong> is pinned full
        (<code>data-pc-fit-ignore</code>); <strong>Duplicate</strong> and
        <strong>Export</strong> shrink to icons; <strong>Delete</strong> is un-tagged,
        so it inherits the toolbar's <code>data-pc-fit-default-priority="20"</code> and
        drops first.
      </.paragraph>

      <div class="fit-slider-row">
        <span>{gettext("Container width")}</span>
        <input type="range" min="200" max="720" value="360" id="stage1-slider" phx-hook="StageWidth" data-stage="stage1" data-output="stage1-w" aria-label="Example 1 width" />
        <output id="stage1-w">360px</output>
      </div>

      <div class="fit-stage" id="stage1" style="max-width: 360px">
        <.card style="margin: 0" title_text={gettext("Sales Overview")}>
          <div id="ex1-toolbar" class="fit-toolbar" data-pc-fit-auto="true" data-pc-fit-default-priority="20" phx-hook="PureAdminNavFit">
            <.button variant="primary" data-pc-fit-ignore="true">
              <:icon>💾</:icon> {gettext("Save")}
            </.button>
            <.button data-pc-fit="steps" data-pc-fit-priority="40">
              <span data-pc-fit-step="0"><span class="pa-btn__icon">⧉</span> {gettext("Duplicate")}</span>
              <span data-pc-fit-step="1" class="pc-fit-hidden"><span class="pa-btn__icon">⧉</span></span>
            </.button>
            <.button data-pc-fit="steps" data-pc-fit-priority="30">
              <span data-pc-fit-step="0"><span class="pa-btn__icon">⬇️</span> {gettext("Export")}</span>
              <span data-pc-fit-step="1" class="pc-fit-hidden"><span class="pa-btn__icon">⬇️</span></span>
            </.button>
            <.button>
              <:icon>🗑️</:icon> {gettext("Delete")}
            </.button>
          </div>
          <.paragraph class="mt-3 mb-0 pa-text--secondary">
            Drag left: Delete drops → Export shrinks to its icon, then drops →
            Duplicate shrinks → only Save remains, always full.
          </.paragraph>
        </.card>
      </div>

      <%!-- ── Example 2 — CSS container query: chart ↔ KPI ────────────────── --%>
      <.heading level={3} class="mt-5 mb-2">2 · Product card — chart ↔ KPI</.heading>
      <.paragraph>
        Swapping a rich <strong>chart</strong> for compact <strong>KPI numbers</strong>
        is a 2-D layout change, not a 1-D row fold — so this one is a pure CSS
        <strong>container query</strong> on the card, no JS engine. The right half
        shows the Chart.js sparkline while there's room and swaps to a
        <code>pa-stat</code> KPI once the card narrows past <code>45rem</code> (450px).
      </.paragraph>

      <div class="fit-slider-row">
        <span>{gettext("Container width")}</span>
        <input type="range" min="260" max="720" value="640" id="stage2-slider" phx-hook="StageWidth" data-stage="stage2" data-output="stage2-w" aria-label="Example 2 width" />
        <output id="stage2-w">640px</output>
      </div>

      <div class="fit-stage" id="stage2" style="max-width: 640px; border: 0">
        <.card class="fit-cq" style="margin: 0">
          <.product_head_beverages chart_id="ex2-chart" />
        </.card>
      </div>
      <.paragraph class="mt-2 pa-text--secondary">
        Drag left (or view on a phone): past <code>45rem</code> the chart gives way to
        the KPI stat — same data, denser. Drag right to bring the chart back.
      </.paragraph>

      <.heading level={4} class="mt-4 mb-2">Same card, no slider — resize your browser window</.heading>
      <.paragraph class="pa-text--secondary">
        Identical card, but with <strong>no <code>.fit-stage</code> wrapper and no
        slider</strong> — full-width in the page. The container query reads the card's
        <em>real</em> width, so drag your browser window narrower and the chart becomes
        the KPI on its own. This is the production behaviour; the slider above only
        simulated it.
      </.paragraph>
      <.card class="fit-cq" style="margin: 0">
        <.product_head_beverages chart_id="ex2b-chart" />
      </.card>

      <%!-- ── Example 3 — one CSS container query, three levels ───────────── --%>
      <.heading level={3} class="mt-5 mb-2">3 · Rich product card — degrade on multiple levels</.heading>
      <.paragraph>
        One card restyling on <strong>several axes at once</strong>. This is a single
        CSS <strong>container query</strong> with three widths. As it narrows, the
        three data panels (<strong>Orders · Stock · Sales</strong>) collapse from a
        <strong>3-column grid</strong> into <strong>tabs</strong>, then the tab labels
        drop to <strong>icons only</strong>; in step, the header sheds its supplier,
        then its packaging line and trend badge.
      </.paragraph>

      <div class="fit-slider-row">
        <span>{gettext("Container width")}</span>
        <input type="range" min="260" max="880" value="760" id="stage3-slider" phx-hook="StageWidth" data-stage="stage3" data-output="stage3-w" aria-label="Example 3 width" />
        <output id="stage3-w">760px</output>
      </div>

      <div class="fit-stage" id="stage3" style="max-width: 760px; border: 0">
        <.card id="ex3-card" class="prod" style="margin: 0" phx-hook="CardTabs" data-panel-class="prod__panel">
          <div class="prod__header">
            <div style="min-width: 0">
              <.badge theme_color="3">Beverages</.badge>
              <h4 class="prod__title">Arabica Cold Brew</h4>
              <div class="prod__meta">
                <code>SKU-4471</code><span class="prod__meta-pkg"> · 1 L bottle · 12 per case</span><span class="prod__meta-sup"> · Yirgacheffe Co-op</span>
              </div>
            </div>
            <div class="prod__price">
              <div class="prod__price-num">$4.80</div>
              <.badge variant="success" class="prod__price-trend">▲ 12.5%</.badge>
            </div>
          </div>

          <.tabs align="full" class="prod__tabs">
            <button class="pa-tabs__item pa-tabs__item--active pa-tooltip" data-tooltip="Orders" data-panel="orders">
              <i class="fa-solid fa-cart-shopping"></i><span>Orders</span>
            </button>
            <button class="pa-tabs__item pa-tooltip" data-tooltip="Stock" data-panel="stock">
              <i class="fa-solid fa-boxes-stacked"></i><span>Stock</span>
            </button>
            <button class="pa-tabs__item pa-tooltip" data-tooltip="Sales" data-panel="sales">
              <i class="fa-solid fa-chart-line"></i><span>Sales</span>
            </button>
          </.tabs>

          <div class="prod__panels">
            <.product_panel base="prod" panel="orders" active title="Orders" icon="📦" icon_variant="primary" number="1,204" label="Orders · 30d" rows={[{"Open", "38"}, {"Fulfilled", "1,142"}, {"Returned", "24"}]} />
            <.product_panel base="prod" panel="stock" title="Stock" icon="🏬" icon_variant="warning" number="8,450" label="On hand" rows={[{"Reserved", "1,120"}, {"Available", "7,330"}, {"Reorder at", "2,000"}]} />
            <.product_panel base="prod" panel="sales" title="Sales" icon="💰" icon_variant="success" number="$847K" label="Revenue · 30d" rows={[{"Units", "12.4k"}, {"Avg order", "$68.30"}, {"Margin", "41%"}]} />
          </div>
        </.card>
      </div>
      <.paragraph class="mt-2 pa-text--secondary">
        Three levels, one query. <strong>≥640px</strong> → the 3-panel grid;
        <strong>340–640px</strong> → tabbed with labels; <strong>&lt;340px</strong> →
        icon-only tabs. Nothing is re-fetched or re-rendered — the same markup re-flows.
      </.paragraph>

      <%!-- ── Example 4 — the engine-driven twin, chart on demand ─────────── --%>
      <.heading level={3} class="mt-5 mb-2">4 · Same card, on the engine — with a chart it builds on demand</.heading>
      <.paragraph>
        Example 3's card again — the same three-level degrade — but driven by the
        <strong>Container Breakpoint engine</strong> instead of a CSS
        <code>@container</code>. Two things CSS can't do: the engine toggles a
        <strong>real <code>.d-none</code> class</strong> you can watch hop in devtools,
        and it fires a per-flip callback — so the grid-only <strong>revenue chart</strong>
        is <em>built only when the card is wide enough to show it, and destroyed
        otherwise</em>. Watch the log.
      </.paragraph>

      <.callout variant="info" class="mb-3">
        <strong>What the numbers mean.</strong>
        The thresholds are <strong>rem</strong> — minimum widths of the <em>card
        itself</em>, not the viewport. Root font-size is <code>10px</code>, so
        <code>34</code> = 340px and <code>64</code> = 640px. The engine picks the
        <strong>largest</strong> mode whose width the card has passed.
      </.callout>

      <div class="fit-slider-row">
        <span>{gettext("Container width")}</span>
        <input type="range" min="260" max="880" value="760" id="stage4-slider" phx-hook="StageWidth" data-stage="stage4" data-output="stage4-w" aria-label="Example 4 width" />
        <output id="stage4-w">760px</output>
      </div>

      <div class="fit-stage" id="stage4" style="max-width: 760px; border: 0">
        <.card
          id="ex4"
          class="prodx"
          style="margin: 0"
          phx-hook="FitToSizeEx4"
          data-breakpoints={@breakpoints}
          data-chart="ex4-chart"
          data-log="ex4-log"
          data-panel-class="prodx__panel"
        >
          <div class="prodx__header">
            <div style="min-width: 0">
              <.badge theme_color="3">Beverages</.badge>
              <h4 class="prodx__title">Arabica Cold Brew</h4>
              <div class="prodx__meta">
                <code>SKU-4471</code><span data-pc-show="grid tabs"> · 1 L bottle · 12 per case</span><span class="d-none" data-pc-show="grid"> · Yirgacheffe Co-op</span>
              </div>
            </div>
            <div class="prodx__price">
              <div class="prodx__price-num">$4.80</div>
              <.badge variant="success" data-pc-show="grid tabs">▲ 12.5%</.badge>
            </div>
          </div>

          <div class="prodx__chart d-none" data-pc-show="grid"><canvas id="ex4-chart"></canvas></div>

          <.tabs align="full" class="prodx__tabs" data-pc-show="tabs icons">
            <button class="pa-tabs__item pa-tabs__item--active pa-tooltip" data-tooltip="Orders" data-panel="orders">
              <i class="fa-solid fa-cart-shopping"></i><span data-pc-show="tabs">Orders</span>
            </button>
            <button class="pa-tabs__item pa-tooltip" data-tooltip="Stock" data-panel="stock">
              <i class="fa-solid fa-boxes-stacked"></i><span data-pc-show="tabs">Stock</span>
            </button>
            <button class="pa-tabs__item pa-tooltip" data-tooltip="Sales" data-panel="sales">
              <i class="fa-solid fa-chart-line"></i><span data-pc-show="tabs">Sales</span>
            </button>
          </.tabs>

          <div class="prodx__panels">
            <.product_panel base="prodx" panel="orders" active hide_title title="Orders" icon="📦" icon_variant="primary" number="1,204" label="Orders · 30d" rows={[{"Open", "38"}, {"Fulfilled", "1,142"}, {"Returned", "24"}]} />
            <.product_panel base="prodx" panel="stock" hide_title title="Stock" icon="🏬" icon_variant="warning" number="8,450" label="On hand" rows={[{"Reserved", "1,120"}, {"Available", "7,330"}, {"Reorder at", "2,000"}]} />
            <.product_panel base="prodx" panel="sales" hide_title title="Sales" icon="💰" icon_variant="success" number="$847K" label="Revenue · 30d" rows={[{"Units", "12.4k"}, {"Avg order", "$68.30"}, {"Margin", "41%"}]} />
          </div>
        </.card>
      </div>
      <div class="ex4-log" id="ex4-log" aria-live="polite"></div>

      <.callout variant="warning" class="mt-4">
        <strong>Right tool check.</strong>
        The fit <em>engine</em> (example 1) shrinks a 1-D <strong>row</strong> of items.
        A <strong>container query</strong> (examples 2–3) is for a 2-D
        <strong>layout swap</strong> — chart ↔ KPI, then several swaps stacked into one
        query. And when the hidden branch is <strong>expensive</strong> (a chart, a
        date-picker, a shadow-DOM widget), reach past CSS for the <strong>Container
        Breakpoint engine</strong> (example 4): same width thresholds, but it emits a
        callback so JS can <em>build the widget only when its mode is on screen and
        tear it down otherwise</em>.
      </.callout>
    </div>
    """
  end

  # ── Local render helpers ────────────────────────────────────────────────────

  # The beverages card body shared by example 2's two cards: product info on the
  # left, the Chart.js sparkline (wide) ↔ pa-stat KPI (narrow) on the right. The
  # container query in <style> toggles which of the two shows.
  attr(:chart_id, :string, required: true)

  defp product_head_beverages(assigns) do
    ~H"""
    <div class="d-flex" style="align-items: center; gap: 1.5rem">
      <div class="flex-1" style="min-width: 0">
        <.badge theme_color="3">Beverages</.badge>
        <h4 class="mt-2 mb-1">Arabica Cold Brew</h4>
        <div class="pa-text--secondary" style="font-size: var(--pc-font-size-sm, 1.4rem)">
          <code>SKU-4471</code> · 1 L bottle
        </div>
      </div>
      <div style="flex: 0 0 auto">
        <div class="fit-cq__chart">
          <canvas id={@chart_id} phx-hook="FitSparkline" data-points="[612, 640, 606, 701, 760, 803, 847]"></canvas>
        </div>
        <div class="fit-cq__kpi">
          <.stat number="$847K" label_text={gettext("Revenue")} icon_variant="success">
            <:icon>📈</:icon>
          </.stat>
          <.badge variant="success">▲ 12.5%</.badge>
        </div>
      </div>
    </div>
    """
  end

  # A single Orders/Stock/Sales panel: title + icon stat + dot-leader detail.
  # `base` is the panel BEM base ("prod" | "prodx") so the same helper serves both
  # the CSS-query card and the engine card; `hide_title` pre-stamps `.d-none` on
  # the engine card's per-panel title (revealed only in grid mode via data-pc-show).
  attr(:base, :string, required: true)
  attr(:panel, :string, required: true)
  attr(:active, :boolean, default: false)
  attr(:hide_title, :boolean, default: false)
  attr(:title, :string, required: true)
  attr(:icon, :string, required: true)
  attr(:icon_variant, :string, required: true)
  attr(:number, :string, required: true)
  attr(:label, :string, required: true)
  attr(:rows, :list, required: true)

  defp product_panel(assigns) do
    ~H"""
    <div class={[@base <> "__panel", @active && (@base <> "__panel--active")]} data-panel={@panel}>
      <h5
        class={[@base <> "__panel-title", "mb-1", @hide_title && "d-none"]}
        data-pc-show={@hide_title && "grid"}
      >{@title}</h5>
      <.stat number={@number} label_text={@label} icon_variant={@icon_variant}>
        <:icon>{@icon}</:icon>
      </.stat>
      <.dot_leaders class="mt-2">
        <.dot_leader :for={{k, v} <- @rows} label={k} value={v} />
      </.dot_leaders>
    </div>
    """
  end
end
