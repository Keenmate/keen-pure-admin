# keen-pure-admin ↔ pure-admin core — Alignment Plan

**Started:** 2026-09-28
**Mode:** Plan-first (catalog findings → review → fix in batches). No fixes applied yet except where noted.

## Purpose

A fresh, deeper alignment pass of every keen (Phoenix LiveView) component against
pure-admin core. Prior class-sweep + structural audits (see `component-audit.md`)
still left drift because they checked emitted classes more than **option
coverage** and **API ergonomics**. This pass does, per component:

- **A) Coverage** — does keen expose every variant / size / modifier / render-form
  the core component supports?
- **B) Gaps** — what core options are missing → this plan.
- **C) Structure** — does keen's emitted DOM match the canonical snippet shape for
  each option combination?

## Source of truth

**Core snippet (`packages/core/snippets/*.html`) + component SCSS + `dist/css/main.css`
is the arbiter — NOT svelte-pure-admin.** This pass already found svelte itself
drifted from the snippet (e.g. it always wraps the button label in `.pa-btn__label`,
which the snippet never shows; it lacks the `ghost` variant core defines). So svelte
and keen are two implementations both measured against core.

## Finding buckets

| Bucket | Meaning |
|--------|---------|
| 🔴 PHANTOM | keen emits a class core does not define (grep `dist/css/main.css` = 0, and not a blessed-but-unstyled snippet hook) |
| 🟠 MISSING-OPTION | a core variant/size/modifier/render-form keen exposes no prop for |
| 🟡 STRUCTURAL | keen's element nesting / wrapper / ordering differs from the canonical snippet |
| 🔵 API-ERGONOMICS | keen forces the consumer to hand-author canonical markup the wrapper should generate |
| ⚪ DEAD/OFF-CONTRACT | a keen attr/class that is a no-op in core |

---

## Priority triage (all 47 components)

**P0 — live breakage (renders wrong today):**
1. `loader.ex` — `color` maps to phantom `--pc-{success,danger,warning,info}-bg` (should be `--pa-*-bg`); semantic loader colours render grey. LIVE in demo.
2. `toast.js` — exit uses phantom `pa-toast--dismissing` (should be `pa-toast--hide`); exit animation dead.
3. `comparison.ex` — value `<td>`s emit no `data-label`; mobile card-stack shows a blank label gutter on every cell.
4. `table.ex` — `is_responsive`/`is_responsive_grid` emit no `data-label`/`data-grid`/`data-span`; responsive tables are non-functional via the component (demos bypass it with raw markup).
5. `layout.ex` — `main/1` injects phantom `.pc-layout__main__inner` on **every page**; `divider/1` emits phantom `.pa-divider` (0 CSS defs).
6. `badge.ex` — `badge_group` forces `--show-all` then re-hides via injected `<style>` keyed on undefined `pa-badge-group--expanded`.

**P1 — ergonomics (design-goal violations) + missing options:**
- **No wrapper for whole core systems:** the **fit-to-size engine** (responsive.ex) and the **masked `pa-icon` primitive** (icon.ex) have no keen component — demos hand-author `data-pc-fit*`/`pc-fit-hidden` and `pa-icon pa-icon--*` internals everywhere.
- **Features that bypass their component:** table row-selection API; profile favorites + tabs; card footer meta/actions + header-underline theme-color; checkbox_group/radio_group orientation+layout; kpi hero/bento `__chart-svg`; command-palette fullscreen + token `__remove`; sheet barcode/qr.
- **Missing options:** outline guards (button/alert/modal-banded → phantom `--outline-*`); checkbox/radio label-position; range `disabled`; popconfirm base icon; data-bar value + `bar_list` component; badge composite `icon_variant`; responsive grid offset.

**P2 — structural / cosmetic / dead:**
- KPI bare `<h3>` header (systemic, 8 files); pager two-group `__controls`; field copy wrapper span; editorial `<em>`; filter-card toggle order + `hidden` a11y; list semantic `<ul>/<li>`; timeline scroll/load-more wrappers.
- Dead/redundant: checkbox/1 `disabled` not declared; modal `header_variant`; tooltip `is_inline` vs `is_keyword`; timeline `:meta`; faicon fill/stroke; icon `color` on `<i>`; doc overclaims (filter-card, pa_link, typography fallback).

