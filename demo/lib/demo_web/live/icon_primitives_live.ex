defmodule DemoWeb.Live.IconPrimitivesLive do
  @moduledoc """
  Reference for the framework's structural icons — the `.pa-icon` masked CSS
  primitive that ships in pure-admin-core. Mirrors the svelte/pure-admin `icons`
  demo page. (Distinct from `/phoenix/icons`, which documents keen's Elixir icon
  *components* — `<.icon>`, `<.faicon>`, `<.heroicon>`.)
  """
  use DemoWeb, :live_view

  # One entry per shipped icon variable (name without the `--` prefix).
  @close_clear_remove ~w(x clear remove)
  @disclosure ~w(chevron chevron-up chevron-right chevron-down chevron-left caret-up caret-down expand collapse)
  @actions ~w(add edit delete save copy download)
  @utility ~w(search refresh filter check ellipsis ellipsis-vertical link external-link settings bell user favorites)
  # Severity marks — shown in their shared semantic colour.
  @severity ~w(info success warning danger)
  # Sizes used in the masked-primitive showcase.
  @primitive_sizes ~w(1.2rem 1.6rem 2.4rem 3.2rem)

  def mount(_params, _session, socket) do
    # Code snippets are passed as strings so <.code_block> shows the literal
    # markup/CSS instead of HEEx trying to evaluate it.
    code_examples = %{
      primitive_html: ~s"""
      <!-- default 1em, inherits text colour -->
      <span class="pa-icon pa-icon--search" aria-hidden="true"></span>

      <!-- sized + coloured -->
      <span class="pa-icon pa-icon--search"
            style="--pa-icon-size: 2.4rem; color: var(--pc-accent);"></span>\
      """,
      token_chain: ~s"""
      .pa-icon--search  →  var(--pa-icon-src)
                        →  var(--pa-icon-search)
                        →  var(--base-icon-search, /* inline Lucide fallback */)\
      """,
      hover_css: ~s"""
      /* your glyph — resting outline + filled-on-hover source */
      .pa-icon--star {
        --pa-icon-src:       var(--pa-icon-star);         /* Lucide outline */
        --pa-icon-src-hover: url("…tabler filled star…"); /* filled variant */
      }

      /* framework rule (ships in core) — no-op unless a glyph declared a hover src. */
      .pa-btn:not(:disabled):hover .pa-icon,
      .pa-tabs__item:not(:disabled):hover .pa-icon {
        mask-image: var(--pa-icon-src-hover, var(--pa-icon-src));
      }\
      """
    }

    {:ok,
     assign(socket,
       page_title: "Icons",
       close_clear_remove: @close_clear_remove,
       disclosure: @disclosure,
       actions: @actions,
       utility: @utility,
       severity: @severity,
       primitive_sizes: @primitive_sizes,
       code_examples: code_examples
     )}
  end

  def render(assigns) do
    ~H"""
    <style>
      /* Reference grid for the icon family (auto-fill — no 12-col utility fits). */
      .icon-ref-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(12rem, 1fr));
        gap: 0.75rem;
        margin-top: 1rem;
      }
      .icon-ref {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 0.6rem 0.75rem;
        border: 1px solid var(--pc-border-color);
        border-radius: var(--pc-border-radius);
        background: var(--pa-card-bg);
      }
      .icon-ref .pa-icon {
        --pa-icon-size: 2rem;
        color: var(--pc-text-color-1);
      }
      .icon-ref code {
        font-size: 1.15rem;
        color: var(--pc-text-color-2);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      /* Severity chips shown in their semantic colour */
      .icon-ref--info .pa-icon { color: var(--pc-info); }
      .icon-ref--success .pa-icon { color: var(--pc-success); }
      .icon-ref--warning .pa-icon { color: var(--pc-warning); }
      .icon-ref--danger .pa-icon { color: var(--pc-danger); }

      /* ── Hover-to-fill live demo ──────────────────────────────────────────
         Lucide (the default set) is outline-only, so the framework's hover-to-fill
         is dormant with it. This demo supplies a Tabler regular/filled star pair
         (Tabler is a Lucide look-alike that ships filled variants) so the swap is
         actually visible. The core rule in _icons.scss does the rest on hover of
         an enabled .pa-btn / .pa-tabs__item. */
      .demo-fill-star {
        --pa-icon-src: url("data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22 fill=%22none%22 stroke=%22%23000%22 stroke-width=%222%22 stroke-linecap=%22round%22 stroke-linejoin=%22round%22%3E%3Cpath d=%22M12 17.75l-6.172 3.245l1.179 -6.873l-5 -4.867l6.9 -1l3.086 -6.253l3.086 6.253l6.9 1l-5 4.867l1.179 6.873l-6.158 -3.245%22/%3E%3C/svg%3E");
        --pa-icon-src-hover: url("data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22%3E%3Cpath d=%22M8.243 7.34l-6.38 .925l-.113 .023a1 1 0 0 0 -.44 1.684l4.622 4.499l-1.09 6.355l-.013 .11a1 1 0 0 0 1.464 .944l5.706 -3l5.693 3l.1 .046a1 1 0 0 0 1.352 -1.1l-1.091 -6.355l4.624 -4.5l.078 -.085a1 1 0 0 0 -.633 -1.62l-6.38 -.926l-2.852 -5.78a1 1 0 0 0 -1.794 0l-2.853 5.78z%22/%3E%3C/svg%3E");
      }
    </style>

    <p>
      The framework's structural icons are drawn with a single masked primitive,
      <.code>.pa-icon</.code>, so every glyph inherits the current text colour, scales
      with font size, and is themeable from one place. At this layer an icon is a raw
      <.code>&lt;span class="pa-icon pa-icon--NAME"&gt;</.code> — how the library's own
      chrome renders affordances. There is also an
      <.pa_link href="/phoenix/icons"><.code>&lt;.icon&gt;</.code> component</.pa_link>
      that resolves names through swappable provider sets (Font Awesome, Heroicons,
      Lucide, …) — see Icon Components. This page lists the masked icons that ship as
      variables and explains the hover-to-fill affordance.
    </p>

    <%!-- ── The masked primitive ───────────────────────────────────────── --%>
    <.card title_text={gettext("The masked icon primitive")} class="mt-4">
      <.paragraph>
        Each masked glyph is a <.code>&lt;span class="pa-icon pa-icon--name"&gt;</.code>. The glyph is
        an SVG <.code>mask</.code>; the box is painted in <.code>currentColor</.code> and shows
        through it. That means an icon automatically matches its surrounding text colour and
        scales with <.code>font-size</.code> (default <.code>1em</.code>, override with
        <.code>--pa-icon-size</.code>).
      </.paragraph>

      <div class="component-showcase align-items-center" style="gap: 1.5rem;">
        <span :for={size <- @primitive_sizes} class="pa-icon pa-icon--search" style={"--pa-icon-size: #{size};"} aria-hidden="true"></span>
        <span class="pa-icon pa-icon--search" style="--pa-icon-size: 2.4rem; color: var(--pc-accent);" aria-hidden="true"></span>
        <span class="pa-icon pa-icon--search" style="--pa-icon-size: 2.4rem; color: var(--pc-danger);" aria-hidden="true"></span>
      </div>
      <.paragraph class="text-sm text-secondary mt-3">
        Same class, sized with <.code>--pa-icon-size</.code> and coloured with <.code>color</.code> /
        <.code>currentColor</.code>.
      </.paragraph>

      <.code_block language="html">{@code_examples.primitive_html}</.code_block>
    </.card>

    <%!-- ── Icon variables ─────────────────────────────────────────────── --%>
    <.card title_text={gettext("Icon variables")} class="mt-4">
      <.paragraph>
        These structural affordances ship as icon variables. Add the modifier class to a
        <.code>.pa-icon</.code> span; each modifier points <.code>--pa-icon-src</.code> at the
        matching <.code>--pa-icon-name</.code> token.
      </.paragraph>

      <.heading level={4}>{gettext("Close / clear / remove")}</.heading>
      <div class="icon-ref-grid">
        <div :for={name <- @close_clear_remove} class="icon-ref">
          <span class={"pa-icon pa-icon--#{name}"} aria-hidden="true"></span>
          <code>--{name}</code>
        </div>
      </div>

      <.heading level={4} class="mt-6">{gettext("Disclosure & direction")}</.heading>
      <.paragraph class="text-sm text-secondary">
        The four chevron directions are one glyph rotated with a transform, so overriding the
        chevron re-skins all four at once. Same for the ellipsis (horizontal / vertical).
      </.paragraph>
      <div class="icon-ref-grid">
        <div :for={name <- @disclosure} class="icon-ref">
          <span class={"pa-icon pa-icon--#{name}"} aria-hidden="true"></span>
          <code>--{name}</code>
        </div>
      </div>

      <.heading level={4} class="mt-6">{gettext("Actions")}</.heading>
      <div class="icon-ref-grid">
        <div :for={name <- @actions} class="icon-ref">
          <span class={"pa-icon pa-icon--#{name}"} aria-hidden="true"></span>
          <code>--{name}</code>
        </div>
      </div>

      <.heading level={4} class="mt-6">{gettext("Utility")}</.heading>
      <div class="icon-ref-grid">
        <div :for={name <- @utility} class="icon-ref">
          <span class={"pa-icon pa-icon--#{name}"} aria-hidden="true"></span>
          <code>--{name}</code>
        </div>
      </div>

      <.heading level={4} class="mt-6">{gettext("Severity")}</.heading>
      <.paragraph class="text-sm text-secondary">
        One shared family used by toasts, alerts, callouts, notifications and popconfirm, so every
        severity surface shows the same mark. Shown here in their semantic colours.
      </.paragraph>
      <div class="icon-ref-grid">
        <div :for={name <- @severity} class={"icon-ref icon-ref--#{name}"}>
          <span class={"pa-icon pa-icon--#{name}"} aria-hidden="true"></span>
          <code>--{name}</code>
        </div>
      </div>
    </.card>

    <%!-- ── Token chain ────────────────────────────────────────────────── --%>
    <.card title_text={gettext("How the tokens re-skin")} class="mt-4">
      <.paragraph>
        Most icons trace through a shared, cross-ecosystem contract, so a single override re-skins
        Pure Admin, the pure-css shell and the KeenMate web components together:
      </.paragraph>
      <.code_block language="css">{@code_examples.token_chain}</.code_block>
      <ul>
        <li>
          <strong><.code>--base-icon-*</.code></strong> — the shared contract (published in
          <.code>@keenmate/base-css-variables</.code> and mirrored by <.code>@keenmate/pure-css</.code>).
          Override once to re-skin everything.
        </li>
        <li>
          <strong><.code>--pa-icon-*</.code></strong> — Pure Admin's family; falls back to an inline
          Lucide glyph so icons always render even without the contract loaded.
        </li>
        <li>
          <strong>pa-only glyphs</strong> — a few (e.g. <.code>--pa-icon-favorites</.code>) are Pure
          Admin-only and are <em>not</em> part of the <.code>--base-*</.code> contract, so they're
          defined directly with no <.code>--base-icon-*</.code> route.
        </li>
      </ul>
      <.paragraph>
        To retarget a single glyph, set its <.code>--pa-icon-name</.code> (or the shared
        <.code>--base-icon-name</.code>) at <.code>:root</.code> or on any subtree.
      </.paragraph>
    </.card>

    <%!-- ── Hover-to-fill ──────────────────────────────────────────────── --%>
    <.card title_text={gettext("Hover-to-fill (enabled buttons & tabs)")} class="mt-4">
      <.paragraph>
        An icon can swap to a <strong>filled</strong> variant when its enabled button or tab is
        hovered. It's opt-in on two axes:
      </.paragraph>
      <ul>
        <li>
          <strong>Per glyph</strong> — an icon opts in by declaring a filled source on
          <.code>--pa-icon-src-hover</.code>. Icons without one are left untouched.
        </li>
        <li>
          <strong>Per context</strong> — the swap only fires inside an <em>enabled</em>
          <.code>.pa-btn</.code> or <.code>.pa-tabs__item</.code> on <.code>:hover</.code>. Disabled
          controls never react.
        </li>
      </ul>

      <.callout variant="warning" heading_text={gettext("The default Lucide set is outline-only")}>
        <:icon><span class="pa-icon pa-icon--warning" aria-hidden="true"></span></:icon>
        Lucide ships no filled glyphs, so hover-to-fill is <strong>dormant out of the box</strong> —
        the mechanism is present but there's nothing to fill to. To activate it, point
        <.code>--pa-icon-src-hover</.code> at a filled glyph from a set that has one —
        <strong>Tabler</strong> (a Lucide look-alike), Fluent, or Material. The live demo below uses
        a Tabler regular/filled star pair.
      </.callout>

      <.heading level={4} class="mt-6">{gettext("Live demo")}</.heading>
      <.paragraph class="text-sm text-secondary">
        Hover each control. The first uses a Tabler outline→filled star and morphs; the second is a
        Lucide star and stays outline (nothing to fill to); the third is the <em>same</em> Tabler
        star but disabled, so it never reacts despite being fillable (proving the disabled gate). No
        transition — <.code>mask-image</.code> can't tween, so the fill is an instant swap.
      </.paragraph>
      <div class="component-showcase align-items-center" style="gap: 1rem;">
        <button class="pa-btn pa-btn--primary">
          <span class="pa-icon demo-fill-star" aria-hidden="true"></span> Favorite (Tabler)
        </button>
        <button class="pa-btn pa-btn--secondary">
          <span class="pa-icon pa-icon--favorites" aria-hidden="true"></span> Favorite (Lucide)
        </button>
        <button class="pa-btn pa-btn--primary" disabled>
          <span class="pa-icon demo-fill-star" aria-hidden="true"></span> Disabled (Tabler)
        </button>
      </div>

      <div class="pa-tabs pa-tabs--full mt-6" style="max-width: 32rem;">
        <button class="pa-tabs__item pa-tabs__item--active">
          <span class="pa-icon demo-fill-star" aria-hidden="true"></span>
          <span>Starred</span>
        </button>
        <button class="pa-tabs__item">
          <span class="pa-icon pa-icon--user" aria-hidden="true"></span>
          <span>Profile</span>
        </button>
      </div>

      <.heading level={4} class="mt-6">{gettext("How to enable it")}</.heading>
      <.paragraph>
        Define a modifier that declares both a resting (outline) and a hover (filled) source. The
        framework's global rule swaps them on hover:
      </.paragraph>
      <.code_block language="css">{@code_examples.hover_css}</.code_block>
      <.paragraph class="text-sm text-secondary">
        The fallback to <.code>--pa-icon-src</.code> is what makes the rule safe to ship globally:
        any icon that didn't declare a filled source simply keeps its resting glyph.
      </.paragraph>
    </.card>
    """
  end
end
