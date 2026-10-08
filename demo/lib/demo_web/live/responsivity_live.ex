defmodule DemoWeb.Live.ResponsivityLive do
  @moduledoc """
  "Responsivity — how it works": the conceptual overview of the two responsive
  engines Pure Admin ships (Fit + Container Breakpoint), the relocation-sink
  model, and the framework (Svelte / LiveView) hands-off contract.

  Port of the pure-admin demo `responsivity.mustache`, rebuilt with the keen
  (kpa) Phoenix components. The one live demo — the relocate bar that folds its
  badge cluster into a "•••" flyout when it runs out of room — is wired with the
  shared `PureAdminNavFit` hook (fit is container-generic, not navbar-only) and
  the built-in `floating-menu` sink; the slider is the `StageWidth` demo hook.
  """
  use DemoWeb, :live_view

  @engines [
    %{
      aspect: "Decides by",
      fit: "Measuring content — \"does the row still fit?\"",
      cb: "Declared width thresholds — \"which named band am I in?\""
    },
    %{
      aspect: "Output",
      fit: "Degrades slots one at a time (hide / step-down / relocate)",
      cb: "One named mode reflected to [data-mode]"
    },
    %{
      aspect: "Best for",
      fit: "A row of things competing for one line (toolbars, the navbar)",
      cb: "A component that restyles wholesale at set sizes (grid → tabs → icons)"
    },
    %{
      aspect: "Event",
      fit: "pc:fit-relocate (on a relocated slot)",
      cb: "pc:breakpoint (on mode flip)"
    }
  ]

  @code_fit """
  <div class="toolbar" data-pc-fit-default-priority="20">
    <span data-pc-fit="steps" data-pc-fit-priority="30">   <!-- full → smaller → gone -->
      <span data-pc-fit-step="0">Pure Admin</span>
      <span data-pc-fit-step="1">PA</span>
    </span>
    <span data-pc-fit="hide" data-pc-fit-priority="10">v2.9.0</span> <!-- drops first -->
    <button data-pc-fit-ignore>Save</button>                 <!-- pinned, never yields -->
  </div>
  """

  @code_relocate """
  <span data-pc-fit="relocate" data-pc-fit-target="floating-menu">
    <span class="pa-badge">Users 123</span> …
  </span>
  """

  @code_event """
  // fit fires a DOM CustomEvent on the slot. In managed mode NO node is moved —
  // you attach the listener the way your framework attaches DOM listeners.
  // In a LiveView hook:
  mounted() {
    this.el.addEventListener("pc:fit-relocate", (e) => {
      // e.detail = { action: "out" | "in", target, container }
      this.pushEvent("relocated", { out: e.detail.action === "out" })
    })
  }

  // The server assigns the mode and renders ONLY the branch for the current
  // placement — never a stale off-screen copy:
  <.flyout :if={@relocated}><.stats users={@users} rooms={@rooms} subs={@subs} /></.flyout>
  <.stats :if={!@relocated} users={@users} rooms={@rooms} subs={@subs} />
  """

  @code_cb """
  <div phx-hook="PureAdminContainerBreakpoint"
       data-pc-breakpoints='{"icons":0,"tabs":34,"grid":64}'
       data-pc-breakpoint-initial="tabs">
    <div data-pc-show="grid">…rich grid…</div>        <!-- .d-none unless mode = grid -->
    <div data-pc-show="tabs icons">…compact…</div>
  </div>
  """

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Responsivity — How It Works")
     |> assign(engines: @engines)
     |> assign(
       code_fit: @code_fit,
       code_relocate: @code_relocate,
       code_event: @code_event,
       code_cb: @code_cb
     )}
  end

  def render(assigns) do
    ~H"""
    <style>
      /* Demo-only scaffolding. Every VISIBLE UI piece is a real pa-* component;
         the resp-* classes are layout scaffolding, and the .pc-fit-flyout__*
         block is a scoped fallback mirror of the fit-flyout sink styles so the
         live relocate demo looks right before the themes are rebuilt (the demo
         loads theme CSS, not core main.css). Harmless once themes ship it. */
      .resp-stage {
        max-width: 100%;
        margin-block: 0.75rem;
        border: 1px dashed var(--pc-border-color);
        border-radius: 8px;
        padding: 0.75rem;
        transition: max-width 0.08s ease;
      }
      .resp-slider-row {
        display: flex; align-items: center; gap: 0.75rem; margin-top: 1rem;
        font-size: var(--pc-font-size-sm, 1.4rem); color: var(--pc-text-color-2);
      }
      .resp-slider-row input[type="range"] { flex: 1; min-width: 0; }
      .resp-slider-row output { font-variant-numeric: tabular-nums; min-width: 4.5ch; text-align: end; }
      .resp-bar { display: flex; align-items: center; gap: 0.6rem; width: 100%; }
      .resp-bar > * { flex: 0 0 auto; white-space: nowrap; }
      .resp-bar__brand { font-weight: 700; }
      .resp-bar__spacer { flex: 1 1 auto; min-width: 0; }
      .resp-stats { display: inline-flex; gap: 0.4rem; }

      /* ---- Fallback mirror of the fit-flyout sink (see note above) ---------- */
      .pc-fit-flyout__trigger {
        display: inline-flex; align-items: center; justify-content: center;
        flex: 0 0 auto; width: 2.8rem; height: 2.8rem; padding: 0;
        border: 1px solid transparent; border-radius: var(--pc-border-radius);
        background: transparent; color: inherit; cursor: pointer;
      }
      .pc-fit-flyout__trigger:hover { background: var(--pc-hover-bg, rgba(0,0,0,.05)); }
      .pc-fit-flyout__trigger[aria-expanded="true"] { background: var(--pc-hover-bg, rgba(0,0,0,.08)); }
      .pc-fit-flyout__dots,
      .pc-fit-flyout__dots::before,
      .pc-fit-flyout__dots::after { width: .4rem; height: .4rem; border-radius: 50%; background: currentColor; }
      .pc-fit-flyout__dots { position: relative; }
      .pc-fit-flyout__dots::before,
      .pc-fit-flyout__dots::after { content: ""; position: absolute; top: 0; }
      .pc-fit-flyout__dots::before { inset-inline-start: -.7rem; }
      .pc-fit-flyout__dots::after { inset-inline-start: .7rem; }
      .pc-fit-flyout__panel {
        position: fixed; z-index: 4010; display: none;
        min-width: 20rem; max-width: 32rem; padding: 0.5rem;
        background: var(--pc-card-bg); border: 1px solid var(--pc-border-color);
        border-radius: var(--pc-border-radius); box-shadow: 0 4px 12px rgba(0,0,0,.15);
      }
      .pc-fit-flyout__panel--open { display: block; }
      .pc-fit-flyout__item { padding: 0.4rem 0.5rem; }
      .pc-fit-flyout__item + .pc-fit-flyout__item { border-top: 1px solid var(--pc-border-color); }
    </style>

    <div class="pa-page-content">
      <.heading level={1} class="mb-2">{gettext("Responsivity — how it works")}</.heading>
      <.paragraph color="secondary" class="mb-4">
        Two small JavaScript engines let a component react to <strong>the space it is
        actually given</strong> — not the size of the window. That is the difference
        between a media query (asks the viewport) and a <em>container</em> query (asks
        the box). Pure Admin ships both a CSS-native path and a JS path, because some
        responsive moves (mounting a chart, moving a block into a menu) can't be done
        in CSS alone.
      </.paragraph>

      <.callout variant="info" class="mb-4">
        <strong>The big idea.</strong>
        A sidebar, a split pane, or a card in a grid can be narrow while the window is
        wide. Viewport media queries can't see that. Everything on this page keys off
        an <em>element's own width</em>, so a component adapts correctly wherever you
        drop it.
      </.callout>

      <%!-- ── The two engines ─────────────────────────────────────────────── --%>
      <.heading level={2} class="mt-4 mb-2">{gettext("The two engines")}</.heading>
      <.table rows={@engines} is_bordered class="mb-4">
        <:col :let={r} label="">{r.aspect}</:col>
        <:col :let={r} label="Fit — fit.js">{r.fit}</:col>
        <:col :let={r} label="Container Breakpoint — container-breakpoint.js">{r.cb}</:col>
      </.table>

      <%!-- ── 1 · Fit ─────────────────────────────────────────────────────── --%>
      <.heading level={2} class="mt-4 mb-2">1 · Fit — degrade a row to fit</.heading>
      <.paragraph>
        Fit watches a horizontal container and, when the content can't fit, degrades
        the <strong>lowest-priority slot first</strong>, restoring as space returns.
        The navbar auto-inits; any other flex row opts in with
        <code>pureAdmin.components.fit.init(el)</code> (or the
        <code>PureAdminNavFit</code> hook). You mark participants with attributes:
      </.paragraph>

      <.code_block language="html" class="mb-3">{@code_fit}</.code_block>

      <ul class="text-secondary mb-4">
        <li><code>data-pc-fit="hide"</code> — remove the slot when it must yield.</li>
        <li><code>data-pc-fit="steps"</code> — show the largest ranked variant that fits (logo → wordmark → monogram).</li>
        <li><code>data-pc-fit="relocate"</code> — move the slot somewhere else entirely (next section).</li>
        <li><code>data-pc-fit-priority</code> — lower degrades first; <code>data-pc-fit-auto</code> folds in every child of a container; <code>data-pc-fit-ignore</code> pins one out.</li>
      </ul>

      <%!-- ── 2 · Relocation (live) ───────────────────────────────────────── --%>
      <.heading level={2} class="mt-4 mb-2">2 · Relocation — fit decides, a <em>sink</em> places</.heading>
      <.paragraph>
        A <code>relocate</code> slot doesn't just hide — it <strong>moves out of the
        row</strong> into a named destination and comes back on widen. Crucially, the
        Fit engine only <strong>decides</strong> a slot must yield; <em>where</em> it
        goes is a pluggable <strong>sink</strong> named by
        <code>data-pc-fit-target</code>. Two sinks ship built-in:
      </.paragraph>
      <ul class="text-secondary mb-3">
        <li><code>target="floating-menu"</code> — folds into a "•••" flyout panel. Self-contained; needs no sidebar.</li>
        <li><code>target="sidebar"</code> — rebuilds the slot as a sidebar list item.</li>
        <li><em>your own</em> — <code>pureAdmin.components.fit.registerSink("name", &#123; out, in &#125;)</code>.</li>
      </ul>

      <.paragraph color="secondary">
        <strong>Live — drag to narrow the bar.</strong>
        The badge cluster is one <code>relocate</code> slot targeting
        <code>floating-menu</code>; when the bar runs out of room it folds into the
        "•••" panel, and returns when you widen. "New" is pinned with
        <code>data-pc-fit-ignore</code>.
      </.paragraph>

      <div class="resp-slider-row">
        <span>{gettext("Bar width")}</span>
        <input
          type="range" min="240" max="720" value="720"
          id="resp-slider" phx-hook="StageWidth"
          data-stage="respStage" data-output="resp-w"
          aria-label={gettext("Relocate demo width")}
        />
        <output id="resp-w">720px</output>
      </div>

      <div class="resp-stage" id="respStage" style="max-width: 720px">
        <div class="resp-bar" id="respBar" phx-hook="PureAdminNavFit">
          <span class="resp-bar__brand">Acme Console</span>
          <span
            class="resp-stats"
            data-pc-fit="relocate" data-pc-fit-target="floating-menu" data-pc-fit-priority="10"
          >
            <.badge theme_color="1">Users&nbsp;123</.badge>
            <.badge theme_color="3">Rooms&nbsp;23</.badge>
            <.badge theme_color="5">Subs&nbsp;45</.badge>
          </span>
          <span class="resp-bar__spacer"></span>
          <.button variant="primary" size="sm" data-pc-fit-ignore="true">{gettext("New")}</.button>
        </div>
      </div>

      <.code_block language="html" class="mt-3 mb-3">{@code_relocate}</.code_block>

      <.callout variant="success" class="mb-4">
        <strong>Why a sink registry?</strong>
        The engine used to hard-code "move into the sidebar." Extracting the
        destination means one generic detector serves many placements — sidebar,
        flyout, or anything you register — and it's the seam that lets the navbar
        live in the foundation layer while the sidebar-specific sink stays in the
        admin layer.
      </.callout>

      <%!-- ── 3 · Event + managed mode ────────────────────────────────────── --%>
      <.heading level={2} class="mt-4 mb-2">3 · The event &amp; hands-off mode (Svelte / Phoenix)</.heading>
      <.paragraph>
        Before it moves anything, Fit fires a cancelable <code>pc:fit-relocate</code>
        event on the slot (<code>detail = &#123; action, target, container &#125;</code>).
        A plain HTML page lets the built-in sink do the DOM move. A reactive framework
        does the opposite: it <strong>owns placement itself</strong>.
      </.paragraph>
      <.paragraph>
        Set <code>data-pc-fit-managed</code> (or call <code>preventDefault()</code>)
        and Fit performs <strong>no DOM surgery</strong> — it only hides the slot
        in-row and tells you it flipped. The framework then re-renders the block in
        its new home <em>from state</em>. That solves the staleness trap: a moved DOM
        node keeps its old <code>Users: 123</code>; a re-render is bound to the live
        assigns, so the relocated copy is always fresh.
      </.paragraph>

      <.code_block language="javascript" class="mb-3">{@code_event}</.code_block>

      <.callout variant="info" class="mb-4">
        Same contract in Phoenix LiveView: the hook forwards
        <code>pc:fit-relocate</code> with <code>pushEvent</code>, the server assigns
        the mode, and only the branch for the current placement is rendered — never a
        stale off-screen copy.
      </.callout>

      <%!-- ── 4 · Container Breakpoint ────────────────────────────────────── --%>
      <.heading level={2} class="mt-4 mb-2">4 · Container Breakpoint — named modes at set widths</.heading>
      <.paragraph>
        When a component restyles <em>wholesale</em> at set sizes — not a row shedding
        pieces, but a card that becomes a grid, then tabs, then icons — declare width
        thresholds and let the engine name the band. It's the JS counterpart to a CSS
        <code>@container</code> query, for the cases CSS can't reach (mount a chart,
        push to the server).
      </.paragraph>

      <.code_block language="html" class="mb-3">{@code_cb}</.code_block>

      <ul class="text-secondary mb-3">
        <li>Thresholds are <strong>rem</strong> by default (root font is 10px, so <code>34</code> = 340px, <code>64</code> = 640px); add <code>data-pc-breakpoint-unit="px"</code> for pixels.</li>
        <li>The engine reflects the band to <code>[data-mode]</code> (CSS can key off it) and toggles <code>.d-none</code> on <code>data-pc-show</code> pieces.</li>
        <li>It fires <code>pc:breakpoint</code> only on a flip — the hook for "mount on demand" (build the chart in <code>grid</code>, destroy it otherwise).</li>
        <li>A small <strong>hysteresis</strong> dead-band stops flip-flopping right at a threshold.</li>
      </ul>

      <.callout variant="info" class="mb-4">
        See it live on the <.link navigate="/layout/fit-to-size">Fit to Size</.link>
        page — Example 4 builds a Chart.js instance only once the card reaches
        <code>grid</code> mode and destroys it below, logging every flip. A standalone
        engine demo lives at
        <.link navigate="/layout/container-breakpoint">Container Breakpoint</.link>.
      </.callout>

      <%!-- ── Which do I use ──────────────────────────────────────────────── --%>
      <.heading level={2} class="mt-4 mb-2">{gettext("Which one do I reach for?")}</.heading>
      <.callout variant="warning" class="mb-4">
        <strong>Row of items fighting for one line?</strong>
        Fit — it measures and sheds by priority.<br />
        <strong>One component that reshapes at set widths?</strong>
        Container Breakpoint — it names the band and you style/mount per mode.<br />
        <strong>Purely cosmetic swap with no mount/DOM move?</strong>
        A plain CSS <code>@container</code> query — no JS at all. Reach for an engine
        only when a move needs JavaScript: relocating a node, or mounting/destroying
        on demand.
      </.callout>

      <.paragraph color="secondary">
        Ready to see Fit degrade real cards and toolbars across several strategies?
        Head to <.link navigate="/layout/fit-to-size">Fit to Size</.link> for the
        worked, slider-driven examples.
      </.paragraph>
    </div>
    """
  end
end
