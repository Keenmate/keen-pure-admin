# Changelog

## [Unreleased]

### Added

### Changed

### Fixed

## [2.0.0-rc.1] - 2026-10-09 [PUBLISHED]

Full sync to `@keenmate/pure-admin-core@^3.3.0-rc06` (was `^2.9.0-rc18`) — a **major**
bump mirroring core's 2.x → 3.x cut. Themes must be rebuilt at 3.3.0-rc06 and reinstalled
via `npx @keenmate/pureadmin themes install`.

**BREAKING — foundation/component token ownership split (`--pc-*` vs `--pa-*`).**
The app-shell classes (`pa-row`/`pa-col*`/`pa-mode-*` → `pc-*`) and the **foundation**
runtime tokens (surfaces, text, accent, links, radius, transitions, the `--pc-color-1..9`
palette, navbar/sidebar/footer shell) are `--pc-*`. **Component** tokens are `--pa-*`
(buttons, cards, modals, tables, badges, KPI, command palette, splitter, range, gauge,
chart, detail-panel, icons…). `--base-*` is unchanged. Apps migrate their own overrides
accordingly (shell/foundation → `--pc-`, components → `--pa-`).

### Added — server-driven dialogs (`PureAdmin.Dialog`)

- **New `PureAdmin.Dialog` module** — open a modal dialog **from the server** in a
  LiveView and receive the answer as an ordinary `handle_event`. Built on the
  declarative `modal/1` (server-rendered — no JS bridge, no promise shuttled back),
  complementing the client-only `window.PureAdmin.confirm/alert/prompt` JS API that a
  server process can't call directly. Setup once: add `{PureAdmin.Dialog, :default}`
  to your `live_session`'s `on_mount` and mount `<PureAdmin.Dialog.host dialog={@pa_dialog} />`
  in your layout.
  - **Standard dialogs** — `confirm/2` (cancel + confirm) and `info/success/warning/error`
    alerts. Each button names the event (+ optional `phx-value` payload) the consumer
    handles, and the dialog auto-closes. Options: `variant`, plain-vs-`banded`,
    `position` (`:center`/`:top`), `size`, `dismissible` (`false` = forced choice —
    no ✕, backdrop, or Escape dismiss), and `on_dismiss` (the ✕/backdrop/Escape
    dismissal fires this event too, so a dismiss is never silent — e.g. to toast
    or treat it as cancel).
  - **Custom / form dialogs** — `open/3` stashes a keyed spec so you render your own
    `<.modal>` with a full LiveView form (`phx-change`/`phx-submit`); `close/1` dismisses
    either kind.
  - Demo: Surfaces → Modal Dialogs → "Server-Initiated Dialog".
- **Client dialog service (`assets/js/modal_dialogs.js`, `window.PureAdmin.confirm/alert/prompt/custom`)
  gains an `isBanded` option** — banded programmatic dialogs, matching core's
  `modal-dialogs.js` and svelte's `dialogService` (all three share the key).

### Fixed — command palette

- **Leading-key command shortcuts (`g <letter>`)** now open a command, e.g. `g g` → Go
  to Page — matching the pure-admin demo and svelte. This replaces the old `Alt+<letter>`
  hotkeys, which were unusable on macOS (Option+letter is a text-composition modifier:
  Option+G types `©`). The `PureAdminCommandPalette` hook arms on a modifier-free `g`
  (only when not typing and the palette is closed) and pushes the resolved key as
  `cp:hotkey`; the demo source's hotkeys move to `g d` / `g a` / `g g` / `g t`. Home
  keycap hints split on whitespace **or** `+`.
- **The idle "home" screen is now keyboard-navigable.** `↑ ↓` traverse the commands +
  contexts (first pre-selected via `cp_active_index: 0`) and `Enter`/`cp:select` enters
  the highlighted one — previously `cp:navigate` only walked `cp_results`, which is empty
  on the home screen, so arrows did nothing there.
- **`PgUp`/`PgDn` (jump a page of 8) and `Home`/`End` (first/last item)** added to the
  list navigation (`cp:navigate` gains `page_up`/`page_down`/`home`/`end` directions).
- **Palette item icons render through the real icon path, not unicode.**
  `PureAdmin.Components.CommandPalette` now routes an item's `:icon` through a dispatcher
  (mirroring the sidebar's `sidebar_icon_span`): raw inline SVG is rendered raw, an
  icon-provider / Font Awesome / affordance NAME goes through `<.icon>`, and a plain
  emoji still renders as text. The demo's Go-to-Page list now uses the SAME
  `DemoWeb.SidebarIcons.sidebar_icon/1` glyphs the sidebar uses (+ a section-name
  subtitle), instead of hardcoded emoji.

### Typography — flat `text-*` consolidation

- **`paragraph/1` and `text/1` now emit the flat `text-*` utilities** instead of the
  removed `.pa-text` BEM component (core dropped `.pa-text` entirely). The muted
  colour is `text-secondary` (`color="secondary"` / `variant="secondary"`), matching
  the component `--secondary` role vocabulary. `paragraph`'s `size` prop maps
  **directly** to the same-named utility (`sm`→`text-sm`=14, `lg`→`text-lg`=18, …) and
  **no `size` renders a plain `<p>` at the body default (16px)** — so a default
  paragraph matches a bare `<p>` and the reference. `align`/`semantic` →
  `text-{start,center,end}` / `text-{caption,lead}`.
- **New Typography showcase** (`/components/typography`, Design → Typography) —
  rebuilt entirely from the typography components (Headings, Paragraph sizes/colours/
  alignment/semantic, inline `text/1` variants, links, class reference), mirroring the
  pure-admin reference and the svelte docs page.
- Swept the demo's remaining raw `pa-text--secondary` / dead `pa-text-secondary`
  usages to `text-secondary` (component props where the element is a paragraph/text).

### Forms — alignment with svelte-pure-admin

Aligned the form components' prop vocabulary with `svelte-pure-admin` (the more
mature of the two wrappers) so the same concept has the same name across stacks.
keen stays snake_case — the faithful translation of svelte's camelCase.

- **Canonical validation-state prop is now `state`** (was `validation`) on `input/1`,
  `select/1`, `textarea/1`, and `form_group/1` — matching svelte's `state`.
- **Canonical theme-colour prop is now `theme_color`** (was `color`, now accepts an
  integer or string) on `input/1`, `select/1`, `textarea/1`, and `form_help/1` —
  matching svelte's `themeColor` and keen's own `alert/1`.
- **Canonical label-text prop is now `label_text`** (was `label`) on `checkbox/1` and
  `radio/1` — matching svelte's `labelText`.
- The old `validation` / `color` / `label` props are kept as **deprecated aliases**
  (coalesced old→new) so existing markup keeps rendering; new markup should use the
  canonical names.
- **Accessibility:** `input/1`, `select/1`, `textarea/1` now emit `aria-invalid="true"`
  in the error state, and gained a `touched` attr (default `true`) that suppresses the
  error state + inline help when `false` — mirroring svelte's `touched` gate. The
  `:field` path derives `touched` from `used_input?/1`.
- **New `form_field/1` orchestrator** — `form_group` + label + control + help/error/
  success text with automatic state derivation and `:let`-forwarded `%{errors, touched,
  state}`; accepts a Phoenix `:field`. Mirrors svelte's `<FormField>`.
- **New `form_error_summary/1`** — a danger alert with an error count and anchor links
  to each field (`%{field:, id:, message:}`). Mirrors svelte's `<FormErrorSummary>`.
- **`input/1` split into typed components** mirroring svelte's six input components.
  `input/1` is now **text-like only** (`text`/`email`/`password`/`tel`/`url`/`search`);
  the other HTML input types moved to dedicated components — **`number_input/1`,
  `date_input/1`, `color_input/1`, `file_input/1`, `range_input/1`** — each declaring
  only the native attrs relevant to its type (`min`/`max`/`step`, `accept`/`multiple`/
  `capture`, …) instead of `input/1` carrying the union of all of them through one
  `:global` rest. A shared private `pa_input_classes/4` keeps the `.pa-input` modifier
  logic in one place. (This is a **breaking** narrowing of `input/1` — `type="number"`
  etc. is no longer accepted; use the typed component.)
- Demo: swept form-control call-sites to the canonical names, migrated every
  non-text `<.input type="…">` to its typed component, and rebuilt the validations
  page's "Combined (Recommended)" section from `<.form_error_summary>` + `<.form_field>`.

### Demo — Spanish localization (i18n)

- **The demo now ships English + Spanish, switchable at runtime.** Added Phoenix **Gettext**
  to the demo and bridged the library chrome into it: `config :keen_pure_admin, translate:
  &DemoWeb.PaTranslate.translate/2` forwards every `PureAdmin.Translations.t/2` key to the
  `pure_admin` Gettext domain, falling back to keen's built-in English defaults on a miss.
  One locale drives both the demo's own content (`default` domain) and the library chrome.
  This is the intended integration for `PureAdmin.Translations` — the callback is the seam a
  host's Gettext (or DB translation table) plugs into; keen and Gettext share `%{param}`
  interpolation, so the bridge is a pass-through.
- **Locale state + redirect switcher.** New `DemoWeb.Locale` plug resolves session →
  `Accept-Language` → default and persists it; a `GET /locale/:code` controller
  (`DemoWeb.LocaleController`) writes the session and redirects back (LiveView can't write the
  Plug session — the full round-trip re-mounts every LiveView, and the layout-mounted command
  palette, at the new locale). `DemoWeb.Nav.on_mount` re-applies the locale in the socket.
  Language picker (EN | ES) in the navbar.
- **UI labels localized across the whole demo** — nav, sidebar, buttons, placeholders, table
  headers, KPI/stat labels, statuses, and the command-palette commands/contexts (~1,850
  message ids). Documentation prose and demo data are intentionally left as-is.
  `DemoWeb.CommandPaletteSource` `commands/0`/`contexts/0` were moved from module attributes
  to functions so their strings translate per request — a module attribute would freeze the
  locale at compile time.

### Sync to pure-admin-core 3.0.0 → 3.3.0-rc06

**Peer-dep floor raised to `^3.3.0-rc06`** (from `^3.3.0-rc03`) in `package.json`; the
wrapper markup is unchanged across rc04–rc06. Rebuild and reinstall themes at 3.3.0-rc06
(`npx @keenmate/pureadmin themes install`).

**Corrected the component-token prefix (core rc20 ownership split).** An earlier pass
over-migrated component tokens to `--pc-*`; core rc20 renamed them back to `--pa-*`
(only the foundation stayed `--pc-*`). Every component token keen emits — command palette,
splitter, gauge, KPI, chart-trendline, detail-panel, range — was flipped `--pc-*` → `--pa-*`
so those runtime overrides resolve again (they had become silent no-ops).

#### Added

- **`pa-document` — Word-style hierarchical numbered sections.** New `document/1`,
  `document_section/1`, `document_text/1`. Outline numbers (`1`, `1.1`, `1.1.1` …) are
  generated by CSS counters (nest sections to sub-number); `is_manual` for author-written
  numbers (`number` per section), `density` and `is_flush` modifiers. Demo at
  `/components/document`.
- **`pa-sheet` — printable A4 document shell** for invoices, orders, quotes, receipts and
  delivery notes. New `sheet/1` container (modifiers `density` / `is_framed` / `is_fluid` /
  `is_fill` / `is_landscape` / `print_mode`) plus the full region set: `sheet_masthead/1`
  (+ `sheet_logo/1`), `sheet_parties/1` + `sheet_party/1`, `sheet_meta/1` +
  `sheet_meta_row/1`, `sheet_title/1`, `sheet_totals/1` + `sheet_total_row/1`,
  `sheet_notes/1`, and `sheet_footer/1` + `sheet_signatures/1` + `sheet_sign/1` +
  `sheet_legal/1` + `sheet_pageno/1`. Demo at `/components/sheet`.
- **Single-element printing.** Vendored `sheet_print_core.js` registers
  `pureAdmin.printElement` / `printSheet` (clones one element into an isolated iframe;
  rc03 orientation-aware for landscape sheets; strips `[data-print-omit]` / `.pa-print-hide`).
  New `PureAdminSheetPrint` hook + `sheet_print_button/1` convenience (LiveView-idiomatic
  trigger, carries `data-print-omit`).
- **`pc_grid/1` + `pc_grid_cell/1` — CSS-Grid layout primitive** (`pc-grid`,
  `--cols-N` / `--flush` / `--ruled`; cells span via `pc-col-span-N` / `pc-row-span-N`).
  A companion to the flex `grid`/`column`, for dense ruled forms (prints reliably).
- **`table_item/1` two-line cell** (`pa-table__item-title` + optional `pa-table__item-desc`)
  and **`is_plain`** on `table/1` (`pa-table--plain`, neutral ruled table for paper forms).
- **`modal/1` `title_icon`** — optional leading masked severity glyph in `.pa-modal__title`.
- **Stateful, extensible command palette — `PureAdmin.CommandPalette` LiveComponent +
  `PureAdmin.CommandPalette.Source` behaviour.** The reusable interaction state machine
  (modes `/command` · `:context` · global, the multi-step wizard, pagination, keyboard nav,
  inline/token display, open/close, global `Ctrl+K`/`⌘K`) now ships as a LiveComponent you
  mount **once in your layout**. Per-project behaviour — commands, contexts, step options,
  search and selection actions — is injected via a `use PureAdmin.CommandPalette.Source`
  module (`commands/0`, `contexts/0`, `step_options/4`, `search/2`, `on_select/1`,
  `on_complete/2`, all overridable). Side-effecting actions are declarative return values
  the component executes (`{:navigate, path}`, `{:patch, path}`, `{:toast, …}`, `:close`),
  so the palette can live globally without every LiveView needing matching handlers. Drive
  it from a parent via `send_update/2` (`open_with:` / `display:`). The presentational
  `PureAdmin.Components.CommandPalette.command_palette/1` remains for plain-LiveView hosts;
  its shared inner markup is now `command_palette_body/1`.

#### Changed

- **Masked-icon sweep (core 3.1.0 / 3.2.0).** Structural affordance & severity icons now
  render the masked `.pa-icon--*` family instead of Font Awesome / emoji: navbar search,
  notifications bell, profile-button user, settings-panel cog, split-button chevron (empty
  canonical span), filter-card toggle chevron + refresh, tab scroll arrows, range-group
  caret, flash severity, and icon-only copy buttons (`pa-field__copy`,
  `pa-comparison-table__copy`). Programmatic dialogs (`modal_dialogs.js`) show the severity
  glyph in the generated title.
- **Vendored `overflow.js`** — the injected "more" trigger now uses the masked
  `.pa-icon--ellipsis-vertical` glyph (keen's `destroy()` + `moveToRoot` guard deviations
  preserved).
- **Demo sidebar re-synced to pure-admin's information architecture.** The demo nav is
  regrouped into functional sections (Design · Layout & responsivity · Forms & inputs ·
  Buttons & actions · Surfaces · Data display · Data visualization · Feedback · Interactive
  & misc · Virtual Scroll) with nested Tables / KPI / Timeline submenus, matching
  `demo/views/partials/sidebar.mustache`. Glyphs are now **inline Lucide outline SVGs**
  (via the new `DemoWeb.SidebarIcons`) instead of Font Awesome classes. Items with no keen
  route are omitted; keen-only pages (Phoenix/LiveView, Stats, Typography, Layouts,
  Container Breakpoint, Responsive Form, Combined KPI dashboard, Advanced timeline) are
  folded into the closest group so nothing is orphaned.
- **`sidebar_item` / `sidebar_submenu` gained inline-SVG icon support + the icon-hover
  marker.** The `icon` attr now accepts raw SVG markup (rendered verbatim) in addition to
  `<.icon>` names, and the `.pc-sidebar__icon` span always carries `pc-icon-hover-highlight`
  so glyphs recolour on hover under the foundation rule (pure-css ≥1.1.1). Requires themes
  rebuilt at that foundation for the hover effect to paint; markup is correct regardless.
- **Profile panel migrated off Font Awesome to Lucide, matching pure-admin's demo.** The
  demo profile panel now renders inline Lucide SVGs for the nav (user / lock / bell /
  settings / help) and favorites (dashboard / forms) via `DemoWeb.SidebarIcons` (four new
  keys added), with tabs, close, and favorite-remove on the masked `.pa-icon--*` family and
  the footer buttons de-iconed — so keen and pure-admin's profile panels are visually
  identical. `profile_nav_item` gained the same raw-inline-SVG `icon` support as the sidebar
  items, and the library's default avatar glyph is now the masked `.pa-icon--user` instead
  of `<i class="fa-solid fa-user">`.

#### Fixed

- **Markup-fidelity sweep #12 — KPI fragment family (terminal + per-tile/row sub-components)
  corrected against core.** Extends the harness below the KPI showcase *containers* (swept in
  #9/#10) down to the terminal chrome and every deferred per-tile / per-row sub-component:
  `kpi_terminal`, the base `kpi_tile` / `kpi_detail` / `kpi_sparkline` primitives, and the
  design tiles/rows `kpi_bento_tile` / `kpi_editorial_tile` / `kpi_strip_row` /
  `kpi_sparkline_row` / `kpi_hero_main` / `kpi_hero_side` / `kpi_gauge`. Real keen markup fixes:
  - **kpi_terminal:** `build_classes("pa-card", ["pa-kpi-terminal"], …)` passed the namespace as a
    bare-string "modifier", which `build_classes/3` silently drops (keeps only `{class, true}`
    tuples) → the `pa-kpi-terminal` class never rendered; folded into the base. The header title
    was a bare `<h3>` → now the canonical `.pa-card__title > h3.pa-card__title-text` shape. Tab
    `aria-selected={bool}` rendered as a bare/omitted HEEx boolean attr → `to_string/1` so it emits
    explicit `"true"`/`"false"` (matches the snippet).
  - **kpi_gauge:** the `__bar` inlined `style={bar_style(nil, nil)}` → HEEx renders `style={nil}` as
    an empty `style=""` artifact; routed through conditional attrs (the same guard the gauge-list
    grid already uses).
  `kpi_tile` / `kpi_detail` / `kpi_sparkline` and the bento/editorial/strip/sparkline-row tiles were
  already core-faithful (tuple-guarded modifiers, no phantom defaults, no `style=""`) — locked with
  regression tests anyway. `kpi_terminal` is **capability-only** on the svelte side (its svelte
  counterpart is dumper-blocked by an init-time `setContext`); `kpi_sparkline` is **keen-only** (the
  svelte chart slot takes any SVG). Locked by new `kpi_test.exs` + `kpi_terminal_test.exs` and
  extended bento/editorial/strip/sparkline-list/gauge-list/hero test files (419 keen tests +
  16 doctests, 0 failures).
- **Fidelity tooling #12 (dev-only).** Added `fidelity/*.map.json` capability maps for all 11 KPI
  fragment components + the matching `mix pa.fidelity.dump` clauses (+ `Kpi` / `KpiTerminal` aliases
  and a bespoke `kpi-terminal` render clause that feeds attributed `:pane` demo slots so the
  tabs/tab/pane markup renders). The core container fixtures now fixture-ref these fragments (their
  per-tile/row `__*` classes are verified against the fragment goldens instead of acknowledged prose).
- **Markup-fidelity sweep #11 (FINISH) — form family, shell, typography, grid, list/loader/data-viz
  variants, and misc singletons corrected against core.** The closing sweep brings every remaining
  both-wrapper component into the harness (41 components across form/layout/typography/grid/loader/
  data_viz/list/button/badge/code/pager/table/tooltip/responsive). Real keen markup fixes:
  - **checkbox:** always emitted a phantom `data-indeterminate="false"` → now only `="true"` when set.
  - **form-group:** `is_required` was a dead no-op → now emits the live `pa-form-group--required`
    escape-hatch class (matches core + svelte).
  - **divider:** emitted a phantom `pa-divider` base class (absent from main.css/snippets/themes) →
    now a bare `<hr>` (class via passthrough only).
  - **profile-button:** `aria-label="User profile"` → `"User Profile"` (oracle casing).
  - **typography `text/1`:** emitted the wrong base (`pa-text` paragraph component) + off-canonical
    variant mapping → rewritten to the canonical inline coloured span (`text-{variant}`, class-less
    when none). `paragraph/1` brought to parity (size/color/align/semantic modifiers + base `pa-text`).
  - **grid:** `valign` gained the missing `stretch` → `pc-row--stretch`; **column:** `col_classes`
    leaked a literal `"false"` token into the class string when a flex modifier was off → filtered.
  - **load-more:** the loading button lacked the native `disabled` attr → added.
  - **progress-group:** added an `inner_block` bar-override slot (auto-bar preserved as fallback) so
    the composed shape reconciles with the slot-based svelte wrapper.
  Locked by new/extended unit tests across form/layout/typography/grid/loader/data_viz/list/pager
  test files (317 keen component tests total, 0 failures). Several components are **capability-only**
  where the two wrappers' pre-JS SSR shells diverge by design (notifications, split-button, popover,
  breakpoint-container, nav-menu `collapse` — keen inline/LiveView-hook'd + generated ids vs svelte
  client-portaled/`onMount`-configured); their class contracts are asserted via the maps.