**Clean components (no changes needed):** callout · stat · splitter · settings_panel · code · document · kpi_detail (+ kpi_strip's prior phantom is fixed).

---

## Progress log

### Batch 1 — easy wins (2026-09-29) ✅ DONE (uncommitted)
- **loader.ex** — `color_style/1` fallback `--pc-#{color}-bg` → `--pa-#{color}-bg` (P0; semantic loader colours now paint). Test `loader_test.exs` updated to assert `--pa-danger-bg`; the "no color" test broadened to `refute "color: var("`. `mix test loader_test` → 5/0. 
- **toast.js** — exit class `pa-toast--dismissing` → `pa-toast--hide` (P0; exit transition now fires, 300ms timeout matches `$transition-normal`).
- **layout.ex** — `main/1` dropped the phantom `.pc-layout__main__inner` wrapper; content now renders directly in `<main class="pc-layout__main">` (P0).
- **typography.ex** — `pa_link/1` @doc example `text-secondary` (nonexistent) → `text-color-2` / real `text-*` utilities.
- **filter_card.ex** — `is_loading` docstring corrected (core `--loading` dims the card; it does not spin the refresh icon).
- `mix compile` clean.

### Batch 2 — stale test debt from the shell→pure-css `pa-*`→`pc-*` rename (2026-09-29) ✅ DONE (uncommitted)
`layout_test.exs` had 25 failures: the code correctly emits the migrated foundation contract
but the tests still asserted the OLD names. Verified the CODE is authoritative against
pure-css source (old `pa-*` names return 0 hits in `pure-css/src/scss`; `fit.js` reads
`data-pc-fit*`). Migrated the test assertions:
- foundation classes `pa-{navbar,navmenu,sidebar,layout,page-header,app-header}*` → `pc-*`
  (component classes `pa-icon`/`pa-search-*` correctly left as `pa-*`).
- nav attrs: `data-pa-nav-collapse`→`data-pc-fit-nav`, `data-pa-nav-priority`→`data-pc-fit-nav-priority`,
  `data-pa-nav-more-label`→`data-pc-fit-nav-more-label`, `data-pa-nav-icon`→`data-pc-nav-icon`.
- fit attrs: `data-pa-fit*`→`data-pc-fit*`, `pa-fit-hidden`→`pc-fit-hidden`.
- hook: `PureAdminNavCollapse`→`PureAdminNavFitCollapse` (old hook deleted; new one is registered).
Full keen suite now **16 doctests + 184 tests, 0 failures.**

### Batch 3 — small safe component + demo fixes (2026-09-29) ✅ DONE (uncommitted)
- **modal.ex** — header now renders ONCE in a single `.pa-modal__title` (`render_slot(@header)`),
  replacing the `:for` that could emit multiple `.pa-modal__title` and break the header flex row.
- **demo** — removed phantom `pa-table--hover` (grep core=0; hover is built into `.pa-table`) from
  `data_visualization_live.ex`, `detail_panel_live.ex`, `table_multi_select_live.ex`.
- `mix compile` + full suite still **184 tests + 16 doctests, 0 failures.**

### Batch 4 — easy-tier demo + API cleanups (2026-09-29) ✅ DONE (uncommitted)
- **cards demo** (`cards_live.ex`) — DELETED the "Bordered Cards" section. Its prose taught the
  phantom `pa-card--bordered` class (grep core=0) and its 4 cards used the `is_bordered` prop,
  which the `card/1` component already documents as a deprecated **no-op** — so the "bordered"
  cards rendered identically to normal cards. Misleading demo of a non-existent feature. (The
  `is_bordered` attr itself stays on `card/1` as a documented no-op for back-compat.)
- **navigation.ex** — REMOVED the redundant `is_border_top` boolean knob. It duplicated
  `style="border-top"` (already an enumerated `style` value) — two ways to do one thing, with
  confusing precedence (only applied when `style == nil`). `style="border-top"` is the single
  canonical way. Dropped the attr, the `effective_style` branch, and the test's base-map entry.
- **typography `text/1`** — reviewed, **no change**: the `values:` list (muted/small/primary/
  secondary/success/danger/warning/info) maps 1:1 to real core classes via `text_variant_class/1`
  (verified all targets: `pa-text--secondary/--primary/--sm`, `text-success/-danger/-warning/-info`
  all grep=1). The list is accurate — nothing to trim. (Earlier "trim" flag was a false lead.)
- `mix compile` (lib + demo) clean; full suite **184 tests + 16 doctests, 0 failures.**

### Batch 5 — button P1 ergonomics (2026-09-29) ✅ DONE (uncommitted)
First P1-tier item (closest to the original button-alignment trigger). Two `button/1` fixes:
- **outline phantom-class guard** — `@outline_variants` set; `is_outline` only emits
  `pa-btn--outline-{v}` for the six core-defined variants, else falls back to solid fill.
  Kills `pa-btn--outline-light/-dark/-ghost` (grep core=0).
- **`should_truncate_text`** — new boolean; wrapper emits the inner `<span class="text-truncate">`
  so the consumer stops hand-authoring pa internals (the ergonomics gap the user flagged).
  Refactored the label render into a single `label_wrap_class` cond (truncate > center > bare),
  deduped across `<a>`/`<button>`. Docstring reblessed.
- **`is_input_group_button`** — new boolean; appends `pa-input-group__button` alongside `pa-btn`
  so a button flattens as an addon inside `.pa-input-group` (was svelte-only). Closes the last
  open button finding — **button.ex is now fully aligned.**
- +3 tests (outline guard across light/dark/ghost; truncate span wrap; input-group button). Suite
  now **187 tests + 16 doctests, 0 failures**; demo compiles clean.

### Batch 6 — forms choice-control ergonomics (2026-09-29) ✅ DONE (uncommitted)
The sharpest design-goal violation in the plan (the demo couldn't even use `<.radio>` for
label-position/group-layout — it hand-wrote raw `<label class="pa-radio">` markup). Mirrors the
svelte fix (`Radio` __label span + `labelPosition` + group `layout`). All classes verified in core.
- **`radio/1`** — now emits the canonical `<span class="pa-radio__label">` wrapper + `:label_content`
  slot (parity with checkbox); new `radio_classes/1` helper.
- **`checkbox/1` + `radio/1`** — new `label_position` attr (`start/end/top` → `pa-*--label-{pos}`).
- **`checkbox_group/1` + `radio_group/1`** — new `layout` attr (`horizontal/grid/2col/3col`).
- **Demo** (`forms_live.ex`) — dropped ALL hand-written `pa-checkbox--label-*` / `pa-*-group--*`
  classes AND the raw radio-markup blocks; now pure component props.
- +6 tests. Suite **193 tests + 16 doctests, 0 failures**; demo compiles clean.

**Remaining P1 ergonomics (not yet done):** `pa_icon/1` component (highest payoff), table
selection/responsive `data-label`, fit-to-size wrapper, profile favorites/tabs, kpi chart-svg, etc.
Plus minor doc-overclaim tidies.

---

## button.ex — `button/1`, `button_group/1`, `overflow/1`, `split_button/1`

**Core contract** (`snippets/buttons.html` + `_buttons.scss`): variants
primary/secondary/**ghost**/success/warning/danger/info/light/dark; outline **only**
for primary/secondary/success/warning/danger/info (snippet notes *no* outline-light/dark);
theme slots `--color-{1..9}` + `--outline-color-{1..9}`; sizes xs/sm/lg/xl; `--block`,
`--icon-only`, `--loading` (+`__spinner`), `--ripple`, `--align-{start,end,center,justify}`;
label is bare text, wrapped in `.pa-btn__label` only for `--align-center`; truncation =
inner `<span class="text-truncate">` (snippet L435-438) with a width utility; input-group
button = `pa-input-group__button` on a `.pa-btn` inside `.pa-input-group`.

**Findings:**
- 🔴 **outline + light/dark/ghost → phantom class.** ✅ FIXED (Batch 5). `is_outline` with
  {light, dark, ghost} emitted `pa-btn--outline-light/-dark/-ghost`, none defined in core
  (grep=0). Added `@outline_variants ~w(primary secondary success warning danger info)`;
  the outline branch now guards on membership and any other variant falls back to the solid
  fill. Test: outline+light/dark/ghost → asserts NO `pa-btn--outline-*`, IS `pa-btn--{variant}`.
- 🟠 **No `is_input_group_button`.** ✅ FIXED (Batch 5). Added `is_input_group_button` boolean →
  appends `pa-input-group__button` alongside `pa-btn` (core class sits on the same element:
  snippet forms.html L301; dist grep=3). Test asserts both classes present.
- 🔵 **Truncation forces manual `<span>`.** ✅ FIXED (Batch 5). Added `should_truncate_text`
  boolean → the wrapper now emits the inner `<span class="text-truncate">` itself (consumer no
  longer hand-authors pa internals). Unified all label-wrap cases into one `label_wrap_class`
  cond (truncate > center > bare), shared by the `<a>`/`<button>` branches; docstring reblessed
  to use `should_truncate_text class="maxwr-10"`. Test asserts the span wraps the label.

**Otherwise verified present & correct:** all variants incl. ghost, sizes, theme_color
(+ outline), is_block, is_loading (+`__spinner`), is_icon_only, is_ripple (+`data-ripple`),
align (+`pa-btn__label` on center), icon_position, href/anchor form, type; `button_group/1`
covers vertical + center/end/stretch + nowrap + responsive; `split_button/1` & `overflow/1`
structurally verified in prior audit.

---

## FORMS

### form.ex — `input/1`, `select/1`, `textarea/1`, `checkbox/1`, `radio/1`, `checkbox_group/1`, `radio_group/1`, `form_group/1`, `input_group/1`, `input_wrapper/1`, `simple_form/1`
- 🔵 **checkbox_group / radio_group have no orientation/layout prop** — ✅ FIXED (Batch 6). Added
  `layout` attr (`horizontal/grid/2col/3col` → `pa-{checkbox,radio}-group--{layout}`; all 4 dist=1)
  to both groups. Demo no longer hand-writes group classes.
- 🔵 **radio emits bare-text label, not `.pa-radio__label` span** — ✅ FIXED (Batch 6). `radio/1`
  now wraps the label in `<span class="pa-radio__label">` (canonical, snippet forms.html:257; dist=7)
  and gained a `:label_content` slot for parity with checkbox. This unblocks label-position and lets
  the demo drop its entire raw `<label class="pa-radio">…</label>` hand-authored markup (it couldn't
  use `<.radio>` at all before).
- 🟠 **checkbox/radio label-position modifiers unexposed** — ✅ FIXED (Batch 6). Added `label_position`
  attr (`start/end/top` → `pa-{checkbox,radio}--label-{pos}`; dist=2 each) to both.
- ⚪ **checkbox/1 `pa-checkbox--disabled` is dead** — `disabled` only in `:rest` include, so `Map.get(assigns,:disabled,false)` always false (form.ex:353,403). Dimming still works via core `:has(input:disabled)`. Fix: declare `attr(:disabled)` (as `checkbox_box/1` does) or drop the branch.
- 🟡 **simple_form actions use `pc-row/pc-col-100 text-end`, not `.pa-form-actions`** — misses the blessed actions-row spacing contract (form.ex:693-697 vs forms.html:57-60). Fix: emit `<div class="pa-form-actions justify-content-end">`.
- 🟡 **input_group fixes button addons after append** — leading/interleaved buttons (stepper −/input/+, forms.html:312-317) unreachable via slots. Fix: `:prepend_button`/`:append_button` positioned slots, or document composing inside inner_block.
- ✅ Input sizes/validation, color-1..9, textarea (correctly no validation border), input-group sizes, input-wrapper `__clear` (`pa-icon--x`), form_group horizontal/validation/required, bare-`<label>` auto-styling — all aligned. Dropped-dead `pa-form--inline` correctly gone.

### range_group.ex — `range/1`, `range_group/1`
- 🟠 **`pa-range--disabled` unexposed** — documented disabled slider (range-group.html:170-180). No `disabled` prop. Fix: add `disabled` → `pa-range--disabled` + `disabled` on both thumbs.
- ✅ Otherwise faithful: exact `__rail/__track/__fill/__thumb--min/--max` tree, `--single`, all 4 handle shapes, full `.pa-range-group` scaffold; ticks/summary correctly left to JS.

### checkbox_list.ex — `checkbox_list/1`, `checkbox_list_item/1`, `checkbox_box/1`
- 🔵 **checkbox_list_item can't forward size / is_x_mark / is_indeterminate to its checkbox** — hardcodes id/checked/disabled only (checkbox_list.ex:123). Sized/tri-state lists need dropping to raw markup. Fix: forward those attrs or accept a `:checkbox` slot.
- ✅ `checkbox_box/1` clean (here `disabled` IS declared → `--disabled` works). variant (compact/bordered/striped) + layout (inline/grid/2col/3col) cover all 7 modifiers; `__text`/`__description`/`__actions` nesting correct.

## FEEDBACK

### alert.ex — `alert/1`
- 🟠 **outline + {secondary,light,dark} → unstyled `pa-alert--outline-*`** — core defines outline only for primary/success/danger/warning/info (grep=0 for the others; snippet L198). `is_outline` accepts all 8. Fix: guard to the 5 supported.
- 🔵 **demo leaks raw `pa-alert__list`** — `alerts_live.ex:98` uses `<.basic_list class="pa-alert__list">` instead of the working `:list` slot (component API is fine). Fix: use the slot in the demo.
- ✅ Both shapes (icon→`__content`, no-icon→direct children), close glyph `pa-icon--x`, sizes (sm/lg only) aligned.

### callout.ex — `callout/1`
- ✅ **CLEAN.** 6 variants + color-1..9 + sizes complete; icon-conditional `__content` wrapper matches the snippet's icon-only rule. No missing options (callouts have no dismissible/list class in core).

### toast.ex — `toast/1`, `toast_container/1`, `push_toast/*` (+ toast.js)
- 🔴 **JS phantom `pa-toast--dismissing`** — hook adds it on exit (toast.js:140) but core's exit class is `pa-toast--hide` (grep: dismissing=0, hide=5). Exit animation never fires. Fix: swap to `pa-toast--hide`.
- 🟠 **client toasts (the recommended `push_toast` path) emit no `pa-toast__icon`** — hook builds no icon chip (toast.js:70-79); snippet always includes the severity chip. Fix: derive glyph from variant in the hook.
- 🟡 **`__progress` supported only in client path**, not server `toast/1` (minor asymmetry). Fix: optional progress attr on `toast/1`.
- ✅ Six logical container positions, close glyph, `__actions` `pa-btn--xs` all aligned.

### flash.ex — `flash/1`, `flash_group/1`, `push_flash/*` (+ flash.js)
- 🟡 **two render paths disagree** — SSR `flash/1` emits `__icon`+`__content` (on-contract, flash.ex:90-91); the `PureAdminFlash` hook (the demo's actual path) drops the icon but keeps `__content` (flash.js:82), producing an off-contract icon-less-but-wrapped alert. Fix: emit the severity icon in flash.js (resolves both).
- ⚪ `pa-link` on markdown links is redundant inside alerts (bare `<a>` auto-styles) — cosmetic.
- ✅ Variant map (error→danger), kinds, close glyph correct.

## SURFACES

### card.ex — `card/1` (+ header/footer/actions/tabs)
- 🔴 **`pa-card--bordered` taught by the demo** — component correctly emits nothing (deprecated no-op), but cards_live.ex:328-353 has a "Bordered Cards" section telling users to use `pa-card--bordered` (grep=0). Fix: rewrite/delete that demo section.
- 🔵 **header-underline theme-color slot forces raw class** — `header_underline_color` only accepts success/warning/danger/info; to get `--underline-color-{1..9}` the demo hand-passes `header_class="pa-card__header--underline-color-1"` (cards_live.ex:418,423; demo even references a nonexistent `headerUnderlineThemeColor` prop). Fix: add `header_underline_theme_color` (1..9).
- 🔵 **footer meta/actions require hand-authored internals** — demo hand-writes `<span class="pa-card__meta">`/`<div class="pa-card__actions">` (cards_live.ex:84-88). Fix: steer footer through `:actions` + a meta affordance.
- 🟡 **`:header` slot bypasses the canonical title contract** — full `:header` dumps verbatim → demo fills with bare `<h3>` (legacy shape core moved away from). Fix: prefer `title_text`/`:title`; reserve `:header` for custom rows.
- ✅ Variant list, ghost, live-state, `--stat`, tabs, `--wrap`, responsive/overflow actions plumbing, canonical title emission all match.

### comparison.ex — `comparison_table/1`, `comparison_row/1`
- 🟠🟡 **`data-label` never emitted → broken mobile stacking** — every value `<td>` needs `data-label` (SCSS renders `content:attr(data-label)` ≤768px; without it a 120px blank label gutter shows). `comparison_row` emits no data-label and has no slot attr for it (comparison.ex:110-114). Fix: add `label`/`data_label` on the `:cell` slot (or auto-derive from column head).
- ✅ 2/3-col, `__label`, `__section` colspan, `__changed`/`--solid`/`__conflict`/`__conflict--solid` composition, `__value`+`__copy` all correct.

### stat.ex — `stat/1`
- ✅ **CLEAN.** default/hero/hero-compact/square variants correct (`pa-stat--hero-compact` single-dash); color modifier correctly gated on `variant=="square"`; `icon_variant` incl. danger; `__value` vs `__number` element-name gotcha handled; prefix/suffix order; fit-mode data-attrs + hook; 5-step sentiment. Minor pre-existing core quirk: non-hero `__change` is unstyled by core CSS (not keen drift).

## OVERLAYS

### modal.ex — `modal/1`, `show_modal/1`, `hide_modal/1`
- 🔵 **`header_variant` is a redundant/leaky knob** — core has one theming axis (root `.pa-modal--{variant}`); keen exposes both `variant` and `header_variant` but collapses them to the same root class (modal.ex:152). "Header-only theming" is a promise core can't keep; the demo leans on it as if real. Fix: drop `header_variant`.
- 🟠 **`variant="primary"` + `is_banded` → unstyled band** — band tokens exist only for success/warning/danger/info (snippet L369,379). No guard. Fix: restrict banded to the 4 band roles.
- 🟡 **header slot emits one `<h3>` per slot entry** — `:for` over the slot risks multiple `.pa-modal__title` (modal.ex:100). Fix: render once.
- ⚪ **no scrollbar-gutter compensation** on show/hide → page shift on open (behavior gap vs modals.html:313-316). Fix: add padding-right / `scrollbar-gutter: stable`.
- ✅ Sizes (md→bare, no phantom `--container--md`), `is_static` suppresses backdrop/ESC/close, `title_icon` (`pa-icon--*`), themed close-button variants all correct. Programmatic `pureAdmin.confirm/alert/prompt` intentionally not ported (JS-imperative; declarative `<.modal>` is the LiveView equivalent).

### tooltip.ex — `tooltip/1`, `popover/1`
- 🟡 **`is_inline` tooltip renders a DOUBLE tooltip** — inline omits `pa-tooltip--floating` so the CSS pseudo is active, but the global delegated listener (tooltip.js:165) still portals a `.pa-tooltip-floating` for any `[data-tooltip]`. Two tooltips stack. Fix: always emit `--floating` (JS portal is keen's canonical path) or skip elements lacking it.
- 🔵 **`is_inline` vs `is_keyword` overlap; `is_inline` is a partial no-op** — only `is_keyword` emits `--keyword`; `is_inline` emits no class (no `pa-tooltip--inline` in core), so the promised dotted underline never appears (demo uses is_inline for API/CSS terms). Fix: collapse to one prop emitting `--keyword`.
- ✅ Positions (top=default no class; bottom/end/start map 1:1), popover structure/sizes/alignment, body-portal alignment-class survival all correct.

### popconfirm.ex — `popconfirm/1`
- 🟠 **base warning icon (no modifier) unreachable** — `__icon` only emitted when `icon_variant != nil` and always paired with `--{variant}`; core supports bare `pa-popconfirm__icon` (SCSS:72-82). Fix: allow `has_icon` / `icon_variant="default"` for the bare icon.
- 🔵 **trigger wrapped in a non-contract inline-block `<div>`** — anchoring workaround (uses inline style, not a phantom class) that can perturb button-group layouts. Fix: consider `display:contents` on the wrapper.
- ⚪ `confirm_value` map only forwards `:id`. Fix: iterate map to multiple `phx-value-*` or document.
- ✅ `__arrow`/`__content`/`__message`/`__actions` structure, always-authored position, `--compact`, danger/warning/info icon variants all correct.

## DATA-LISTS

### table.ex — `table/1`, `table_container/1`, `table_card/1`, `table_item/1`
- 🟠🔵 **`is_responsive` / `is_responsive_grid` are effectively non-functional** — `:col` slot has no `data-label`/`data-grid`/`data-span` path (table.ex:51-56,95); responsive collapses to cards with blank labels, grid can't emit at all. Every working responsive-grid demo hand-authors raw `<table class="pa-table">` (tables_responsive_live.ex:118-122,266-278). Fix: auto-derive `data-label` from `col[:label]`; add row `data-grid` + `:col` `span`→`data-span`.
- 🔵 **no selection API** — row selection (`.pa-table__checkbox-col` + `tr.pa-table__row--selected`) has no component surface; the entire multi-select feature bypasses `.table` with hand-authored internals (table_multi_select_live.ex:228-270). Fix: add `selectable`/`selected` row predicate + checkbox-column affordance.
- 🔴 **demo leaks `pa-table--hover`** (grep=0) — attr correctly dropped from component, but demo markup still writes it (table_multi_select_live.ex:229). Fix: drop from demo.
- 🟠 **`:col` cells can't set colspan/data-*/title** (only `:foot` is a raw escape hatch). Fix: allow a `rest` global on `:col`.
- 🟡 **`table_container` still carries deprecated `--panel` sub-tree** (table.ex:189-217; deprecated rc10). Fix: schedule removal.
- ✅ Sizes, striped/bordered/plain, compact→xs, `table_card` variants/color-N/plain/scrollable/description/actions/footer, `table_item` all clean.

### list.ex — `basic_list/1`, `ordered_list/1`, `definition_list/1`, `list/1`, `list_item/1`
- 🟠 **complex `.pa-list` can't render the semantic `<ul>/<li>` form** core recommends (snippet 194-211) — `list/1`/`list_item/1` hardcode `<div>` (list.ex:138,175). Fix: add `as`/`tag` attr (div default, allow ul+li).
- 🟡 list_item inner_block placed as bare `__item` child (off-contract for edge combo). Fix: route into `__content` or document.
- ✅ basic_list correctly suppresses `--success`; roman/alpha, definition inline, `__meta`-inside-`__content` nesting all match. Dead `pa-list--bordered` correctly documented.

### pager.ex — `pager/1`, `load_more/1`
- 🟡 **pager splits controls into TWO `__controls` groups straddling `__info`** — snippet uses a single `__controls` + trailing `__info` (tables.html:382-394). Changes button grouping/gap semantics. Fix: one `__controls` with all buttons, `__info` trailing (or bless the sandwich deliberately).
- ✅ Alignment (start/center/end), `load_more` (`__button--loading`/`__spinner`/`__text`/`__count`) all match. Icon override is a clean addition.

## LAYOUT / NAV

### layout.ex — navbar/sidebar/footer/main + navmenu, search, profile-btn, notifications, section
- 🔴 **`main/1` wraps content in phantom `.pc-layout__main__inner`** — 0 CSS defs anywhere; snippet puts content directly in `<main class="pc-layout__main">` (layout.html:45-47). Injected on EVERY keen page. Fix: drop the inner div.
- 🔴 **`divider/1` emits `.pa-divider`** — 0 CSS defs in core (no `<hr>` divider class exists). Fix: drop `divider/1` (bare `<hr>` styles via base) or add the rule to core first.
- ✅ Everything else verified against dist: full navbar/navmenu/app-header/page-header/profile-btn/search (all sizes)/sidebar block (+icon-collapse/resizable)/footer/search-results/autocomplete/notifications/section; correct `pc-*` (foundation) vs `pa-*` (component) split; dropped `is_sticky` correctly gone.
- (Note: profile_panel tabs/favorites are hand-authored raw pa-* in app.html.heex:304-352 — belongs to profile.ex below.)

### navigation.ex — `tabs/1`, `tab_item/1`
- ⚪ **`is_border_top` duplicates `style="border-top"`** — two knobs, one variant. Fix: drop the boolean, document `style="border-top"` as the single knob.
- 🟡 **`--collapse` mode requires the label wrapped in `<span>`** — not enforced/documented; demo hand-authors `<span>` (tabs_live.ex:762-777). Fix: warn in `tab_item` docstring (or wrap automatically).
- ✅ All variants/sizes/alignments/overflow modes (pills/boxed/border-top/vertical/sm/lg/centered/full/nowrap/wrap-labels/scrollable/collapse) resolve; fixed-width correctly via minwr/maxwr utilities (retired `--w-{N}x` not reintroduced); scroll buttons wired to keen's own JS.

### splitter.ex — `splitter/1`
- ✅ **CLEAN.** Always emits the blessed N-pane alternating pane/gutter model; per-pane + root data-attrs, `role="separator"`, aria-orientation, `--minimize-mirror` all correct. Legacy 2-pane shorthand correctly not emitted.

## DATA-VIZ

### data_display.ex — fields/field-group/desc-table/prop-card/banded/accent-grid/dot-leaders
- 🟡 **field copy markup inserts a non-canonical wrapper `<span>`** — snippet puts value text directly in `.pa-field__value` then the button (data-display.html:366-374); keen wraps text in an extra span. Codegen-fidelity drift (harmless to layout). Fix: drop the inner wrapper; put `data-copy-value` on the value element.
- ⚪ verify the `data-pa-copy` JS delegator actually toggles `--copied` (else the "Copied!" feedback never appears).
- ✅ accent-grid correctly restricted to the 4 semantic accents (no phantom `--primary`/`--color-N`); desc-table/banded/prop-card/field layouts/field-group/dot-leaders all mapped; `value_variant` correctly excludes nonexistent `--secondary`.

### data_viz.ex — progress/stacked/ring/gauge/data-bar/heatmap/sparkline
- 🟠 **`data_bar` never renders `pa-data-bar__value`** (SCSS:391-396). Fix: add optional `value_text`/slot.
- 🟠 **no `bar_list` component** — full `pa-bar-list` family (SCSS `_data-viz.scss:541-616`) unimplemented in either data_viz or data_display. Fix: add `bar_list`/`bar_list_item`.
- ✅ `--primary` correctly suppressed everywhere (fixes prior "dead --primary"); heatmap correctly restricted to success/danger; gauge structure/zones/`--pa-gauge-size`; stacked `--secondary` all correct.

### code.ex — `code/1`, `code_block/1`
- ✅ **CLEAN.** 7 language accents + sensible aliases; `--numbered` honestly documented; bare-`<pre>` vs headered `.pa-code-block` branching matches snippet; copy button is an intentional de-emoji upgrade keeping `pa-btn__icon`. `copy_text` double-pass is an unavoidable LiveView limitation (documented).

## INTERACTIVE

### command_palette.ex — `command_palette/1` (+ body)
- 🟠 **mobile fullscreen sheet not emittable** — no `__fullscreen-bar`/`__fullscreen-title`/`__close` markup (snippet 33-38); mobile users get no close button. Fix: emit the fullscreen-bar row (hidden until `--fullscreen`).
- 🟡 **token pills lack `__remove` dismiss button** — selection badges render label only (command-palette.ex:210-219 vs snippet 192-201). Fix: add `pa-badge__remove` wired to a remove event.
- 🟡 `__section` inline divider unused for search/paginated results (optional). 
- ✅ Shell/item/home/empty/loader/pagination/context/size-presets all match; data-* are JS-hook contracts.

### profile.ex — `profile_panel/1`
- 🟠 **no favorites render-form** — full `__favorites`/`__favorite-item`/`__favorite-icon`/`__favorite-label`/`__favorite-remove`/`__favorites-add` subtree (snippet 248-275) unexposed; consumer hand-authors the whole DOM. Fix: add a `<:favorite>` list slot.
- 🔵 **tabs force hand-authored `pa-tabs` internals + `data-profile-tab` wiring** (snippet 216-245; demo app.html.heex:304-313). Fix: structured `<:tab label icon>` slot that emits the tab shape and pairs panels.
- ⚪ `actions` slot self-deprecated but `__actions` is still a valid core placement distinct from `__footer`. Fix: keep one, document the distinction.
- ✅ header/info/close/avatar/`--no-avatar`/`--icon-only` tabs/nav/role-badge/masked-icon primitives correct.

### settings_panel.ex — `settings_panel/1`
- ✅ **CLEAN.** Every element maps to defined SCSS; `--open` toggled by JS; data-* are the JS-hook API; single-call component, no consumer-authored internals.

### loader.ex — `spinner/1`, `loader/1`, `loader_center/1`, `loader_overlay/1`
- 🔴 **loader `color` emits phantom `--pc-{success,danger,warning,info}-bg` tokens** — none exist (core uses `--pa-*-bg`); with no fallback, `color:` is invalid → loaders render grey. LIVE in loaders_live.ex:140-162. Fix: change `color_style/1` to `var(--pa-#{color}-bg)`.
- ✅ Loader types/`--lg`/spinner/`--xs`/center/overlay all match; inline-`color` architecture correct — only the token prefix is wrong.

### badge.ex — `badge/1`, `label/1`, `composite_badge/1`, `badge_group/1`
- 🔴 **badge_group forces `--show-all` then re-hides via injected `<style>` keyed on undefined `pa-badge-group--expanded`** — fights core's native nth-child hiding instead of using it (badge.ex:290-291,328-345; grep expanded=0). Fix: don't force `--show-all` when `limit != nil`; toggle only the expanded override.
- 🟠 **composite_badge missing `icon_variant`** — core defines `--icon-{v}` for all 8 (SCSS:85-88); keen exposes label/button variant but not icon. Fix: add `icon_variant`.
- ⚪ `is_interactive` correctly inert+documented; `--btn-danger` DOES exist (the stale "no --btn-danger" lore is in the core snippet, not keen).
- ✅ badge (all variants/sizes/`--pill`/`--ellipsis-start`/`--color-1..9`/`__icon`), label (correctly excludes light/dark), composite base structure all clean.

## KPI SUITE

**Systemic across all 8 card-shaped KPI wrappers:**
- 🟡 **bare `<h3>` header instead of `.pa-card__title > .pa-card__title-text`** — legacy shape (renders browser-bold 700 vs intended semibold 600); affects kpi_terminal/bento/editorial/gauge_list/hero/sparkline_list/strip. Fix: one shared header helper emitting the title wrapper.
- 🔵 **`__chart-svg` inner wrapper leaks to the consumer in hero + bento** — required fixed-height Y-distortion guard must be hand-authored in the `:chart` slot (proven by both demos: kpi_bento_live.ex:16, kpi_hero_supporting_live.ex:49,98,131). sparkline_list shows the correct no-extra-wrapper pattern. Fix: emit `__chart-svg` in kpi_hero_main + kpi_bento_tile.

**Per-file:**
- kpi.ex — 🟠 `kpi_sparkline` hardcodes `.pa-kpi-tile__spark`, unusable in spark-list/hero/bento. ✅ tile/sentiment/status/detail otherwise correct.
- kpi_editorial.ex — 🟡 `<em>tgt</em>` diverges from the snippet's plain-text `tgt {value}` (em rule exists so not phantom; pick one shape). ✅ grids/deltas correct.
- kpi_strip.ex — 🟢 **prior phantom FIXED** (maps to blessed `--prev`/`--delta`/`--target`, no `--metric`/`--now`; `--num` correct). ✅ composable toggles/bars.
- kpi_detail.ex — ✅ CLEAN.
- kpi_terminal / kpi_bento / kpi_gauge_list / kpi_hero / kpi_sparkline_list — ✅ clean aside from the two systemic items above (no phantoms remain; all interpolated modifiers resolve).

## DOCUMENTS / MISC

### document.ex — `document/1`, `document_section/1`
- ✅ **CLEAN.** `--manual/--compact/--spacious/--flush`, depth-driven h2–h6, `pa-document__number`/`__text`, mid-chapter content all match snippet 1:1.

### sheet.ex — `sheet/1` + region components
- 🟠 **no `__barcode` / `__qr` / `__qr-label` slot components** (snippet 229-240; all styled in dist). Consumer hand-authors the divs. Fix: add `sheet_barcode/1` + `sheet_qr/1` (with `label`).
- 🟡 **masthead can't put doctitle as a direct child / rich title markup** — string attrs only; snippet's bare-`<h1>` form + status-badge-beside-title unreachable. Fix: optional `:title` slot.
- ✅ All 8 modifiers, party boxed/strong, meta/totals/total-row-grand/totals-start, title/legal/pageno, print button (hook + data-print-omit/target) all verified; line items composed as raw `pa-table` per the "compose don't reinvent" contract.

### timeline.ex — `timeline/1`, `timeline_item/1`
- ⚪ **`:meta` slot is a dead/redundant hook** — renders a plain `<p>` (no `__meta` in core); implies a concept core lacks. Fix: drop it or document as "extra paragraph."
- 🔵 scroll/load-more utility wrappers hand-authored raw in feed demo (timeline_feed_live.ex:146,162). Low-pri. Fix: optional `timeline_scroll/1`+`timeline_load_more/1`.
- ✅ **phantom-avoidance verified** (bare `<h3>`/`<p>`, `__title`/`__meta`=0); all variants/layout-modifiers/colors/`--filled`/date-header/avatar/comment correct.

### filter_card.ex — `filter_card/1`
- 🟡 **toggle button placed FIRST in `__actions`; snippet places it LAST** (filter_card.ex:83-92 vs filter-card.html:53-63). Fix: move toggle to end.
- 🟠 **`__advanced` DOM-removed when collapsed** instead of the blessed `hidden`-attr toggle (a11y/form-state; filter-card.html:95). Fix: always render with `hidden={!@is_expanded}`.
- ⚪ `is_loading` docstring overclaims "spins refresh" (core `--loading` is opacity only). Fix: correct doc.
- ✅ `--loading`/`--disabled`, row/filters/actions/advanced nesting, icon-only buttons, phx wiring, `:actions` slot all correct.

## PRIMITIVES

### typography.ex — `heading/1`, `paragraph/1`, `text/1`, `pa_link/1`
- ⚪ **`text` `values:` list advertises fallback names; `text-secondary` doesn't exist** (grep=0) — not live (secondary is special-cased to `pa-text--secondary`), but the fallback branch would emit a phantom for theme-slot names. Fix: trim the values list / document fallback scope.
- 🔵 **`pa_link` @doc example uses nonexistent `text-secondary`** — copying it gives a no-op. Fix: use `text-color-2` (the real muted slot).
- ✅ headings unclassed, `muted→pa-text--secondary` etc. all map to real classes; no invented `pa-text--muted/success/...`.

### grid.ex — `row/1`, `column/1`, `grid/1`
- 🟠 **no responsive offset prop** — core has `pc-offset-{bp}-{size}` (grid.html:314); `column/1` only emits scalar `pc-offset-N`. Fix: add `offset_sm/md/lg/xl`.
- ✅ All classes resolve, correct `pc-` prefix, auto-equal `pc-col` default, `pc-grid*`/span classes correct.

### responsive.ex — `breakpoint_container/1`, `breaker/1`
- 🔵 **the fit-to-size engine has NO keen wrapper** — the framework's primary responsive-degradation system; both demos hand-author raw `data-pc-fit`/`-priority`/`-step`/`-ignore`/`-target` + `class="pc-fit-hidden"` (fit_to_size_live.ex:144-154; responsivity_live.ex:39-50,231-242). Largest ergonomics defect in the group. Fix: add `fit_bar/1` (container hook + `data-pc-fit-auto`/`-default-priority`) + `fit_slot/1` (mode/priority/target/step).
- 🔵 **breakpoint_container/breaker bypassed even in the demo** — responsivity_live.ex:73-77 hand-writes `phx-hook`/`data-pc-show` instead. Signals under-scoped wrappers (no relocate sink). Fix: exercise + extend the wrappers.
- ✅ Container-breakpoint wrapper itself is faithful (data-pc-breakpoints JSON, initial/unit/mode, FOUC style, `data-pc-show`).

### icon.ex / faicon.ex / heroicon.ex
- 🔵 **no component renders the masked `pa-icon` primitive** — core's OWN icon system (the theme-swappable, provider-agnostic glyph) is unreachable via the icon API; it's hand-authored ~20+ times across keen components + JS. Consumers wanting the blessed close/chevron/search glyph must hand-write `<span class="pa-icon pa-icon--x" aria-hidden>`. Fix: add `pa_icon/1` (glyph from the shipped modifier set, optional size, auto aria-hidden).
- 🟠 **icons_live.ex demos zero `pa-icon` primitives** (grep=0) — the core-styled icon system is absent from the icon showcase. Fix: demo it once the component exists.
- 🟡 **`icon`/`faicon` render a bare `color=` attr on `<i>`** — not a valid HTML attribute; `color="red"` silently does nothing. Fix: fold into inline `style`.
- ⚪ `faicon` `fill`/`stroke` attrs are never rendered (no-op). Fix: drop or keep doc note.
- ✅ heroicon inline-SVG structure/currentColor/size/placeholder sound.
