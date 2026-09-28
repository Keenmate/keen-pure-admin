defmodule DemoWeb.Live.SplitterLive do
  @moduledoc """
  Port of `pure-admin/demo/views/splitter.mustache` — uses keen_pure_admin
  components throughout (`<.card>`, `<.code>`, `<.code_block>`, `<.paragraph>`,
  `<.heading>`, `<.basic_list>`, `<.definition_list>`, `<.button>`, `<.table>`,
  `<.splitter>`, `<.faicon>`) so the demo exercises the wrapper rather than
  the underlying pure-admin CSS directly.

  Stateful pieces (N-pane count, persistence-reset status) live in the
  socket. The mirror-toggle (Demo 4) flips a DOM class via
  `Phoenix.LiveView.JS`; the overflow-direction toggle (Demo 4b) uses
  inline `onchange` JS since it sets a data attribute on an element inside
  a `phx-update="ignore"` subtree. Storage-reset goes through the
  `SplitterStorageClear` hook.

  ## Known wrapper gaps (called out in the wrapper-consistency sweep)

  * `<.card>` has no inline-suffix title attr — upstream's
    `<h3>Title <small>— subtitle</small></h3>` pattern is rendered via the
    `:header` slot with raw `<.heading>` + `<small>` markup. `<small>` is
    semantic HTML, not a wrapper candidate.
  * Cards inside splitter panes need `style="height: 100%; margin: 0;"`
    pass-through to fill the pane — works through `<.card>`'s `:rest` global,
    but the inline-style requirement might warrant a future `is_pane_filling`
    attr or similar.
  """
  use DemoWeb, :live_view
  alias Phoenix.LiveView.JS

  @multi_pane_min 3
  @multi_pane_max 6

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Splitter",
       multi_pane_count: 3,
       multi_pane_min: @multi_pane_min,
       multi_pane_max: @multi_pane_max,
       storage_status: nil,
       horizontal_code: horizontal_code(),
       vertical_code: vertical_code(),
       minimize_code: minimize_code(),
       minimize_end_code: minimize_end_code(),
       two_pane_markup: two_pane_markup(),
       n_pane_markup: n_pane_markup(),
       phoenix_markup: phoenix_markup(),
       js_api_markup: js_api_markup(),
       root_attr_rows: root_attr_rows(),
       legacy_attr_rows: legacy_attr_rows(),
       pane_attr_rows: pane_attr_rows(),
       keyboard_rows: keyboard_rows()
     )}
  end

  def handle_event("set_multi_pane_count", %{"count" => count}, socket) do
    n =
      count
      |> String.to_integer()
      |> max(@multi_pane_min)
      |> min(@multi_pane_max)

    {:noreply, assign(socket, multi_pane_count: n)}
  end

  def handle_event("storage_cleared", %{"cleared" => cleared}, socket) do
    msg =
      if cleared == 0,
        do: "No saved splitter sizes found.",
        else: "Cleared #{cleared} saved size(s). Reload the page to see the defaults."

    {:noreply, assign(socket, storage_status: msg)}
  end

  def render(assigns) do
    ~H"""
    <.paragraph class="mb-6">
      Resizable container with two or more panes and draggable gutters. Drag
      to resize, double-click a gutter to collapse / restore, and use arrow
      keys (or <kbd>Home</kbd> / <kbd>End</kbd>) when a gutter is focused.
      Sizes can be constrained per pane and persisted to localStorage.
    </.paragraph>

    <%!-- ───────── Demo 1 — Horizontal ───────── --%>
    <.card class="mb-4">
      <:header>
        <.heading level="3">
          {gettext("Horizontal split")}
          <small class="text-secondary">{gettext("— side-by-side, vertical gutter")}</small>
        </.heading>
      </:header>
      <.paragraph class="mb-3">
        Sidebar + main content. Start pane is constrained to <.code>min: 200px</.code>
        and <.code>max: 60%</.code>, with a default of <.code>280px</.code>. Size persists
        to <.code>localStorage</.code> under the id <.code>demo-horizontal</.code>.
      </.paragraph>

      <.splitter
        id="demo-horizontal"
        orientation="horizontal"
        style="height: 360px; border: 1px solid var(--pc-border-color); border-radius: var(--pc-border-radius);"
      >
        <:pane
          size="280px"
          min="200px"
          max="60%"
          style="background: var(--pc-subtle-bg); padding: 1.6rem;"
        >
          <.heading level="4" class="mb-3" style="margin-top: 0;">{gettext("Files")}</.heading>
          <.basic_list>
            <li>📁 components/</li>
            <li>📁 utils/</li>
            <li>📄 main.scss</li>
            <li>📄 README.md</li>
            <li>📄 package.json</li>
            <li>📄 .gitignore</li>
            <li>📄 LICENSE</li>
          </.basic_list>
        </:pane>
        <:pane style="padding: 1.6rem;">
          <.heading level="4" class="mb-3" style="margin-top: 0;">main.scss</.heading>
          <.paragraph class="text-secondary mb-3">
            Drag the gutter, double-click it to collapse, or focus it and use arrow keys.
          </.paragraph>
          <.code_block language="scss">{@horizontal_code}</.code_block>
        </:pane>
      </.splitter>
    </.card>

    <%!-- ───────── Demo 2 — Vertical ───────── --%>
    <.card class="mb-4">
      <:header>
        <.heading level="3">
          {gettext("Vertical split")}
          <small class="text-secondary">{gettext("— stacked, horizontal gutter")}</small>
        </.heading>
      </:header>
      <.paragraph class="mb-3">
        Editor over console. Constraints: <.code>min: 80px</.code>, <.code>max: 80%</.code>,
        default <.code>60%</.code>. Persists under <.code>demo-vertical</.code>.
      </.paragraph>

      <.splitter
        id="demo-vertical"
        orientation="vertical"
        style="height: 420px; border: 1px solid var(--pc-border-color); border-radius: var(--pc-border-radius);"
      >
        <:pane size="60%" min="80px" max="80%" style="padding: 1.6rem;">
          <.heading level="4" class="mb-3" style="margin-top: 0;">{gettext("Editor")}</.heading>
          <.code_block language="javascript">{@vertical_code}</.code_block>
        </:pane>
        <:pane style="background: var(--pc-subtle-bg); padding: 1.6rem; font-family: var(--pc-font-mono, monospace); font-size: 1.3rem;">
          <%!-- Console mockup with custom font + blinking cursor — no wrapper
               covers a custom-styled terminal-mock layout. --%>
          <div class="mb-2" style="opacity: 0.6;">$ node demo.js</div>
          <div>Hello, Pure Admin!</div>
          <div class="mb-2" style="opacity: 0.6;">$ npm test</div>
          <div>✓ 42 tests passed</div>
          <div>✓ 0 failures</div>
          <div style="opacity: 0.6;">$ <span style="border-right: 1px solid currentColor; animation: pa-blink 1s steps(2) infinite;">&nbsp;</span></div>
        </:pane>
      </.splitter>
    </.card>

    <%!-- ───────── Demo 3 — Spaced cards ───────── --%>
    <.card class="mb-4">
      <:header>
        <.heading level="3">
          {gettext("Spaced cards")}
          <small class="text-secondary">{gettext("— gutter with breathing room")}</small>
        </.heading>
      </:header>
      <.paragraph class="mb-3">
        Use native <.code>gap</.code> on the splitter root to add space between the panes
        and the gutter — the JS subtracts it from the available space so percent
        constraints stay accurate. A thicker gutter is opt-in via
        <.code>--pa-splitter-gutter-size</.code>.
      </.paragraph>

      <.splitter
        id="demo-spaced"
        orientation="horizontal"
        style="height: 280px; gap: 1.6rem; --pa-splitter-gutter-size: 1rem;"
      >
        <:pane size="40%" min="25%" max="75%" style="padding: 0;">
          <.card title_text={gettext("Left card")} style="height: 100%; margin: 0;">
            <.paragraph class="mb-0">
              This pane holds a card. The flex <.code>gap</.code> on the splitter keeps
              the card from touching the gutter — no per-pane padding hack needed.
            </.paragraph>
          </.card>
        </:pane>
        <:pane style="padding: 0;">
          <.card title_text={gettext("Right card")} style="height: 100%; margin: 0;">
            <.paragraph class="mb-0">
              Drag the gutter — both cards reflow. The 10px gutter is set inline via
              <.code>--pa-splitter-gutter-size</.code>; the default is 6px.
            </.paragraph>
          </.card>
        </:pane>
      </.splitter>
    </.card>

    <%!-- ───────── Demo 4 — Minimize-to-rail (start) ───────── --%>
    <.card class="mb-4">
      <:header>
        <.heading level="3">
          {gettext("Minimize to rail")}
          <small class="text-secondary">{gettext("— vertical header instead of collapse")}</small>
        </.heading>
      </:header>
      <.paragraph class="mb-3">
        Opt in with <.code>is_minimizable</.code> on the start pane. The gutter's collapse
        action (double-click, <kbd>Enter</kbd>/<kbd>Space</kbd>, the toggle button in
        the header, or pressing the gutter while minimized) toggles the start pane to a
        thin rail with a vertical card title — instead of disappearing. Click the rail
        or press the gutter to restore. Rail width is configurable via <.code>rail_size</.code>
        (default 40px). <strong>You can also just drag the gutter inward</strong> — once
        the requested width drops below 40% of the minimized side's natural min
        (configurable via <.code>minimize_threshold</.code>) it snaps to rail; dragging
        back outward across the same threshold pops it back to min.
      </.paragraph>

      <.paragraph class="mb-3 text-sm">
        <strong>Bonus:</strong> the Editor card's actions use the new
        <.code>actions_variant="responsive"</.code> pattern — drag the gutter rightward to
        shrink the Editor pane, and once the header drops below
        <.code>$card-actions-collapse-at</.code> (28rem ≈ 280px) the spread buttons
        collapse into a single split button. Pure CSS container query, no JS observer.
      </.paragraph>

      <label class="mb-3" style="display: inline-flex; align-items: center; gap: 0.6rem; cursor: pointer;">
        <input
          type="checkbox"
          phx-click={JS.toggle_class("pa-splitter--minimize-mirror", to: "#demo-minimize")}
        />
        <span>Mirror title (apply <.code>transform: scale(-1, -1)</.code> to the heading)</span>
      </label>

      <.splitter
        id="demo-minimize"
        orientation="horizontal"
        rail_size={44}
        style="height: 320px; gap: 1.2rem;"
      >
        <:pane size="320px" min="220px" max="80%" is_minimizable style="padding: 0;">
          <.card
            title_text={gettext("File explorer")}
            actions_variant="overflow"
            actions_id="demoFileExplorerActions"
            style="height: 100%; margin: 0;"
          >
            <:title_icon><.faicon name="folder-tree" /></:title_icon>
            <:tools>
              <.button variant="secondary" size="xs" title="New file" aria-label="New file">
                <.faicon name="file-circle-plus" />
              </.button>
              <.button variant="secondary" size="xs" title="New folder" aria-label="New folder">
                <.faicon name="folder-plus" />
              </.button>
              <.button variant="secondary" size="xs" title="Refresh" aria-label="Refresh">
                <.faicon name="arrows-rotate" />
              </.button>
              <.button
                variant="secondary"
                size="xs"
                title="Minimize panel"
                aria-label="Minimize panel"
                data-pa-splitter-toggle
                data-pa-actions-priority="10"
              >
                <.faicon name="chevron-left" />
              </.button>
            </:tools>
            <.basic_list>
              <li>📁 src/</li>
              <li>📁 dist/</li>
              <li>📄 main.scss</li>
              <li>📄 splitter.js</li>
              <li>📄 README.md</li>
            </.basic_list>
            <.paragraph class="text-sm text-secondary mt-3 mb-0">
              Click the chevron in the header to minimize. Click the rail (or press the
              gutter) to restore.
            </.paragraph>
          </.card>
        </:pane>
        <:pane style="padding: 0;">
          <.card
            title_text={gettext("Editor")}
            actions_variant="responsive"
            style="height: 100%; margin: 0;"
          >
            <:title_icon><.faicon name="code" /></:title_icon>
            <:tools>
              <div class="pa-card__actions-full">
                <.button variant="secondary" size="xs" title="Save" aria-label="Save">
                  <.faicon name="floppy-disk" />
                </.button>
                <.button variant="secondary" size="xs" title="Format" aria-label="Format code">
                  <.faicon name="wand-magic-sparkles" />
                </.button>
                <.button variant="primary" size="xs" title="Run" aria-label="Run">
                  <.faicon name="play" />
                </.button>
              </div>
              <div class="pa-card__actions-collapsed">
                <%!-- GAP: no <.btn_split> wrapper yet — keeping pa-btn-split
                     markup raw. Worth a future wrapper to mirror the upstream
                     split-button component. --%>
                <div class="pa-btn-split">
                  <.button variant="primary" size="xs" title="Run" aria-label="Run">
                    <.faicon name="play" />
                  </.button>
                  <.button
                    variant="primary"
                    size="xs"
                    class="pa-btn-split__toggle"
                    aria-label="More actions"
                  >
                    <.faicon name="chevron-down" class="pa-btn-split__chevron" />
                  </.button>
                  <div class="pa-btn-split__menu">
                    <div class="pa-btn-split__menu-inner">
                      <button class="pa-btn-split__item" type="button">
                        <.faicon name="floppy-disk" /> {gettext("Save")}
                      </button>
                      <button class="pa-btn-split__item" type="button">
                        <.faicon name="wand-magic-sparkles" /> {gettext("Format")}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </:tools>
            <.paragraph class="mb-3">
              When the file explorer minimizes, this card stays put and the gutter
              slides next to the rail.
            </.paragraph>
            <.code_block language="javascript">{@minimize_code}</.code_block>
          </.card>
        </:pane>
      </.splitter>
    </.card>

    <%!-- ───────── Demo 4b — Progressive overflow ───────── --%>
    <.card class="mb-4">
      <:header>
        <.heading level="3">
          {gettext("Progressive overflow")}
          <small class="text-secondary">
            — buttons drop into a "More" menu one at a time
          </small>
        </.heading>
      </:header>
      <.paragraph class="mb-3">
        A second collapse model, complementing <.code>--responsive</.code>. Mark the
        actions wrapper with <.code>actions_variant="overflow"</.code> and the
        <.code>PureAdminCardActionsOverflow</.code> hook measures each button on init.
        A <.code>ResizeObserver</.code> watches the wrapper; when the row can't fit, the
        lowest-priority button moves into a "..." menu (appended to <.code>&lt;body&gt;</.code>
        so card <.code>overflow: hidden</.code> can't clip it).
      </.paragraph>
      <ul class="mb-3">
        <li>Priority via <.code>data-pa-actions-priority="N"</.code> — higher stays longer.</li>
        <li>
          Tiebreak direction via <.code>data-pa-actions-overflow-from="end"</.code>
          (default — rightmost drops first) or <.code>"start"</.code> (leftmost drops first).
        </li>
      </ul>

      <label class="mb-3" style="display: inline-flex; align-items: center; gap: 0.6rem; cursor: pointer;">
        <input
          type="checkbox"
          onchange="document.getElementById('demoOverflowActions').setAttribute('data-pa-actions-overflow-from', this.checked ? 'start' : 'end')"
        />
        <span>Drop from the start (left) instead of the end (right)</span>
      </label>

      <.splitter
        id="demo-overflow"
        orientation="horizontal"
        rail_size={44}
        style="height: 220px; gap: 1.2rem;"
      >
        <:pane size="40%" min="160px" max="80%" is_minimizable style="padding: 0;">
          <.card
            title_text={gettext("Editor")}
            actions_variant="overflow"
            actions_id="demoOverflowActions"
            style="height: 100%; margin: 0;"
          >
            <:title_icon><.faicon name="toolbox" /></:title_icon>
            <:tools>
              <.button variant="secondary" size="xs">
                <:icon><.faicon name="floppy-disk" /></:icon>
                {gettext("Save")}
              </.button>
              <.button variant="secondary" size="xs">
                <:icon><.faicon name="wand-magic-sparkles" /></:icon>
                {gettext("Format")}
              </.button>
              <.button variant="secondary" size="xs">
                <:icon><.faicon name="arrows-rotate" /></:icon>
                {gettext("Refresh")}
              </.button>
              <.button variant="secondary" size="xs">
                <:icon><.faicon name="file-export" /></:icon>
                {gettext("Export")}
              </.button>
              <.button variant="primary" size="xs" data-pa-actions-priority="10">
                <:icon><.faicon name="play" /></:icon>
                {gettext("Run")}
              </.button>
            </:tools>
            <.paragraph class="text-sm text-secondary mb-0">
              Shrink me — buttons collapse into the "..." menu by ascending priority.
              <.code>Run</.code> has <.code>data-pa-actions-priority="10"</.code> and stays last.
            </.paragraph>
          </.card>
        </:pane>
        <:pane style="padding: 0;">
          <.card style="height: 100%; margin: 0; background: var(--pc-subtle-bg);">
            <.paragraph class="text-sm text-secondary mb-0">
              Drag the gutter left/right to shrink and grow the editor card. Watch the
              action row in its header.
            </.paragraph>
          </.card>
        </:pane>
      </.splitter>
    </.card>

    <%!-- ───────── Demo 5 — Minimize END pane ───────── --%>
    <.card class="mb-4">
      <:header>
        <.heading level="3">
          {gettext("Minimize")} <em>{gettext("end")}</em> {gettext("pane to rail")}
          <small class="text-secondary">{gettext("— right-edge inspector pattern")}</small>
        </.heading>
      </:header>
      <.paragraph class="mb-3">
        Set <.code>is_minimizable</.code> on the LAST pane to collapse it to a
        vertical-title rail on the right edge. Same restore paths as the start variant
        (rail click, gutter press, toggle button, dblclick, <kbd>Enter</kbd>/<kbd>Space</kbd>,
        or drag the gutter outward past the threshold). Useful for inspector / detail /
        properties panels.
      </.paragraph>

      <.splitter
        id="demo-minimize-end"
        orientation="horizontal"
        rail_size={44}
        style="height: 320px; gap: 1.2rem;"
      >
        <:pane size="65%" min="40%" max="80%" style="padding: 0;">
          <.card title_text={gettext("Editor")} style="height: 100%; margin: 0;">
            <:title_icon><.faicon name="code" /></:title_icon>
            <.paragraph class="mb-3">
              Drag the gutter to the right (shrinking the inspector) — once the
              inspector's width drops below 75% of its implied min, it snaps to a rail
              on the right edge.
            </.paragraph>
            <.code_block language="javascript">{@minimize_end_code}</.code_block>
          </.card>
        </:pane>
        <:pane is_minimizable style="padding: 0;">
          <.card title_text={gettext("Inspector")} style="height: 100%; margin: 0;">
            <:title_icon><.faicon name="circle-info" /></:title_icon>
            <:tools>
              <.button
                variant="secondary"
                size="xs"
                aria-label="Minimize inspector"
                title="Minimize inspector"
                data-pa-splitter-toggle
              >
                <.faicon name="chevron-right" />
              </.button>
            </:tools>
            <.paragraph class="text-sm text-secondary mb-0">
              Properties, outlines, references, etc. live here. Click the chevron,
              double-click the gutter, or drag the gutter rightward to collapse.
            </.paragraph>
          </.card>
        </:pane>
      </.splitter>
    </.card>

    <%!-- ───────── Demo 6 — N-pane configurable ───────── --%>
    <.card class="mb-4">
      <:header>
        <.heading level="3">
          {gettext("N panes")}
          <small class="text-secondary">{gettext("— pick a count, both edges minimizable")}</small>
        </.heading>
        <div class="pa-card__actions" style="display: flex; gap: 0.6rem; align-items: center;">
          <label for="multiPaneCount" class="text-sm">Panes:</label>
          <form phx-change="set_multi_pane_count">
            <select id="multiPaneCount" name="count" class="pa-input pa-input--sm" style="width: auto;">
              <option :for={n <- @multi_pane_min..@multi_pane_max} value={n} selected={n == @multi_pane_count}>
                {n}
              </option>
            </select>
          </form>
        </div>
      </:header>

      <.paragraph class="mb-3">
        N-pane markup uses per-pane <.code>size</.code> / <.code>min</.code> /
        <.code>max</.code> attrs instead of root-level <.code>min-start</.code> /
        <.code>max-start</.code>. The first and last panes opt into rail collapse with
        <.code>is_minimizable</.code>. Middle panes can also collapse (post-edge-only
        restriction lift in 2.9.0-rc03). Drag any gutter and either neighbour will snap
        to rail below the threshold. Each pane count remembers its own layout in
        localStorage.
      </.paragraph>

      <.splitter
        id={"demo-multi-pane-#{@multi_pane_count}"}
        orientation="horizontal"
        is_minimize_mirror
        style="height: 420px; border: 1px solid var(--pc-border-color); border-radius: var(--pc-border-radius); column-gap: 0.8rem; padding: 0.8rem; background: var(--pc-subtle-bg);"
      >
        <:pane
          :for={i <- 0..(@multi_pane_count - 1)}
          size={pane_size(i, @multi_pane_count)}
          min={pane_min(i, @multi_pane_count)}
          max={pane_max(i, @multi_pane_count)}
          is_minimizable
        >
          <.card title_text={pane_title(i, @multi_pane_count)} style="height: 100%; margin: 0;">
            <:title_icon><.faicon name={pane_icon(i, @multi_pane_count)} /></:title_icon>
            <:tools>
              <.button
                variant="secondary"
                size="xs"
                title="Minimize"
                aria-label="Minimize"
                data-pa-splitter-toggle
              >
                <.faicon name="window-minimize" />
              </.button>
            </:tools>
            <.multi_pane_body index={i} count={@multi_pane_count} />
          </.card>
        </:pane>
      </.splitter>
    </.card>

    <%!-- ───────── Demo 7 — Persistence reset ───────── --%>
    <.card class="mb-4">
      <:header><.heading level="3">{gettext("localStorage persistence")}</.heading></:header>
      <.paragraph class="mb-3">
        Both demos above persist their size under <.code>pa-splitter:&lt;id&gt;</.code>.
        Reload the page — your drag positions stick. Clear them with the button below.
      </.paragraph>
      <.button
        variant="secondary"
        id="splitter-storage-clear"
        phx-hook="SplitterStorageClear"
      >
        {gettext("Clear saved splitter sizes")}
      </.button>
      <.paragraph :if={@storage_status} class="mt-3 text-sm text-secondary">
        {@storage_status}
      </.paragraph>
    </.card>

    <%!-- ───────── Reference cards (markup / data attrs / keyboard / API) ───────── --%>
    <.grid>
      <.column size="100" lg="50">
        <.card class="mb-4">
          <:header><.heading level="3">{gettext("Markup — two panes (legacy shorthand)")}</.heading></:header>
          <.code_block language="html">{@two_pane_markup}</.code_block>
          <.paragraph class="text-sm mt-3 mb-0">
            Triggered by the <.code>--start</.code> / <.code>--end</.code> modifiers. The
            end pane fills the leftover via <.code>flex: 1</.code>; only the start pane
            carries an explicit size. The Phoenix wrapper always emits the N-pane form
            below (upstream normalises legacy markup into N-pane at init anyway).
          </.paragraph>
        </.card>

        <.card class="mb-4">
          <:header><.heading level="3">{gettext("Markup — N panes")}</.heading></:header>
          <.code_block language="html">{@n_pane_markup}</.code_block>
          <.paragraph class="text-sm mt-3 mb-0">
            Any N ≥ 2. Panes and gutters must alternate. Per-pane
            <.code>data-pa-splitter-size</.code> / <.code>-min</.code> / <.code>-max</.code>
            replace the root-level <.code>-start</.code> attributes. Only pane 0 and pane
            N-1 honour <.code>data-pa-splitter-minimize</.code> (middle panes can collapse
            too as of 2.9.0-rc03 — slack tunnels through the rail wall). Panes without
            an explicit size share leftover space equally.
          </.paragraph>
        </.card>

        <.card class="mb-4">
          <:header><.heading level="3">{gettext("Phoenix wrapper")}</.heading></:header>
          <.code_block language="heex">{@phoenix_markup}</.code_block>
          <.paragraph class="text-sm mt-3 mb-0">
            <.code>&lt;.splitter&gt;</.code> emits the N-pane HTML above and wires the
            <.code>PureAdminSplitter</.code> hook when <.code>id</.code> is set. Gutters
            are inserted automatically between panes.
          </.paragraph>
        </.card>
      </.column>

      <.column size="100" lg="50">
        <.card class="mb-4">
          <:header><.heading level="3">{gettext("Data attributes")}</.heading></:header>

          <.paragraph class="text-sm mb-2">
            <strong>On root</strong> (both modes):
          </.paragraph>
          <.table rows={@root_attr_rows} is_compact>
            <:col :let={r} label={gettext("Attribute")}><.code>{r.attr}</.code></:col>
            <:col :let={r} label={gettext("Default")}><.code>{r.default}</.code></:col>
            <:col :let={r} label={gettext("Description")}>{r.desc}</:col>
          </.table>

          <.paragraph class="text-sm mt-3 mb-2">
            <strong>On root</strong> (legacy 2-pane only):
          </.paragraph>
          <.table rows={@legacy_attr_rows} is_compact>
            <:col :let={r} label={gettext("Attribute")}><.code>{r.attr}</.code></:col>
            <:col :let={r} label={gettext("Default")}><.code>{r.default}</.code></:col>
            <:col :let={r} label={gettext("Description")}>{r.desc}</:col>
          </.table>

          <.paragraph class="text-sm mt-3 mb-2">
            <strong>On each pane</strong> (N-pane only):
          </.paragraph>
          <.table rows={@pane_attr_rows} is_compact>
            <:col :let={r} label={gettext("Attribute")}><.code>{r.attr}</.code></:col>
            <:col :let={r} label={gettext("Default")}><.code>{r.default}</.code></:col>
            <:col :let={r} label={gettext("Description")}>{r.desc}</:col>
          </.table>
        </.card>

        <.card class="mb-4">
          <:header><.heading level="3">{gettext("Keyboard")}</.heading></:header>
          <.table rows={@keyboard_rows} is_compact>
            <:col :let={r} label={gettext("Key")}>{Phoenix.HTML.raw(r.key)}</:col>
            <:col :let={r} label={gettext("Action")}>{r.action}</:col>
          </.table>
          <.paragraph class="text-sm mt-3 mb-0">
            Each gutter handles its own keyboard input. <kbd>Tab</kbd> focuses the next
            gutter; the "left pane" is whichever pane sits before the focused gutter.
          </.paragraph>
        </.card>

        <.card class="mb-4">
          <:header><.heading level="3">{gettext("JavaScript API")}</.heading></:header>
          <.paragraph class="mb-2">
            Auto-initializes on <.code>[data-pa-splitter]</.code> at
            <.code>DOMContentLoaded</.code>. The Phoenix wrapper's
            <.code>PureAdminSplitter</.code> hook also calls <.code>init()</.code> on
            mount + update for LiveView-patched markup. For manually inserted splitters:
          </.paragraph>
          <.code_block language="javascript">{@js_api_markup}</.code_block>
          <.paragraph class="text-sm mt-3 mb-0">
            <.code>init()</.code> is idempotent — calling it twice on the same element
            is a no-op.
          </.paragraph>
        </.card>
      </.column>
    </.grid>

    <style>
      @keyframes pa-blink { 50% { border-color: transparent; } }
    </style>
    """
  end

  # ── Demo 6 pane body ──────────────────────────────────────────────────────

  attr :index, :integer, required: true
  attr :count, :integer, required: true

  defp multi_pane_body(%{index: 0} = assigns) do
    ~H"""
    <.basic_list>
      <li>📁 src/</li>
      <li>📁 demo/</li>
      <li>📄 main.scss</li>
      <li>📄 README.md</li>
    </.basic_list>
    """
  end

  defp multi_pane_body(%{index: i, count: n} = assigns) when i == n - 1 do
    ~H"""
    <.definition_list>
      <dt>Type</dt><dd>function</dd>
      <dt>Args</dt><dd>name: string</dd>
      <dt>Returns</dt><dd>string</dd>
    </.definition_list>
    """
  end

  defp multi_pane_body(assigns) do
    ~H"""
    <.paragraph class="text-secondary mb-2">
      Workspace {@index} of {@count - 2}
    </.paragraph>
    <.code_block language="javascript">{"// Pane #{@index + 1}\nconsole.log(\"hi\");"}</.code_block>
    """
  end

  # ── Per-pane attrs (Demo 6) ───────────────────────────────────────────────

  defp pane_size(0, _n), do: "220px"
  defp pane_size(i, n) when i == n - 1, do: "240px"
  defp pane_size(_i, _n), do: nil

  defp pane_min(0, _n), do: "160px"
  defp pane_min(i, n) when i == n - 1, do: "180px"
  defp pane_min(_i, _n), do: "160px"

  defp pane_max(0, _n), do: "360px"
  defp pane_max(i, n) when i == n - 1, do: "380px"
  defp pane_max(_i, _n), do: nil

  defp pane_icon(0, _n), do: "folder-tree"
  defp pane_icon(i, n) when i == n - 1, do: "circle-info"

  defp pane_icon(i, _n) do
    middle = ~w(code terminal flask chart-line)
    Enum.at(middle, rem(i - 1, length(middle)))
  end

  defp pane_title(0, _n), do: "Sidebar"
  defp pane_title(i, n) when i == n - 1, do: "Inspector"
  defp pane_title(i, _n), do: "Workspace #{i}"

  # ── Static reference snippets ─────────────────────────────────────────────

  defp horizontal_code do
    ~s|@use 'variables/index' as *;
