defmodule DemoWeb.Live.ContainerBreakpointLive do
  @moduledoc """
  Demonstrates the Container Breakpoint engine (pure-admin-core v2.9.0-rc17,
  vendored as `container_breakpoint_core.js`) via the
  `PureAdminContainerBreakpoint` hook.

  The card measures its OWN inline size (like a CSS `@container` query) and maps
  it to a named `mode` from the declared thresholds. The engine reflects the mode
  into `[data-mode]` and toggles the shared `.d-none` on `data-pc-show`
  descendants — so pieces appear/disappear based on the space the card is given,
  not the viewport. Resize the browser (or open on a phone) to watch it adapt;
  the sidebar means the card crosses its thresholds well before the window does.

  This demo is purely client-side (no `pushEvent`) — it drives `.d-none` + the
  `[data-mode]` attribute. To render server-side per mode (mount-on-demand), add
  `data-pc-breakpoint-event="..."` and handle the pushed event; the hook forwards
  the flip to the LiveView only when that attribute is present.
  """
  use DemoWeb, :live_view

  @breakpoints Jason.encode!(%{compact: 0, comfy: 34, wide: 64})

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Container Breakpoint")}
  end

  def render(assigns) do
    assigns = assign(assigns, :breakpoints, @breakpoints)

    ~H"""
    <div class="pa-page-content">
      <.heading level={1}>{gettext("Container Breakpoint")}</.heading>
      <.paragraph>
        The JS counterpart to a CSS <code>@container</code> query. The card below
        carries <code>phx-hook="PureAdminContainerBreakpoint"</code> and
        <code>data-pc-breakpoints</code>; the engine maps its width to a named
        <em>mode</em> — <code>compact</code> / <code>comfy</code> / <code>wide</code>
        — reflected into <code>[data-mode]</code>, and toggles <code>.d-none</code>
        on the <code>data-pc-show</code> pieces. Thresholds are <strong>rem</strong>
        (<code>34</code> = 340px, <code>64</code> = 640px at the 10px root). Resize
        the window and watch the class hop in devtools.
      </.paragraph>

      <div
        id="cb-product-card"
        phx-hook="PureAdminContainerBreakpoint"
        data-pc-breakpoints={@breakpoints}
        data-pc-breakpoint-initial="comfy"
        class="pa-card"
      >
        <div class="pa-card__body">
          <div class="d-flex" style="align-items: flex-start; gap: 1.5rem">
            <div class="flex-1" style="min-width: 0">
              <span class="pa-badge pa-badge--color-3">Beverages</span>
              <h4 class="mt-2 mb-1">Arabica Cold Brew</h4>
              <div style="color: var(--pc-text-color-2)">
                <code>SKU-4471</code>
                <span data-pc-show="comfy wide"> · 1 L bottle · 12 per case</span>
                <span class="d-none" data-pc-show="wide"> · Yirgacheffe Co-op</span>
              </div>
            </div>

            <div class="d-none" data-pc-show="wide" style="flex: 0 0 auto">
              <div class="pa-stat">
                <div class="pa-stat__icon pa-stat__icon--success">📈</div>
                <div class="pa-stat__content">
                  <div class="pa-stat__number">$847K</div>
                  <div class="pa-stat__label">Revenue · 30d</div>
                </div>
              </div>
            </div>
          </div>

          <div class="d-none mt-3" data-pc-show="wide comfy">
            <div class="pa-dot-leaders">
              <div class="pa-dot-leaders__item">
                <span class="pa-dot-leaders__label">Open orders</span>
                <span class="pa-dot-leaders__leader"></span>
                <span class="pa-dot-leaders__value">38</span>
              </div>
              <div class="pa-dot-leaders__item">
                <span class="pa-dot-leaders__label">On hand</span>
                <span class="pa-dot-leaders__leader"></span>
                <span class="pa-dot-leaders__value">8,450</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <.callout variant="info" class="mt-4">
        Every visible piece is a real <code>pa-*</code> class; only the engine's
        <code>.d-none</code> toggling changes as the card resizes. The 1-D toolbar
        companion is the fit engine (<code>data-pc-fit</code> + the
        <code>PureAdminNavFit</code> hook).
      </.callout>
    </div>
    """
  end
end
