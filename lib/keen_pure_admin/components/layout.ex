defmodule PureAdmin.Components.Layout do
  @moduledoc """
  Layout components for Pure Admin.

  Provides the full page structure: navbar, layout wrapper, sidebar, main content, and footer.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias PureAdmin.Config
  import PureAdmin.Components.Icon
  import PureAdmin.Helpers

  @doc """
  Renders the universal top navbar (rc14): a fixed burger anchor plus three OPEN,
  degradable zones (`start` / `center` / `end`), all direct children of
  `.pc-navbar__inner`. The navbar prescribes no fixed brand/nav/search/profile
  slots — compose each zone from the content pieces (`app_header/1`,
  `nav_menu/1`, `page_header/1`, `navbar_search/1`, `profile_button/1`,
  notifications) and wrap anything responsive in `fit_slot/1`.

  ## Examples

      <.navbar>
        <:burger><.navbar_burger target="sidebar" /></:burger>
        <:start>
          <.app_header>My App</.app_header>
          <.nav_menu>
            <.nav_item href="/" is_active>Dashboard</.nav_item>
          </.nav_menu>
        </:start>
        <:center>
          <.page_header><h2>Dashboard</h2></.page_header>
        </:center>
        <:end_>
          <.profile_button name="John Doe" phx-click={toggle_profile_panel()} />
        </:end_>
      </.navbar>
  """
  attr(:id, :string, default: nil, doc: "Optional navbar id; derives the fit container's id")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot(:burger,
    doc:
      "Fixed anchor (rc13) — rendered as `.pc-navbar__inner`'s FIRST child, a sibling " <>
        "of the degradable zones so it never collapses. Put `navbar_burger/1` here."
  )

  slot(:start, doc: "START zone (inline-start): app_header, primary nav_menu, …")
  slot(:center, doc: "CENTER zone (flex:1): page_header, search, …")
  slot(:end_, doc: "END zone (inline-end): secondary nav_menu, notifications, profile_button, …")

  def navbar(assigns) do
    # The `.pc-navbar__inner` is the navbar-fit container (rc12): the
    # PureAdminNavFit hook drives priority-driven header degradation for any
    # child carrying `data-pc-fit`. A hook needs a stable id; derive one. The
    # burger is a fixed anchor OUTSIDE the zones (rc13) — first child, sibling of
    # the zones — so it is never measured/degraded.
    assigns =
      assign_new(assigns, :_inner_id, fn ->
        case assigns[:id] do
          nil -> "pc-navbar-inner-#{System.unique_integer([:positive])}"
          id -> "#{id}-inner"
        end
      end)

    ~H"""
    <nav id={@id} class={build_classes("pc-navbar", [], @class)} {@rest}>
      <div id={@_inner_id} class="pc-navbar__inner" phx-hook="PureAdminNavFit">
        <%= for burger <- @burger do %>
          <%= render_slot(burger) %>
        <% end %>
        <div :if={@start != []} class="pc-navbar__start">
          <%= for start <- @start do %>
            <%= render_slot(start) %>
          <% end %>
        </div>
        <div :if={@center != []} class="pc-navbar__center">
          <%= for center <- @center do %>
            <%= render_slot(center) %>
          <% end %>
        </div>
        <div :if={@end_ != []} class="pc-navbar__end">
          <%= for end_ <- @end_ do %>
            <%= render_slot(end_) %>
          <% end %>
        </div>
      </div>
    </nav>
    """
  end

  @doc """
  Renders the burger menu button for sidebar toggle.
  """
  attr(:target, :string, default: "sidebar", doc: "ID of the sidebar element to toggle")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def navbar_burger(assigns) do
    ~H"""
    <button
      class={build_classes("pc-navbar__burger burger-menu", [], @class)}
      phx-click={toggle_sidebar(@target)}
      aria-label="Toggle sidebar"
      {@rest}
    >
      <span></span>
      <span></span>
      <span></span>
    </button>
    """
  end

  @doc """
  Renders the app-identity block (`pc-app-header`, rc14) — typically the navbar
  START zone. A thin composable wrapper: render your own brand markup as children
  (usually an `<h1>` wordmark, optionally a `fit_slot/1` steps ladder + version
  tag), or omit children to fall back to the configured logo + app name.

  The old built-in `version` / `monogram` ladder is gone — compose it with
  `fit_slot/1` + `fit_step/1` (see the second example), matching the universal
  navbar's "nothing fit-aware is baked in" model.

  ## Examples

      <.app_header>My App</.app_header>

      <%!-- Config fallback: logo + app_name --%>
      <.app_header />

      <%!-- Responsive wordmark → monogram; version tag drops first --%>
      <.app_header>
        <h1>
          <.fit_slot strategy="steps" priority={30} class="pc-app-header__name">
            <.fit_step index={0}>Pure Admin</.fit_step>
            <.fit_step index={1}>PA</.fit_step>
          </.fit_slot><.fit_slot strategy="hide" priority={10} class="pc-app-header__version">v2.9.0</.fit_slot>
        </h1>
      </.app_header>
  """
  attr(:logo, :string, default: nil, doc: "Logo image URL for the config fallback (falls back to config :app_logo)")
  attr(:logo_alt, :string, default: "", doc: "Logo alt text")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, doc: "Brand content; omit to fall back to config logo + :app_name")

  def app_header(assigns) do
    assigns =
      assigns
      |> assign_new(:_logo, fn -> assigns.logo || Config.app_logo() end)
      |> assign_new(:_name, fn -> Config.app_name() end)

    ~H"""
    <div class={build_classes("pc-app-header", [], @class)} {@rest}>
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <img :if={@_logo} src={@_logo} alt={@logo_alt} class="pc-app-header__logo" />
        <h1 :if={@_name}>{@_name}</h1>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a navbar menu (`pc-navmenu`, rc14) placed inside a `navbar/1` zone. A
  menu's side is decided purely by which zone it sits in — rc14 dropped the old
  `--start`/`--end` modifiers.

  Owns its responsive collapse: when `collapse` is set it drives the one Fit
  engine's nav path via the `PureAdminNavFitCollapse` hook (data-pc-fit-nav),
  folding its lowest-priority items out as the header narrows and restoring them
  as it widens. Per-item config lives on the `nav_item/1` children
  (`priority` / `collapse="hide"` / `icon`).

  ## Examples

      <.nav_menu>
        <.nav_item href="/">Dashboard</.nav_item>
        <.nav_item href="/settings">Settings</.nav_item>
      </.nav_menu>

      <%!-- Responsive collapse: fold low-priority items into a "More" menu --%>
      <.nav_menu collapse="menu" more_label="More">
        <.nav_item href="/" is_active priority={10}>Dashboard</.nav_item>
        <.nav_item href="/reports">Reports</.nav_item>
      </.nav_menu>
  """
  attr(:collapse, :string,
    default: nil,
    values: [nil, "menu", "sidebar"],
    doc:
      "Responsive collapse mode. \"menu\" folds items into a generated \"More\" dropdown; " <>
        "\"sidebar\" rebuilds them as native sidebar items. Requires the PureAdminNavFitCollapse hook."
  )

  attr(:more_label, :string, default: nil, doc: "Label for the generated \"More\" trigger (menu mode)")

  attr(:collapse_target, :string,
    default: nil,
    doc: "CSS selector for the sidebar <ul> to inject into (sidebar mode)"
  )

  attr(:collapse_label, :string,
    default: nil,
    doc: "Section heading for the folded-in items (sidebar mode)"
  )

  attr(:collapse_icon, :string,
    default: nil,
    doc: "Default icon for folded-in items (sidebar mode; \"\" to omit)"
  )

  attr(:id, :string, default: nil, doc: "DOM id (auto-derived when collapse is set — the hook needs one)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def nav_menu(assigns) do
    # The PureAdminNavFitCollapse hook requires a stable DOM id; only force one
    # when a collapse mode is active so plain navs stay id-free.
    assigns =
      if assigns.collapse && is_nil(assigns.id) do
        assign(assigns, :id, "pc-navmenu-#{System.unique_integer([:positive])}")
      else
        assigns
      end

    ~H"""
    <nav
      id={@id}
      class={build_classes("pc-navmenu", [], @class)}
      data-pc-fit-nav={@collapse}
      data-pc-fit-nav-more-label={@more_label}
      data-pc-fit-nav-target={@collapse_target}
      data-pc-fit-nav-label={@collapse_label}
      data-pc-fit-nav-icon={@collapse_icon}
      phx-hook={@collapse && "PureAdminNavFitCollapse"}
      phx-update={@collapse && "ignore"}
      {@rest}
    >
      <ul>
        <%= render_slot(@inner_block) %>
      </ul>
    </nav>
    """
  end

  @doc """
  Renders a navigation item within `nav_menu/1` (`pc-navmenu__item`, rc14).

  Following the canonical DOM, a plain item carries NO class (the `pc-navmenu`
  block styles its `<ul> > <li> > <a>` directly); only `is_active`
  (`pc-navmenu__item--active`) and `has_dropdown`
  (`pc-navmenu__item pc-navmenu__item--has-dropdown`) add classes.

  ## Examples

      <.nav_item href="/dashboard">Dashboard</.nav_item>

      <.nav_item has_dropdown>
        Products
        <:dropdown>
          <.nav_dropdown>
            <.nav_item href="/products">All</.nav_item>
          </.nav_dropdown>
        </:dropdown>
      </.nav_item>
  """
  attr(:href, :string, default: "#")
  attr(:has_dropdown, :boolean, default: false, doc: "Whether this item has a dropdown submenu")

  attr(:is_active, :boolean,
    default: false,
    doc: "Marks the current section — emits pc-navmenu__item--active"
  )

  attr(:priority, :integer,
    default: nil,
    doc: "Collapse priority — lowest drops first. Emitted as data-pc-fit-nav-priority."
  )

  attr(:icon, :string,
    default: nil,
    doc: "Icon for this item when folded into the sidebar. Emitted as data-pc-nav-icon."
  )

  attr(:collapse, :string,
    default: nil,
    values: [nil, "hide"],
    doc:
      "Per-item collapse behaviour. \"hide\" drops the item when it doesn't fit instead of " <>
        "relocating it. Emitted as data-pc-fit-nav."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(navigate patch))
  slot(:inner_block, required: true)
  slot(:dropdown, doc: "Dropdown submenu content (use with has_dropdown)")

  def nav_item(assigns) do
    ~H"""
    <li
      class={nav_item_classes(assigns)}
      data-pc-fit-nav-priority={@priority}
      data-pc-nav-icon={@icon}
      data-pc-fit-nav={@collapse}
    >
      <a href={safe_url(@href)} class={if @has_dropdown, do: "pc-navmenu__link"} {@rest}>
        <%= render_slot(@inner_block) %>
      </a>
      <%= for dropdown <- @dropdown do %>
        <%= render_slot(dropdown) %>
      <% end %>
    </li>
    """
  end

  # rc14 canonical: a plain item has no class; `--has-dropdown` brings the base
  # `pc-navmenu__item`, `--active` stands alone as the held-pill modifier.
  defp nav_item_classes(assigns) do
    []
    |> then(fn acc ->
      if assigns.has_dropdown, do: acc ++ ["pc-navmenu__item", "pc-navmenu__item--has-dropdown"], else: acc
    end)
    |> then(fn acc -> if assigns.is_active, do: acc ++ ["pc-navmenu__item--active"], else: acc end)
    |> then(fn acc -> if assigns.class, do: acc ++ [assigns.class], else: acc end)
    |> case do
      [] -> nil
      list -> Enum.join(list, " ")
    end
  end

  @doc """
  Renders a dropdown submenu for a `nav_item/1` (`pc-navmenu__dropdown`, rc14).

  ## Examples

      <.nav_dropdown>
        <.nav_item href="/products">All Products</.nav_item>
        <.nav_item href="/categories">Categories</.nav_item>
      </.nav_dropdown>
  """
  attr(:is_level2, :boolean, default: false, doc: "Second-level nested dropdown")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def nav_dropdown(assigns) do
    ~H"""
    <ul
      class={build_classes("pc-navmenu__dropdown", [{"pc-navmenu__dropdown--level2", @is_level2}], @class)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  @doc """
  Renders the page-title block (`pc-page-header`, rc14) — typically the navbar
  CENTER zone. A thin structural wrapper (core gives it truncation / flexing); to
  have the title degrade as the header narrows, wrap it in a `fit_slot/1`.

  ## Examples

      <.page_header><h2>Dashboard</h2></.page_header>

      <%!-- Degrade the title (drops before the brand when the header is tight) --%>
      <.fit_slot strategy="hide" priority={20}>
        <.page_header><h2>Dashboard</h2></.page_header>
      </.fit_slot>
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def page_header(assigns) do
    ~H"""
    <div class={build_classes("pc-page-header", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Generic navbar-fit participation wrapper (rc12) — opts *any* header content into
  priority-driven degradation. `fit_slot/1` renders THE measured element itself
  (not a wrapper around it), so pass `class` to also carry the styled class (e.g.
  `class="pc-app-header__version"`).

  Compose it inside `navbar/1` (whose `.pc-navbar__inner` is the fit container);
  the engine degrades participating slots one at a time, LOWEST `priority` first,
  until the header row fits, then restores as space returns. Nothing fit-aware is
  baked into the navbar components (rc14) — a slot only degrades if you wrap it here.

  ## Strategies

  - `"hide"` (default) — the slot disappears when it must yield:

        <.fit_slot priority={15}>
          <button class="pa-btn pa-btn--icon-only">…</button>
        </.fit_slot>

  - `"steps"` — a ladder of ranked `fit_step/1` variants (widest first); the
    engine climbs down 0 → 1 → 2 … then hides. See `fit_step/1`:

        <.fit_slot strategy="steps" priority={30} class="pc-app-header__name">
          <.fit_step index={0}>Pure Admin</.fit_step>
          <.fit_step index={1}>PA</.fit_step>
        </.fit_slot>

  - `"sidebar"` — relocate the slot into the sidebar when it yields; restored on
    widen. Optionally point `sidebar_target` at the destination `<ul>` selector.
  """
  attr(:strategy, :string,
    default: "hide",
    values: ~w(hide steps sidebar),
    doc: "How the slot yields: hide (disappear) | steps (swap ranked fit_step variants) | sidebar (relocate)."
  )

  attr(:priority, :integer, default: 0, doc: "Degrade order; lower yields first.")

  attr(:sidebar_target, :string,
    default: nil,
    doc: "(strategy=sidebar) CSS selector of the `<ul>` to relocate into; defaults to the first sidebar nav list."
  )

  attr(:tag, :string, default: "span", doc: "Wrapper element — `span` for inline header slots, `div` for block.")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, doc: "The slot content (hide/sidebar), or the fit_step ladder (steps).")

  def fit_slot(assigns) do
    ~H"""
    <.dynamic_tag
      tag_name={@tag}
      class={@class}
      data-pc-fit={@strategy}
      data-pc-fit-priority={@priority}
      data-pc-fit-sidebar-target={@strategy == "sidebar" && @sidebar_target}
      {@rest}
    >{render_slot(@inner_block)}</.dynamic_tag>
    """
  end

  @doc """
  One ranked variant inside a `<.fit_slot strategy="steps">` (rc12 navbar-fit).
  The engine shows the largest step that fits and climbs the ladder
  (0 → 1 → 2 … → hidden) as the header narrows.

  Order the steps widest-first and give each its 0-based `index`; every step past
  the first is stamped `pc-fit-hidden` so before JS runs only the widest paints
  (no stacked flash, no-JS-safe). Renders a single `<span data-pc-fit-step="N">`
  that must be a DIRECT child of the steps slot — which it is, since function
  components add no wrapper DOM.

  ## Examples

      <.fit_slot strategy="steps" priority={30} class="pc-app-header__name">
        <.fit_step index={0}>Pure Admin</.fit_step>
        <.fit_step index={1}>PA</.fit_step>
        <.fit_step index={2}><i class="fa-solid fa-a" aria-hidden="true"></i></.fit_step>
      </.fit_slot>
  """
  attr(:index, :integer, required: true, doc: "0-based step index in DOM order; 0 = widest/default.")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def fit_step(assigns) do
    ~H"""
    <span data-pc-fit-step={@index} {fit_step_attrs(@index, @class)} {@rest}>{render_slot(@inner_block)}</span>
    """
  end

  # Every step past the first is hidden until the engine promotes it — correct
  # first paint. Returned as a spread so step 0 (or a bare step with no extra
  # class) emits NO class attribute at all (matching the canonical DOM), rather
  # than an empty `class=""` that HEEx's class normalisation would produce.
  defp fit_step_attrs(index, extra) do
    [(index > 0 && "pc-fit-hidden") || nil, extra]
    |> Enum.reject(&(&1 in [nil, false, ""]))
    |> case do
      [] -> []
      list -> [class: Enum.join(list, " ")]
    end
  end

  @doc """
  Renders the compact navbar search trigger — a button that opens the command
  palette (`.pc-navbar-search--sm`, rc12 pattern **B**).

  It participates in navbar-fit by default (`data-pc-fit="hide"`, priority 25) so
  it's the first affordance dropped when the header runs out of room. For an
  inline live-search box use `navbar_search_field/1`; for a sidebar entry point
  use `sidebar_search/1`.

  ## Examples

      <.navbar_search phx-click={show_command_palette()} />

      <.navbar_search placeholder="Search…" size="sm" phx-click={show_command_palette()} />
  """
  attr(:placeholder, :string, default: "Search…")
  attr(:size, :string, default: "sm", values: [nil, "xs", "sm", "md", "lg", "xl"])

  attr(:is_fit, :boolean,
    default: true,
    doc: "Drop the trigger first when the header is tight (navbar-fit hide, priority 25)."
  )

  attr(:is_hidden, :boolean, default: false, doc: "Render with the standard `hidden` attribute.")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def navbar_search(assigns) do
    ~H"""
    <button
      type="button"
      class={build_classes("pc-navbar-search", [{"pc-navbar-search--#{@size}", @size != nil}], @class)}
      hidden={@is_hidden}
      aria-label="Search (Ctrl+K)"
      data-pc-fit={@is_fit && "hide"}
      data-pc-fit-priority={@is_fit && "25"}
      {@rest}
    >
      <span class="pc-navbar-search__icon" aria-hidden="true"></span>
      <span class="pc-navbar-search__placeholder">{@placeholder}</span>
      <span class="pc-navbar-search__shortcut">
        <kbd>Ctrl</kbd>
        <kbd>K</kbd>
      </span>
    </button>
    """
  end

  @doc """
  Renders an inline live-search field in the navbar (`.pc-navbar-search--field`,
  rc12 pattern **A**) — a text input with its own autocomplete results dropdown,
  independent of the Ctrl+K palette.

  Wire the input to a LiveView handler with the usual bindings via the global
  attrs (they land on the `<input>`), and render matches into the `:results`
  slot; the `.pa-search-autocomplete` container is hidden while the slot is empty.

  ## Examples

      <.navbar_search_field id="nav-search" phx-keyup="search" phx-debounce="200">
        <:results :if={@matches != []}>
          <a :for={m <- @matches} href={m.href} class="pa-search-autocomplete__item">{m.label}</a>
        </:results>
      </.navbar_search_field>
  """
  attr(:id, :string, required: true, doc: "Unique id; the input/results get `-input`/`-results` suffixes.")
  attr(:placeholder, :string, default: "Search…")
  attr(:is_hidden, :boolean, default: false, doc: "Render with the standard `hidden` attribute.")
  attr(:class, :string, default: nil)
  attr(:rest, :global, doc: "Forwarded to the <input> (e.g. phx-keyup, phx-debounce, name).")
  slot(:results, doc: "Autocomplete matches; the results container hides when this is empty.")

  def navbar_search_field(assigns) do
    ~H"""
    <div id={@id} class={build_classes("pc-navbar-search pc-navbar-search--field", [], @class)} hidden={@is_hidden}>
      <span class="pc-navbar-search__icon" aria-hidden="true"></span>
      <input
        type="text"
        id={"#{@id}-input"}
        class="pc-navbar-search__field"
        placeholder={@placeholder}
        autocomplete="off"
        aria-label="Search"
        {@rest}
      />
      <div class="pa-search-autocomplete" id={"#{@id}-results"} hidden={@results == []}>
        <%= render_slot(@results) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a "type-and-go" navbar search (`.pc-navbar-search--input`, rc15) — a real
  `<input>` in the pill shell wrapped in a `<form>` whose native GET submit navigates
  to a results page on Enter. NO dropdown, NO palette.

  It's the simplest of the three navbar search shapes: contrast `navbar_search/1`
  (a pill that opens the command palette) and `navbar_search_field/1` (live in-place
  results). Point `action` at your search route (see `search_results/1` for the
  destination) and `name` becomes the query param (e.g. `?q=…`).

  Participates in navbar-fit by default (`data-pc-fit="hide"`, priority 25), matching
  the other navbar search entry points.

  ## Examples

      <.navbar_search_input action={~p"/search"} />

      <.navbar_search_input action="/search" name="query" placeholder="Search docs…" />
  """
  attr(:action, :string, required: true, doc: "Form target — your search results route (e.g. \"/search\").")
  attr(:method, :string, default: "get", values: ~w(get post), doc: "HTTP method; get keeps the query in the URL.")
  attr(:name, :string, default: "q", doc: "Query field name — becomes the URL param.")
  attr(:value, :string, default: nil, doc: "Initial query text.")
  attr(:placeholder, :string, default: "Search…")

  attr(:is_fit, :boolean,
    default: true,
    doc: "Drop the box first when the header is tight (navbar-fit hide, priority 25)."
  )

  attr(:is_hidden, :boolean, default: false, doc: "Render with the standard `hidden` attribute.")
  attr(:class, :string, default: nil)
  attr(:rest, :global, doc: "Forwarded to the <form>.")

  def navbar_search_input(assigns) do
    ~H"""
    <form
      class={build_classes("pc-navbar-search pc-navbar-search--input", [], @class)}
      action={@action}
      method={@method}
      role="search"
      hidden={@is_hidden}
      data-pc-fit={@is_fit && "hide"}
      data-pc-fit-priority={@is_fit && "25"}
      {@rest}
    >
      <span class="pc-navbar-search__icon" aria-hidden="true"></span>
      <input
        type="search"
        name={@name}
        value={@value}
        class="pc-navbar-search__field"
        placeholder={@placeholder}
        autocomplete="off"
        aria-label="Search"
      />
    </form>
    """
  end

  @doc """
  Renders the profile button (`pc-navbar__profile-btn`, rc14) — typically the
  navbar END zone. Triggers the profile panel.

  ## Examples

      <.profile_button name="John Doe" />

      <.profile_button name="John Doe" phx-click={toggle_profile_panel()}>
        <:icon><img src="/avatar.jpg" /></:icon>
      </.profile_button>
  """
  attr(:name, :string, default: nil, doc: "User display name")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:icon, doc: "Custom icon/avatar content")

  def profile_button(assigns) do
    ~H"""
    <button
      class={build_classes("pc-navbar__profile-btn", [], @class)}
      aria-label="User Profile"
      {@rest}
    >
      <span :if={@icon != []} class="pa-btn__icon">
        <%= for icon <- @icon do %>
          <%= render_slot(icon) %>
        <% end %>
      </span>
      <span :if={@icon == []} class="pa-btn__icon"><span class="pa-icon pa-icon--user" aria-hidden="true"></span></span>
      <span :if={@name} class="pc-navbar__profile-name"><%= @name %></span>
    </button>
    """
  end

  @doc """
  Renders a notifications bell button with dropdown panel.

  ## Examples

      <.notifications count={3}>
        <.notification_item variant="primary" icon="fa-solid fa-file-pen">
          <:title>New task assigned</:title>
          <:text>Review the Q4 report by end of week</:text>
          <:time>2 minutes ago</:time>
        </.notification_item>
      </.notifications>
  """
  attr(:id, :string, default: "notifications")
  attr(:count, :integer, default: nil, doc: "Badge count (nil = no badge)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, doc: "Notification items")
  slot(:footer_, doc: "Footer content (e.g. 'View all' link)")

  def notifications(assigns) do
    ~H"""
    <div id={@id} class={build_classes("pa-notifications", [], @class)} {@rest}>
      <button
        class="pa-notifications__btn"
        phx-click={toggle_notifications(@id)}
        aria-label="Notifications"
      >
        <span class="pa-notifications__icon"><span class="pa-icon pa-icon--bell" aria-hidden="true"></span></span>
        <span :if={@count && @count > 0} class="pa-notifications__badge"><%= @count %></span>
      </button>

      <div id={"#{@id}-panel"} class="pa-notifications__panel" style="display: none;">
        <div class="pa-notifications__header">
          <h3>Notifications</h3>
        </div>
        <ul :if={@inner_block != []} class="pa-notifications__list">
          <%= render_slot(@inner_block) %>
        </ul>
        <div :if={@footer_ != []} class="pa-notifications__footer">
          <%= for footer_ <- @footer_ do %>
            <%= render_slot(footer_) %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a single notification item within `notifications`.

  ## Examples

      <.notification_item variant="success" icon="fa-solid fa-check">
        <:title>Build completed</:title>
        <:text>Production deployment finished</:text>
        <:time>15 minutes ago</:time>
      </.notification_item>
  """
  attr(:variant, :string,
    default: nil,
    values: [nil, "primary", "secondary", "success", "warning", "danger", "info"]
  )

  attr(:icon, :string, default: nil, doc: "Icon class (e.g. 'fa-solid fa-check')")
  attr(:is_unread, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:title, doc: "Notification title")
  slot(:text, doc: "Notification body text")
  slot(:time, doc: "Timestamp text")

  def notification_item(assigns) do
    ~H"""
    <li
      class={build_classes("pa-notifications__item", [{"pa-notifications__item--unread", @is_unread}], @class)}
      {@rest}
    >
      <div class={build_classes("pa-notifications__icon-wrapper", [{"pa-notifications__icon-wrapper--#{@variant}", @variant != nil}])}>
        <i :if={@icon} class={@icon}></i>
      </div>
      <div class="pa-notifications__content">
        <h4 :if={@title != []}>
          <%= for title <- @title do %>
            <%= render_slot(title) %>
          <% end %>
        </h4>
        <p :if={@text != []}>
          <%= for text <- @text do %>
            <%= render_slot(text) %>
          <% end %>
        </p>
        <span :if={@time != []} class="pa-notifications__time">
          <%= for time <- @time do %>
            <%= render_slot(time) %>
          <% end %>
        </span>
      </div>
    </li>
    """
  end

  @doc "JS command to toggle the notifications panel."
  @spec toggle_notifications(String.t()) :: JS.t()
  def toggle_notifications(id \\ "notifications") do
    JS.toggle(to: "##{id}-panel", display: "block")
  end

  @doc """
  Renders the main layout container (below navbar).

  ## Examples

      <.layout>
        <.sidebar>...</.sidebar>
        <.main>...</.main>
        <.footer>...</.footer>
      </.layout>
  """
  attr(:id, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def layout(assigns) do
    ~H"""
    <div id={@id} class={build_classes("pc-layout", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders the layout inner container (sidebar + content).
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def layout_inner(assigns) do
    ~H"""
    <div class={build_classes("pc-layout__inner", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders the layout content wrapper.
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def layout_content(assigns) do
    ~H"""
    <div class={build_classes("pc-layout__content", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders the sidebar navigation.

  ## Examples

      <.sidebar>
        <.sidebar_item href="/" icon="📊" label="Dashboard" is_active />
        <.sidebar_item href="/users" icon="👥" label="Users" />
      </.sidebar>
  """
  attr(:id, :string, default: "sidebar")
  # Note: former `is_sticky` attr emitted `pc-layout__sidebar--sticky`, a class
  # that never existed in core (no JS, no SCSS) — dropped. Sticky mode is a
  # body-level concern (`pc-layout--sticky` on `<body>`, driven by the sidebar
  # JS / localStorage), not a sidebar-element modifier.
  attr(:is_icon_collapse, :boolean, default: false)

  attr(:is_resizable, :boolean,
    default: false,
    doc:
      "Enables drag-to-resize (emits pc-layout__sidebar--resizable). The " <>
        "PureAdminSidebar hook drives the vendored sidebar-resize module, which " <>
        "creates its own .pc-sidebar-resize handle and updates --pc-local-sidebar-width."
  )

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sidebar(assigns) do
    ~H"""
    <aside
      id={@id}
      class={sidebar_classes(assigns)}
      phx-hook="PureAdminSidebar"
      {@rest}
    >
      <nav class="pc-sidebar__nav">
        <ul>
          <%= render_slot(@inner_block) %>
        </ul>
      </nav>
    </aside>
    """
  end

  @doc """
  Renders a sidebar search entry point (`.pc-sidebar__search`, rc12/rc15) — a
  full-width `<li>` at the top of the sidebar that collapses to just its icon in an
  icon-collapse sidebar. Place it as the first child of `sidebar/1`.

  Two modes:

  - **Trigger** (default) — a `<button>` firing `phx-click` (e.g. open the command
    palette).
  - **Type-and-go** — pass `action` to render `.pc-sidebar__search--input`: a `<form>`
    whose native GET submit navigates to a results page (see `search_results/1`) on
    Enter. Its magnifier is a `type="submit"`, so it still submits from the collapsed
    icon-rail (an empty query lands on the bare results page). `name` becomes the
    query param.

  ## Examples

      <.sidebar>
        <.sidebar_search phx-click={show_command_palette()} />
        <.sidebar_item href="/" icon="fa-solid fa-gauge" label="Dashboard" />
      </.sidebar>

      <.sidebar_search action={~p"/search"} placeholder="Search…" />
  """
  attr(:label, :string, default: "Search…")
  # The magnifier is the canonical masked search glyph (`.pa-icon--search` in the
  # button trigger; a CSS mask on `.pc-sidebar__search-icon` in the type-and-go
  # form) — it traces to `--base-icon-search`, so it matches the navbar search and
  # command palette and re-skins with the theme. This attr is retained for
  # backward compatibility but is no longer rendered.
  attr(:icon, :string,
    default: "fa-solid fa-magnifying-glass",
    doc: "Deprecated / unused — the search glyph is the masked `.pa-icon--search`."
  )

  attr(:action, :string,
    default: nil,
    doc: "Set to switch to type-and-go form mode (`.pc-sidebar__search--input`)."
  )

  attr(:method, :string, default: "get", values: ~w(get post), doc: "HTTP method (type-and-go mode).")
  attr(:name, :string, default: "q", doc: "Query field name → URL param (type-and-go mode).")
  attr(:value, :string, default: nil, doc: "Initial query text (type-and-go mode).")
  attr(:placeholder, :string, default: "Search…", doc: "Input placeholder (type-and-go mode).")
  attr(:is_hidden, :boolean, default: false, doc: "Render with the standard `hidden` attribute.")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def sidebar_search(%{action: action} = assigns) when action != nil do
    ~H"""
    <li class="pc-sidebar__item">
      <form
        class={build_classes("pc-sidebar__search pc-sidebar__search--input", [], @class)}
        action={@action}
        method={@method}
        role="search"
        hidden={@is_hidden}
        {@rest}
      >
        <button type="submit" class="pc-sidebar__search-icon" aria-label="Search"></button>
        <input
          type="search"
          name={@name}
          value={@value}
          class="pc-sidebar__search-field"
          placeholder={@placeholder}
          autocomplete="off"
          aria-label="Search"
        />
      </form>
    </li>
    """
  end

  def sidebar_search(assigns) do
    ~H"""
    <li class="pc-sidebar__item">
      <button type="button" class={build_classes("pc-sidebar__search", [], @class)} hidden={@is_hidden} {@rest}>
        <span class="pc-sidebar__icon pc-icon-hover-highlight" aria-hidden="true"><span class="pa-icon pa-icon--search"></span></span>
        <span class="pc-sidebar__label">{@label}</span>
      </button>
    </li>
    """
  end

  @doc """
  Renders a page-level search results list (`.pa-search-results`, rc15) — the
  *destination* a type-and-go search submits to (see `navbar_search_input/1` /
  `sidebar_search/1` with an `action`), distinct from the `.pa-search-autocomplete`
  dropdown under a live field (`navbar_search_field/1`).

  One item tree, four presets on the container via `variant`:

  - `"compact"` (default) — dense one-liners (title + type).
  - `"detailed"` — tinted icon tile + snippet + meta trail.
  - `"grouped"` — items bucketed under `__group` / `__group-title` (by `:group`).
  - `"cards"` — a responsive grid of result cards.

  Each result is a map: `:title` (required), and optionally `:icon`, `:snippet`,
  `:meta` (list of strings), `:type`, `:href`, `:id`, and `:group` (grouped preset).

  Full-text match highlight: a backend returns the matched fragment wrapped in
  `<mark class="pa-search-results__mark">…</mark>` (Elasticsearch highlight /
  Postgres `ts_headline`). Set `allow_html` to render `:title`/`:snippet`/`:meta` as
  HTML so the `<mark>` shows — the value is injected verbatim, so it MUST be
  backend-sanitised.

  ## Examples

      <.search_results results={@results} variant="detailed" allow_html />

      <.search_results
        results={@results}
        variant="grouped"
        groups={[%{id: "pages", label: "Pages"}, %{id: "products", label: "Products", limit: 5}]}
      />
  """
  attr(:results, :list, required: true, doc: "List of result maps.")

  attr(:variant, :string,
    default: "compact",
    values: ~w(compact detailed grouped cards),
    doc: "Container preset."
  )

  attr(:groups, :list,
    default: nil,
    doc:
      "Group metadata (`%{id, label, limit}`) for the grouped preset, keyed by `:group`. Omit to derive groups from the distinct `:group` values in first-seen order."
  )

  attr(:allow_html, :boolean,
    default: false,
    doc: "Render `:title`/`:snippet`/`:meta` as HTML so a backend `<mark>` highlight shows (must be sanitised)."
  )

  attr(:empty_text, :string, default: "No results", doc: "Shown when `results` is empty.")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def search_results(assigns) do
    assigns =
      assign(
        assigns,
        :sections,
        if(assigns.variant == "grouped", do: search_sections(assigns.results, assigns.groups), else: [])
      )

    ~H"""
    <div class={build_classes("pa-search-results pa-search-results--#{@variant}", [], @class)} {@rest}>
      <%!-- Core defines no __empty for this block (unlike the autocomplete popup),
           so the empty message is a plain paragraph rather than an invented class. --%>
      <p :if={@results == []}>{@empty_text}</p>
      <%= if @results != [] and @variant == "grouped" do %>
        <div :for={section <- @sections} class="pa-search-results__group">
          <div :if={section.label not in [nil, ""]} class="pa-search-results__group-title">{section.label}</div>
          <.search_result_item :for={result <- section.items} result={result} allow_html={@allow_html} />
        </div>
      <% end %>
      <%= if @results != [] and @variant != "grouped" do %>
        <.search_result_item :for={result <- @results} result={result} allow_html={@allow_html} />
      <% end %>
    </div>
    """
  end

  attr(:result, :map, required: true)
  attr(:allow_html, :boolean, default: false)

  defp search_result_item(assigns) do
    ~H"""
    <a class="pa-search-results__item" href={safe_url(@result[:href] || "#")}>
      <span :if={@result[:icon]} class="pa-search-results__icon" aria-hidden="true">{@result[:icon]}</span>
      <div class="pa-search-results__content">
        <div class="pa-search-results__title">{search_text(@result[:title], @allow_html)}</div>
        <p :if={@result[:snippet]} class="pa-search-results__snippet">{search_text(@result[:snippet], @allow_html)}</p>
        <div :if={@result[:meta] not in [nil, []]} class="pa-search-results__meta">
          <span :for={m <- @result[:meta]} class="pa-search-results__meta-item">{search_text(m, @allow_html)}</span>
        </div>
      </div>
      <span :if={@result[:type]} class="pa-search-results__type">{@result[:type]}</span>
    </a>
    """
  end

  defp search_text(value, true), do: Phoenix.HTML.raw(value)
  defp search_text(value, _), do: value

  # Bucket results by :group (first-seen order), then order/limit by the optional
  # `groups` metadata — any bucket without matching metadata trails in first-seen
  # order. Mirrors svelte SearchResults' grouped sectioning.
  defp search_sections(results, groups) do
    {keys, buckets} =
      Enum.reduce(results, {[], %{}}, fn r, {keys, buckets} ->
        key = Map.get(r, :group) || ""

        if Map.has_key?(buckets, key) do
          {keys, Map.update!(buckets, key, &[r | &1])}
        else
          {keys ++ [key], Map.put(buckets, key, [r])}
        end
      end)

    buckets = Map.new(buckets, fn {k, v} -> {k, Enum.reverse(v)} end)
    has_meta = is_list(groups) and groups != []
    order = if has_meta, do: Enum.map(groups, & &1[:id]), else: keys
    extra = if has_meta, do: Enum.reject(keys, &(&1 in order)), else: []

    Enum.flat_map(order ++ extra, &section_for(&1, buckets, groups))
  end

  defp section_for(key, buckets, groups) do
    case Map.get(buckets, key) do
      items when is_list(items) and items != [] ->
        meta = is_list(groups) && Enum.find(groups, &(&1[:id] == key))
        label = (meta && meta[:label]) || key
        items = if meta && meta[:limit], do: Enum.take(items, meta[:limit]), else: items
        [%{id: key, label: label, items: items}]

      _ ->
        []
    end
  end

  defp sidebar_classes(assigns) do
    build_classes(
      "pc-layout__sidebar",
      [
        {"pc-layout__sidebar--icon-collapse", assigns.is_icon_collapse},
        {"pc-layout__sidebar--resizable", assigns.is_resizable}
      ],
      assigns.class
    )
  end

  # Renders the `.pc-sidebar__icon` span for a link/submenu. The `pc-icon-hover-highlight`
  # marker opts the glyph into the foundation's hover-recolour rule (pure-css ≥1.1.1).
  # `icon` may be an inline SVG string (rendered raw, matching pure-admin's Lucide
  # sidebar) OR a `<.icon>` name (FA / `hero-*`).
  attr(:icon, :string, default: nil)

  defp sidebar_icon_span(assigns) do
    ~H"""
    <span :if={@icon} class="pc-sidebar__icon pc-icon-hover-highlight"><%= if svg_icon?(@icon) do %><%= Phoenix.HTML.raw(@icon) %><% else %><.icon name={@icon} /><% end %></span>
    """
  end

  # True when the icon value is raw SVG/HTML markup (starts with `<`) rather than
  # an `<.icon>` name — lets the sidebar render pure-admin's inline Lucide glyphs.
  defp svg_icon?(icon) when is_binary(icon), do: String.starts_with?(String.trim_leading(icon), "<")
  defp svg_icon?(_), do: false

  @doc """
  Renders a sidebar menu item (link).

  ## Examples

      <.sidebar_item href="/dashboard" icon="📊" label="Dashboard" is_active />
  """
  attr(:href, :string, default: "#")
  attr(:icon, :string, default: nil, doc: "Icon text, emoji, or HTML")
  attr(:label, :string, required: true)
  attr(:is_active, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(phx-click navigate patch))

  def sidebar_item(assigns) do
    ~H"""
    <li class="pc-sidebar__item">
      <a
        href={safe_url(@href)}
        class={build_classes("pc-sidebar__link", [{"pc-sidebar__link--active", @is_active}], @class)}
        {@rest}
      >
        <.sidebar_icon_span icon={@icon} />
        <span class="pc-sidebar__label"><%= @label %></span>
      </a>
    </li>
    """
  end

  @doc """
  Renders a collapsible sidebar submenu item.

  ## Examples

      <.sidebar_submenu icon="📋" label="Tables">
        <.sidebar_item href="/tables" icon="📊" label="Standard" />
        <.sidebar_item href="/tables-lazy" icon="⚡" label="Lazy Loading" />
      </.sidebar_submenu>
  """
  attr(:id, :string, default: nil)
  attr(:icon, :string, default: nil)
  attr(:label, :string, required: true)
  attr(:is_open, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def sidebar_submenu(assigns) do
    assigns =
      assign_new(assigns, :submenu_id, fn ->
        assigns[:id] || "submenu-#{System.unique_integer([:positive])}"
      end)

    ~H"""
    <li
      class={build_classes("pc-sidebar__item", [{"pc-sidebar__item--open", @is_open}], @class)}
      phx-hook="PureAdminSidebarSubmenu"
      id={"#{@submenu_id}-wrapper"}
      data-has-active-page={to_string(@is_open)}
    >
      <button
        class="pc-sidebar__toggle"
        phx-click={toggle_submenu(@submenu_id)}
        {@rest}
      >
        <.sidebar_icon_span icon={@icon} />
        <span class="pc-sidebar__label"><%= @label %></span>
        <span class="pc-sidebar__chevron">&#8250;</span>
      </button>
      <ul id={@submenu_id} class={build_classes("pc-sidebar__submenu", [{"pc-sidebar__submenu--open", @is_open}])}>
        <%= render_slot(@inner_block) %>
      </ul>
    </li>
    """
  end

  @doc """
  Renders a flat, non-interactive sidebar group heading (rc09).

  A small uppercase label (`PROJECT`, `GUIDES`, …) for grouping links when the
  groups are always visible (docs-style nav). Sits as an `<li>` sibling to the
  items inside the sidebar's `<ul>`. For collapsible groups use
  `sidebar_submenu/1` instead.

  ## Examples

      <.sidebar_section label="Project" />
      <.sidebar_section>Live Demos</.sidebar_section>
  """
  attr(:label, :string, default: nil, doc: "Heading text (alternative to the default slot)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, doc: "Heading content (overrides label)")

  def sidebar_section(assigns) do
    ~H"""
    <li class={build_classes("pc-sidebar__section", [], @class)} {@rest}>
      <%= if @inner_block != [] do %>
        <%= render_slot(@inner_block) %>
      <% else %>
        <%= @label %>
      <% end %>
    </li>
    """
  end

  @doc """
  Renders a thin horizontal rule between sidebar groups (rc09).

  Sits as an `<li class="pc-sidebar__divider">` in the sidebar's `<ul>` flow and
  carries no text. Distinct from `divider/1`, which is a standalone `<hr>`.

  ## Examples

      <.sidebar_divider />
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def sidebar_divider(assigns) do
    ~H"""
    <li class={build_classes("pc-sidebar__divider", [], @class)} {@rest}></li>
    """
  end

  @doc """
  Renders the main content area.
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def main(assigns) do
    ~H"""
    <main class={build_classes("pc-layout__main", [], @class)} {@rest}>
      <%= render_slot(@inner_block) %>
    </main>
    """
  end

  @doc """
  Renders the footer with three-section layout.

  When no slots are provided, auto-populates from config:
  - `:start` falls back to `config :copyright`
  - `:end_` falls back to `config :app_version`

  ## Examples

      <%!-- Minimal: reads from config --%>
      <.footer />

      <%!-- Explicit content --%>
      <.footer>
        <:start>&copy; 2026 My App</:start>
        <:end_>v1.0.0</:end_>
      </.footer>
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:start, doc: "Left section (falls back to config :copyright)")
  slot(:center, doc: "Center section")
  slot(:end_, doc: "Right section (falls back to config :app_version)")

  def footer(assigns) do
    assigns =
      assigns
      |> assign_new(:_copyright, fn -> Config.copyright() end)
      |> assign_new(:_version, fn -> Config.app_version() end)

    ~H"""
    <footer class={build_classes("pc-layout__footer", [], @class)} {@rest}>
      <%= if @start != [] do %>
        <div class="pc-footer__start">
          <%= for start <- @start do %>
            <%= render_slot(start) %>
          <% end %>
        </div>
      <% else %>
        <div :if={@_copyright} class="pc-footer__start">
          <span>{@_copyright}</span>
        </div>
      <% end %>
      <div :if={@center != []} class="pc-footer__center">
        <%= for center <- @center do %>
          <%= render_slot(center) %>
        <% end %>
      </div>
      <%= if @end_ != [] do %>
        <div class="pc-footer__end">
          <%= for end_ <- @end_ do %>
            <%= render_slot(end_) %>
          <% end %>
        </div>
      <% else %>
        <div :if={@_version} class="pc-footer__end">
          <span>v{@_version}</span>
        </div>
      <% end %>
    </footer>
    """
  end

  @doc """
  Renders a content section with optional heading.

  ## Examples

      <.section title_text="My Section">
        Section content here.
      </.section>
  """
  attr(:title_text, :string, default: nil, doc: "Section heading text (renders as h3)")
  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def section(assigns) do
    ~H"""
    <div class={build_classes("pa-section", [], @class)} {@rest}>
      <h3 :if={@title_text}><%= @title_text %></h3>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders a visual divider/separator — a bare `<hr>`.

  Core blesses NO class for a standalone horizontal rule (the old `pa-divider`
  had zero SCSS rules — no `.pa-divider` in main.css, no snippet, no theme — so
  it was a phantom base class; svelte's `<Divider>` emits a bare `<hr>` too). Pass
  `class` to style it yourself (e.g. spacing utilities). Distinct from
  `sidebar_divider/1`, which is an `<li class="pc-sidebar__divider">` in the
  sidebar flow.
  """
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def divider(assigns) do
    ~H"""
    <hr class={@class} {@rest} />
    """
  end

  @doc """
  Renders a hidden input containing the page context as JSON.

  JS hooks read this synchronously via `getPageContext()` instead of
  fetching from APIs. CSP-safe (no inline scripts with data).

  ## Examples

      <.page_context />

      <.page_context extra={%{"user" => %{"id" => 1}}} />
  """
  attr(:extra, :map, default: %{}, doc: "Additional context to merge (from app assigns)")
  attr(:rest, :global)

  def page_context(assigns) do
    context =
      PureAdmin.PageContext.build(assigns)
      |> Map.merge(assigns.extra)

    assigns = assign(assigns, :context_json, Jason.encode!(context))

    ~H"""
    <input type="hidden" id="pa-page-context" value={@context_json} {@rest} />
    """
  end

  @doc """
  Inline script that reads persisted UI preferences from localStorage and
  applies the corresponding classes before the page paints, preventing a
  flash of unstyled content.

  `default_mode` is the mode used on first visit, when localStorage has no
  `theme-mode` entry yet. Must be `"light"`, `"dark"`, or `"auto"`. `"auto"`
  resolves to light/dark via `prefers-color-scheme` at runtime.

  ## Examples

      <.fouc_prevention_script />
      <.fouc_prevention_script default_mode="auto" />
  """
  attr(:default_mode, :string, default: "light", values: ~w(light dark auto))

  def fouc_prevention_script(assigns) do
    ~H"""
    <script data-default-mode={@default_mode}>
      (function(){
        var b=document.body,h=document.documentElement;
        var s=document.currentScript;
        var dm=(s&&s.getAttribute('data-default-mode'))||'light';
        var m=localStorage.getItem('theme-mode')||dm;
        if(m==='dark')b.classList.add('pc-mode-dark');
        else if(m==='auto'&&window.matchMedia('(prefers-color-scheme:dark)').matches)b.classList.add('pc-mode-dark');
        else b.classList.add('pc-mode-light');
        var fs=localStorage.getItem('font-size');
        if(fs&&fs!=='default')h.classList.add('font-size-'+fs);
        var ff=localStorage.getItem('font-family');
        if(ff&&ff!=='default')b.classList.add('font-family-'+ff);
        var cw=localStorage.getItem('container-width');
        if(cw&&cw!=='fluid')b.classList.add('pa-container-'+cw);
        if(localStorage.getItem('sidebar-mode')==='sticky')b.classList.add('pc-layout--sticky');
        var isMobile=window.innerWidth<=768;
        if(!isMobile){if(localStorage.getItem('sidebar-hidden')==='true'){b.classList.add('sidebar-hidden')}else{var bm=document.querySelector('.burger-menu');if(bm)bm.classList.add('active')}}
        var sw=localStorage.getItem('sidebar-width');
        if(sw){var w=parseInt(sw,10);if(!isNaN(w)&&w>=180&&w<=500){h.style.setProperty('--pc-local-sidebar-width',(w/10)+'rem');b.classList.add('pc-sidebar-resized')}}
        var cv=localStorage.getItem('color-variant');
        if(cv)b.classList.add('pa-color-'+cv);
        if(localStorage.getItem('compact-mode')==='true')b.classList.add('compact-mode');
        if(localStorage.getItem('rtl-mode')==='true')h.setAttribute('dir','rtl');
        var ss=localStorage.getItem('pc-sidebar-submenus');
        if(ss){try{var sm=JSON.parse(ss);var r=[];for(var id in sm){if(sm[id]){
        r.push('#'+id+'-wrapper>.pc-sidebar__submenu{display:block}');
        r.push('#'+id+'-wrapper>.pc-sidebar__toggle>.pc-sidebar__chevron{transform:rotate(90deg)}');
        }}if(r.length){var st=document.createElement('style');st.id='pa-submenu-preload';st.textContent=r.join('');document.head.appendChild(st)}}catch(e){}}
      })();
    </script>
    """
  end

  @doc "JS command to toggle the sidebar visibility."
  @spec toggle_sidebar(String.t()) :: JS.t()
  def toggle_sidebar(id \\ "sidebar") do
    %JS{}
    |> JS.dispatch("pa:toggle_sidebar", to: "##{id}")
  end

  @doc "JS command to toggle a submenu open/closed."
  @spec toggle_submenu(String.t()) :: JS.t()
  def toggle_submenu(submenu_id) do
    %JS{}
    |> JS.toggle_class("pc-sidebar__item--open", to: {:closest, ".pc-sidebar__item"})
    |> JS.toggle_class("pc-sidebar__submenu--open", to: "##{submenu_id}")
  end
end