@use 'core' as *;
@use 'utilities' as *;

:root {
  @include output-base-css-variables;
  @include output-pc-css-variables;
}|
  end

  defp vertical_code do
    ~s|function greet(name) {
  return `Hello, ${name}!`;
}

console.log(greet('Pure Admin'));|
  end

  defp minimize_code do
    ~s|// Toggle the minimize state:
//   - double-click the gutter
//   - focus gutter + press Enter / Space
//   - click the rail (while minimized)
//   - press the gutter (while minimized)|
  end

  defp minimize_end_code do
    ~s|// The inspector on the right is the
// rail-side here. Press the rail, the
// gutter, or the toggle button to
// restore it.|
  end

  defp two_pane_markup do
    ~s|<div class="pa-splitter pa-splitter--horizontal"
     data-pa-splitter
     data-pa-splitter-id="my-id"
     data-pa-splitter-min-start="200px"
     data-pa-splitter-max-start="60%"
     data-pa-splitter-default="280px">
  <div class="pa-splitter__pane
              pa-splitter__pane--start">A</div>
  <div class="pa-splitter__gutter"
       role="separator"
       aria-orientation="vertical"
       tabindex="0"></div>
  <div class="pa-splitter__pane
              pa-splitter__pane--end">B</div>
</div>|
  end

  defp n_pane_markup do
    ~s|<div class="pa-splitter pa-splitter--horizontal"
     data-pa-splitter
     data-pa-splitter-id="my-id">
  <div class="pa-splitter__pane"
       data-pa-splitter-size="240px"
       data-pa-splitter-min="180px"
       data-pa-splitter-minimize>A</div>
  <div class="pa-splitter__gutter"
       role="separator" tabindex="0"></div>
  <div class="pa-splitter__pane"
       data-pa-splitter-min="240px">B</div>
  <div class="pa-splitter__gutter"
       role="separator" tabindex="0"></div>
  <div class="pa-splitter__pane"
       data-pa-splitter-size="280px"
       data-pa-splitter-minimize>C</div>
