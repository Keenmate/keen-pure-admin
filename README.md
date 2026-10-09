# PureAdmin

[![Hex.pm](https://img.shields.io/hexpm/v/keen_pure_admin.svg)](https://hex.pm/packages/keen_pure_admin)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/keen_pure_admin)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

Phoenix LiveView component library wrapping the [Pure Admin](https://github.com/KeenMate/pure-admin) CSS framework into function components and LiveComponents.

Drop-in replacement for Phoenix `CoreComponents` -- provides `button/1`, `badge/1`, `card/1`, `modal/1`, `table/1`, `input/1`, and 35+ more components with full BEM class support.

**Main site**: [pureadmin.io](https://pureadmin.io) — themes, documentation, and component showcase

**Live demo**: [elixir.demo.pureadmin.io](https://elixir.demo.pureadmin.io)

## What's new in v2.0.0-rc.1

**Major** sync to `@keenmate/pure-admin-core` `^3.3.0-rc06` (was `^2.9.0-rc18`), mirroring core's 2.x → 3.x cut. Themes must be rebuilt at 3.3.0-rc06 and reinstalled (`npx @keenmate/pureadmin themes install`). Highlights:

- **BREAKING — token ownership split (`--pc-*` vs `--pa-*`).** Foundation + app-shell runtime tokens (surfaces, text, accent, links, radius, the `--pc-color-1..9` palette, navbar/sidebar/footer) are now `--pc-*`; **component** tokens (buttons, cards, modals, tables, badges, KPI, command palette, splitter, range, gauge, chart…) are `--pa-*`. Migrate your overrides accordingly. `--base-*` is unchanged.
- **Server-driven dialogs (`PureAdmin.Dialog`)** — open a modal from the server in a LiveView and receive the answer as an ordinary `handle_event`. `confirm/2` + `info/success/warning/error` alerts and custom/form dialogs, built on the declarative `modal/1` (no JS bridge). The client `window.PureAdmin.confirm/alert/prompt` service gains an `isBanded` option.
- **New printable components** — `<.document>` (Word-style hierarchical numbered sections via CSS counters) and `<.sheet>` (printable A4 shell for invoices/orders/quotes with masthead, parties, meta, and print modes).
- **Forms aligned with svelte-pure-admin** — canonical `state` / `theme_color` / `label_text` props (old names kept as deprecated aliases), `input/1` split into typed `number_input`/`date_input`/`color_input`/`file_input`/`range_input`, new `form_field/1` + `form_error_summary/1`, and `aria-invalid` + `touched` gating. Typography consolidated onto the flat `text-*` utilities (core dropped `.pa-text`).
- **Command palette** — leading-key `g <letter>` shortcuts (replacing macOS-hostile `Alt+<letter>`), a keyboard-navigable home screen (`↑ ↓`, `PgUp`/`PgDn`, `Home`/`End`), and palette icons rendered through the real icon path instead of unicode.

See the full [CHANGELOG](CHANGELOG.md) for the complete 3.x sync.

## What's new in v1.3.0-rc.2

Maintenance sync to `@keenmate/pure-admin-core` `^2.9.0-rc08`. Highlights:

- **Peer-dep bumped `^2.9.0-rc07` → `^2.9.0-rc08`.** rc08 is an internal upstream SCSS restructuring (the variable system, utilities, and the `.pc-row`/`.pc-col` grid moved into the shared `@keenmate/pure-css` package) — public import paths and every emitted class name are unchanged, so no component, hook, or emitted DOM changed. Reinstall themes (`npx @keenmate/pureadmin themes install`) to pick up the rc08 CSS.
- **Verified no impact** from rc08's breaking-looking changes: the removed legacy PureCSS `.pure-g`/`.pure-u-*` grid isn't used (we already emit `.pc-row`/`.pc-col-*`), and the new SCSS `--load-path=node_modules` build requirement is internal to upstream theme compilation.
- **Docs** — corrected the downloaded theme-zip structure (`css/`, not `dist/`) and documented both theme-install paths (pureadmin CLI + manual download) in getting-started.

See the full [CHANGELOG](CHANGELOG.md) for details.

## Prerequisites

Create a new Phoenix project **without Tailwind** — Pure Admin provides its own CSS framework:

```bash
mix phx.new my_app --no-tailwind
```

> If you have an existing project that uses Tailwind, remove the Tailwind dependency and its configuration before adding Pure Admin, as the two CSS frameworks will conflict.

## Installation

Add `keen_pure_admin` to your list of dependencies in `mix.exs`:

### From Hex (recommended)

```elixir
def deps do
  [
    {:keen_pure_admin, "~> 1.0"}
  ]
end
```

### From GitHub

```elixir
def deps do
  [
    {:keen_pure_admin, github: "KeenMate/keen-pure-admin", tag: "v1.2.0"}
  ]
end
```

### Local path (for development)

```elixir
def deps do
  [
    {:keen_pure_admin, path: "../keen-pure-admin"}
  ]
end
```

Then fetch dependencies:

```bash
mix deps.get
```

## Setup

### 1. Replace CoreComponents import

In your `MyAppWeb` module (e.g. `lib/my_app_web.ex`), find the `html_helpers` function and replace:

```diff
- import MyAppWeb.CoreComponents
+ use PureAdmin.Components
```

This replaces `button/1`, `input/1`, `simple_form/1`, `modal/1`, `table/1`, `list/1`, `label/1`, `flash/1`, and `flash_group/1`. A few CoreComponents functions are not replaced:

- **`header/1`** — use `@page_title` in `<.navbar_title>` (the layout renders it, each LiveView sets it)
- **`icon/1`** — use Font Awesome directly: `<i class="fa-solid fa-user"></i>`
- **`translate_error/1`** — `PureAdmin.Components.Form.translate_error/1` ships a plain `%{key}`-interpolating default. For Gettext, set `config :keen_pure_admin, :error_formatter, {MyAppWeb.CoreComponents, :translate_error}` (MFA tuple or 1-arity function) and errors flow through your existing pipeline.
- **`show/1`**, **`hide/1`** — use `Phoenix.LiveView.JS.show/1` and `JS.hide/1` directly

### 2. Replace the generated layouts

Phoenix generates a `layouts.ex` with inline `app/1` and `flash_group/1` functions that conflict with PureAdmin. Replace it:

```elixir
# lib/my_app_web/components/layouts.ex
defmodule MyAppWeb.Layouts do
  use MyAppWeb, :html
  embed_templates "layouts/*"
end
```

Then create `lib/my_app_web/components/layouts/app.html.heex` with a PureAdmin layout:

```heex
<.layout>
  <.navbar>
    <:start>
      <.navbar_burger />
      <.navbar_brand />
    </:start>
    <:center>
      <.navbar_title>
        <h2>{assigns[:page_title] || "Home"}</h2>
      </.navbar_title>
    </:center>
  </.navbar>

  <.layout_inner>
    <.sidebar>
      <.sidebar_item label="Home" icon="fa-solid fa-house" href="/" />
    </.sidebar>

    <.layout_content>
      <.main>
        <.flash_group flash={@flash} />
        {@inner_content}
      </.main>
      <.footer />
    </.layout_content>
  </.layout_inner>
</.layout>
```

Add the app layout to your router's browser pipeline (Phoenix 1.8 doesn't set this by default — the generated code used an inline `app/1` function instead):

```elixir
# lib/my_app_web/router.ex
pipeline :browser do
  # ... existing plugs ...
  plug :put_root_layout, html: {MyAppWeb.Layouts, :root}
  plug :put_layout, html: {MyAppWeb.Layouts, :app}       # <-- add this line
  # ...
end
```

Also clean up these generated files that use Tailwind classes or CoreComponents functions:

- **Delete** `lib/my_app_web/components/core_components.ex` — no longer needed
- **Delete** `priv/static/assets/default.css` — Phoenix default styles that conflict with Pure Admin
- **Replace** `lib/my_app_web/controllers/page_html/home.html.heex` — the generated page uses Tailwind classes and `Layouts.flash_group` which no longer exists

### 3. Configure your app (optional)

```elixir
# config/config.exs
config :keen_pure_admin,
  app_name: "My App",
  app_version: "1.0.0",
  copyright: "© 2026 My Company",
  font_class: "pa-font-responsive"
```

The `navbar_brand` and `footer` components read from this config automatically. Add the font class to `<html>` in your root layout:

```heex
<html lang="en" {PureAdmin.Config.root_html_attrs()}>
```

### 4. Install a theme

Theme CSS files include the core framework — you only need a theme. Declare the themes your app uses in `pureadmin.json` at your project root, then download with the PureAdmin CLI:

```json
// pureadmin.json
{
  "themesDir": "priv/static/themes",
  "themes": { "audi": {} }
}
```

```bash
npx @keenmate/pureadmin themes install
```

`themes install` writes a `pureadmin.lock.json` (commit it — same convention as `package-lock.json`) and extracts each theme to `priv/static/themes/<id>/`. CI / Docker should run `themes ci` instead — strict reproduce from the lock, fails on drift. Add `priv/static/themes/` to `.gitignore`; themes are downloaded artifacts.

Add `themes` to your static paths so Phoenix serves the files:

```elixir
# lib/my_app_web.ex
def static_paths, do: ~w(assets fonts images themes favicon.ico robots.txt)
```

Then link the theme in your `root.html.heex`:

```html
<link rel="stylesheet" href="/themes/audi/css/audi.css" />
```

Browse all available themes at [pureadmin.io](https://pureadmin.io).

> Remove the Phoenix-generated `default.css` link — it contains default Phoenix styles that conflict with Pure Admin.

### 5. Register JS hooks

Add `PureAdminHooks` to your LiveSocket in `assets/js/app.js` and call
`initPureAdminEvents()` once to wire the delegated click handlers (popover,
popconfirm, copy-to-clipboard, tabs scroll, badge-group expand/collapse):

```javascript
import { PureAdminHooks, initPureAdminEvents } from "keen_pure_admin"

// Merge with any existing hooks (e.g. colocatedHooks)
const liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...colocatedHooks, ...PureAdminHooks }
})

// Wire delegated click handlers. Idempotent; safe to call once at startup.
initPureAdminEvents()
```

All component behaviour is delivered through `PureAdminHooks` and
`initPureAdminEvents` — no inline `onclick=` handlers in the rendered markup,
so apps can ship with strict CSP (`script-src 'self'`) without
`'unsafe-inline'`. The one exception is the optional FOUC-prevention script
(`<.fouc_prevention_script />`), which must run inline in `<head>` before CSS
loads; for CSP-strict apps, attach a per-request nonce.

### 6. Add Floating UI (required for tooltips, popovers, split buttons)

```html
<script src="https://cdn.jsdelivr.net/npm/@floating-ui/core@1.6.9"></script>
<script src="https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.6.13"></script>
```

Or install via npm:

```bash
cd assets
npm install @floating-ui/dom
```

### 7. Add Font Awesome (icons)

```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
```

### 8. Add FOUC prevention (optional)

In your root layout, add the script before `{@inner_content}` to prevent flash of unstyled content when using the settings panel or sidebar submenus:

```heex
<body>
  <.fouc_prevention_script />
  {@inner_content}
</body>
```

### 9. Add global toast service (optional)

Add a toast container to your app layout for app-wide toast notifications:

```heex
<.toast_container id="toasts" position="top-end" is_hook />
```

Then push toasts from any LiveView:

```elixir
alias PureAdmin.Components.Toast, as: PureToast

socket |> PureToast.push_toast("success", "Saved!", "Changes saved successfully.")
```

For cross-page delivery (e.g., background tasks that complete after navigation), broadcast via PubSub and handle in an `on_mount` hook:

```elixir
# In your on_mount hook
Phoenix.PubSub.subscribe(MyApp.PubSub, "toasts")

attach_hook(socket, :global_toasts, :handle_info, fn
  {:push_toast, variant, title, message, opts}, socket ->
    {:halt, PureToast.push_toast(socket, variant, title, message, opts)}
  _other, socket ->
    {:cont, socket}
end)

# From a background task
Phoenix.PubSub.broadcast(MyApp.PubSub, "toasts",
  {:push_toast, "success", "Done!", "Task completed.", duration: 0})
```

## Components

### Layout

Full page structure matching the Pure Admin three-section navbar + sidebar + content + footer pattern:

```heex
<.layout>
  <.navbar>
    <:start>
      <.navbar_burger />
      <.navbar_brand><.heading level="1">My App</.heading></.navbar_brand>
      <.navbar_nav>
        <.navbar_nav_item href="/">Dashboard</.navbar_nav_item>
        <.navbar_nav_item href="/reports" has_dropdown>
          Reports
          <:dropdown>
            <.navbar_dropdown>
              <.navbar_nav_item href="/reports/sales">Sales</.navbar_nav_item>
              <.navbar_nav_item href="/reports/users">Users</.navbar_nav_item>
            </.navbar_dropdown>
          </:dropdown>
        </.navbar_nav_item>
      </.navbar_nav>
    </:start>
    <:center>
      <.navbar_title><.heading level="2">Dashboard</.heading></.navbar_title>
    </:center>
    <:end_>
      <.notifications count={3}>
        <.notification_item variant="primary" icon="fa-solid fa-bell" is_unread>
          <:title>New message</:title>
          <:text>You have a new message</:text>
          <:time>2 min ago</:time>
        </.notification_item>
      </.notifications>
      <.navbar_profile_btn name="John Doe" phx-click={toggle_profile_panel()} />
    </:end_>
  </.navbar>

  <.layout_inner>
    <.sidebar>
      <.sidebar_item label="Dashboard" icon="fa-solid fa-gauge" href="/" is_active />
      <.sidebar_submenu id="settings" label="Settings" icon="fa-solid fa-gear" is_open={String.starts_with?(@current_path, "/settings")}>
        <.sidebar_item label="General" href="/settings" />
        <.sidebar_item label="Security" href="/settings/security" />
      </.sidebar_submenu>
    </.sidebar>

    <.layout_content>
      <.main>
        <.flash_group flash={@flash} />
        {@inner_content}
      </.main>
      <.footer>
        <:start>&copy; 2026 My App</:start>
      </.footer>
    </.layout_content>
  </.layout_inner>
</.layout>
```

### Profile Panel

Slide-out profile panel with avatar, tabs, navigation, and click-outside-to-close:

```heex
<.profile_panel name="John Doe" email="john@example.com" role="Admin">
  <:tabs>
    <div class="pa-tabs pa-tabs--full">
      <button class="pa-tabs__item pa-tabs__item--active" data-profile-tab="profile">
        <i class="fa-solid fa-user"></i>
        <span class="pa-profile-panel__tab-text">Profile</span>
      </button>
      <button class="pa-tabs__item" data-profile-tab="favorites">
        <i class="fa-solid fa-star"></i>
        <span class="pa-profile-panel__tab-text">Favorites</span>
      </button>
    </div>
  </:tabs>

  <div class="pa-tabs__panel pa-tabs__panel--active" data-profile-panel="profile">
    <nav class="pa-profile-panel__nav">
      <ul>
        <.profile_nav_item href="/profile" icon="fa-solid fa-user">Settings</.profile_nav_item>
        <.profile_nav_item href="/logout" icon="fa-solid fa-right-from-bracket">Sign Out</.profile_nav_item>
      </ul>
    </nav>
  </div>

  <:footer_>
    <button class="pa-btn pa-btn--danger pa-btn--block">Sign Out</button>
  </:footer_>
</.profile_panel>
```

### Settings Panel

Client-side settings panel for theme mode, layout width, sidebar options, fonts, and more -- all persisted to localStorage:

```heex
<.settings_panel />
```

### UI Components

| Component | Description |
|---|---|
| `button/1`, `split_button/1`, `button_group/1` | Buttons with variants, sizes, loading, split dropdown, responsive groups |
| `badge/1`, `label/1`, `composite_badge/1`, `badge_group/1` | Badges, labels, composite badges with expand/collapse |
| `alert/1` | Dismissible alerts |
| `callout/1` | Callout/info boxes |
| `card/1` | Cards with header (title/subtitle/description), body, footer, tabs |
| `modal/1` | Modal dialogs |
| `popconfirm/1` | Popconfirm dialogs anchored to trigger buttons |
| `table/1`, `table_card/1`, `table_container/1` | Data tables with sorting, card wrappers, responsive grid |
| `comparison_table/1`, `comparison_row/1`, `comparison_value/1` | Two/three-column data comparison with change/conflict highlighting |
| `tabs/1` | Tab navigation with panels |
| `input/1`, `textarea/1`, `select/1`, `checkbox/1`, `radio/1`, `form_group/1`, `input_wrapper/1` | Form inputs with labels, errors, clear button. Accept `field={@form[:x]}` for one-line Phoenix form binding (derives name/id/value/checked + auto-renders errors) |
| `filter_card/1` | Expandable filter card with advanced filters |
| `grid/1`, `column/1` | Flexbox grid with percentage/fraction columns |
| `section/1` | Content section with optional `title_text` heading |
| `stat/1` | Stat cards (hero, square) |
| `timeline/1` | Timeline displays |
| `loader/1`, `loader_center/1`, `loader_overlay/1` | Loading spinners |
| `basic_list/1`, `ordered_list/1`, `definition_list/1` | HTML lists with spacing, icons, borders |
| `checkbox_list/1`, `checkbox_list_item/1`, `checkbox_box/1` | Checkbox lists with variants, layouts, actions |
| `list/1`, `list_item/1` | Complex lists with avatar, title, subtitle, meta |
| `code/1`, `code_block/1` | Inline code and code blocks |
| `tooltip/1`, `popover/1` | Tooltips and popovers with Floating UI positioning |
| `toast/1`, `toast_container/1`, `push_toast/5` | Toast notifications with client-side rendering via JS hook |
| `flash/1`, `flash_group/1`, `flash_container/1`, `push_flash/5`, `clear_flash/2` | Flash messages — standard `@flash` compat + independent containers with markdown, action buttons, and `replace: true` to wipe prior alerts in the container |
| `pager/1`, `load_more/1` | Pagination with page input, first/last buttons |

### JS Hooks

| Hook | Description |
|---|---|
| `PureAdminSettings` | Settings panel localStorage management |
| `PureAdminProfilePanel` | Profile panel tabs, favorites, click-outside |
| `PureAdminTooltip` | Tooltip positioning |
| `PureAdminPopover` | Popover positioning |
| `PureAdminToast` | Toast auto-dismiss |
| `PureAdminFlash` | Independent inline flash containers with markdown and action buttons |
| `PureAdminCommandPalette` | Command palette: multi-step commands (`/`), scoped search (`:`), keyboard nav |
| `PureAdminDetailPanel` | Detail panel toggle |
| `PureAdminSidebarResize` | Drag-to-resize sidebar |
| `PureAdminCharCounter` | Character counter with translatable messages |
| `PureAdminCheckbox` | Tri-state checkbox indeterminate sync |
| `PureAdminSplitButton` | Split button dropdown via Floating UI |
| `PureAdminSidebarSubmenu` | Sidebar submenu localStorage persistence |
| `PureAdminInfiniteScroll` | IntersectionObserver-based infinite scroll |

## CSS Framework

All classes follow the BEM pattern: `pa-{block}`, `pa-{block}--{modifier}`, `pa-{block}__{element}`.

Browse the live component showcase and theme previews at [pureadmin.io](https://pureadmin.io).

### Available Themes

| Theme | Package |
|---|---|
| Default | `@keenmate/pure-admin-core` |
| Audi | `@keenmate/pure-admin-theme-audi` |
| Corporate | `@keenmate/pure-admin-theme-corporate` |
| Dark | `@keenmate/pure-admin-theme-dark` |
| Express | `@keenmate/pure-admin-theme-express` |
| Minimal | `@keenmate/pure-admin-theme-minimal` |

### Installing Themes

Each theme is self-contained: compiled CSS at `css/<id>.css` references fonts via relative paths (`../assets/fonts/...`), so extracting preserves correct asset resolution with no path adjustments needed. Theme zips include compiled CSS, SCSS source (for customization), bundled fonts, and a `theme.json` manifest.

#### Option A: Pure Admin CLI (recommended)

Pure Admin uses a three-file config modeled on `package.json` / `package-lock.json`:

| File | Role | Tracked? |
|---|---|---|
| `pureadmin.json` | declarations only — which themes the project uses | yes (hand-edited) |
| `pureadmin.lock.json` | resolved versions, content shas, fetch timestamps | yes (tool-managed) |
| `.pureadmin.json` | per-developer overrides (local paths, dev API keys) | no (gitignored) |

Create `pureadmin.json` at your project root:

```json
{
  "themesDir": "priv/static/themes",
  "themes": {
    "audi": {},
    "dark": {},
    "express": {}
  }
}
```

Then resolve and download with the CLI:

```bash
# Local dev: install + write/refresh the lockfile
npx @keenmate/pureadmin themes install

# Bump every theme to the latest registry version (writes the lock)
npx @keenmate/pureadmin themes update

# CI / Docker: strict reproduce from the lockfile, fail on drift, never write
npx @keenmate/pureadmin themes ci
```

`themes install` is the everyday "make this project work" verb. `themes ci` is the strict CI verb. Add `priv/static/themes/` and `.pureadmin.json` to `.gitignore`.

```
priv/static/themes/
├── audi/
│   ├── theme.json
│   ├── css/audi.css
│   ├── scss/audi.scss
│   └── assets/fonts/*.woff2
├── dark/
│   ├── css/dark.css
│   └── ...
└── ...
```

#### Option B: Manual download

Download theme zips from [pureadmin.io](https://pureadmin.io) and extract them into `priv/static/themes/`. Same on-disk layout as the CLI produces.

#### Option C: Download during CI/CD build

Run `themes ci` during your Docker build. Copy the two config files first, then run the install:

```dockerfile
COPY pureadmin.json pureadmin.lock.json ./
RUN apt-get update && apt-get install -y --no-install-recommends nodejs npm && rm -rf /var/lib/apt/lists/* \
  && npx @keenmate/pureadmin themes ci
```

See the `Dockerfile` in the repo root for a complete working example.

#### Theme cache invalidation

The demo app's `ThemePlug` caches downloaded themes to disk. Each theme's `theme.json` contains a `checksums.content_sha` field — a SHA-256 hash of the package contents. On access, the plug validates the cache in the background by sending a conditional request (`If-None-Match: <content_sha>`) to pureadmin.io. If the server returns 200 (theme updated), it re-downloads without blocking the current request. Freshness checks are throttled to once per 10 minutes per theme.

To force-clear the cache:

```bash
make themes-clear
```

## Translations (i18n)

All user-facing strings in components are translatable via a runtime callback. Without configuration, English defaults are used.

```elixir
# config/config.exs
config :keen_pure_admin,
  translate: &MyApp.Translations.translate/2
```

The callback receives a flat key and a params map:

```elixir
defmodule MyApp.Translations do
  def translate(key, params) do
    # Load from DB, Gettext, ETS — whatever fits your app
    translation = MyApp.Repo.get_translation(key, current_locale())
    PureAdmin.Translations.interpolate(translation, params)
  end
end
```

Keys follow the `pureAdmin.*` convention (e.g., `pureAdmin.buttons.cancel`, `pureAdmin.pagination.nextPage`, `pureAdmin.commandPalette.searching`). See `PureAdmin.Translations.defaults()` for the full list.

## Page Context

Server-rendered JSON in a hidden input, available to JS synchronously — no API fetch needed. CSP-safe.

```heex
<%!-- In your root layout --%>
<.page_context />
```

Register providers via config:

```elixir
config :keen_pure_admin,
  page_context_providers: [
    &MyApp.PageContext.theme_manifests/1,
    &MyApp.PageContext.user_context/1
  ]
```

Each provider receives assigns and returns a map merged into the context. The settings panel reads `themeManifests` from the context automatically (falls back to API if missing). See `PureAdmin.PageContext` for details.

## Logging

All JS hooks use a categorized logger — silent by default, zero overhead in production.

```javascript
// Enable in browser console
PureAdmin.logging.enableLogging()

// Or per-category
PureAdmin.logging.setCategoryLevel('PA:SETTINGS', 'debug')

// List categories
PureAdmin.logging.getCategories()
// => ["PA:SETTINGS", "PA:CMD_PALETTE", ...]
```

Also available via `window.components['keen-pure-admin'].logging` (KeenMate convention).

## Requirements

- Elixir ~> 1.15
- Phoenix LiveView ~> 1.0
- `@keenmate/pure-admin-core` CSS (v2.9.0-rc06+)

## Development

```bash
mix deps.get      # Install dependencies
mix compile        # Compile
mix test           # Run tests
mix format         # Format code
mix quality        # Format check + credo + dialyzer
```

### Demo App

```bash
cd demo
mix setup         # Install deps + build assets
mix phx.server    # Visit http://localhost:4000
```

### Running the Demo with Podman

Using Make (recommended):

```bash
make podman-build     # Build the image
make podman-run       # Run the container (port 4000)
make podman-deploy    # Build + run in one step
make podman-push      # Push to registry.km8.es
make podman-logs      # Tail container logs
make podman-stop      # Stop the container
make podman-clean     # Remove container and image
```

Or manually:

```bash
podman build -t keen-pure-admin-demo .
podman run -p 4000:4000 \
  -e SECRET_KEY_BASE=$(mix phx.gen.secret) \
  -e PHX_HOST=localhost \
  keen-pure-admin-demo
```

For production (`elixir.demo.pureadmin.io`):

```bash
SECRET_KEY_BASE=<your-secret> PHX_HOST=elixir.demo.pureadmin.io make podman-deploy
```

## License

MIT
