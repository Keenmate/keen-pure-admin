defmodule DemoWeb.Live.ResponsiveFormLive do
  @moduledoc """
  Container-breakpoint demo: a form that sheds optional fields as its own width
  shrinks, driven entirely by the `<.breakpoint_container>` + `<.breaker>`
  components (a declarative wrapper over the Container Breakpoint engine).

  The call site writes no `data-pc-show` / `.d-none` — the container names a mode
  from its width and each `<.breaker show="…">` block appears only in the listed
  modes. Layout that changes with size (the two-up row) keys off the reflected
  `[data-mode]`, not a viewport media query. Drag the slider to watch it adapt.
  """
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Responsive Form")}
  end

  def render(assigns) do
    ~H"""
    <style>
      /* Demo scaffolding only: the resizable stage the slider controls. */
      .rf-stage { max-width: 100%; margin-block: 0.75rem; border: 1px dashed var(--pc-border-color); border-radius: 8px; transition: max-width 0.08s ease; }
      .rf-slider-row { display: flex; align-items: center; gap: 0.75rem; margin-top: 1rem; font-size: var(--pc-font-size-sm, 1.4rem); color: var(--pc-text-color-2); }
      .rf-slider-row input[type="range"] { flex: 1; min-width: 0; }
      .rf-slider-row output { font-variant-numeric: tabular-nums; min-width: 4.5ch; text-align: end; }
      /* Layout keyed off the CARD's own width via the reflected [data-mode] —
         not a viewport media query — so the two-up row only splits when the card
         (not the window) is wide. */
      #rf[data-mode="wide"] .rf-cols { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
    </style>

    <div class="pa-page-content">
      <.heading level={1} class="mb-2">{gettext("Responsive form")}</.heading>
      <.paragraph class="pa-text--secondary mb-3">
        The form <em>is</em> the breakpoint container; each field group is a
        <code>&lt;.breaker&gt;</code> that declares the modes it survives in. As the
        card narrows it sheds optional fields down to the essentials. Notice the call
        site below has no <code>data-pc-show</code> / <code>.d-none</code> — the
        components emit that. Drag the slider (or open this on a phone).
      </.paragraph>

      <div class="rf-slider-row">
        <span>{gettext("Card width")}</span>
        <input
          type="range" min="240" max="760" value="520"
          id="rf-slider" phx-hook="StageWidth" data-stage="rf-stage" data-output="rf-w"
          aria-label={gettext("Form width")}
        />
        <output id="rf-w">520px</output>
      </div>

      <div class="rf-stage" id="rf-stage" style="max-width: 520px">
        <.breakpoint_container
          id="rf"
          steps={%{compact: 0, comfy: 34, wide: 64}}
          initial="comfy"
          class="pa-card"
          style="margin: 0"
        >
          <div class="pa-card__header">
            <div class="pa-card__title"><span class="pa-card__title-text">{gettext("New contact")}</span></div>
          </div>
          <div class="pa-card__body">
            <form phx-submit="save" class="pa-form">
              <%!-- Essentials: no <.breaker> → the engine never touches them, always visible. --%>
              <.form_group>
                <.form_label for="rf-name">{gettext("Full name")}</.form_label>
                <.input id="rf-name" name="name" required placeholder="Jane Doe" />
              </.form_group>
              <.form_group>
                <.form_label for="rf-email">{gettext("Email")}</.form_label>
                <.input id="rf-email" type="email" name="email" required placeholder="jane@acme.com" />
              </.form_group>

              <%!-- Secondary: present in comfy + wide, dropped in compact. --%>
              <.breaker show="comfy wide">
                <.form_group>
                  <.form_label for="rf-phone">{gettext("Phone")}</.form_label>
                  <.input id="rf-phone" type="tel" name="phone" placeholder="+1 555 0142" />
                </.form_group>
              </.breaker>
              <.breaker show="comfy wide">
                <.form_group>
                  <.form_label for="rf-company">{gettext("Company")}</.form_label>
                  <.input id="rf-company" name="company" placeholder="Acme Inc." />
                </.form_group>
              </.breaker>

              <%!-- Rich: wide only — a two-up row plus notes. --%>
              <.breaker show="wide">
                <div class="rf-cols">
                  <.form_group>
                    <.form_label for="rf-title">{gettext("Job title")}</.form_label>
                    <.input id="rf-title" name="title" placeholder="Head of Ops" />
                  </.form_group>
                  <.form_group>
                    <.form_label for="rf-source">{gettext("Lead source")}</.form_label>
                    <.select
                      id="rf-source" name="source" prompt={gettext("Choose…")}
                      options={[{"web", gettext("Website")}, {"ref", gettext("Referral")}, {"event", gettext("Event")}]}
                    />
                  </.form_group>
                </div>
                <.form_group>
                  <.form_label for="rf-notes">{gettext("Notes")}</.form_label>
                  <.textarea id="rf-notes" name="notes" rows="4" placeholder="Context, next steps…" />
                  <.form_help>Only you and your team can see this.</.form_help>
                </.form_group>
              </.breaker>

              <%!-- Compact-only nudge. --%>
              <.breaker show="compact">
                <.callout variant="info" class="mt-2">
                  Widen this panel to add phone, company, and notes.
                </.callout>
              </.breaker>

              <%!-- The submit is essential → always present. --%>
              <.button type="submit" variant="primary" class="mt-3">{gettext("Save contact")}</.button>
            </form>
          </div>
        </.breakpoint_container>
      </div>

      <.callout variant="info" class="mt-4">
        <strong>How it's wired.</strong>
        <code>&lt;.breakpoint_container steps=… initial=…&gt;</code> measures its own width
        and names a mode (<code>compact</code> / <code>comfy</code> / <code>wide</code>);
        each <code>&lt;.breaker show="…"&gt;</code> appears only in the listed modes (it emits
        <code>data-pc-show</code>, the engine toggles the shared <code>.d-none</code>). Thresholds
        are rem — root 10px, so <code>34</code> = 340px and <code>64</code> = 640px. The two-up
        row uses the reflected <code>[data-mode="wide"]</code>, since this keys off the card's
        own width, not the viewport.
      </.callout>
    </div>
    """
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end
end