- **Fidelity tooling #11 (dev-only).** Added `fidelity/*.map.json` capability maps for all 41
  finish-sweep components + the matching `mix pa.fidelity.dump` clauses (+ `Typography`/`Grid`/
  `Responsive` aliases). This completes both-wrapper markup-fidelity coverage; the only components
  left uncovered are single-wrapper (comparison, document, bar-list, detail-panel), the experimental
  sheet, candidacy-uncertain file-selector/search-results, provider-bridge icon, and `kpi_terminal`
  (its svelte counterpart is dumper-blocked by an init-time `setContext`).
- **Markup-fidelity sweep #10 — KPI gauge-list / hero corrected against core.** Same cross-repo
  harness, closing out the KPI namespace/title bug class flagged in sweep #9. Both `kpi_gauge_list/1`
  and `kpi_hero_list/1` had the **silently-dropped namespace class** (`pa-kpi-gauge-list` /
  `pa-kpi-hero-list` passed as a bare string into `build_classes/3`'s tuple-only modifier list →
  never rendered); both had the **bare `<h3>` title** instead of the canonical `pa-card__title` >
  `h3.pa-card__title-text`; `kpi_gauge_list/1` additionally had the **`style=""` artifact** on its
  grid when the cell-min width was nil. All fixed and locked by new unit tests (kpi_gauge_list ×7,
  kpi_hero ×4). (The third KPI module flagged in #9, `kpi_terminal`, is not yet swept — its svelte
  counterpart is dumper-blocked, so it's deferred to a dedicated pass.)
- **Fidelity tooling #10 (dev-only).** Added `fidelity/*.map.json` capability maps for
  navbar / sidebar / footer / tabs / kpi-gauge-list / kpi-hero and the matching
  `mix pa.fidelity.dump` clauses (+ `Navigation`/`KpiGaugeList`/`KpiHero` aliases; `Layout` already
  aliased). **App-shell coverage begins:** footer (`pc-layout__footer` + `pc-footer` sections) is a
  full 2/2 strict compare; navbar (`pc-navbar`) and sidebar (`pc-layout__sidebar`) land
  capability-only — their roots carry a `phx-hook` + a driver/generated `id` (NavFit, sidebar
  toggle/resize anchors) that the svelte wrappers attach at runtime, so the pre-JS SSR shells can't
  share a golden; their class contracts are asserted via the maps. tabs (`pa-tabs`, 12 modifiers;
  the JS scrollable scaffold deferred to cssStateElements) is a full 14/14 strict compare — no keen
  change needed. kpi-gauge-list 15/15, kpi-hero 9/9. All 0 capability hard failures both wrappers.
- **Markup-fidelity sweep #9 — KPI showcases (bento / editorial / strip / sparkline-list)
  corrected against core.** Same cross-repo harness. Three recurring bugs across the KPI
  container components: (1) the showcase namespace class (`pa-kpi-bento` / `pa-kpi-edit`) was
  passed as a bare string into `build_classes/3`'s modifier list, which only keeps `{class, true}`
  tuples — so the namespace class was **silently dropped and never rendered** (fixed in kpi_bento
  + kpi_editorial by folding it into the base class). (2) A `style=""` artifact when the optional
  density/row-height style was nil (HEEx renders `style={nil}` as an empty attribute) — folded into
  `:rest` only when present (kpi_bento + kpi_editorial). (3) The header title rendered a bare `<h3>`
  instead of the canonical `pa-card__title` > `h3.pa-card__title-text` card-header shape (fixed in
  all four: kpi_bento / kpi_editorial / kpi_strip / kpi_sparkline_list). Locked by new/extended
  unit tests (kpi_bento ×6, kpi_editorial ×5, kpi_strip ×3, kpi_sparkline_list ×3). NOTE: the same
  dropped-namespace-class pattern likely remains in `kpi_gauge_list` / `kpi_hero` / `kpi_terminal`
  (not touched this sweep — flagged for a follow-up).
- **Fidelity tooling #9 (dev-only).** Added `fidelity/*.map.json` capability maps for
  input / kpi-bento / kpi-strip / kpi-editorial / kpi-sparkline-list and the matching
  `mix pa.fidelity.dump` clauses (+ `Form`/`KpiBento`/`KpiStrip`/`KpiEditorial`/`KpiSparklineList`
  aliases). input (flat `pa-input`: size/state/theme-color modifiers + native type/placeholder/
  disabled/… attrs; field-wrapper chrome deferred) is a full 31/31 compare; the four KPI showcases
  are container contracts (the per-KPI tile/row blocks come from separate sub-components through a
  text-only slot → deferred as prose), covering the card chrome + grid/layout modifiers each
  container emits inline. input needed no keen change (already core-faithful). kpi-bento 9/9,
  kpi-strip 10/10, kpi-editorial 15/15, kpi-sparkline-list 10/10 — all 0 capability hard failures.
- **Markup-fidelity sweep #8 — profile aria-label corrected against core.** Same cross-repo
  harness. `profile_panel/1`'s close button carried `aria-label="Close profile"` (lowercase),
  diverging from the oracle snippet and the svelte wrapper, which use Title-Case
  `"Close Profile"`. Corrected and locked by a new `test/keen_pure_admin/components/profile_test.exs`
  (11 tests). `table_card/1` and `command_palette/1` needed no keen markup change (already
  core-faithful — both emit only real, SCSS-blessed classes).
- **Fidelity tooling #8 (dev-only).** Added `fidelity/*.map.json` capability maps for
  table-card / command-palette / profile and the matching `mix pa.fidelity.dump` clauses
  (+ `CommandPalette`/`Profile` aliases; `Table` already aliased). table-card (in-scope card
  chrome header/body/footer; the inner `<table>` is a deferred slot region) 15/15 and profile
  (`pa-profile-panel`; inline header avatar/name/email in scope, nav/favorites item classes
  deferred, `--open` is cssStateClasses) 8/8 are full compares. command-palette is capability-only
  — its pre-JS SSR shells are irreconcilable by design (keen stamps a driver `id` +
  `data-mode`/`data-display`/`data-locked-length` and always renders the context/home/tokens
  regions; svelte emits a bare reactive `<div>`), so no shared full-tree golden exists; its class
  contract (5 modifiers + 31 `__*` elements, split across cssStateClasses / cssStateElements /
  deferred) is asserted via the maps. All 0 capability hard failures both wrappers.
- **Markup-fidelity sweep #7 — table / section / sparkline / range-group corrected against core.**
  Same cross-repo harness, four real markup fixes. (1) `table/1` was data-driven only (required
  `rows` + `:col`, always injected a `<thead><tr></tr></thead><tbody></tbody>` skeleton) —
  structurally incompatible with the core-blessed "consumer hand-authors the rows" shape and with
  the svelte container. Added a backward-compatible **container-only path**: with no `:col` slots
  it renders a bare `<table class="pa-table …">{inner_block}</table>` (new optional `inner_block`
  slot; `rows` defaults to `[]`; `:col` no longer required). The data-driven path and its tests are
  untouched. (2) `section/1` emitted its title as `<h3 class="pa-section-title">` — injecting the
  *standalone* heading component's class inside the container; core + svelte emit a bare `<h3>`
  (styled by `.pa-section > h3`). Fixed to a bare `<h3>`. (3) `sparkline/1`'s `size` attr allowed
  only `[nil, "lg"]` though core ships `pa-sparkline--sm` — added `"sm"`. (4) `range_group/1`
  emitted a phantom `style=""` on `__panel` (HEEx renders `style={nil}` as an empty attribute) —
  folded the panel style into the attrs only when present. Locked by 13 new unit tests
  (`table` ×3, `layout`/section ×3, `data_viz`/sparkline ×3, `range_group` ×4).
- **Fidelity tooling #7 (dev-only).** Added `fidelity/*.map.json` capability maps for
  settings-panel / sparkline / table / section / range-group and the matching
  `mix pa.fidelity.dump` clauses (+ `SettingsPanel`/`Table`/`Layout`/`RangeGroup` aliases).
  table (container-only `<table>` shell; native thead/tbody, element classes deferred) and
  range-group (container-only control shell; `__panel`/`__row*`/`__seg*` are JS-built → cssState*
  / deferred) are container contracts; section (inline, zero modifiers) and sparkline (data-driven
  bars via inline `--value:N%`, fully SSR) are full compares. settings-panel is capability-only —
  it's a fixed-chrome leaf whose two wrappers' internals diverge by design (keen loads theme
  manifests via a phx-hook; svelte has a static mode fallback), so no shared full-tree golden
  exists; its class contract (`--open` state + 9 `__*` elements) is still asserted via the map.
  sparkline 9/9, table 13/13, section 3/3, range-group keen 5/5 (svelte dumper-blocked by an
  init-time lifecycle hook, capability-only) — all 0 capability hard failures.
- **Markup-fidelity sweep #6 — label / composite-badge / gauge corrected against core.**
  Same cross-repo harness, three real markup bugs. (1) `label/1` declared `variant` values
  including `"light"`/`"dark"`, but core emits no `pa-label--light`/`--dark` — narrowed to
  the six core colours so those phantom classes can't be produced. (2) `composite_badge/1`
  emitted invented element modifiers `pa-composite-badge__label--{v}` / `__button--{v}`;
  core's SCSS `@each` generates only the **block** modifiers `pa-composite-badge--label-{v}`
  / `--btn-{v}` — fixed to emit those on the wrapper, added the missing `icon_variant` attr
  (`--icon-{v}`), and dropped a dead inline `style=""` the conditional `cursor:pointer`
  produced. (3) `gauge/1` leaked a `text-center` layout wrapper into the component, emitted a
  trailing `;` in its inline size style, and stacked a colour `variant` class on top of
  `is_zones` (zones replaces the whole fill) — all three corrected against the snippet.
  Locked by five new unit tests (`badge_test` ×2, `data_viz_test` ×3). `accent-grid` and
  `definition-list` needed no keen markup change (already core-faithful).
- **Fidelity tooling #6 (dev-only).** Added `fidelity/*.map.json` capability maps for
  accent-grid / label / composite-badge / definition-list / gauge and the matching
  `mix pa.fidelity.dump` clauses. accent-grid (container-only: its `__item*` variants/copy
  states live in the separate item sub-component the generic dumper can't compose — deferred)
  and definition-list (container-only `pa-list-definition` `<dl>` shell; `dt`/`dd` are native
  consumer markup, no `__element` classes) are container contracts; label (flat, self-
  contained), composite-badge (renders its `__icon`/`__label`/`__button` parts inline — in
  scope) and gauge (CSS `conic-gradient` driven by an inline `--value`, fully SSR) are full.
  accent-grid 3/3, label 15/15, composite-badge 34/34, definition-list 5/5, gauge 11/11 —
  all 0 capability hard failures.
- **Markup-fidelity sweep #5 — desc-table corrected against core.** Same cross-repo
  harness, one markup bug: `desc_table/1` rendered `style={@computed_style}` directly, so a
  nil `label_width` emitted a stray `style=""` (HEEx renders `style={nil}` as an empty
  attribute, unlike `class`), diverging from the blessed snippet and the svelte wrapper
  (both omit the attribute). Fixed by folding the computed style into `@rest` only when
  present. Locked by three new `desc_table/1` unit tests. `banded` / `dot-leaders` / `fields`
  / `prop-card` needed no keen markup change (already core-faithful).
- **Fidelity tooling #5 (dev-only).** Added `fidelity/*.map.json` capability maps for
  banded / desc-table / dot-leaders / fields / prop-card and the matching
  `mix pa.fidelity.dump` clauses (the data-display family). All scoped container-only —
  their row/label/value/field children come from separate sub-components the generic dumper
  can't compose, so those element classes are acknowledged-deferred; the valuable coverage is
  the container contract + its modifiers (`fields` exercises 23 scenarios across its full
  modifier set via a `blocks: […]` family fixture). banded 12/12, desc-table 13/13,
  dot-leaders 3/3, fields 23/23, prop-card 4/4 — all 0 capability hard failures.
- **Markup-fidelity sweep #4 — stacked-bar / filter-card corrected against core.** Same
  cross-repo harness, two more markup bugs:
  - **Stacked bar:** `stacked_bar/1` declared `size` values `[nil, "lg"]`, omitting `"sm"`
    though core ships `pa-stacked-bar--sm` and svelte supports it. Added `"sm"` to the
    allowed values.
  - **Filter card:** the clear-all button used `pa-icon--x`; the blessed snippet
    (`snippets/filter-card.html`) uses `pa-icon--clear`. Corrected.

  stacked-bar fix locked by two new unit tests; `heatmap` / `splitter` / `checkbox-list`
  needed no keen markup change (already core-faithful).
- **Fidelity tooling #4 (dev-only).** Added `fidelity/*.map.json` capability maps for
  stacked-bar / heatmap / splitter / checkbox-list / filter-card and the matching
  `mix pa.fidelity.dump` clauses. (`stacked-bar` / `checkbox-list` are scoped container-only
  — their segment/legend/row children come from separate sub-components the generic dumper
  can't compose, so those element classes are acknowledged-deferred. `splitter` renders
  root + attrs faithfully; its repeated-pane slot composition is an acknowledged divergence
  a single static golden can't reconcile.)
- **Markup-fidelity sweep #3 — pager / toast corrected against core.** Same cross-repo
  harness, two more markup bugs:
  - **Pager:** the First/Prev/Next/Last nav buttons carried a hardcoded `title={…}`
    attribute that neither the blessed snippet (`snippets/tables.html`) nor the svelte
    wrapper emits — a second markup shape for one slot, against the one-canonical-shape
    rule. Removed; the `pureAdmin.pagination.*Page` translation keys remain defined for
    consumers.
  - **Toast:** `toast/1` had no actions affordance despite the snippet showing
    `pa-toast__actions`. Added a `:actions` slot rendered as
    `<div class="pa-toast__actions">` inside `pa-toast__content`.

  Each fix is locked by a new or expanded unit test. `modal` and `data-bar` needed no
  keen markup change (already core-faithful).
- **Fidelity tooling #3 (dev-only).** Added `fidelity/*.map.json` capability maps for
  modal / popconfirm / pager / toast / data-bar and the matching `mix pa.fidelity.dump`
  clauses. (`popconfirm` is capability-mapped but not render-compared: its LiveView
  trigger-wrapper + required `id` / `data-*` / `phx-*` scaffolding can't reconcile to a
  shared static SSR golden — an acknowledged, flagged divergence.)
- **Card tabs now sit INSIDE the header, next to the title.** `card/1` previously
  rendered non-inline tabs in a `<div class="pa-card__tabs">` *outside* the header; the
  canonical placement (snippets/cards.html) is inside `pa-card__header`, after the title
  (the `pa-card__tabs--inline` negative-margin CSS assumes it). Unified the inline and
  default tab strips into one header-level block (`pa-card__tabs`, plus `--inline` for the
  pill style) and removed the outside-header block. Surfaced by the markup-fidelity harness
  (svelte had the mirror bug — it *dropped the title* when tabs were present). Locked by a
  new Floki test asserting the tab strip nests in the header.
- **Fidelity fragment tooling (dev-only).** Added `mix pa.fidelity.dump` clauses +
  `fidelity/*.map.json` for the sub-component fragments card-tab / list-item / timeline-item
  (tested in isolation; parent fixtures defer to them, verified).
- **Markup-fidelity sweep — badge / alert / stat corrected against core.** A new
  cross-repo markup-fidelity harness (core renders the blessed golden markup per scenario;
  keen renders the same component via `mix pa.fidelity.dump`; the two are normalized and
  diffed — no browser) surfaced three places where keen emitted markup the core CSS no
  longer blesses:
  - **Badge:** a `theme_color` badge wrongly stacked `pa-badge--primary` on top of
    `pa-badge--color-N` — the default `variant` class was emitted unconditionally. The
    variant class is now suppressed when `theme_color` is set (mirrors `button/1`).
  - **Alert:** the dismiss button (`pa-alert__close`) was missing `type="button"`,
    risking an implicit submit inside a `<form>`.
  - **Stat:** fit-mode square stats emitted `<div>` for the number/symbol where the
    canonical shape is `<span>`; the change/context disclosure rows were also dead code
    on the non-fit path and now live in the fit-only branch. Non-fit square keeps `<div>`.

  Each fix is locked by a new or expanded unit test.
- **Fidelity tooling (dev-only).** Added `fidelity/*.map.json` capability maps for
  badge / alert / callout / stat / tooltip and the matching `mix pa.fidelity.dump`
  clauses, so keen's emitted DOM is continuously checkable against core's golden markup.
- **Markup-fidelity sweep #2 — progress / loader / timeline corrected against core.**
  Same cross-repo harness, three more markup bugs:
  - **Progress:** the bar now carries its accessibility contract —
    `role="progressbar"` + `aria-valuenow` + `aria-valuemin="0"` + `aria-valuemax="100"`
    (svelte already emitted these; keen emitted none).
  - **Loader:** `loader/1` emitted a phantom `style=""` attribute when no colour was
    set (LiveView renders `style={nil}` as `style=""`); the colour now rides `@rest`
    so the attribute is omitted entirely when absent.
  - **Timeline:** the alternating variant emitted a `<div>`; it now always emits
    `<ul>` (the canonical semantic list — the SCSS keys off `:nth-child`, not the tag),
    matching svelte and the snippet.

  Each fix is locked by a new or expanded unit test. `code` and `list` needed no
  markup change.
- **Fidelity tooling #2 (dev-only).** Added `fidelity/*.map.json` capability maps for
  code / progress / loader / timeline / list and the matching `mix pa.fidelity.dump`
  clauses.
- **Command palette did nothing except on its own demo page — including `Ctrl+K`.** The
  palette component (and the JS hook that registers the global `Ctrl+K`/`⌘K` listener) was
  only rendered on `/components/command-palette`, so on every other page the navbar/sidebar
  search triggers dispatched `pa:command-palette:open` to a `#command-palette` element that
  didn't exist, and the keyboard shortcut had nowhere to bind. Reworked the palette into the
  `PureAdmin.CommandPalette` LiveComponent (see Added) and mounted it once in the demo app
  layout, so search triggers and `Ctrl+K` now work on **every** page. The hook pushes its
  `cp:*` events to the component when mounted inside one (falls back to the view otherwise).
- **Demo loaded a stale theme stylesheet — the whole app ran on an outdated build.** The
  root layout linked `/themes/{t}/css/{t}.css`, but the current theme install now writes
  `/themes/{t}/dist/{t}.css`; a leftover `css/{t}.css` in `_build` shadowed it (the
  `ThemePlug` serves the requested path when it exists, so the fallback to `dist/` never
  fired). The old build predated recent pure-css, so the sidebar rendered at
  `font-weight:400` instead of the intended medium `500` (looked visibly heavier/larger than
  pure-admin) and the `pc-icon-hover-*` rules were entirely absent (hover markers painted
  nothing). Repointed the layout link + the theme-switcher JS to `dist/` (the plug still
  falls back `dist/ → css/` for registry-downloaded themes). Sidebar weight now matches
  pure-admin and icon-hover works.
- **Modal-dialog scroll-lock double-compensation.** `modal_dialogs.js` set a manual
  `body { padding-right }` on top of the CSS `scrollbar-gutter`, shifting page content
  sideways; it now uses the refcounted `pureAdmin.overlay.lockBodyScroll()` (core 3.2.0 fix).
- **Table row heights** now apply their intended button-synced minimum height (core rc03
  fixed the invalid `$btn-height-*` string interpolation that silently dropped the rule) —
  delivered via the rebuilt 3.3.0-rc03 themes.
- **Sidebar search glyph was a mis-sized Font Awesome icon.** `sidebar_search` rendered
  `<.icon>` (an `<i class="fa-…">`) — the wrong size in the trigger, and in the type-and-go
  form it double-rendered *over* the CSS-masked magnifier on `.pc-sidebar__search-icon`.
  Both variants now use the canonical masked search glyph (`.pa-icon--search` → the shared
  `--base-icon-search`), so the icon matches the navbar search / command palette and
  re-skins with the theme, just like pure-admin.

### Earlier (pre-3.x) sync — carried into this release

**Foundation namespace `pa-` → `pc-` for the app shell.** The grid + mode classes
(`pa-row`/`pa-col*`/`pa-mode-*` → `pc-*`) are de-branded. Emitted shell markup, JS hooks,
and vendored theme/core CSS are updated. Apps migrate own shell markup via find/replace
(the `pa-row`/`pa-col`/`pa-mode-` classes).

Full sync to `@keenmate/pure-admin-core` `^2.9.0-rc15` (peer-dep bumped `^2.9.0-rc08` → `^2.9.0-rc15`; `package.json`). Covers rc09 (responsive navbar collapse + touch dropdowns + sidebar section/divider + active nav state), rc10 (table wrapper consolidation), rc11 (the `window.pureAdmin` namespace + config + event bus, the `.pa-icon` masked-icon X-glyph sweep, the reworked drag-to-resize sidebar, mobile off-canvas drawers), rc12 (priority-driven navbar-fit engine, `pureAdmin.device` + `pureAdmin.overlay`, the mobile fullscreen command palette, and the three search entry-point patterns), rc13 (the burger as a fixed sibling of the navbar zones), **rc14 — the universal, composable navbar: the monolithic `.pa-header__*` block split into `pa-navbar__*` / `pa-app-header` / `pa-page-header` / `pa-navmenu`**, and **rc15 — the `pa-search-results` page component, type-and-go search forms, and command-palette size presets**. Component surface mirrors the svelte-pure-admin decomposition. Theme CSS (masked icons, resize knob, drawer, fit utilities, the renamed navbar blocks + `--pc-navbar-*` tokens, the rc15 search-results styles + unified `--pc-search-mark-*` `<mark>` highlight + runtime palette-size vars + the scroll-lock `scrollbar-gutter` fix) picks up once themes are reinstalled via `npx @keenmate/pureadmin themes install` **against rc15-built theme sources**.

### Added

- **`<.breakpoint_container>` + `<.breaker>` — declarative Container Breakpoint components** (`PureAdmin.Components.Responsive`). A thin wrapper over the `PureAdminContainerBreakpoint` engine so call sites never hand-write `data-pc-show` / `.d-none`: `<.breakpoint_container id=… steps={%{compact: 0, comfy: 34, wide: 64}} initial="comfy">` measures its own width and names a mode; each `<.breaker show="comfy wide">…</.breaker>` block appears only in the listed modes. The container also emits a scoped pre-paint `<style>` keyed on `[data-mode]`, so out-of-mode blocks don't flash before JS runs. New demo at `/components/responsive-form` (Responsivity submenu): a contact form that sheds optional fields down to the essentials as the card narrows — built from kpa form components + `<.breaker>`, with the two-up row keyed off the reflected `[data-mode]`.
- **Responsivity demo — a new sidebar section with two pages, built entirely with kpa components.** `/responsivity` (How It Works) explains the two responsive engines (Fit + Container Breakpoint), the relocation-sink model, and the LiveView hands-off contract, with a live relocate bar (drag it → the badge cluster folds into a "•••" flyout via the built-in `floating-menu` sink). `/components/fit-to-size` walks four worked, slider-driven examples: a fit-engine toolbar (`PureAdminNavFit`), a CSS container-query chart↔KPI card, one query restyling a card on three levels, and the Container Breakpoint engine building/destroying a Chart.js instance on demand. New demo hooks `StageWidth`, `FitSparkline`, `CardTabs`, `FitToSizeEx4`; sidebar submenu + `/responsivity` and `/components/fit-to-size` routes.
- **Settings panel — Command Palette size selector (rc15 palette presets).** New `data-setting="command-palette-size"` select (Default 608px / Small 480px / Large 768px / Extra Large 896px) that toggles `pa-command-palette--{sm,lg,xl}` on the palette — targeted by class, so it no-ops when no palette is on the page. Persist / load / reset ride the panel's generic `[data-setting]` machinery. This section was present in pure-admin's settings panel but missing from keen.
- **`make kill-port`** — frees the demo server port (default `18700`; override with `PORT=…`). `netstat|awk|taskkill` on Windows, `lsof|kill` elsewhere.
- **Sync extended to `@keenmate/pure-admin-core` `^2.9.0-rc17`** (peer-dep bumped from `^2.9.0-rc15`), wrapping the Container Breakpoint engine (rc17) and the fit-engine's group opt-in / opt-out + container-generic init (rc16/rc17). Vendored core JS re-ported: `navbar_fit_core.js` ← core's renamed `fit.js`, new `container_breakpoint_core.js`, and `pure_admin_core.js` config gains `fit` + `containerBreakpoint` defaults.
- **`PureAdminContainerBreakpoint` hook (core rc17).** The JS counterpart to a CSS `@container` query: a node carrying `phx-hook="PureAdminContainerBreakpoint"` + `data-pa-breakpoints='{"compact":0,"comfy":34,"wide":64}'` maps its own inline size to a named mode, reflecting `[data-mode]` and toggling the shared `.d-none` on `data-pa-show` descendants (rem thresholds; `data-pa-breakpoint-unit="px"` for pixels; hysteresis dead-band). Client-side by default; add `data-pa-breakpoint-event="…"` and the hook pushes each flip to the LiveView for server-side mount-on-demand. Registered in `keen_pure_admin.js`; demo at `/components/container-breakpoint`.
- **Fit engine — group opt-in / opt-out + container-generic (core rc16/rc17).** `data-pa-fit-auto` on a container folds every child into the fit set without tagging each; `data-pa-fit-ignore` pins one out; un-ranked slots inherit `data-pa-fit-default-priority` / `pureAdmin.config.fit.defaultPriority`. The engine is no longer navbar-only (`pureAdmin.components.fit`, `navFit` alias kept). The `PureAdminNavFit` hook is unchanged.
- **`<.navbar_nav>` responsive collapse (rc09).** New `collapse` attr (`"menu"` / `"sidebar"`) emits `data-pa-nav-collapse` and wires the `PureAdminNavCollapse` hook + `phx-update="ignore"` (the engine reparents `<li>`s, which a LiveView diff would clobber). Companion attrs `more_label`, `collapse_target`, `collapse_label`, `collapse_icon`; a stable `id` is auto-derived when collapse is active. `menu` folds low-priority items into a generated "More ▾" dropdown; `sidebar` rebuilds them as native `.pa-sidebar__*` markup.
- **`<.navbar_nav_item>` collapse + active props (rc09).** `is_active` emits `pa-header__nav-item--active`; `priority`, `icon`, and `collapse="hide"` emit `data-pa-nav-priority` / `-icon` / `data-pa-nav-collapse` per `<li>`. Every leaf item now always carries `pa-header__nav-item`.
- **`<.sidebar_section>` and `<.sidebar_divider>` (rc09).** `sidebar_section/1` → `<li class="pa-sidebar__section">` (flat uppercase group heading); `sidebar_divider/1` → `<li class="pa-sidebar__divider">` (thin rule in the `<ul>` flow, distinct from the standalone `<hr>` `divider/1`).
- **`<.table_card>` subtitle (rc11).** New `subtitle_text` attr + `:subtitle` slot emit `<p class="pa-table-card__description">` between the title and actions, matching upstream's new canonical DOM (`.pa-table-card__title` becomes `flex: 0 1 auto`). This makes `table_card` a strict superset of the deprecated bare-table-in-card shape, so the responsive/dashboard demos migrated 1:1 (see Changed).
- **`<.navbar_brand version="…">` (rc11).** Optional muted version tag emitted as `<span class="pa-header__version">` inside the wordmark `<h1>`.
- **`window.pureAdmin` bootstrap vendored (`pure_admin_core.js`), imported first.** The shared namespace (events bus, viewport source, `config`, `debug`, `menus`, `components` registry, `colorScheme`) is now installed before any hook runs, so the vendored core modules get their event bus + config baseline. A `body.loaded` class is set shortly after load — rc11 gates the mobile-drawer slide + sidebar link/chevron transitions behind it, and nothing else sets it. **rc12** re-vendored it to add `pureAdmin.device` (capability-first mobile/tablet/desktop classification — pointer/hover + a 600px short-side line, emits `device:change`) and `pureAdmin.overlay` (`lockBodyScroll` + `observeKeyboardInset` fullscreen-sheet primitives), plus `config.tabletMinShortSide`.
- **Navbar-fit engine vendored (`navbar_fit_core.js`) + `PureAdminNavFit` hook (rc12).** Priority-driven degradation for the whole header: any slot carrying `data-pa-fit` (`hide` | `steps` | `sidebar`) degrades lowest-`data-pa-fit-priority` first when the row can't fit, restoring on widen (reset-then-degrade). `navbar/1` now attaches the hook to `.pa-navbar__inner` (auto-derives its id) — a no-op until a `data-pa-fit` slot exists. It folds collapsing navs first via the new `navCollapse.relayoutAll()` (merged into `navbar_collapse_core.js`, keen `destroy()` preserved).
- **`<.fit_slot>` — generic navbar-fit participation wrapper (rc12).** Opts *any* header content into fit without that content knowing about `data-pa-fit`: `variant` (`hide` | `steps` | `sidebar`), `priority`, `sidebar_target`, and a `tag` override (span/div). The `steps` variant takes ordered `:step` slots (0 = widest/default; the engine climbs 0 → 1 → 2 … then hides), and every non-first step is emitted with `.pa-fit-hidden` so only the widest shows before JS runs (no stacked flash, no-JS-safe). `navbar_brand/1` now builds its wordmark→monogram ladder and version tag through `fit_slot`, dogfooding the single mechanism.
- **`<.navbar_brand>` wordmark → monogram degradation (rc12).** The default wordmark is wrapped in a `data-pa-fit="steps"` `.pa-header__brand-name` (step 0 = wordmark, step 1 = monogram + `.pa-fit-hidden`), and the version tag became a `data-pa-fit="hide"` slot (priority 10). New `monogram` attr defaults to the wordmark's initials (e.g. "Pure Admin" → "PA"). A custom brand slot is left untouched.
- **`<.navbar_title is_fit>` (rc12).** The centre title drops (`data-pa-fit="hide"`, priority 20) before the brand degrades; opt out with `is_fit={false}`.
- **Search entry-point components (rc12).** `navbar_search/1` refactored (**BREAKING**: was a `<div role="button">` inside a non-canonical `.pa-header__search` wrapper) into the canonical compact trigger `<button class="pa-navbar-search pa-navbar-search--sm">` (fit=hide, priority 25) that opens the palette; new `navbar_search_field/1` (`.pa-navbar-search--field` inline live-search input + `.pa-search-autocomplete` results slot) and `sidebar_search/1` (`.pa-sidebar__search` trigger). A Settings → **Search Box** selector (`data-setting="search-position"`) reveals one of the three and re-runs navbar-fit.
- **Mobile fullscreen command palette (rc12).** `PureAdminCommandPalette` adds `.pa-command-palette--fullscreen` when `pureAdmin.device` reports a phone, and (while open) holds a `pureAdmin.overlay` body scroll-lock + soft-keyboard inset on its container, released on close/unmount. New `show_command_palette/2` JS command dispatches `pa:command-palette:open` to the palette element so any trigger (navbar/sidebar search) opens it without per-trigger LiveView wiring.
- **`<.search_results>` — page-level results list (rc15).** New component (`.pa-search-results`) for the *destination* a search submits to, distinct from the `.pa-search-autocomplete` dropdown under a live field. One item tree (`__icon` + `__content`/`__title`/`__snippet`/`__meta`/`__meta-item` + `__type`) restyled by four `variant` presets: `compact` / `detailed` / `grouped` / `cards`. Takes a `results` list of maps (`:title` required; `:icon`/`:snippet`/`:meta`/`:type`/`:href`/`:group`); `grouped` buckets by `:group` under `__group`/`__group-title` with optional `groups` metadata (`%{id, label, limit}`, order + per-group cap). `allow_html` renders `:title`/`:snippet`/`:meta` as HTML so a backend `<mark class="pa-search-results__mark">` highlight (Elasticsearch / Postgres `ts_headline`) shows — the value is injected verbatim, so it must be backend-sanitised. Mirrors svelte `SearchResults`.
- **Type-and-go search forms (rc15).** New `navbar_search_input/1` (`.pa-navbar-search--input`) — a real `<input>` in a `<form>` whose native GET submit navigates to a results page on Enter (no dropdown, no palette; consumer sets `action`/`method`/`name`); participates in navbar-fit (hide, priority 25) like the other entry points. `sidebar_search/1` gains an `action` attr that switches it into the `.pa-sidebar__search--input` form mode (submit-`type` magnifier so the collapsed icon-rail still submits) — mirroring svelte's single dual-mode `SidebarSearch`. These are the third navbar/sidebar search shape alongside the palette trigger and the live field.
- **Command palette size presets (rc15).** `command_palette/1` gains a `size` attr (`"sm"` / `"lg"` / `"xl"`) emitting `.pa-command-palette--{size}` (width + results height together; nil keeps the 60.8/38.4rem default). For an arbitrary size, override the runtime CSS vars `--pc-command-palette-width` / `-offset-top` / `-results-max-height` instead (theme-supplied, no recompile).

### Changed

- **Navbar inline search (entry point A) moved from the `:start` zone to `:center`.** The `navbar_search_field` (`.pc-navbar-search--field`) now shares `pc-navbar__center` with the page title, so Settings → Search Box → "Navbar — inline search (A)" swaps title ↔ search in place and the center zone sizes/centers it — matching pure-admin. It had been rendering left-aligned in `:start` at the wrong width. Also wired a demo `NavbarSearchDemo` hook giving the inline field a live autocomplete dropdown (`.pa-search-autocomplete` items, `<mark>` highlight, keyboard nav) over a static demo dataset, mirroring pure-admin's `navbar-search.js`.
- **Settings panel — removed the redundant "Collapsed" sidebar checkbox.** The sidebar hide/show state is owned by the navbar burger (`sidebar.js` persists `sidebar-hidden`); the panel checkbox was a second control on the same state that pure-admin's panel doesn't have. The Sidebar section now exposes only "Resizable", matching pure-admin. Burger-driven full-hide is unchanged.
- **Makefile pins the recipe shell to Git Bash on Windows.** So `make kill-port` / `themes-install` / the `podman-*` checks run their bash pipelines even when `make` is launched from PowerShell or cmd (which default the recipe shell to `cmd.exe`, breaking `grep`/`awk`/`xargs`).
- **BREAKING (rc13/rc14): the navbar is now universal & composable, and every navbar component was renamed.** rc14 split the monolithic `.pa-header__*` block into honestly-named blocks; keen hard-cut its navbar components to match the svelte-pure-admin decomposition (no aliases):
  - `navbar_brand/1` → **`app_header/1`** (`pa-app-header`, `__name`/`__version`/`__logo`) — now a plain composable wrapper; the old built-in `version`/`monogram` ladder is gone (compose it with `fit_slot`/`fit_step`).
  - `navbar_title/1` → **`page_header/1`** (`pa-page-header`) — plain wrapper; the old built-in `is_fit` is gone (wrap in `fit_slot` to degrade).
  - `navbar_nav/1` → **`nav_menu/1`** (`pa-navmenu`) — dropped the `position` attr / `--start`/`--end` modifiers (a menu's side is its zone).
  - `navbar_nav_item/1` → **`nav_item/1`** (`pa-navmenu__item*`) — a plain item now carries no class (canonical DOM); only `is_active`/`has_dropdown` add classes; dropdown links use `pa-navmenu__link`.
  - `navbar_dropdown/1` → **`nav_dropdown/1`** (`pa-navmenu__dropdown` / `--level2`).
  - `navbar_profile_btn/1` → **`profile_button/1`** (`pa-navbar__profile-btn` / `pa-navbar__profile-name`).
  - `navbar/1` — zones renamed `pa-navbar__start`/`center`/`end`; new **`:burger` slot** renders the burger as `.pa-navbar__inner`'s first child (rc13 fixed anchor, sibling of the zones); `navbar_burger/1` emits `pa-navbar__burger`.
  - The three vendored core JS modules were re-synced to rc14's class names: `navbar_fit_core.js` / `navbar_dropdown_core.js` re-vendored verbatim; `navbar_collapse_core.js` string-renamed in place (generated `pa-navmenu__more-menu` / `__more-chevron` / `__item--more`) preserving keen's `destroy()` + `relayoutAll` deviations. `PureAdminProfilePanel` / `PureAdminSettings` selectors updated (`.pa-navbar__profile-btn`, `.pa-page-header`).
- **BREAKING (fit API): `fit_slot/1` renamed its `variant` attr to `strategy`, and steps now use `fit_step/1` children** (was a `:step` slot) — mirroring svelte's `FitSlot`/`FitStep`. `fit_step/1` takes an explicit 0-based `index` (Phoenix can't auto-index across function-component children) and stamps `pa-fit-hidden` on every step past the first.
- **BREAKING (JS globals): all vendored core modules moved to `window.pureAdmin.components.*`.** rc11 consolidated every `window.PaX` / `window.PA_*_DEBUG` global under one `window.pureAdmin`. The six vendored `*_core.js` modules (overflow, navbar-collapse, navbar-dropdown, splitter, range-group, stat-fit) now register under `pureAdmin.components.{overflow,cardActionsOverflow,navCollapse,navDropdown,splitter,rangeGroup,statFit}`; `PaMenus` → `pureAdmin.menus`, `PaSplitMenu` → `pureAdmin.components.splitMenu`, `PA_*_DEBUG` → `pureAdmin.debug`. The thin Phoenix hooks were retargeted accordingly. Keen `destroy()` deviations on `overflow_core.js` / `navbar_collapse_core.js` were preserved. Consumers who reference the old `window.Pa*` globals directly must update; the bundled hooks handle it transparently.
- **Sidebar drag-to-resize reworked to the rc11 core module.** Replaced the hand-rolled resize with the vendored first-class `sidebar_resize_core.js` (`pureAdmin.components.sidebarResize`), which reads its bounds from the `--pc-local-sidebar-min/max-width` CSS vars, writes `--pc-local-sidebar-width` (rem), sets `body.pa-sidebar-resized` (so the tablet band honours a resized width), is touch-grabbable, and resets on double-click. `<.sidebar is_resizable>` now emits `pa-layout__sidebar--resizable` (the module's activation hook) and **no longer server-renders the `.pa-sidebar-resize` handle** — the module creates it (a pre-existing handle would make it skip binding its drag listeners). Driven from `PureAdminSidebar` on mount/update; `fouc_prevention_script/1` preloads a saved width (+`pa-sidebar-resized`) to avoid a flash.
- **Mobile sidebar is now a proper off-canvas drawer.** `PureAdminSidebar` adds an iOS-safe background scroll-lock (pins `<body>`, restores scroll, compensates the scrollbar) and tap-scrim-to-dismiss (close on any tap outside the drawer that isn't the burger), matching rc11's drawer behavior. The slide/backdrop CSS arrives via the theme.
- **`<.table_container is_panel>` marked deprecated (rc10);** the Tables demo's "Panel Tables" section and the responsive/dashboard bare-table-in-card usages migrated to `<.table_card>` (now with subtitle).
- **Required-field marker is now attribute-driven (follows core `d423d05`).** Core renders the required asterisk itself via `.pa-form-group:has(:required) > label:not(.pa-checkbox):not(.pa-radio)::after` — purely off the native `required` attribute. keen dropped its hand-rendered `<span class="text-danger"> *</span>` from `form_label/1` (it would double the core marker once the new theme CSS is served); `is_required` on `form_label/1` and `form_group/1` is now a **documented no-op** — mark the control with native `required` instead. keen's structure already satisfies the selector (the `label` shorthand and nested `form_label` both render a top-level `<label>` that is a direct child of `.pa-form-group` and isn't `.pa-checkbox`/`.pa-radio`). Demo forms migrated all `is_required` label usages to `required` on the control.

### Fixed

- **`stat/1` icon-slot rendered an empty stat.** The whitespace HEEx captures around a named `<:icon>` slot was treated as a custom-layout `inner_block` override, so `<.stat number=… label_text=…><:icon>…</:icon></.stat>` rendered nothing — number, label, and icon all dropped. This also blanked the existing `/components/stats` icon cards. `inner_block` now counts as an override only when no structured inputs (`number` / `value` / `:icon`) are supplied.
- **Resizable sidebar never worked (dead hook).** The `PureAdminSidebarResize` hook was never attached (a LiveView element takes one `phx-hook`, and the sidebar already uses `PureAdminSidebar`), and the old markup emitted a phantom `pa-layout__sidebar--resizable` class with no CSS. Resize is now driven from `PureAdminSidebar` against the real rc11 module + handle. `PureAdminSidebarResize` remains as a thin standalone escape-hatch hook.
- **Removed the phantom `pa-table-responsive` wrapper.** `table/1 is_responsive` wrapped the table in a `<div class="pa-table-responsive">` that has no upstream CSS; the mobile transform is entirely the `pa-table--responsive` modifier on `<table>` (still emitted). Dropped the dead wrapper and the vestigial `table_responsive/1` component (breaking).
- **`.pa-icon --x` masked-icon sweep (rc11).** Every close/remove/clear affordance now emits `<span class="pa-icon pa-icon--x" aria-hidden="true">` instead of a text `×`/`✕`, an inline SVG, or a FontAwesome `fa-xmark`/`fa-times`: alert & flash dismiss (component + `flash.js`), modal close, toast close (component + `toast.js`), input-wrapper clear (+ added `aria-label="Clear"`), popover close, profile-panel close, filter-card "Clear all". Severity icons and multiplication signs are deliberately left as text. The `.pa-icon` CSS ships via the theme.
- **Tooltip `--color-1..9` / semantic variants missing on the hook path.** `PureAdminTooltip`'s floating element copied no variant classes (only the document-delegated path did), so a hook-driven `pa-tooltip--color-5` / `--primary` rendered unstyled. The variant copy now lives in `createFloatingTooltip`, so both paths get it.
- **Sidebar chevron rotation leaked into nested groups during FOUC preload.** Scoped the pre-paint `<style>` selector to the wrapper's own toggle child (`#id-wrapper > .pa-sidebar__toggle > .pa-sidebar__chevron`).
- **Full re-validation vs pure-admin's post-audit snippets (`d423d05`) — invented / dead modifier classes removed.** pure-admin re-reviewed all 39 snippets adversarially; re-ran the same lens over every keen component (grep-verified each flagged class against the built `dist/css/main.css`). Removed classes that render as no-ops: `form.ex` `pa-form-label` / `--required` (core auto-styles a bare `<label>` in `.pa-form-group`) and `pa-textarea--{success,warning,error}` (textarea has no validation border — errors surface via `pa-form-help--error`); `loader.ex` `pa-loader-{type}--{color}` (loaders paint from `currentColor` → inline `style="color: var(--pc-…)"`); `typography.ex` invented `pa-text--{muted,small,success,danger,warning,info}` + all `pa-link--*` (mapped friendly `text/1` names to real `pa-text--*` / `.text-*`; `pa-link` has no modifiers); `command_palette.ex` results-item `pa-command-palette__item-shortcut` + `<code>` → blessed `__shortcut` + `__key`; `data_display.ex` accent-grid `--color-{1..9}` / `--primary` (only the four semantic variants exist); `badge.ex` dead `pa-composite-badge--interactive`; `card.ex` `variant="info"` + `is_bordered` (`pa-card--info` / `--bordered` have no rule); `stat.ex` `icon_variant="secondary"` dropped and the colour variant gated on `variant="square"` (core only defines `.pa-stat--square.pa-stat--{color}`). Structural: `field_group` title `<div>` → `<h3>`; `callout.ex` no-icon branch no longer wraps in `__content`. Added `checkbox_list` `state="selected"` (a real state keen had no path to).
- **Demo — the invented `text-muted` utility (0 rules in core CSS) swept to the real `pa-text--secondary`** (`color: var(--pc-text-color-2)`) across 15 LiveViews, including two pages that were *teaching* it as a real utility; dropped hardcoded dead `pa-card--bordered` + `variant="info"` from the validations/cards demos.

## [1.3.0-rc.2] - 2026-08-05

### Changed

- **Peer-dep bumped `^2.9.0-rc07` → `^2.9.0-rc08`; verified against pure-admin-core 2.9.0-rc08.** rc08 is an internal SCSS restructuring — the variable system, `--base-*`/`--pa-*` emit mixins, utilities, and the `.pc-row`/`.pc-col` grid were single-sourced out of core into the shared `@keenmate/pure-css` package via `@import`/`@forward` shims. **Public SCSS import paths and every emitted class name are unchanged**, so no keen component, JS hook, or emitted DOM needed to change. Three potentially-breaking upstream changes were checked and cleared: (1) the removed legacy PureCSS `.pure-g`/`.pure-u-*` grid doesn't touch us — `<.grid>`/`<.column>` already emit `.pc-row`/`.pc-col-*`; (2) the new SCSS-build `--load-path=node_modules` requirement is internal to upstream theme compilation — the demo consumes pre-built theme CSS via `npx @keenmate/pureadmin themes install`, not local SCSS; (3) rc08's additive utilities (`.gap-*`/`.gap-x-*`/`.gap-y-*`, `.font-family-system`/`-sans`, the now-live `.border`/`.rounded`, `--pa-border-color`) are unused by the library. Theme CSS picks up the rc08 rules once themes are reinstalled.

### Fixed

- **Docs — corrected theme-zip structure (`css/`, not `dist/`) and documented both theme-install paths** (pureadmin CLI + manual download) in getting-started, plus gaps found dogfooding a clean install.

## [1.3.0-rc.1] - 2026-07-31 [PUBLISHED]

### Added

- **`PureAdmin.Config` — `:default_icon_size` and `:icon_callback` config keys.** `default_icon_size` (default `"1.25rem"`) is the CSS length applied as SVG `width`/`height` on `<.heroicon>` and inline `font-size` on `<.faicon>` / `<.icon>` fallback when the call site doesn't pass an explicit `size`. `icon_callback` accepts `&Mod.fun/1`, `{Mod, :fun}`, or `{Mod, :fun, 1}` — tuple forms are preferred in `config.exs` since user modules aren't compiled when config evaluates. The callback is a function component (receives the full assigns) invoked by `<.icon>` for any name that doesn't start with `hero-`.
- **`<.icon>` callback dispatch.** Non-`hero-` names route through the configured `:icon_callback` if set; otherwise the existing FA-style `<i class={name}>` fallback runs. Lets a project standardize on a custom icon set (Lucide SVGs, a private sprite, base64, etc.) without touching every call site that uses the legacy `attr :icon, :string` pattern.
- **Future-improvement note in `<.icon>` moduledoc** — sketches a compile-time inline icon-set generator (same approach as `<.heroicon>`) as a follow-up to the runtime callback. Captures the tradeoffs (0 HTTP requests, recolorable via `currentColor`, larger BEAM, recompile to add icons) for when a project outgrows the callback pattern.
- **`PureAdmin.Components.Faicon`** — Font Awesome icon wrapper. Renders `<i class="fa-{variant} fa-{name}">` from `name` + `variant` (solid/regular/light/brands). Stylesheet (CDN or local) must be loaded by the consumer. Zero deps.
- **`PureAdmin.Components.Heroicon`** — inline-SVG Heroicons component. Ships 25 curated outline icons (matching the pureadmin CLI's heroicons → canonical-name map) as `def heroicon/1` clauses with embedded SVG path data. No external CSS, no Tailwind plugin, no hex dep. `stroke="currentColor"` so icons inherit parent text color. Unknown names render a debuggable `<span class="heroicon-missing" title="Unknown heroicon: X">`.
- **`PureAdmin.Components.Icon`** — smart string-based dispatcher. `<.icon name="hero-X" />` routes to `<.heroicon name="X">`; anything else renders as `<i class={name}>`. Lets the legacy `attr :icon, :string` pattern (`sidebar_item`, `sidebar_submenu`, `button`, `flash`, `profile_nav_item`) transparently handle heroicon strings. All three components are auto-imported via the `use PureAdmin.Components` bulk macro.
- **`<.card>` — `title_class` attr.** Passes extra CSS classes onto the `.pa-card__title` element. Primarily for `actions_variant="overflow"`: a `minw-*` floor (e.g. `title_class="minw-45"`) makes the header title yield to a min-width before the header actions collapse, matching the pure-admin card-overflow snippet.
- **Demo `buttons_live` — overflow toolbar filled out to the full canonical set.** The standalone toolbar gains a second split button ("Members", priority 15) whose rows carry inline delete buttons that survive the collapse into `[⋮]` and still fire (`remove_member`). A new "In card headers" section adds the three-up `<.card actions_variant="overflow">` examples (Quarterly / Database Migration / Team Members), demonstrating title-yield via `title_class="minw-*"`, priority pinning, and the split button collapsing last as an atomic labeled group.

### Changed

- **Peer-dep bumped `^2.9.0-rc06` → `^2.9.0-rc07`; verified against pure-admin-core 2.9.0-rc07.** rc07 is CSS-only over rc06 — `overflow.js` is byte-identical, so no JS re-port. It floors the `.pa-overflow` / `.pa-card__actions--overflow` shrink `min-width` at the `[⋮]` trigger footprint (`3.1rem`, was `0`) so a long sibling title can't clip the trigger, and adds a `.pa-btn.text-truncate:not(:has(> *))` inline-block tolerance. The only keen source changes rc07 prompted are the button/card follow-ups in **Fixed** below (the theme CSS itself carries the rc07 rules once themes are reinstalled via `npx @keenmate/pureadmin themes install`).

- **`<.heroicon>` — explicit `width`/`height` from `:size`.** SVG opening tag now emits `width={@size_value}` `height={@size_value}` (resolved against `PureAdmin.Config.icon_size/0`). `class` default dropped from `"size-5"` to `nil` — sizing is now attribute-driven, not Tailwind-class-driven. Public `heroicon/1` is a thin wrapper that computes `size_value` then delegates to the 25 `defp do_heroicon/1` SVG clauses.
- **`<.faicon>` — inline `font-size` from `:size`.** Renders `style="font-size: {size}"` (resolved against `PureAdmin.Config.icon_size/0`). Dropped bogus `size` / `fill` / `stroke` HTML attrs from the `<i>` — they're SVG-only and were silently ignored.
- **`<.icon>` fallback — inline `font-size` from `:size`.** Same treatment as `<.faicon>` for the FA-style `<i class={name}>` branch.
- **`attr :icon, :string` slots now render via `<.icon>`.** `sidebar_item`, `sidebar_submenu`, `button`, `flash`, `profile_nav_item` render their icon through `<.icon name={@icon} />` instead of `<i class={@icon}>`. Backwards compatible for FA strings (`"fa-solid fa-rocket"` still works); `"hero-X"` strings now render as inline SVG via `<.heroicon>` instead of an empty `<i class="hero-X">`. Unblocks the `--heroicons` mode of the elixir-phoenix-liveview template, which emitted `<.icon name="hero-X" />` against Phoenix's stock `CoreComponents.icon/1` — deleted by the recipe in favor of `PureAdmin.Components`.
- **`<.code_block>` — match pure-admin's actual class surface.** Removed invented classes (`pa-code-block-wrapper`, `pa-code-block--heex`, `pa-code-block__filename`, `pa-code-block__language`). Two branches now: with `filename` → `pa-code-block` > `__header` (with `__title`) > `__body` > `<pre class="pa-code pa-code--{lang}">`; without filename → naked `<pre class="pa-code …">`. Inner `<code>` element removed (was double-applying inline-code styling). New `is_compact` and `is_numbered` attrs. Language normalization map handles `heex→html`, `ts→javascript`, `sh→bash`, `py→python`, etc.; supported pure-admin language modifiers are `javascript json html css bash sql python`.

### Fixed

- **Docker build — `themes ci` failed with `Could not extract ZIP — install unzip or tar`.** The builder stage (`elixir:1.18-slim`) shipped GNU `tar` (can't unpack `.zip`) and no `unzip`, so a recent `@keenmate/pureadmin` CLI release (v1.3.4) that distributes themes as ZIPs failed to extract all 15 themes (`0 installed, 15 failed`) and aborted the build. The Dockerfile pins nothing (`npx --yes @keenmate/pureadmin`), so the failure appeared "suddenly" on fresh CI runners without any repo change — the CLI moved underneath the pin-less invocation. Fixed by adding `unzip` to the builder's apt install list. (Consider pinning the CLI version to keep builds reproducible.)
- **`/phoenix/core-components` demo page crashed with `KeyError: key :form not found`.** The migration-comparison table at `demo/lib/demo_web/live/core_components_live.ex:59` showed `<code>field={@form[:x]}</code>` as illustrative text — but HEEx parses `{…}` inside element bodies as an Elixir interpolation, so `@form` was looked up on assigns at render time. Escaped the curlies as `&#123;` / `&#125;` so they reach the browser as literal text.
- **Overflow toolbar crashed under LiveView (`NotFoundError`) and never collapsed.** `overflow_core.js` appends the `[⋮]` trigger and reparents overflowing buttons as real DOM nodes, but they aren't in the server-rendered markup — so any LiveView diff deleted the trigger (and would re-insert server copies of the moved buttons as duplicates), and the next `ResizeObserver` relayout threw `insertBefore … not a child of this node`, aborting every collapse. Fixed by rendering the `<.overflow>` and `<.card actions_variant="overflow">` wrappers with `phx-update="ignore"` — LiveView renders the buttons once, then leaves the subtree to the hook — plus a defensive guard in `moveToRoot()` that re-attaches the trigger if a patch detached it (so the raw class survives even without `phx-update`). Consequence: a toolbar's button set is fixed after mount — change the wrapper `id` to remount and update it from the server.
- **`<.button>` — icon + `text-truncate` didn't ellipse; the leading icon spilled out of a `maxwr-*` button.** The label was unconditionally wrapped in `.pa-btn__label` whenever an `:icon` slot was present, but that wrapper is `flex: 0 1 auto` with no `min-width: 0`, so a nested `.text-truncate` span could never shrink below content — the row overflowed and, because rc06 centers button content, the leading icon escaped left. Pure-admin's canonical structure (`buttons.html` snippet) emits the label as a **bare** flex child (its `overflow: hidden` resolves the flex min-size to `0` → ellipsis) and uses `.pa-btn__label` only as an opt-in wrapper for `--align-center` flex-fill. `<.button>` now matches: bare label by default, `.pa-btn__label` only when `align="center"` — which is therefore mutually exclusive with `text-truncate`, same limitation as core.

### Pure-admin 2.9.0 sync

Full sync to `@keenmate/pure-admin-core@2.9.0-rc06`. Peer-dep bumped `^2.8.0` → `^2.9.0-rc06` (`package.json`). Covers rc01 token/markup alignments, rc02 splitter + card-actions overflow/responsive, rc03 splitter drag rework, rc04 (splitter events, stat-fit, range-group), rc05 (canonical card header), and rc06 (`.pa-overflow` progressive-collapse toolbar + unified button model). Because none of the 2.9.0 pre-releases have shipped a stable tag, this changelog describes the **final rc06 shape** — the rc04 `pa-btn-split--auto-absorb` toolbar it superseded is not carried as a released feature.

- **`<.profile_panel>` role chip migrated from `pa-profile-panel__role` to `<span class="pa-badge">`.** The bespoke role class was retired upstream (pure-admin 2.9.0-rc01) because it pointed `background-color` / `color` at `--pa-header-profile-name-color` — tuned for the header bg, not the panel surface — so the chip rendered black-on-dark and went invisible when the panel opened on dark themes. `.pa-badge` is mode-adaptive via `--pa-btn-secondary-bg` / `-text` (already cross-mode tuned). Visual change: no more forced uppercase + letter-spacing. Consumers wanting a quieter chip can add `pa-badge--light`, or `--primary` / `--info` / `--success` etc. for role colour variants.
- **Demo `theme_variables_live.ex` — dropped `--base-primary-bg` row** from the Semantic State Colors token table. The token was retired upstream (one of six `--base-*` legacy aliases dropped in 2.9.0-rc01: `--base-surface-1` / `-2` / `-3` / `-inverse`, `--base-primary-bg`, `--base-primary-bg-hover`) — they duplicated existing semantic tokens with no behavioural difference.
- **Demo `grid_live.ex` — `var(--base-primary-bg)` references swapped to `var(--pa-surface-hover)`** (8 inline-style usages on row-alignment demo containers). The dropped alias resolved to the same value as `--base-main-bg` (page background) — effectively no visible tint. `--pa-surface-hover` (4% text-color-1 over transparent) gives a clean light/dark-adaptive subtle wash, exactly what these demo containers want.
- **`<.card>` gained `actions_variant` + `actions_overflow_from` attrs** wrapping pure-admin 2.9.0-rc02's two new header-actions collapse models. `actions_variant="responsive"` emits `pa-card__actions--responsive` — caller supplies both `.pa-card__actions-full` and `.pa-card__actions-collapsed` subtrees inside `:tools` and a CSS container query swaps which one's visible at the `$card-actions-collapse-at` threshold (28rem ≈ 280px). `actions_variant="overflow"` emits `pa-card__actions--overflow` + wires up `phx-hook="PureAdminCardActionsOverflow"` automatically (auto-derives an id from `:rest`'s id or generates a unique one); buttons drop into a "..." menu one at a time as the row shrinks. Per-button `data-pa-actions-priority="N"` pins via `:rest` passthrough; wrapper-level `actions_overflow_from` (`"end"` default / `"start"`) sets tiebreak direction and can be flipped at runtime (the hook's MutationObserver re-runs the drop walk).
- **`PureAdminCardActionsOverflow` hook — consolidated onto the shared `overflow_core.js`.** rc06 upstream promoted the original `card-actions-overflow.js` into the generic `overflow.js` primitive, which auto-inits on BOTH `.pa-overflow` and `.pa-card__actions--overflow` and is a strict superset of the old card-only logic. The keen hook is now a thin wrapper over `window.PaOverflow` (`init` on mount/update, the keen-added `destroy` on `destroyed()`) instead of a ~235-line standalone port, so card-header overflow gains the same behaviour as `<.overflow>`: a nested `.pa-btn-split` collapses as one atomic labeled group (the old standalone impl flattened it and would have broken a split button in card actions), `.pa-btn__icon` rows are normalized so menu rows don't zig-zag, and the menu shares one dismissal registry + positioner with the split button. `destroyed()` still tears everything down (disconnect observers, restore pulled-out items, remove the body-portal menu + trigger) via `overflow_core.js`'s `destroy()`. **Visual change:** the `[⋮]` trigger now defaults to a bordered `pa-btn--secondary` square (upstream's rc06 default) instead of the old ghost glyph — new `<.card actions_overflow_trigger="ghost">` restores the chromeless look.
- **`PureAdmin.Components.Splitter` (`<.splitter>`)** wrapping pure-admin 2.9.0-rc02's new `.pa-splitter` component. Single function component with a required `:pane` slot; renders the splitter root + interleaved pane / gutter children (N panes → N-1 gutters) and wires the `PureAdminSplitter` hook when `id` is set. Always emits N-pane markup (per-pane `data-pa-splitter-size` / `-min` / `-max` / `-minimize`) — upstream normalizes the legacy 2-pane shorthand into the same form at init, so a single API surface is enough. Root carries `phx-update="ignore"` so LiveView diffs don't clobber the JS-applied `flex-basis` styles and `--minimized` classes; dynamic pane content goes through nested `<.live_component>` or `live_render`.
- **`PureAdminSplitter` hook + `splitter_core.js`** — `splitter_core.js` is the upstream `src/js/splitter.js` ported verbatim (~1100 LOC) so future syncs are a plain file copy. The hook is a thin wrapper: `mounted()` and `updated()` both call `window.PaSplitter.init(this.el)` which the upstream init guards with `__paSplitterInit` (idempotent). Cleanup is best-effort — upstream doesn't expose teardown, so ResizeObserver / event listeners live as long as the DOM subtree; persistence is flushed to `localStorage` on every drag-end so nothing is lost when the element goes away.
- **Demo `/components/splitter`** — 1:1 port of `pure-admin/demo/views/splitter.mustache`. Seven live examples (1: horizontal sidebar/content, 2: vertical editor/console, 3: spaced cards with `gap` + `--pa-splitter-gutter-size`, 4: minimize-to-rail-start with full BEM card chrome + mirror checkbox + bonus `<.card actions_variant="responsive">` showcase, 4b: progressive overflow with `<.card actions_variant="overflow">` and live drop-direction toggle, 5: minimize-end-pane right-edge inspector pattern, 6: configurable 3-6 pane N-pane picker via socket-state-driven `phx-change` — each count gets its own `localStorage` id, 7: storage-reset button via the demo-side `SplitterStorageClear` hook). Plus four reference cards (legacy 2-pane markup, N-pane markup, Phoenix wrapper markup, data attrs / keyboard / JS API tables). Mirror-toggle for Demo 4 flips a DOM class via `Phoenix.LiveView.JS.toggle_class/2`; overflow-direction toggle for Demo 4b uses inline `onchange` JS since the target sits inside the splitter's `phx-update="ignore"` subtree.

#### rc03 → rc05 delta

- **`splitter_core.js` re-synced to rc05 `splitter.js` (verbatim, ~1323 LOC).** Brings the rc03 drag-model rework (rebalance-on-drag with CLASSIC/TUNNEL slack distribution, asymmetric drag-from-rail, N-pane restore-gap fixes, rAF-throttled pointer move) plus rc04's three bubbling `CustomEvent`s — `pa-splitter:resize` (`{ index, pane, size }`), `pa-splitter:collapse` / `pa-splitter:expand` (`{ index, pane }`) — and the per-pane `pa-splitter__pane--horizontal` / `--vertical` orientation class. Consumers can now listen once on the splitter root instead of polling `localStorage`. Init from saved state does not fire `collapse` for already-rail'd panes. **Upstream dropped its legacy 2-pane normalization at rc05; keen keeps a `normalizeLegacyMarkup()` shim** in `splitter_core.js` so hand-written legacy markup still resolves through the single N-pane path. `<.splitter>` moduledoc gains an Events section.
- **`<.stat>` gained fit-to-box mode (`is_fit`) + the `.pa-stat__context` (P4) row** wrapping pure-admin 2.9.0-rc04's `pa-stat--square[data-pa-stat-fit]`. `is_fit` (square-only) emits `data-pa-stat-fit`, wires `phx-hook="PureAdminStatFit"`, and auto-derives an id. The primary `__number` is sized to fill the tile at the largest font that still fits (JS `ResizeObserver`), then a priority ladder reveals `__symbol` → `__label` → `__change` → `__context` as the tile earns width *and* height; ≥32rem wide it flips to a horizontal banner (`.pa-stat--fit-wide`, toggled by JS). New `context_text` attr + `:context` slot (dual `_text`/slot pair) render the P4 element. `change_text` / `change_direction` now also render (as `__change`, P3) in fit mode; classic square is visually unchanged.
- **`PureAdminStatFit` hook + `pa_stat_fit_core.js`** — verbatim port of upstream `src/js/pa-stat-fit.js` (exposes `window.PaStatFit.init` / `.refresh`); thin hook re-fits on mount and on `updated()` (number/symbol text change). The JS wraps the authored-flat `__number` + `__symbol` into `__slot > __group` and the meta rows into `__meta` at runtime, so authored markup stays minimal.
- **`<.overflow>` + `PureAdminOverflow` hook** wrapping pure-admin 2.9.0-rc06's `.pa-overflow` progressive-collapse toolbar. `overflow/1` renders `.pa-overflow` (the `min-width:0; overflow:hidden; flex-shrink` layout host) and wires the hook + auto-id; overflowing children fold into a dedicated `[⋮]` "more" menu as the bar narrows, and pop back out as space returns. Per-child drop priority via `data-pa-actions-priority` (`:rest` passthrough); tiebreak direction via the `overflow_from` attr (`"end"` default / `"start"`) emitted as `data-pa-actions-overflow-from`, flippable at runtime; `trigger="ghost"` swaps the default bordered `pa-btn--secondary` `[⋮]` square for the chromeless ghost look. A nested `<.split_button>` collapses as one **atomic labeled group** — its primary action + its own menu items travel together under a section label (so its options never mix with unrelated toolbar commands), and per-row action buttons (`:item action_icon`) survive the collapse and still fire. `overflow_core.js` is the verbatim upstream IIFE (`window.PaOverflow`) with one documented deviation — its auto-init selector is narrowed to `.pa-overflow` so it doesn't double-init the `.pa-card__actions--overflow` wrappers that keen already drives via `PureAdminCardActionsOverflow`. It reparents DOM only and relies on keen's existing `PureAdminSplitButton` hook to open a collapsed split's menu; it degrades gracefully to a hand-rolled positioner when the shared `window.PaSplitMenu` / Floating UI isn't loaded.
  - **Replaces the rc04 `pa-btn-split--auto-absorb` mechanism** (`btn_toolbar/1` + `PureAdminBtnSplitAutoAbsorb`), which never shipped in a stable release. That model made a domain split button double as the overflow sink, so unrelated commands ended up under a semantic menu like `Export ▾`. **Migration:** swap `<.btn_toolbar>` → `<.overflow>`, drop the `pa-btn-split--auto-absorb` class from the nested split button, rename `data-pa-absorb-priority` → `data-pa-actions-priority`, and move drop direction from the split button's `data-pa-absorb-from` to the wrapper's `overflow_from` attr.
- **`<.split_button>` — `keep_open` item attr** (emits `data-pa-keep-open`) keeps the dropdown open when that item is clicked instead of the default close-on-click, for items that open a popconfirm / sub-panel anchored to the row. `PureAdminSplitButton` honours the opt-out (skips `_close()` when the click target has a `[data-pa-keep-open]` ancestor). Mirrors upstream `split-button.js`.
- **Buttons — unified inner-content model note (`align` attr).** Upstream rc06 collapsed every `.pa-btn` type onto one `inline-flex` row that centers by default (icons now sit at the padding edge, no fixed icon column), so full-width / block icon+label buttons that used to left-align now center. This is CSS-driven — the `button/1` markup (`pa-btn__icon` + `pa-btn__label`) is unchanged — but the `align` attr doc now flags that `align="start"` restores the old left-aligned look.
- **`PureAdmin.Components.RangeGroup` (`<.range_group>` + `<.range>`)** — new component wrapping pure-admin 2.9.0-rc04's compact multi-range filter (`.pa-range-group`) and its standalone slider primitive (`.pa-range`). `range/1` emits a single- or dual-thumb `.pa-range` (handle-shape modifiers `rect`/`bar`/`arrow`/`needle`, optional ticks / tick-labels / snap-ticks, number formatting). `range_group/1` is the toggle-+-floating-panel wrapper over N `:range` slot rows (one per dimension), wiring `phx-hook="PureAdminRangeGroup"` + `phx-update="ignore"` (the panel reparents to `<body>`; per-instance `--pa-range-*` token overrides go on `panel_style` / the rows, never the root). The group emits bubbling `pa-range-group:change` / `:apply` / `:reset` events with a `values` payload keyed by `data-key` (a bound at its extent reports `null` = "Any"). Registered in the `use PureAdmin.Components` bulk macro. `range_group_core.js` is the verbatim upstream `range-group.js` (`window.PaRangeGroup`). New demo at `/components/range-group`.
- **`<.card>` header rework to rc05 canonical structure.** The title is now ALWAYS `.pa-card__title` > `.pa-card__title-text` (the `.pa-card__title-icon` span is the only optional part) — the previous three-way branching (bare `<h3>` when no icon, `.pa-card__title` when icon) is gone, so one DOM tree serves every card. Dropped the invented `pa-card__description--truncate` class: `.pa-card__description` truncates by default in the stylesheet and `header_wrap` (`pa-card__header--wrap`) opts out. Footer buttons already live in `.pa-card__actions` (auto-pinned to the trailing edge, no spacer needed). Backward compatible for callers using `title_text` / `:title` / `:title_icon`.
- **Demos** — `stats_live` gains a fit-mode showcase (priority ladder, wide/narrow layouts, `:context` slot); `buttons_live` gains an overflow toolbar section (two resizable bars — default `[⋮]` trigger + drop-from-end, and a ghost trigger + drop-from-start, each with a nested split button that collapses as an atomic labeled group); new `range_group_live` mirrors `range-group.mustache` (basic multi-range filter, handle shapes, ticks & click-to-seek, filter-card row) with a live event readout; all built with keen wrapper components.

## [1.2.0] - 2026-05-30 [PUBLISHED]

### Pure-admin v2.6.0 + v2.7.0 + v2.7.1 + v2.8.0 sync

Four upstream releases absorbed in a single library bump:

- **v2.6.0** (`05b416b`) — KPI showcase suite, framework token consolidation, Tailwind role palette, `pa-stat--square` redesign.
- **v2.7.0** (`12b9d23`) — `pa-modal--banded`, `pa-gauge` rebuild, CSS-variable consolidation sweep, link tokens, sidebar / btn-split / timeline / chip / live-card / outline-secondary fixes.
- **v2.7.1** (`2754d24`) — KPI showcases promoted from inline demo styles into permanent `pa-kpi-*` core components (8 SCSS partials, all `kpi-*` classes renamed to `pa-kpi-*`, per-component cascade vars namespaced to `--pa-kpi-*`).
- **v2.8.0** (2026-05-28) — the formerly-`[Unreleased]` post-2.7.1 commits graduated to a stable release (generic terminal tab strip, `auto-fit` cell-min grids on gauges + editorial, layout-ratio modifiers on hero + bento, composable `--no-prev`/`--no-delta`/`--no-target` toggles on numeric strip, `--no-delta` on sparkline list — all of which our Phase 2 already covered) **plus one architectural fix** (see below).

#### v2.8.0 architectural fix — CSS variable defaults at `:root` in the unthemed bundle

The bundled `@keenmate/pure-admin-core/css` (`dist/css/main.css`) now emits a complete neutral default for every `--pa-*` / `--base-*` token at `:root`. Before 2.8.0, only themes emitted `:root { --pa-* }` — consumers using the unthemed bundle standalone, OR any page during the FOUC window before its theme stylesheet finished loading, had `var(--pa-positive)` / `--pa-success-bg` / etc. resolve to invalid values. KPI sparklines and deltas rendered near-black via inherited text colour; web components fell back to hardcoded literals.

The fix lives in upstream's `main.scss` (not `_core.scss` — `_core.scss` stays purely component CSS, consumed by BOTH the unthemed bundle AND themes via `@import`; emitting `:root` there would duplicate when a theme also emits its own). Themes are unaffected — they bypass `main.scss` entirely.

**Impact for keen_pure_admin consumers**: no wrapper change required. Bump `@keenmate/pure-admin-core` to `^2.8.0` and KPI sparklines / deltas now render with reasonable neutral colours even before a theme link resolves — or with no theme at all. Supersedes the 2.7.1-era partial fix that only emitted the 5-step sentiment scale at `:root`.

#### KPI component family — 9 new modules / 12+ new function components

Built one module per showcase (matching `@keenmate/svelte-pure-admin` 1:1 in component names and prop names), all on the v2.7.1 `pa-kpi-*` class surface.

- **`PureAdmin.Components.Kpi`** (substrate)
    - `kpi_tile/1` — base tile (head · label · value · prev row · sparkline slot · optional hover detail). Used by Terminal grid + standalone. Status pill is `status_text` + `status_variant` (built-ins `warn` / `good` / `neutral`); `:head` snippet overrides the whole head row. Sentiment variants on value and delta use the 5-step scale (`very_positive` / `positive` / `neutral` / `negative` / `very_negative`). `variant` (formerly `spark_direction`) colours the sparkline via `currentColor`. `is_standalone` for tiles outside a `pa-kpi-terminal__grid`.
    - `kpi_detail/1` — popover element (`pa-kpi-detail` + `__title`). Auto-builds its `<dl>` from typed props (Current / Previous / Δ absolute / Δ percent / Target) on the host tile, or accepts raw markup via `:inner_block`. Replaces the previous `kpi_tile_detail/1` slot scaffold.
    - `kpi_sparkline/1` — opt-in convenience for the simple SVG polyline + trailing-dot pattern, on `pa-kpi-tile__spark`. Consumers using D3 / ApexCharts / Chart.js / Contex / etc. plug their renderer into the `:chart` slot instead.
- **`PureAdmin.Components.KpiDetail`** — shared helpers (`build_auto_rows/1`, `delta_to_sentiment/1`, `sentiment_class/1`, `dasherize/1`) used by every tile / row component. Mirrors `kpi-detail.ts` from svelte-pure-admin.
- **`PureAdmin.Components.KpiTerminal`** — `kpi_terminal/1` card wrapper with generic `:pane` tab strip (each pane has `id`, `label_text`, optional `is_active`); no panes → children wrapped in a single `pa-kpi-terminal__grid--2col`. `:header_controls` for custom toolbars between title and LIVE pill. The retired VALUE/Δ%/TREND view-mode toggle is replaced by the generic tab strip.
- **`PureAdmin.Components.KpiSparklineList`** — `kpi_sparkline_list/1` + `kpi_sparkline_row/1`. `is_no_delta` drops the rightmost Δ% column; `is_chart_first` rotates the L→R order 90° at narrow widths.
- **`PureAdmin.Components.KpiGaugeList`** — `kpi_gauge_list/1` + `kpi_gauge/1`. Default cell-min-driven `auto-fit` grid; switch via `grid_layout="2col"` or `"max_2".."max_6"`. `cell_min_width` overrides `--pa-kpi-gauge-cell-min`. `tick_position` / `tick_color` knobs.
- **`PureAdmin.Components.KpiHero`** — `kpi_hero_list/1` + `kpi_hero_main/1` + `kpi_hero_side/1`. `hero_split="2_3"` / `"3_4"` shifts weight to the hero (default 1:1). Hero has `:meta` slot (or `delta_text` / `period_text` / `target_text` for the canonical pattern), `:chart` for the sparkline; rail is a `:rail` slot.
- **`PureAdmin.Components.KpiBento`** — `kpi_bento/1` + `kpi_bento_tile/1`. Default 6-tile hero-left layout; `bento_layout="hero_right"` mirrors; `bento_layout="5_tile"` is hero + 4 supporting. `row_height` overrides `--pa-kpi-bento-row-height`. Set `is_hero` on the first tile.
- **`PureAdmin.Components.KpiStrip`** — `kpi_strip/1` + `kpi_strip_row/1`. Composable `no_previous_value` / `no_delta_percent` / `no_target_bar` toggles. Header row auto-generated from visible columns; override via `header_labels` (map keyed by column atom) or suppress via `no_header` or replace via `:head` slot. `target_bar_percent` drives the bar fill (capped at 100% visually); `target_percent_text` is the label below (may exceed 100).
- **`PureAdmin.Components.KpiEditorial`** — `kpi_editorial/1` + `kpi_editorial_tile/1`. Cell-min-driven `auto-fit` grid; `is_2_columns` boolean shorthand or `grid_layout="max_N"` cap modifiers. `target_text` auto-renders as `<em>tgt</em>{value}` in the meta row.
- **Three JS hooks** in `lib/assets/js/hooks/`:
    - `PureAdminKpiTile` — cursor-anchored Floating UI popover (virtual reference element); moves `.pa-kpi-detail` to `<body>` on mount, restores on `destroyed`. Auto-engaged whenever a tile / row has a popover.
    - `PureAdminKpiSparkDot` — converts SVG `<circle>` endpoints to `.pa-kpi-spark-dot` CSS spans so dots stay round under `preserveAspectRatio="none"`.
    - `PureAdminKpiTerminalTabs` — client-side tab strip wiring for `pa-kpi-terminal__tab` / `pa-kpi-terminal__pane`. Scoped per terminal so nested terminals (if any) stay isolated.

#### Other v2.7.0 component reworks

- **`Modal` — new `is_banded` boolean.** Emits `pa-modal--banded` alongside the existing `:variant` role modifier. Composes — `<.modal variant="success" is_banded>` produces `pa-modal pa-modal--success pa-modal--banded`. Buttons inside the bands auto-invert via the framework's CSS (light theme renders dark-on-pale; dark theme renders light-on-muted). No markup change beyond the new class.
- **`gauge/1` rebuild** — moved the label out of the donut so `__inner` holds only the value text. Label now renders as a sibling row alongside `__min` and `__max` below the gauge (matches v2.7.0 layout). New `:size` attr emits `--pa-gauge-size` inline (default upstream `12rem`). The `--value` style declaration is unchanged. Existing apps render the label in its new position automatically when they upgrade to `@keenmate/pure-admin-core` ^2.7.0; no markup change required.
- **`Stat` — 5-step sentiment scale on hero deltas.** `change_direction` now accepts `very_positive` / `very_negative` in addition to `positive` / `negative` / `neutral`. Internally converted to kebab-case (`pa-stat__change--very-positive` etc.) to match upstream's SCSS class names. Neutral colour shifted from `--pa-text-color-2` (grey) to `--pa-neutral` — purely a visual change, no API impact.
- **`Stat` icon `:danger`** — already exposed in the `icon_variant` enum (`primary` / `secondary` / `success` / `info` / `warning` / `danger`). The framework's previous omission of `--danger` was fixed in `_statistics.scss`; our wrapper already emitted the class so this becomes valid markup automatically when consumers upgrade.
- **`Card --live-up` / `--live-down`** — already exposed via `live_state="up"` / `"down"`. Upstream migrated the internal SCSS from `rgba(...)` over role colours to `color-mix()` over the 5-step sentiment scale; no API impact.
- **`btn-split`** — verified the wrapper doesn't emit `overflow: hidden` on `.pa-btn-split` (the v2.7.0 chevron-corner fix relies on the container NOT clipping). Wrapper is correct as-is.
- **`Timeline`** — v2.7.0 visual tweaks (simple-dot border-radius `50% → 30%`, shadow opacity `0.3 → 0.5`) are CSS-only with no wrapper change.

#### Demo app — `/kpi` section + non-KPI showcase updates

- **8 new LiveViews under `/kpi/*`** (sidebar entry "KPI", chart-line icon):
    - `/kpi/dashboard` — Combined dashboard exercising all 7 KPI components on one page (Hero + supporting + Terminal + Editorial + Sparkline list + Comparison gauges + Numeric strip + Bento). Useful for integration / spacing / theming verification.
    - `/kpi/terminal-grid`, `/kpi/sparkline-list`, `/kpi/comparison-gauges`, `/kpi/hero-supporting`, `/kpi/bento`, `/kpi/numeric-strip`, `/kpi/editorial-minimal` — each is a 1:1 port of upstream's `demo/views/kpi-*.mustache`: canonical card + layout-test stress sections (1×3 page-grid, 25/45 asymmetric, mixed grid modifiers) + per-page Usage Guide card + CSS Classes Reference card. The four chart-bearing pages (terminal grid, sparkline list, hero + supporting, bento) also include a Chart.js drop-in section demonstrating the library-agnostic `:chart` slot.
- **Chart.js drop-in** — `chart.js@4.4.3` loaded via CDN in `demo/lib/demo_web/components/layouts/root.html.heex`. New `PureAdminKpiChart` LiveView hook (`demo/assets/js/hooks/kpi_chart.js`, ~130 lines) renders bar / line / area charts into any `<canvas data-kpi-chart>`. Reads `currentColor` from the slot's KPI sentiment cascade, re-renders on `pa:theme-change`. Tied to LiveView mount/destroy lifecycle (not a one-shot DOMContentLoaded scan).
- **Modals demo** — new "Banded Modals · v2.7.0" section with 4 role variants (`is_banded` × success / warning / danger / info).
- **Stats demo** — new "5-step sentiment scale · v2.7.0" card showing all five hero deltas (`very_positive` / `positive` / `neutral` / `negative` / `very_negative`) side-by-side.
- **Cards demo** — new "Live-data direction · live_state" section with up / neutral / down tinted cards.
- **Data visualization demo** — new gauge `:size` examples (8rem / 12rem default / 16rem / 20rem) + subtitle noting the v2.7.0 layout rebuild.

#### Theme system — per-developer disk overrides + manifest improvements

- **`demo/pureadmin.json`** — declared all 15 themes (was 5). Team-wide, fetched via lockfile against `pureadmin.io`.
- **`demo/.pureadmin.json`** (gitignored — per-developer override) — maps every theme slug to `../../pure-admin-themes/{slug}` so themes load from a sibling checkout instead of the remote registry. Mirrors upstream `pure-admin/.pureadmin.json`.
- **`DemoWeb.ThemePlug` — dual-layout support.** Themes are now served correctly from BOTH the registry layout (`css/{name}.css` — zip extraction) AND the local-build layout (`dist/{name}.css` — direct copy from a sibling `pure-admin-themes` checkout). `valid_theme_dir?/2` probes either layout. New `resolve_theme_file/3` transparently maps the public URL `/themes/{slug}/css/{slug}.css` to the actual on-disk file. Without this, the on-demand re-downloader silently overwrote local copies on every page load.
- **`DemoWeb.PageContext.slim_color_variants`** — now passes through `description` per variant so the settings panel JS can use it as a `<option title>` tooltip.
- **`PureAdminSettings` JS hook — manifest-driven CSS path.** `_resolveThemeHref/1` reads `manifest.colorVariants[0].file` to build the stylesheet URL (handles both `dist/` and `css/`). `_applyThemeMode/1` is now pattern-aware via `manifest.modeCssClass` and clears every mode class declared by the manifest (was hardcoded `light` / `dark` only — important for themes declaring custom mode ids).

#### Tooling — Makefile + themes-install wiring

- **`Makefile`** — new `themes-install` target runs `npx @keenmate/pureadmin themes install` from `demo/` (defensive: skips silently if neither `demo/pureadmin.json` nor `demo/.pureadmin.json` exists). `dev:` and `setup:` now depend on `themes-install`, so `make dev` snapshots themes from `.pureadmin.json` disk overrides (or the remote-pinned lockfile) before booting the Phoenix server.

#### Fixed — KPI sparkline escape

- **Sparklines escaping their containers in Hero + supporting / Bento / Combined dashboard.** `PureAdminKpiSparkDot` always wrapped the SVG in `.pa-kpi-spark-wrap` (which has no `height` declaration), even when the SVG's parent was already a tight positioned anchor with explicit `height: 3rem` (`.pa-kpi-hero-main__chart-svg`, `.pa-kpi-bento-tile__chart-svg`). The extra wrap broke the SVG's `height: 100%` chain; combined with `preserveAspectRatio="none"` + `overflow: visible`, the polygon stretched across the entire viewport. Ported upstream's tight-anchor check from `pure-admin/demo/js/kpi-showcases.js`: skip wrapping when `getComputedStyle(parent).position !== 'static'` AND `parent.height ≈ svg.height` (within 4px). Terminal grid (where the SVG IS the anchor with its own explicit height) was unaffected by the bug and remains unaffected by the fix.

#### Fixed — KPI tooltip popover rendered empty (black box)

- **Every KPI tile / row showed an empty black popover on hover** when the host supplied `detail_title_text` + auto-built rows (the typical case). Phoenix's `inner_block` slot is always a non-empty list whenever the caller has open/close tags around the component — even if the only content between the tags is an empty `<%= for d <- @detail do %>…<% end %>` loop that produces no output. `kpi_detail/1`'s `has_inner?` check (`assigns.inner_block != []`) treated that as "consumer provided custom popover content" → took the inner_block branch → rendered nothing → typed `title_text` + `rows` were silently ignored. The visible result was the popover chrome (`pa-kpi-detail` background + shadow) with no content inside.
- **Fix at every call site** (8 tile/row modules: `kpi_tile/1`, `kpi_sparkline_row/1`, `kpi_gauge/1`, `kpi_hero_main/1`, `kpi_hero_side/1`, `kpi_bento_tile/1`, `kpi_strip_row/1`, `kpi_editorial_tile/1`): branch the call into `<.kpi_detail>...</...>` form when the consumer's `:detail` slot has content, and `<.kpi_detail .../>` (self-closing) form otherwise. Self-closing leaves `inner_block == []`, so `kpi_detail/1`'s `has_inner?` check becomes a reliable signal. Auto-built rows render correctly; consumer's custom `:detail` slot still wins when supplied.
- **Defensive: no tooltip when none defined.** `has_detail?` is computed as `@detail != [] or @detail_title_text != nil` — when both are absent, `phx-hook="PureAdminKpiTile"` isn't emitted, the `<.kpi_detail>` element isn't rendered, no `.pa-kpi-detail` exists in the DOM, and the JS hook's `mounted()` also has `if (!this.detail) return` as a safety net.

#### Added — `pa:theme-change` event dispatch in settings panel hook (canvas chart reactivity)

- **`PureAdminSettings` hook now dispatches `pa:theme-change` window events** so consumer code that snapshots colours at draw time (Chart.js, ECharts, D3, custom canvas) can re-sample after a theme appearance change. Three event kinds:
    - `{ kind: "mode", mode }` — fired at the end of `_applyThemeMode` after the `pc-mode-*` body class flips (light↔dark toggle).
    - `{ kind: "variant", variant }` — fired at the end of `_applyColorVariant` after the `pa-color-*` body class flips (color variant picker).
    - `{ kind: "theme", themeId }` — fired tied to the `<link id="pa-theme-css">` element's `load` (or `error`) event after a theme stylesheet swap, so canvas re-sampling happens AFTER the new CSS is in effect — not before. One-shot listener that auto-removes itself; the next swap installs its own.
- **Early-return paths intentionally skip the dispatch** — when the target class is already on `<body>` (nothing visual changed) the events don't fire, so consumers don't waste cycles re-drawing.
- **Matches upstream pure-admin demo's contract** (`demo/js/settings-panel.js` dispatches the same event with the same kinds for mode / variant). Theme-swap dispatch is our addition — upstream doesn't fire on swap; the svelte side (1.8.0) covers this case with their separate `chartColorSync` action that listens for the link `load` independently.
- **Why this matters**: SVG sparklines re-colour live via `currentColor`. Canvas charts (including the existing `PureAdminKpiChart` hook in the demo) cache `getComputedStyle(canvas).color` at draw time. Without this dispatch, the canvas froze on every theme/mode change while the SVG around it updated — visually broken. With this dispatch, the hook's `_recolor()` runs and the canvas re-paints in place.

#### Changed — `PureAdminKpiChart` demo hook gains `stacked-bar` + `doughnut` chart types

- **Two new `data-kpi-type` values** for the `demo/assets/js/hooks/kpi_chart.js` hook:
    - `data-kpi-type="stacked-bar"` — multi-series stacked bar chart. `data-kpi-points` accepts array-of-arrays JSON (`"[[120,140,160,180],[280,290,300,320],[60,70,80,90]]"`); each inner array becomes a stacked series. Optional `data-kpi-labels='["Q1","Q2","Q3","Q4"]'` for x-axis labels (mostly cosmetic — axes stay hidden).
    - `data-kpi-type="doughnut"` — single-series doughnut. `data-kpi-points` is a flat array of slice values; cutout fixed at `62%`, slice spacing `2px`.
- **`SERIES_OPACITY = [0.95, 0.65, 0.42, 0.25, 0.15]`** — multi-series and multi-slice colours derive from the host's resolved `currentColor` at decreasing alpha, so each series/slice reads distinctly while still inheriting the KPI sentiment + theme cascade. Both new types re-paint correctly on `pa:theme-change`.
- **`readPoints/1` is now flatten-safe** — when `data-kpi-points` is array-of-arrays (multi-series format) and a single-series chart type (`line` / `bar`) is requested, it returns the first inner array. So the same data attribute shape can drive either single-series or multi-series charts.

#### Changed — Dashboard rewrite (1:1 with @keenmate/svelte-pure-admin v1.8.0)

- **`/` (`DashboardLive`) overhauled** to mirror svelte-pure-admin's `docs/src/routes/+page.svelte`. Diff vs. the previous version:
    - Old placeholder "Top Sales Products" card (an `<i class="fa-chart-bar">` icon and the text "Chart Placeholder") replaced with a real **`kpi_sparkline_list`** carrying 5 product rows (Epsilon up-strong, Alpha / Delta / Beta up, Gamma down), each backed by a Chart.js area sparkline via `<canvas data-kpi-chart>`.
    - Old "Revenue Trend" section (hand-drawn double `<polyline>` SVG with hardcoded points) replaced with a **`kpi_hero_list` `hero_split="2_3"`** + a 13-point Chart.js area chart in the hero + 3 `kpi_hero_side` rail tiles (YTD Revenue, Q4 Actual, Forecast EOY).
    - Old separate "Revenue Trend & Traffic Sources" row removed — Traffic Sources moved into the right column of the new Top Sales row.
    - Timeline items in "Recent Activity" — first 3 (most-recent) items now carry `is_filled` to match svelte's `isFilled`. Filled markers signal "just happened"; the older two stay outlined.
    - New `mount/3` assigns: `top_sales` (5 products with sentiment-ordered ranking + Chart.js data series strings) and `revenue_trend_points` (13-point string).
    - Everything else (4-up metric cards, KPI squares grid, Recent Orders table, Top Products / System Status / Quick Actions footer row) unchanged.

#### Changed — `/kpi/dashboard` extended with Chart.js stacked bars + doughnuts

- **New section: "Revenue by Segment · Q1–Q4 weekly"** — `kpi_sparkline_list` with 4 rows (Enterprise / SMB / Consumer / Marketplace) each showing a stacked-bar Chart.js chart (New + Renewals + Upgrades, 4 quarters). Each row carries the full popover prop set (Current / Previous / Δ absolute / Δ percent / Target) so the tooltip-fix is also exercised on this section.
- **New section: "Pipeline & Distribution · Chart.js mix"** — `kpi_bento` mixing both new chart types in one layout:
    - Hero: Pipeline by Stage (stacked bars, 8 weeks × 3 stages)
    - Customer Mix + Top Channels + Forecast Confidence (doughnuts at 4 / 5 / 2 slices)
    - Deals by Region + Stalled % (stacked bars, 6 categories × 2 series)
    - Sentiment cascade exercised: Stalled % is `negative` (red), Forecast Confidence is `neutral` (grey), the rest are `positive` / `up_strong` (green tones).
- **Integration test coverage**: with all the recent fixes in place, this page exercises (a) the popover-rendering fix in 4 sparkline rows + 6 bento tiles, (b) the `pa:theme-change` event dispatch by re-colouring both inline-SVG sparklines (via `currentColor`) and Chart.js canvases (via `_recolor()`) on mode flip / theme swap, and (c) the new stacked-bar + doughnut chart types via the `SERIES_OPACITY` cascade.

#### Docs / demo / bookkeeping (catch-up pass)

- **`docs/theming.md` rewritten** — full reference for the v2.8.0 token surface: canonical role tokens (`--pa-success` / `-warning` / `-danger` / `-info`), 5-step sentiment scale, text-contrast tiers (`--pa-text-strong` / `-secondary` / `-tertiary`), surface tints (`--pa-surface-hover` / `-track`), link tokens, chart-trendline tokens, detail-popover chrome, gauge-size, KPI namespaced tokens, plus a callout for the v2.8.0 `:root` defaults architectural fix.
- **`pa-stat--square` prefix-currency mode wired up.** New `is_prefix_symbol` boolean on `stat/1` (square variant only) flips DOM order to `<symbol><number>` for prefix currencies (`$847K`, `¥12.4M`); default false renders `<number><symbol>` for suffix units (`87%`, `23°C`). Matches v2.6.0's "markup order drives visual order" contract — no CSS modifier needed. Demo `/components/stats` gained a "Square stats — mixed units · v2.6.0" card showing all four cases side-by-side.
- **`component-audit.md` re-stamped to `d49531c` (v2.8.0).** Seven existing rows re-anchored to `12b9d23` (v2.7.0): Modal (banded), Card (live-up/down sentiment), Stat (square redesign + 5-step), Timeline (visual tweaks), Button (btn-split chevron-corner fix), DataDisplay (fields-chips polish), DataViz (gauge rebuild). Nine new rows added under "no current snippet" for the KPI family (Kpi, KpiDetail, KpiTerminal, KpiSparklineList, KpiGaugeList, KpiHero, KpiBento, KpiStrip, KpiEditorial) — each anchored to its v2.7.1 SCSS partial plus the v2.8.0 commit that added the layout-modifier follow-ups.
- **`package.json` — declared `peerDependencies: { "@keenmate/pure-admin-core": "^2.8.0" }`.** Previously the package made no machine-readable claim about which framework version it targeted; the CHANGELOG and README said "^2.8.0" but `package.json` was silent.

### Pure-admin v2.5.0 sync

Re-anchored the alert component to pure-admin v2.5.0 (`1f9d818`). The framework rewrote the alert layout: structural children stack via `flex-basis: 100%` instead of inheriting the alert's flex row, the heading defaults to a compact look with the punchy treatment becoming opt-in, and the icon-vs-content alignment was inverted to centre by default.

- **`Alert` — drops the `pa-alert__content` wrapper when no `:icon` slot is supplied (Breaking).** The framework's flex-wrap rules give structural children (`__heading`, `__list`, `__actions`, top-level `<p>`/`<hr>`) `flex-basis: 100%` so each lands on its own row inside `.pa-alert` directly. Wrapping them in `__content` "for consistency" moved them out of the `> p` / `> hr` selector reach, which broke the new layout. The wrapper is still emitted whenever an `:icon` slot is present (icon + non-icon content has to be the two flex children of the alert). **Migration:** apps that styled descendants via `.pa-alert__content >` selectors should switch to `.pa-alert >` selectors when the alert has no icon.
- **`Alert` — new `heading_size` attr (`nil` \| `"lg"`).** v2.5.0 unified `pa-alert__heading` to default to the body font-size + semibold weight. `heading_size="lg"` adds the `pa-alert__heading--lg` modifier for the louder, deliberate-read presentation (blocking errors, system updates, quota warnings). Existing alerts that used `<:heading>` or `heading_text` will render visually smaller than before — pass `heading_size="lg"` to preserve the previous appearance.
- **`Alert` — new `is_multiline` attr.** Adds `pa-alert--multiline` to opt back to `align-items: flex-start`. Use when an icon sits next to multi-line `__content` (heading + body + actions) so the icon stays at the top with the heading instead of centring against the whole stack. Default centred alignment is correct for icon + single-line content.
- **`alert__actions`, sizes, and padding scale** — no markup change required on our side; rendering automatically picks up the new toast-style separator above `__actions`, the real `--sm` / `--lg` size scale, and the centred default alignment as soon as the consumer upgrades `@keenmate/pure-admin-core` to ^2.5.0.
- **`component-audit.md`** — alert row re-stamped to `2ef8034` (2026-04-25, v2.5.0). Other components unchanged since v2.5.0 only touched `_alerts.scss` and supporting variables.

Demo `/components/alerts` page gained a "Header style: compact vs. punchy" card (same Validation failed / Saved messages rendered both ways), an explicit "Sizes" stack (sm / default / lg), and an "Icon with multi-line content" example showing `is_multiline`. The old "Compact Alerts in Grid" card was renamed to "Status strip layout" since it's a real-world layout pattern, not a sizes demo.

### Component audit

Cross-checked every library component against the current `@keenmate/pure-admin-core` HTML snippets and recorded per-component audit status in the new `component-audit.md` at repo root. **30 snippets** reviewed across two passes (anchor pure-admin commit `cf75736`):

- First pass (2026-04-24, anchor `e4f1cd6`): 23 snippets that were upstream-audited at the time.
- Second pass (2026-04-25, anchor `cf75736`): 7 newly-audited snippets that closed upstream's pending list and snippet gaps — `modals.html`, `modal-dialogs.html`, `data-display.html`, `notifications.html`, `statistics.html`, `filter-card.html`, `detail-panel.html`. None of the previously-audited snippets changed.

Drift fixes:

- **`Popconfirm`** — server render now emits the initial `pa-popconfirm--{bottom|top|start|end}` class (previously only `data-placement` was set, so CSS rules keyed on the class rendered inconsistently before Floating UI ran). The client-side position helper in `events/popconfirm.js` now strips the logical `start|end` class pair on flip (was looking for physical `left|right` that never appeared) and maps Floating UI's physical `result.placement` back to our logical class via a `physicalToLogical()` helper — RTL collision-flipped popconfirms now render correctly.
- **`Popover`** — title in `.pa-popover__header` now renders as `<h4>` (was `<span class="pa-popover__title">`) to match the snippet's semantic heading pattern and inherit the framework's heading-reset rules.
- **`Callout`** — `.pa-callout__heading` now renders as `<h4>` (was `<div>`) to match the snippet; picks up the shared heading margin reset instead of needing override rules.
- **`Card`** — the `:tools` slot now emits `<div class="pa-card__actions">` (was `pa-card__tools`, which has no CSS backing). Slot name kept for API stability.
- **`Loader` / `spinner`** — `size` attr narrowed from `[nil, "xs", "sm", "md", "lg", "xl", "2xl"]` to `[nil, "xs"]`. The other sizes produced invalid class names (`pa-spinner--lg`, etc.) that don't exist in the SCSS framework — they all rendered at the default 16 px, which is confusing. Demo page updated to show only default + `--xs`. **Breaking for apps passing those size values** — drop the attr to fall back to default.
- **`Modal`** — header close button class flipped from `pa-btn pa-btn--primary pa-btn--icon-only pa-btn--sm` to `pa-btn pa-btn--sm pa-btn--icon-only pa-btn--secondary` for the default modal and `… pa-btn--light` for themed modals (`variant`/`header_variant` set), matching the snippet's "secondary on neutral header / light on coloured header strip" pattern.
- **`PureAdminDetailPanel` JS hook** — full rewrite to match the contract documented in `detail-panel.html`. Drag handle selector changed from `.pa-detail-panel__handle` (which never matched real markup) to `.pa-detail-panel-resize`; new width is written to `--pa-local-detail-panel-width` on `<html>` (was inline `style.width` on the panel, which only worked when the panel had no width-via-CSS-variable rule — i.e. never on real pure-admin markup); body picks up `pa-detail-panel-resizing` during drag to suppress text selection; handle picks up `pa-detail-panel-resize--active`; drag direction inverts in RTL; min-width clamped to 200 px. **Breaking for apps wiring the old hook** — they relied on a selector that didn't match the snippet anyway; switch the handle markup to `<div class="pa-detail-panel-resize">` and the panel will resize correctly.
- **`component-audit.md` (new)** at the repo root tracks every component's audit status, which snippet it was verified against, and the pure-admin commit hash at time of verification. Re-audits flip the row back to ⏳ when upstream ships a newer snippet.

Components with acknowledged gaps deferred to a later release (tracked in `component-audit.md`):
- **`Code`** — still a Phase-2 stub (class naming / copy button / syntax tokens not yet modeled).
- **`Profile`** — favourites subsystem (`__favorite-item`, `__favorite-icon`, `__favorite-label`, `__favorite-remove`, `__favorites-add`) not yet exposed as components; apps hand-roll the markup today.
- **`Timeline`** — alternating-layout `__date`/`__time` logic is muddled and `pa-timeline--single-column` isn't exposed.

### Security

- **`Pager` — dropped `Phoenix.HTML.raw/1` on the `icon_*` attrs (audit finding #1, High).** The four navigation icon attrs (`icon_first`, `icon_previous`, `icon_next`, `icon_last`) are now rendered HTML-escaped and default to Unicode chevrons (`«‹›»`) rather than HTML entity strings. Callers that need markup (e.g. Font Awesome, inline SVG) use the new `:first_icon`/`:previous_icon`/`:next_icon`/`:last_icon` slots. **Breaking for apps passing HTML in the string attrs**; migrate those to the slots.
- **`PureAdminFlash` hook — validate URL scheme in markdown links (audit finding #2, High).** Markdown links of the form `[text](url)` previously let any URL — including `javascript:alert(1)` — flow into `href=`. URLs starting with `javascript:`, `data:`, or `vbscript:` (case- and whitespace-insensitive) are now replaced with `#`. Other schemes (http/https/mailto/tel) and relative paths pass through unchanged.
- **Strict-CSP support — removed every inline `onclick=` and `<script>` from components (audit findings #10 and #11).** `popconfirm/1`, `popover/1`, `badge_group/1`, `tabs/1` (scrollable), and `field/1` (copy buttons) previously rendered inline event handlers and embedded `<script>` blocks that required `'unsafe-inline'` on CSP `script-src`. Behaviour moved into a single delegated-events module (`lib/assets/js/events/`) and exposed via **new `initPureAdminEvents()` export** — components now emit `data-pa-*` attributes and the module's document-level click listeners dispatch on them. Apps can now run with `script-src 'self'` out of the box; the FOUC prevention script (`<.fouc_prevention_script />`) remains the single inline `<script>` and needs a per-request nonce in strict-CSP setups.
  - **Migration:** add `initPureAdminEvents()` alongside your existing `initModalDialogs()` call in `app.js`. No template changes required for library components.
- **`desc_table` — `label_width` validated as a CSS length (audit finding #4).** The attr is now interpolated into `style=` only if it matches a single CSS length token (digits + `%`/`px`/`rem`/`em`/`vw`/`vh`/`ch`/`cm`/`mm`/`in`/`pt`/`pc`). Anything containing `;`, whitespace, parens, or extra tokens is ignored rather than injected, closing a CSS injection path if the attr is bound to user input.
- **Flash / Toast — action buttons no longer round-trip through `data-action` (audit finding #5).** `push_flash` / `push_toast` actions were previously serialised to JSON, attribute-escaped, then parsed back on click. Buttons are now built as DOM elements with the action object captured directly in a closure — no JSON in attributes, no bespoke `_escapeAttr`, and no attribute-escape attack surface. Removed the now-unused `_escapeAttr` helper from both hooks.
- **`PureAdminProfilePanel` — URL scheme check before navigation (audit finding #6).** Favourite items previously assigned `dataset.href` directly to `window.location.href`. `javascript:` / `data:` / `vbscript:` / `file:` URIs are now rejected; everything else (http/https, `mailto:`, `tel:`, `sms:`, deep-link schemes like `slack://`, `intent://`, `myapp://`, relative paths) passes through.
- **`PureAdmin.Helpers.safe_url/1` (audit finding #7).** New helper that returns `url` if it uses a safe scheme, otherwise a fallback (defaults to `"#"`). Deny-list semantics — blocks only the four schemes a browser will execute (`javascript:`, `data:`, `vbscript:`, `file:`), so custom app schemes and non-HTTP protocols still work. Applied automatically to `href={@href}` in `pa_link/1`, `button/1`, `navbar_nav_item/1`, `sidebar_item/1`, and `profile_nav_item/1`, so apps binding user content to those attrs get defense-in-depth for free.
- **`getPageContext()` — robust parse (audit finding #8).** The hidden-input JSON is now parsed inside a try/catch and validated to be a plain object; malformed or non-object payloads fall back to `{}` with a `console.warn` instead of throwing into the caller.
- **Settings / sidebar resize — localStorage inputs validated (audit finding #9).** `font-size` and `container-width` settings are now allowlist-checked before being concatenated into a CSS class name. Sidebar width is integer-parsed and clamped to `[180, 500]` when restored from storage (and only the numeric value, no unit, is persisted).
- **`PureAdmin.custom()` modal — documented trust boundary (audit finding #12).** The caller-supplied `render(container, close)` function writes directly to the DOM — the JSDoc now makes it explicit that this is a ⚠ XSS sink if user content is inserted via `innerHTML`.

### Demo

- Swap the *Stored Submissions* card for `<.table_card is_scrollable>` on the `/phoenix/form-demo` page so narrow viewports scroll the table horizontally inside the card instead of clipping the rightmost columns.

---

## [1.1.0] - 2026-04-23 [PUBLISHED]

### Added

- **`:field` attr on form components** — `input/1`, `textarea/1`, `select/1`, `checkbox/1`, `radio/1`, and `form_group/1` now accept `field={@form[:x]}` for one-line Phoenix form binding. Derives `name`, `id`, `value` (or `checked`), and error state from the `Phoenix.HTML.FormField` struct; explicit attrs still win. `used_input?/1` is respected so unsubmitted fields don't show stale errors.
- **Auto-rendered field errors** — when `field=` is set and the field has errors, `input`/`textarea`/`select` automatically render a `form_help` below themselves in the error variant. Opt out with `show_errors={false}`. `form_group` flips to `validation="error"` in the same condition.
- **`PureAdmin.Components.Form.translate_error/1`** — default `%{key}`-interpolating error formatter, overridable via `config :keen_pure_admin, :error_formatter` (MFA tuple or 1-arity function) for Gettext-aware apps.
- **`PureAdmin.DateTime`** — new top-level helper with `format/2` (styles: `:short_date`, `:long_date`, `:full_date`, `:time`, `:long_time`, `:short_date_time`, `:long_date_time`, `:relative`, or any raw strftime pattern) and `relative/2` (buckets time diffs into `now` / seconds / minutes / hours / yesterday / days / weeks / months / years, past and future; accepts `now:` for deterministic tests). Accepts `Date`, `NaiveDateTime`, and `DateTime`. Month names, weekday names, and relative phrases all flow through `PureAdmin.Translations.t/2`.
- **Translation keys** — 47 new keys under `pureAdmin.datetime.*` (connectors, relative phrases past/future, 12 month names, 7 weekday names).
- **`push_flash/5` gained `replace: true`** — wipes any existing alerts in the container before rendering the new one, so status messages don't stack.
- **`PureAdmin.Components.Flash.clear_flash/2`** — dedicated "clear without pushing" helper.
- **`PureAdminFlash` hook** — honors both the `replace` payload flag and a new `pa:flash-clear` event.

### Fixed

- Getting Started page — resolved an outdented-heredoc compiler warning by moving a code block into a module attribute.

---

## [1.0.0] - 2026-04-11 [PUBLISHED]

First stable release. Phoenix LiveView component library wrapping Pure Admin CSS framework into 35+ function components, 14 JS hooks, and 3 LiveComponents.

### Highlights

- **Drop-in CoreComponents replacement** — `use PureAdmin.Components` replaces the Phoenix-generated `CoreComponents` module
- **`PureAdmin.Config`** — centralized app configuration (`:app_name`, `:app_logo`, `:app_version`, `:copyright`, `:font_class`). Components like `navbar_brand/1` and `footer/1` read from it automatically
- **`package.json`** — enables `import "keen_pure_admin"` in esbuild for hex dependents
- **`pureadmin create` template** — scaffold a full Phoenix LiveView app with PureAdmin layout via the [PureAdmin CLI](https://www.npmjs.com/package/@keenmate/pureadmin)

### What's included

- 35+ function components: layout, navbar, sidebar, buttons, badges, cards, tables, modals, forms, tabs, tooltips, toasts, flash, pagers, loaders, timeline, code, stats, and more
- 14 JS hooks: sidebar toggle/resize/submenu persistence, settings panel, profile panel, command palette, toast/flash, tooltip/popover (Floating UI), split button, char counter, checkbox, infinite scroll
- 3 LiveComponents: CommandPalette, ToastLive, DialogService
- Full BEM class support with `build_classes/3` helper
- i18n via runtime translation callback (~60 keys)
- Page context system (server → JS, CSP-safe)
- Persistent logging (`PureAdmin.logging.enableLogging()` survives page reloads)

### Installation

```elixir
{:keen_pure_admin, "~> 1.0"}
```

See the [README](README.md) for full setup guide or use the PureAdmin CLI:

```bash
npx @keenmate/pureadmin create my-app --template phoenix-liveview
```

Compatible with `@keenmate/pure-admin-core` v2.3.6 and Phoenix LiveView ~> 1.0.

---

## [1.0.0-rc.2] - 2026-04-03 [PUBLISHED]

### Added

- **`PureAdmin.Config`** — application-level configuration system. Set `:app_name`, `:app_logo`, `:app_version`, `:copyright`, `:font_class` in `config.exs` and components read from it automatically
- **`navbar_brand/1`** — falls back to config `:app_name` and `:app_logo` when no inner content provided
- **`footer/1`** — falls back to config `:copyright` (start slot) and `:app_version` (end slot) when no slots provided
- **`PureAdmin.Config.root_html_attrs/0`** — returns `%{class: font_class}` for the `<html>` element, supports `pa-font-responsive` and granular `pa-font-base-{9-12}` / `pa-font-mobile-{9-12}` classes from pure-admin-core v2.3.6
- **Getting Started page** — new demo page with installation, setup timeline, responsive font sizing, available themes, and component overview (mirrors Svelte demo structure)

### Changed

- **Root layout** — removed separate `pure-admin.css` link; theme CSS already includes the core framework
- **Dockerfile** — switched theme download from broken `curl` + zip API to `npx @keenmate/pureadmin themes --dir` CLI, added CSS copy step for `app.css`

### Bug Fixes

- **Sidebar** — fix mobile toggle not working: `toggle_sidebar()` was hardcoded to dispatch to `#sidebar`, now accepts configurable target ID via `navbar_burger` `target` attr
- **Logger** — `enableLogging()` now persists across page reloads via localStorage
- **Sidebar** — optimize resize handler to only act on breakpoint crossings
- **Docker build** — fix 404 for CSS assets (`pure-admin.css`, `audi.css`) — app CSS was never copied to `priv/static` and theme bundle API returned empty zip

## [1.0.0-rc.1] - 2026-04-01 [PUBLISHED]

### Flash Messages

- **`PureAdmin.Components.Flash`** — new module with two approaches:
  - **Standard flash** — `flash/1` and `flash_group/1` as drop-in replacements for CoreComponents, styled with `pa-alert` BEM classes. Works with Phoenix's built-in `put_flash/3`
  - **Independent flash containers** — `flash_container/1` + `push_flash/5` for multiple independent flash groups on the same page. Each container receives messages independently via a JS hook
- **`PureAdminFlash`** JS hook — client-side rendering of flash alerts. Supports markdown body (**bold**, *italic*, `[links](url)`, lists, `---` horizontal rules), action buttons with `pushEvent` callbacks, auto-dismiss, and dismissible close button
- **Markdown body** — flash message text supports basic markdown rendered as proper `pa-alert__content` HTML
- **Action buttons** — flash messages can include action buttons that push events back to the LiveView or dismiss the flash

### Toast Updates (pure-admin 2.3.0)

- **Toast action buttons** — `push_toast/5` accepts `:actions` option with `%{label, event, params, variant, dismiss}` maps. JS hook renders `pa-toast__actions` with `pa-btn--xs` buttons inside `pa-toast__content`. Clicking an action fires `pushEvent` back to the server, then auto-dismisses
- **Toast progress bar** — `:progress` option renders `pa-toast__progress` bar that animates from 100% to 0% over the duration. `:progress_color` option overrides the bar color via inline style
- **Filled toasts via push_toast** — `:filled` option renders `pa-toast--filled-{variant}` class
- **`max_width`** — custom max-width per toast (e.g. `max_width: "50rem"`)
- **Width ratchet** — container `min-width` tracks the widest toast shown, resets when container is empty
- **Click-to-dismiss** — toasts without actions are click-to-dismiss (cursor: pointer). Toasts with actions require close button or action click

### Command Palette v2

- **Multi-step commands** (`/prefix`) — register commands with `steps`, each with `prompt`, `placeholder`, and optional `free_text`. Steps progress sequentially with selections displayed as locked tokens. Commands complete via `handle_info({:command_complete, cmd_id, selections})`
- **Search contexts** (`:prefix`) — register scoped search contexts with `shortcut` and `aliases`. Typing `:p laptop` searches products for "laptop"
- **Global search** — typing without a prefix searches across all data
- **6 modes** — `idle`, `command_list`, `command_step`, `context_list`, `context_search`, `global_search` with full state machine transitions
- **Step filtering** — typing in a command step filters the step options in real-time
- **Step back** — Backspace at position 0 or Escape goes to previous step (or back to command/context list)
- **`cp:` event protocol** — namespaced events (`cp:toggle`, `cp:input`, `cp:select`, `cp:step_back`, etc.) replacing `command_palette_` prefix
- **`cp:reset_input` push_event** — force-clears browser input on mode transitions (LiveView doesn't patch focused inputs)
- **Debounced search** — 150ms debounce for context and global search, instant for command/context list filtering
- **Mode-aware keyboard** — Escape goes back in step/context modes instead of closing. Footer hints update per mode
- **Two display styles** — `display="inline"` (default, Svelte-style: full sentence in input with command badge) and `display="tokens"` (original: colored token spans above a clean input). Switchable at runtime

### Command Palette (pure-admin 2.3.3 / 2.3.4)


- **`pa-command-palette__input-wrapper`** — new wrapper around input + context label for correct positioning
- **`pa-command-palette__token-prompt`** — step prompt text between token badges (replaces `__token--prompt`)
- **Standard `pa-badge`** — item badges now use `pa-badge` instead of custom `pa-command-palette__item-badge`
- **Token badges** — step tokens in tokens mode use `pa-badge pa-badge--primary` for command name, plain `pa-badge` for values
- **Tokens `&:empty` hiding** — tokens div hides automatically when empty via CSS
- **Home screen** — idle state shows categorized list of commands (with Alt+key hotkey badges) and search contexts, all clickable
- **Hotkeys** — `Alt+D` Deploy, `Alt+A` Assign, `Alt+G` Go to Page, `Alt+T` Switch Theme. Work globally and inside the palette
- **Global search includes commands/contexts** — typing "deploy" finds the Deploy command alongside data results. Selecting a command/context enters that mode
- **Form codes** — `/go` page options have numeric codes (e.g., `24` for Alerts). `filter_options` matches on label, description, and exact code
- **`pa-command-palette__home`** — home screen container with `__home-section` separators and `__home-heading` labels
- **`pa-command-palette__shortcut`** — flex container for multi-key hotkey badge groups

### Translations (i18n)

- **`PureAdmin.Translations`** — new module with runtime translation callback system. Ships with ~60 English defaults under `pureAdmin.*` flat keys. Apps override via config: `config :keen_pure_admin, translate: &MyApp.translate/2`
- **`t(key, params)`** — main translation function with `%{param}` interpolation. Falls back to English when callback returns nil or isn't configured
- **`interpolate(string, params)`** — exported helper for app callbacks
- **All components updated** — hardcoded English strings replaced with `t()` calls across command palette, pager, popconfirm, modal, alert, toast, flash, settings panel (~60 keys)

### Components (pure-admin 2.3.1 / 2.3.2)

- **`split_button/1`** — chevron icon now points up (`fa-chevron-up`) for `top-*` placements, down for `bottom-*`
- **`split_button/1` primary icon** — new `icon` attr for Font Awesome icon on the primary button (e.g. `icon="fas fa-download"`)
- **`split_button/1` item icons** — `:item` slot now accepts `icon` attr (e.g. `icon="fas fa-file"`) rendering as `pa-btn-split__item-icon`
- **`split_button/1` inline action buttons** — `:item` slot accepts `action_icon`, `action_event`, `action_value`, `action_variant` attrs for inline action buttons beside menu items (e.g. delete/remove). The JS hook forwards clicks via `pushEvent` since the menu is moved to `document.body`
- **`button/1` label wrapping** — button text is wrapped in `<span class="pa-btn__label">` when an icon is present, enabling proper centering with `align="center"`
- **`split_button/1` menu structure** — uses `pa-btn-split__menu-inner` wrapper and `pa-btn-split__item-row` BEM elements (replaces inline styles), matching pure-admin 2.3.2 two-container pattern
- **`input_group/1`** — `:button` slot now documented to use `class="pa-input-group__button"` on the button element

### Demo

- **Phoenix / LiveView** sidebar section — new section for framework-specific features (matches Svelte demo's "Svelte" section)
- **CoreComponents Migration** page — migration table showing replaced vs manual functions, setup timeline
- **Flash Messages** page — independent containers demo, variant showcase, markdown + action buttons demo, standard `@flash` compatibility
- **Toasts** page — added progress bar demos (standard + filled), action toast demos (Undo, Retry, Update, Filled + Actions), theme color toasts with filled subsection
- **Buttons** page — split buttons card moved after Responsive Direction to match pure-admin layout 1:1, consolidated into single card with subsections (Sizes, Upward Placement, Custom Icons)

### Theme Cache Invalidation

- **`ThemePlug` auto-refresh** — cached themes are validated against pureadmin.io using `content_sha` from the theme's `checksums` field. On first access after startup, the plug sends a conditional request (`If-None-Match`) to the API in the background. If the server returns 200 (sha mismatch), the theme is re-downloaded without blocking the current request. 304 means the cache is fresh. Freshness checks are throttled to once per 10 minutes per theme
- **`make themes-clear`** — new Makefile target to force-clear the theme cache, triggering fresh downloads on next access

### Documentation

- **Prerequisites** section added to README and getting-started guide (`mix phx.new --no-tailwind`)
- **Main site** link added to README ([pureadmin.io](https://pureadmin.io))
- **Theme installation** guide — actual zip structure from pureadmin.io API, self-contained relative paths. Three installation options: Pure Admin CLI (`@keenmate/pureadmin`), manual download, CI/CD Dockerfile
- **Creating custom themes** — new section in theming docs referencing the CLI's `init`, `build`, `pack`, `publish` workflow
- **Theme customization via SCSS** — variable overrides, custom fonts, baseline correction, complete example
- **`make help`** — all Makefile targets now have `## description` comments

Compatible with `@keenmate/pure-admin-core` v2.3.5.

## v1.0.0-rc.1 (initial)

First release candidate. Consolidates all v0.x development into a stable API.

### Highlights

- **35+ function components** covering the full Pure Admin CSS framework: layout, navigation, forms, tables, data display, modals, toasts, and more
- **13 JS hooks** for interactive features: settings panel, tooltips, popovers, split buttons, sidebar persistence, command palette, character counters, and more
- **Drop-in `CoreComponents` replacement** -- `use PureAdmin.Components` gives you everything
- **Full BEM class support** with `build_classes/3` helper
- **RTL support** for tooltips and popovers
- **Podman/Docker support** for the demo app
- **Live demo** at [elixir.demo.pureadmin.io](https://elixir.demo.pureadmin.io)

### Settings Panel

- **Dynamic theme manifests** — settings panel JS now fetches `/api/themes/manifests` and dynamically populates theme selector (sorted alphabetically), replacing hardcoded `themes` prop
- **Color variants** — new `data-section="color-variant"` section, shown/hidden based on theme manifest. Applies `pa-color-{variant}` CSS class to body. Supports per-variant mode lists
- **Mode per variant** — mode selector updates when color variant changes, auto-hides if only one mode available, auto-applies single mode
- **Font detection from manifest** — "Theme Default" option shows bundled font name (e.g., "Theme Default (Fira Sans Condensed)"), skips Google Fonts download if theme already bundles the font
- **Removed `themes` attr** from `settings_panel/1` — themes are now loaded dynamically, only `default_theme` attr remains

### On-Demand Theme Downloads

- **ThemePlug** — new Plug that serves `/themes/:name.css` with on-demand downloading from pureadmin.io. When a theme CSS is requested that isn't bundled at build time, it downloads from `pureadmin.io/api/themes/:name/download`, extracts CSS and `theme.json` manifest from the zip, and caches to disk
- **`/api/themes/manifests`** — returns all available theme manifests as JSON (from both build-time `priv/static/themes/` and on-demand cache)
- **`/api/themes/:name/manifest`** — returns a single theme's manifest
- **Negative cache** — failed downloads are cached for 10 minutes (ETS-based)
- **Slug validation** — theme names must match `^[a-z0-9-]+$`
- **Pure Erlang** — uses `:httpc` and `:zip` for downloads, no external tools needed in runtime image
- **`?theme=cobalt2`** — query param sets localStorage and swaps CSS link before paint, triggering on-demand download if theme not bundled

### Dockerfile & Deployment

- **Dockerfile** (`demo/Dockerfile`) — multi-stage build with `elixir:1.18-slim` builder and `debian:trixie-slim` runtime. Downloads theme bundles from pureadmin.io at build time (CSS + manifests). Configurable via `THEMES_URL` build arg
- **Makefile** — added `podman-build`, `podman-run`, `podman-stop`, `podman-restart`, `podman-logs`, `podman-clean`, `podman-deploy`, `podman-push` targets matching pure-admin conventions. Registry: `registry.km8.es`
- **.dockerignore** — excludes `_build/`, `deps/`, `node_modules/`, `.git/`
- **`force_ssl`** — now opt-in via `FORCE_SSL=true` build-time env var (was always-on, breaking local container testing)

### New Hooks

- **`PureAdminInfiniteScroll`** — IntersectionObserver-based infinite scroll hook. Fires a LiveView event when a sentinel element scrolls into view. Configurable via `data-event`, `data-has-more`, `data-throttle`, `data-root-margin`. Throttled to prevent rapid-fire triggers.

### Components

- **`list_item/1`** — added `:meta` slot for rich meta content (badges, icons) alongside existing `meta_text` string attr
- **`timeline/1`** — fixed alternating variant to use `<div>` container and correct BEM classes (`pa-timeline__date` + `pa-timeline__icon` instead of `pa-timeline__time` + `pa-timeline__marker`). Added `align` attr (`"start"`, `"end"`) and `is_keep_layout` for alternating layout control — replaces raw `class="pa-timeline--start"` usage
- **`timeline_item/1`** — auto-detects layout from props: block/alternating pattern when `icon_text` or `:icon` is provided, simple pattern otherwise
- **`card/1`** — added `is_bordered` attr for bordered card styling — replaces raw `class="pa-card--bordered"` usage
- **`button_group/1`** — added `responsive` attr (`"sm-vertical"`, `"md-horizontal"`, etc.) for responsive direction changes at breakpoints — replaces raw `class="pa-btn-group--md-vertical"` usage
- **`grid/1`** — added `align="stretch"` to allowed values
- **`column/1`** — added `is_no_padding`, `is_grow`, `is_shrink` props for flex layout control
- **`values:` validation** — added compile-time value validation to all `variant`, `color`, `theme_color`, and `level` attrs across alert, badge, label, composite_badge, button, popconfirm, data_display, form, table, and typography components. Typos like `variant="outine-danger"` or `color="10"` now produce compile warnings
- **pure-admin 2.2.0 support** — updated CSS to v2.2.0. Added `theme_color` attr to `button/1`, `callout/1`, and `toast/1` for theme color slots 1-9. Added `is_filled` attr to `toast/1` for full-color background toasts. Alert `theme_color` now uses proper `pa-alert--color-{N}` / `pa-alert--outline-color-{N}` classes (was `pa-bg-color-{N}`)

### Demo

- **45 demo pages** covering all Pure Admin CSS components (up from 34)
- **Dashboard** — rewritten to match pure-admin reference 1:1: 4 hero stat KPIs, 6 square stats with color variants, revenue trend SVG placeholder, traffic sources table, timeline activity feed, recent orders with badges, top products, system status with badge meta, quick actions
- **Timeline pages** — split into 4 pages matching pure-admin: Simple (color-coded, filled bullets), Block (alternating with layout modifiers: start/end/keep-layout), Feed (avatars, comments, date headers, load more, infinite scroll), Advanced
- **Design pages** — new section: Colors (semantic + theme slots), Theme Variables (45 CSS custom properties), CSS Helpers (visibility, borders, overflow, cursor), Layouts (structure, navbar, sidebar, container width)
- **New pages** — Components Overview (index with 27 component cards), Notifications (interactive list with filtering), Sizing & Layout (width/spacing/display utilities), Virtual Scroll (infinite scroll demo with `PureAdminInfiniteScroll` hook, virtual scroll planned)
- **Raw HTML consolidation** — converted remaining raw `pa-` HTML across 10+ demo pages to use components
- **Root layout** — theme CSS loaded via `<link id="pa-theme-css">` with inline script that reads `?theme=` from URL and swaps href before paint
- **Footer** — updated version to v1.0.0-rc.1

### README

- Added Hex/GitHub/path installation options
- Added full setup guide (CSS, Floating UI, Font Awesome, FOUC, toasts)
- Added Podman build/run/deploy instructions with `make` targets
- Updated component and hook tables

Compatible with `@keenmate/pure-admin-core` v2.2.0.

---

## v0.3.4

### New Components
- **comparison**: New `comparison_table/1`, `comparison_row/1`, `comparison_section/1`, `comparison_value/1` — comparison table components for two-column and three-column data diff patterns (version control, merge conflicts). `:cell` slot with `is_changed`, `is_solid`, `is_conflict` modifiers. `comparison_value/1` includes copy-to-clipboard button with visual feedback (icon swap)

### Layout
- **sidebar_submenu**: Fix accordion behavior — opening one submenu no longer closes all others. Each submenu now uses scoped `toggle_submenu/1` with `{:closest, ".pa-sidebar__item"}` and ID-targeted `<ul>`
- **sidebar_submenu**: Add `id` attr for stable submenu identification, `phx-hook="PureAdminSidebarSubmenu"` for localStorage persistence of open/closed state across navigations
- **sidebar_submenu**: Add FOAC prevention — `fouc_prevention_script` injects `<style>` tag from localStorage before sidebar HTML renders, eliminating flash of collapsed submenus
- **split_button**: Close other open split buttons when opening a new one
- **split_button**: Add `on_click` and `action` attrs to `:item` slot for LiveView event handling via hook `pushEvent`

### JS
- **clipboard**: Global `kpa:clipboard-copy` event listener — copy to clipboard via `JS.dispatch`, with visual icon feedback (clipboard → checkmark → revert). Works anywhere, no per-page setup needed
- **PureAdminSidebarSubmenu** (new hook): Persists sidebar submenu open/closed state to localStorage. Restores state on mount, URL-active submenus always win over localStorage. Uses MutationObserver to detect JS command class changes
- **PureAdminSplitButton**: Fix multiple open menus — opening a split button now closes any other open one

### Demo
- Add Comparison Tables demo (`/tables/comparison`) — two-column, three-column, solid background variants using `table_card`
- Restructure routes to hierarchical paths (`/components/buttons`, `/tables/standard`, etc.) — enables `String.starts_with?` for sidebar submenu `is_open` derivation from URL
- Add global toast service — `<.toast_container>` in app layout, PubSub-based `handle_info` hook in `on_mount` for cross-page toast delivery
- Add Split Buttons demo section to buttons page with primary actions, dropdown items, sizes, and toast feedback
- Background task toasts now use PubSub broadcast instead of direct `send/2`, so toasts arrive on whichever page is active

## v0.3.3

### Components (pure-admin 2.1.0 sync)
- **button**: Add `split_button/1` — split button with primary action + dropdown toggle via `PureAdminSplitButton` JS hook. `:item` slot with `is_danger` modifier, `placement` attr for Floating UI positioning, `on_click` for primary action
- **tooltip**: Add `is_keyword` modifier — dotted underline + help cursor for inline term explanations (`pa-tooltip--keyword`)

### Demo
- Add Table Multi-Select demo with cross-filter selection, summary bar, expandable details, bulk actions
- Update pure-admin CSS to v2.1.0

## v0.3.2

### Components
- **table**: Add `table_card/1` — card wrapper with header/footer, color variants (primary/success/warning/danger), theme colors (1-9), `is_scrollable`, `is_plain`
- **table**: Add `:foot` slot for `<tfoot>` support (colspan, totals rows)
- **table**: Add `align` attr on `:col` slot (start/center/end) for per-column text alignment
- **table**: Add `is_responsive_grid` modifier for CSS Grid responsive collapse
- **table**: Render `:action` column first (leftmost) to match pure-admin reference
- **table_container**: Add `is_panel` mode with `title_text`, `:header`, `:actions` slots
- **table_container/table_card**: Use `<h3>` for titles to match pure-admin CSS selectors (colored header text)
- **pager**: Fix layout to match pure-admin: controls-left | info-center | controls-right (was all-controls then info)
- **pager**: Add `icon_first`, `icon_previous`, `icon_next`, `icon_last` attrs for custom icon sets
- **pager**: Change info format to `/ N pages` (was `Page ... of N`)
- **data_display**: Add `is_value_end` and `is_value_center` modifiers to `banded/1` and `desc_table/1`
- **form**: Add `input_wrapper/1` — wraps input/select with optional clear (×) button (`pa-input-wrapper` + `pa-input-wrapper__clear`), `has_clear`, `on_clear` attrs
- **filter_card**: New `filter_card/1` component — expandable filter card with `:filters`, `:advanced_filters`, `:actions` slots, toggle/clear/refresh/apply buttons, `is_expanded`, `is_loading`, `is_disabled` states, matching Svelte `FilterCard`

### Demo
- Split tables into three pages: Standard Tables, Table Sizing, Responsive
- Rewrite Standard Tables demo to match pure-admin reference 1:1 (same data, sections, structure)
- Rewrite Table Sizing demo to match pure-admin reference 1:1 (same data, card structure with inline code headers, text action buttons with correct sizes per variant)
- Rewrite Responsive Tables demo to match pure-admin reference 1:1 (How It Works grid, basic/product/orders tables with actions and badges, CSS Grid Custom Layouts with data-grid/data-span, HTML Implementation with grid advanced section, SCSS variables reference, Testing Tips, LiveView code examples)
- Add Table Filters demo matching pure-admin reference (basic search filter, expandable filters with advanced section toggle, inline horizontal filters, active filter tags with composite badges)
- Remove invented `pa-page-title`/`pa-page-subtitle` CSS classes from all demo pages — use plain `<p>` like the reference
- Clean up `demo.css` — remove unused chart/activity/status classes

## v0.3.1

### New Components
- `popconfirm/1` — small confirmation dialogs anchored to trigger buttons via Floating UI, with `message`, `placement` (top/bottom/start/end, RTL-aware), `icon_variant` (danger/warning/info), `is_compact`, `confirm_event`/`confirm_value` for LiveView integration, click-outside-to-close, move-to-body positioning

### RTL Support
- `tooltip/1` — position values renamed: `right` → `end`, `left` → `start` (RTL-aware via `document.dir`)
- `popover/1` — placement values renamed: `right` → `end`, `left` → `start` (RTL-aware via `document.dir`)
- Tooltip JS hook — added `resolveLogicalPlacement()` that maps `start`/`end` to physical `left`/`right` based on document direction

### Components
- `badge/1` — replaced `width` attr (`pa-badge--w-Nx` classes) with `max_width` attr using `maxwr-N text-truncate` utility classes
- `modal/1` — fixed popover alignment classes (`pa-popover--center`, `pa-popover--end`) to be copied to content element when moved to `document.body`
- Tooltip JS — fixed theme color variants not applied to floating tooltips (regex only matched first class, which was always `floating`)

### JS
- `modal_dialogs.js` — new ES module wrapping pure-admin's programmatic dialog API (`PureAdmin.confirm/alert/prompt/custom`), exported via `initModalDialogs()`

### Demo
- **Modal Dialogs page** — new page with confirm/alert/prompt demos, position options, sequential dialogs, LiveView server integration, API reference tables
- **Modals page** — rewritten to match pure-admin reference (grouped layout, settings modal, richer modal content)
- **Tooltips page** — updated to use `start`/`end` position naming
- **Badges page** — updated fixed-width section to use `max_width` utility approach, renamed "Left-Side Ellipsis" to "Start-Side Ellipsis"
- **Popconfirm page** — new page with basic popconfirms (delete/archive/reset with icon variants), compact variant, table row delete confirmations with LiveView integration
- **Command Palette page** — new page with Spotlight-style search overlay, Ctrl+K shortcut, context switching (/p, /o, /u, /i), keyboard navigation, pagination, LiveView server-side search
- **Data Display page** — new page with pa-fields layouts: stacked, multi-column grid (cols-2/3/4), field groups, horizontal, table-style bordered, striped, compact, inline, row, relaxed, filled, color-coded borders
- **Data Display 2 page** — new page with advanced patterns: Ant Design descriptions table (1/2/fixed columns), dot leaders (invoice style), property cards, banded rows
- **Data Visualization page** — new page with CSS-only visualizations: progress bars (sizes/colors/striped/animated/rounded), stacked bars with legends, progress rings, dashboard gauges, data bars in tables, activity heatmaps, sparkline bars
- **Detail Panel page** — new page with inline split-view and overlay modes, table row selection, field-group detail content
- Fixed all compile warnings across demo (nested `if` parentheses, `dynamic_tag` name deprecation, undefined attributes, missing slots)

## v0.3.0

Compatible with `@keenmate/pure-admin-core` v2.0.2.

### Components
- `section/1` — added `title_text` attr that renders an `<h3 class="pa-section-title">` heading
- `code/1` — fixed to render plain `<code>` without `pa-code` class, matching Svelte reference
- `card/1` — added `:subtitle` slot (rich HTML counterpart to `subtitle_text`)
- `card/1` — fixed `subtitle_text` to render with `pa-text pa-text--secondary` class matching Svelte reference
- `card/1` — fixed title rendering: plain `<h3>` without wrapper div when no icon is present, matching Svelte reference
- `card/1` — fixed non-inline tabs to render outside header as sibling (matching reference DOM structure)
- `card/1` — fixed inline tabs to render after title (not before), matching reference order
- `form_label/1` — added `is_required` attr that renders asterisk indicator
- `checkbox/1` — added `:label_content` slot, `is_indeterminate` (via PureAdminCheckbox hook), `is_x_mark`
- `checkbox_box/1` — added `is_indeterminate` support
- `tabs/1` — scrollable overflow now renders proper scroll buttons and scroll container
- `tab_item/1` — added deterministic `id` and `:not()` exclusion to prevent 2px flash on tab switch
- `switch_tab/3` — scoped tab/panel switching via `tabs_id` + content container id to prevent cross-group interference
- `label/1` — fixed outline to use `pa-label--outline` class (not `pa-label--outline-{variant}`), matching Svelte reference; added `xs`/`xl` size support
- `badge_group/1` — added `limit`, `total`, `is_expanded`, `on_toggle`, `more_text`, `collapse_text` attrs for expand/collapse with two modes: server-side (fires LiveView event for lazy loading) and client-side (CSS-based hiding with JS class toggle, survives LiveView DOM patching)
- `badge/1` — added `width` attr (`pa-badge--w-{size}` BEM class) and `is_ellipsis_start` for left-side truncation
- `composite_badge/1` — added `is_interactive`, `on_label_click`, `on_button_click`, `label_variant`, `button_variant`, `button_text`, `:icon_content` slot for full interactive support with separate label/button click events
- `checkbox_box/1` — new low-level checkbox (input + box) for tables and composite components
- `checkbox_list/1` — new container with variant (compact/bordered/striped) and layout (inline/grid/2col/3col)
- `checkbox_list_item/1` — new item with label, description, state (disabled/locked), and `:actions` slot
- `basic_list/1` — new component for styled `<ul>` with spacing, icon, bordered, striped, inline, unstyled variants
- `ordered_list/1` — new component for styled `<ol>` with numeric, roman, alpha styles
- `definition_list/1` — new component for styled `<dl>` with standard and inline layouts

### JS Hooks
- `PureAdminCharCounter` — new hook for textarea/input character counting with configurable max, translatable message templates via `data-msg`/`data-msg-over` with `{count}`/`{max}` placeholders
- `PureAdminCheckbox` — new hook for syncing `indeterminate` property from `data-indeterminate` attribute (required for tri-state checkboxes)

### Components (enhanced)
- `tooltip/1` — new CSS-only tooltip wrapper with position, variant, multiline, help cursor support
- `popover/1` — new click-triggered popover with title, placement, size, alignment, custom trigger slot
- `pager/1` — enhanced with page input, first/last buttons, configurable events, custom info text, `:controls` and `:info` slots
- `load_more/1` — enhanced with `phx-click` support via `:global` attrs
- `loader_center/1` — new centered loader container (flexbox centering)
- `loader_overlay/1` — enhanced to accept custom content via slot (not just default spinner)
- `toast/1` — added `title_text`, `message_text`, `is_visible`, `on_close`, `:icon` slot, close button with SVG icon
- `toast_container/1` — updated positions to use logical names (top-end, top-center, top-start, bottom-end, bottom-center, bottom-start)

### Demo
- **Cards page** — complete rewrite matching Svelte pure-admin reference (14 sections: same-height, basic, header three-part layout, colored, theme colors, bordered, ghost, underlined headers, statistics, statistics with trends, interactive, advanced features, data display, CSS classes reference)
- **Grid page** — complete rewrite matching Svelte pure-admin reference (overview, basic usage, percentage columns, fraction columns, responsive grid, offsets, row alignment, no gutter, visibility utilities, nested grids, quick reference, code examples)
- **Buttons page** — complete rewrite matching Svelte pure-admin reference (variants, sizes, outline, states, block, button groups with gap sizes, vertical alignment, responsive direction, text truncation, icon buttons, icon-only, fixed width, text alignment, ripple effects, loading states, usage guide, CSS classes reference)
- **Inputs page** — new page matching Svelte pure-admin reference (text inputs with states/sizes/validation/theme colors, input groups with prepend/append/buttons/toggle mode, input types, select dropdowns, textareas, checkboxes & radios with sizes, width variations, CSS classes reference)
- **Validations page** — new page matching Svelte pure-admin reference (10 validation patterns: inline field errors, summary block, combined summary+inline, border+icon only, right-side indicators, helper text transforms, toast notifications, validation timing strategies, multi-field/cross-field, progressive multi-step, CSS classes reference)
- **Tabs page** — complete rewrite matching Svelte pure-admin reference (card header tabs, standalone, icons, fixed width, pills, vertical, boxed, sizes, badges, centered, full width, border-top, icon-only horizontal/vertical, standalone page-level, standalone vertical, bordered horizontal/vertical, long titles with wrap/collapse/scrollable, inline tabs in header)
- **Validations page** — interactive demos: char counter with JS hook, validation timing strategies (real-time/blur/submit), cross-field validation (password match, date range)
- **Badges page** — complete rewrite matching Svelte pure-admin reference (badge sizes reference table, basic badges, pill badges, badges with icons, label sizes reference, labels with outline, badge groups with expand/collapse, fixed-width badges with tooltips, left-side ellipsis, composite badges with mixed colors and interactive click handlers, usage examples)
- **Lists page** — complete rewrite matching Svelte pure-admin reference (basic unordered lists with spacing variants, ordered lists with numeric/roman/alpha, definition lists with standard/inline, icon lists with success/danger/info/warning, bordered/striped, inline/unstyled, complex lists with avatars, implementation guide)
- **Checkbox Lists page** — new page matching Svelte reference (tri-state checkboxes, select-all pattern, disabled states, checkbox lists with descriptions, item states, list variants, task list with actions, inline/grid/multi-column layouts, interactive table with row selection and select-all)
- **Alerts page** — rewrite matching Svelte reference (basic alerts with strong labels, text icon alerts, dismissible alerts, rich content with heading/list/actions, outline alerts, compact alerts in responsive grid)
- **Callouts page** — rewrite matching Svelte reference (basic callouts, headings, icons, lists, sizes, code, links, grid layout, callout vs alert comparison)
- **Loaders page** — rewrite matching Svelte reference (spinner sizes/colors, inline spinners, centered loaders, loaders with text, card loading states, loader types, button loading states)
- **Pagers page** — new page (basic pager, first/last buttons, alignment variants, custom info text, load more with loading state, pager in card footer, CSS classes reference)
- **Tooltips page** — new page matching Svelte reference (positions, color variants, theme colors, button tooltips, icon-only tooltips, multiline, inline text, popovers with sizes/alignment/positions)
- **Toasts page** — new page matching Svelte reference (6 position demos, 5 variant buttons, persistent toasts, action toasts, multiple stacking toasts, long-running background task demo with server push, architecture docs)
- **Sidebar** — reorganized to match Svelte pure-admin layout (Components submenu with Grid, separate Tables and Timeline submenus, Forms as top-level item)

## v0.2.0

### Navbar subcomponents
- `navbar_brand/1` — brand/logo section with optional `logo` image
- `navbar_nav/1` — navigation link group (`position="start"` or `"end"`)
- `navbar_nav_item/1` — nav link with optional `has_dropdown` and `:dropdown` slot
- `navbar_dropdown/1` — CSS-driven dropdown menu (supports `is_level2` for nesting)
- `navbar_title/1` — page title in center section
- `navbar_search/1` — search widget with keyboard shortcut hint
- `navbar_profile_btn/1` — profile button with name and `:icon` slot

### Notifications
- `notifications/1` — bell button with badge count and dropdown panel
- `notification_item/1` — individual notification with variant, title, text, time slots

### Profile panel (enhanced)
- `profile_panel/1` — full slide-out panel with overlay, avatar, name/email/role, `:nav`, `:tabs`, `:footer_` slots
- `profile_nav_item/1` — navigation item within profile panel
- `toggle_profile_panel/1`, `close_profile_panel/1` — JS commands
- `PureAdminProfilePanel` JS hook — tab switching, favorites, click-outside-to-close

### Settings panel
- `settings_panel/1` — floating settings panel (theme mode, layout width, sidebar, fonts, etc.)
- `fouc_prevention_script/0` — inline script preventing flash of unstyled content
- `PureAdminSettings` JS hook — client-side localStorage-based settings management

### Layout
- Added `id` attr to `layout/1`
- `toggle_notifications/1` JS command

### Demo
- Navbar uses three-section layout (start/center/end) matching pure-admin reference
- Components dropdown with nested "More ›" submenu
- Notifications bell with sample items
- Profile panel with tabs (Profile/Favorites), nav items, and footer actions

## v0.1.0

- Initial release
- Phase 1: Foundation + 10 key components (button, badge, alert, card, table, modal, tabs, form, layout, grid)
- BEM class builder helpers
- JS hook scaffold
- `use PureAdmin.Components` for bulk import