</div>|
  end

  defp phoenix_markup do
    ~s|<.splitter
  id="my-id"
  orientation="horizontal"
  style="height: 360px;"
>
  <:pane size="240px" min="180px" is_minimizable>
    A
  </:pane>
  <:pane min="240px">
    B
  </:pane>
  <:pane size="280px" is_minimizable>
    C
  </:pane>
</.splitter>|
  end

  defp js_api_markup do
    ~s|// Init a single element
PaSplitter.init(document.getElementById('my-splitter'));

// Init all uninitialized splitters in a subtree
PaSplitter.initAll(someContainer);|
  end

  # ── Reference-table rows ──────────────────────────────────────────────────

  defp root_attr_rows do
    [
      %{attr: "data-pa-splitter", default: "—", desc: "Marker. Required."},
      %{attr: "data-pa-splitter-id", default: "none", desc: "Enables persistence under pa-splitter:<id>"},
      %{attr: "data-pa-splitter-step", default: "10", desc: "Keyboard step in px"},
      %{attr: "data-pa-splitter-rail-size", default: "40", desc: "Rail width in px (minimized state)"},
      %{attr: "data-pa-splitter-minimize-threshold", default: "0.40", desc: "Drag snaps to rail below this fraction of the minimized side's natural min"}
    ]
  end

  defp legacy_attr_rows do
    [
      %{attr: "data-pa-splitter-min-start", default: "0", desc: "px or %"},
      %{attr: "data-pa-splitter-max-start", default: "available", desc: "px or %"},
      %{attr: "data-pa-splitter-default", default: "30%", desc: "Initial size if no saved state"},
      %{attr: "data-pa-splitter-minimize", default: "off", desc: ~s|"start" or "end" opts into rail collapse on that side|}
    ]
  end

  defp pane_attr_rows do
    [
      %{attr: "data-pa-splitter-size", default: "shared", desc: "Initial size (px or %). Unsized panes split the leftover."},
      %{attr: "data-pa-splitter-min", default: "0", desc: "px or %"},
      %{attr: "data-pa-splitter-max", default: "available", desc: "px or %"},
      %{attr: "data-pa-splitter-minimize", default: "—", desc: "Marker. Only honoured on the first and last panes."}
    ]
  end

  defp keyboard_rows do
    [
      %{key: "<kbd>←</kbd> <kbd>↑</kbd>", action: "Move boundary toward start (shrink left pane)"},
      %{key: "<kbd>→</kbd> <kbd>↓</kbd>", action: "Move boundary toward end (grow left pane)"},
      %{key: "<kbd>Home</kbd>", action: "Jump left pane to its minimum"},
      %{key: "<kbd>End</kbd>", action: "Jump left pane to its maximum"},
      %{key: "<kbd>Enter</kbd> / <kbd>Space</kbd>", action: "Toggle minimize on the nearest minimizable neighbour"}
    ]
  end
end
