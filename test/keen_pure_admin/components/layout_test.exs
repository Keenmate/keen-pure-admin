defmodule PureAdmin.Components.LayoutTest do
  use PureAdmin.ComponentCase, async: true

  alias PureAdmin.Components.Layout

  defp inner(text), do: [%{__slot__: :inner_block, inner_block: fn _, _ -> text end}]

  describe "nav_item/1 (rc14)" do
    test "plain leaf carries NO class (pc-navmenu styles its <li>/<a> directly)" do
      html = render_component(&Layout.nav_item/1, %{href: "/reports", inner_block: inner("Reports")})

      refute html =~ "pc-navmenu__item"
      assert html =~ ~s(href="/reports")
    end

    test "is_active emits the bare active modifier" do
      html =
        render_component(&Layout.nav_item/1, %{href: "/", is_active: true, inner_block: inner("Dashboard")})

      assert_class(html, "pc-navmenu__item--active")
    end

    test "priority/icon/collapse become data attributes" do
      html =
        render_component(&Layout.nav_item/1, %{
          href: "/x",
          priority: 10,
          icon: "🏠",
          collapse: "hide",
          inner_block: inner("X")
        })

      assert html =~ ~s(data-pc-fit-nav-priority="10")
      assert html =~ ~s(data-pc-nav-icon="🏠")
      assert html =~ ~s(data-pc-fit-nav="hide")
    end

    test "has_dropdown emits the item + has-dropdown classes and pc-navmenu__link" do
      html = render_component(&Layout.nav_item/1, %{has_dropdown: true, inner_block: inner("Products")})

      assert_class(html, "pc-navmenu__item")
      assert_class(html, "pc-navmenu__item--has-dropdown")
      assert_class(html, "pc-navmenu__link")
    end
  end

  describe "nav_menu/1 (rc14)" do
    test "plain menu is pc-navmenu with no collapse attrs or hook" do
      html = render_component(&Layout.nav_menu/1, %{inner_block: inner("x")})

      assert_class(html, "pc-navmenu")
      refute html =~ "data-pc-fit-nav"
      refute html =~ "PureAdminNavFitCollapse"
      # rc14 dropped the --start/--end modifiers
      refute html =~ "pc-navmenu--"
    end

    test "collapse mode wires the hook, data attrs, phx-update ignore, and an id" do
      html =
        render_component(&Layout.nav_menu/1, %{collapse: "menu", more_label: "More", inner_block: inner("x")})

      assert html =~ ~s(data-pc-fit-nav="menu")
      assert html =~ ~s(data-pc-fit-nav-more-label="More")
      assert html =~ ~s(phx-hook="PureAdminNavFitCollapse")
      assert html =~ ~s(phx-update="ignore")
      assert html =~ ~s(id="pc-navmenu-)
    end
  end

  describe "nav_dropdown/1 (rc14)" do
    test "renders pc-navmenu__dropdown; level2 modifier optional" do
      html = render_component(&Layout.nav_dropdown/1, %{inner_block: inner("x")})
      assert_class(html, "pc-navmenu__dropdown")
      refute_class(html, "pc-navmenu__dropdown--level2")

      l2 = render_component(&Layout.nav_dropdown/1, %{is_level2: true, inner_block: inner("x")})
      assert_class(l2, "pc-navmenu__dropdown--level2")
    end
  end

  describe "sidebar_section/1 (rc09)" do
    test "renders a flat li heading from label" do
      html = render_component(&Layout.sidebar_section/1, %{label: "Project"})

      assert html =~ ~r{<li class="pc-sidebar__section"[^>]*>\s*Project\s*</li>}
    end

    test "slot content overrides label" do
      html =
        render_component(&Layout.sidebar_section/1, %{
          label: "ignored",
          inner_block: inner("Live Demos")
        })

      assert html =~ "Live Demos"
      refute html =~ "ignored"
    end
  end

  describe "sidebar_divider/1 (rc09)" do
    test "renders an empty li divider" do
      html = render_component(&Layout.sidebar_divider/1, %{})

      assert html =~ ~r{<li class="pc-sidebar__divider"[^>]*></li>}
    end
  end

  describe "sidebar/1 resizable (rc11)" do
    test "is_resizable emits the activation class and NO server-rendered handle" do
      html =
        render_component(&Layout.sidebar/1, %{
          is_resizable: true,
          inner_block: inner("nav")
        })

      assert_class(html, "pc-layout__sidebar--resizable")
      # The resize module creates .pc-sidebar-resize itself; server must not.
      refute html =~ "pc-sidebar-resize"
    end

    test "plain sidebar is not resizable" do
      html = render_component(&Layout.sidebar/1, %{inner_block: inner("nav")})
      refute_class(html, "pc-layout__sidebar--resizable")
    end
  end

  describe "app_header/1 (rc14)" do
    test "renders pc-app-header; children own the markup (no fit injection)" do
      html = render_component(&Layout.app_header/1, %{inner_block: inner("Custom")})

      assert_class(html, "pc-app-header")
      assert html =~ "Custom"
      refute html =~ "data-pc-fit"
      refute html =~ "pa-header__"
    end

    test "config fallback renders an <h1> app name when no children" do
      html = render_component(&Layout.app_header/1, %{})

      assert_class(html, "pc-app-header")
      assert html =~ ~r{<h1}
    end
  end

  describe "page_header/1 (rc14)" do
    test "renders a plain pc-page-header wrapper (no built-in fit)" do
      html = render_component(&Layout.page_header/1, %{inner_block: inner("Dashboard")})

      assert_class(html, "pc-page-header")
      assert html =~ "Dashboard"
      refute html =~ "data-pc-fit"
    end
  end

  describe "profile_button/1 (rc14)" do
    test "renders pc-navbar__profile-btn with name span" do
      html = render_component(&Layout.profile_button/1, %{name: "John Doe"})

      assert_class(html, "pc-navbar__profile-btn")
      assert html =~ ~s(class="pc-navbar__profile-name")
      assert html =~ "John Doe"
      refute html =~ "pa-header__"
    end

    test "aria-label matches the oracle snippet casing (\"User Profile\")" do
      # snippets/profile.html + snippets/layout.html both bless aria-label="User
      # Profile" (capital P); svelte resolves the i18n key to the same literal. The
      # old lowercase "User profile" diverged from both.
      html = render_component(&Layout.profile_button/1, %{name: "John Doe"})

      assert html =~ ~s(aria-label="User Profile")
      refute html =~ ~s(aria-label="User profile")
    end

    test "no name → no .pc-navbar__profile-name span (icon-only trigger)" do
      html = render_component(&Layout.profile_button/1, %{})

      assert_class(html, "pc-navbar__profile-btn")
      refute html =~ "pc-navbar__profile-name"
    end
  end

  describe "navbar/1 fit container + zones (rc13/rc14)" do
    test "navbar__inner carries the PureAdminNavFit hook + an id" do
      html = render_component(&Layout.navbar/1, %{start: inner("brand")})

      assert html =~ ~s(phx-hook="PureAdminNavFit")
      assert html =~ ~r{id="pc-navbar-inner-\d+"}
    end

    test "burger renders as the first child, before the pc-navbar__* zones" do
      html =
        render_component(&Layout.navbar/1, %{
          burger: inner("BURGER"),
          start: inner("S"),
          center: inner("C"),
          end_: inner("E")
        })

      assert html =~ "pc-navbar__start"
      assert html =~ "pc-navbar__center"
      assert html =~ "pc-navbar__end"
      refute html =~ "pa-header__"
      # burger sits before the start zone
      assert html =~ ~r{BURGER.*pc-navbar__start}s
    end
  end

  describe "search entry points (rc12)" do
    test "navbar_search is a fit=hide trigger button" do
      html = render_component(&Layout.navbar_search/1, %{})
      assert html =~ ~s(class="pc-navbar-search pc-navbar-search--sm")
      assert html =~ ~s(data-pc-fit="hide")
      assert html =~ ~s(data-pc-fit-priority="25")
      assert html =~ "pc-navbar-search__shortcut"
    end

    test "navbar_search_input (rc15) is a fit=hide GET form with a real input" do
      html = render_component(&Layout.navbar_search_input/1, %{action: "/search"})

      assert html =~ ~r{<form[^>]*class="pc-navbar-search pc-navbar-search--input"}
      assert html =~ ~s(action="/search")
      assert html =~ ~s(method="get")
      assert html =~ ~s(role="search")
      assert html =~ ~s(data-pc-fit="hide")
      assert html =~ ~r{<input[^>]*type="search"[^>]*name="q"}
      assert html =~ ~s(class="pc-navbar-search__field")
    end

    test "navbar_search_input honours name and method" do
      html = render_component(&Layout.navbar_search_input/1, %{action: "/s", name: "query", method: "post"})
      assert html =~ ~s(name="query")
      assert html =~ ~s(method="post")
    end

    test "sidebar_search with action (rc15) switches to a --input form" do
      html = render_component(&Layout.sidebar_search/1, %{action: "/search"})

      assert html =~ ~r{<form[^>]*class="pc-sidebar__search pc-sidebar__search--input"}
      assert html =~ ~s(action="/search")
      # submit magnifier so the collapsed icon-rail still submits
      assert html =~ ~r{<button[^>]*type="submit"[^>]*class="pc-sidebar__search-icon"}
      assert html =~ ~s(class="pc-sidebar__search-field")
      refute html =~ "pc-sidebar__label"
    end

    test "navbar_search_field renders an input + autocomplete container" do
      html = render_component(&Layout.navbar_search_field/1, %{id: "nav-search"})
      assert html =~ ~s(class="pc-navbar-search pc-navbar-search--field")
      assert html =~ ~s(id="nav-search-input")
      assert html =~ ~s(class="pc-navbar-search__field")
      assert html =~ ~r{class="pa-search-autocomplete"[^>]*hidden}
    end

    test "sidebar_search is a full-width sidebar trigger" do
      html = render_component(&Layout.sidebar_search/1, %{})
      assert html =~ ~s(class="pc-sidebar__search")
      assert html =~ "pc-sidebar__label"
    end

    test "sidebar_search trigger carries NO aria-label (the visible label is the name)" do
      # Oracle snippet (snippets/layout.html) blesses a bare trigger button — the
      # visible .pc-sidebar__label is the accessible name; svelte's trigger matches.
      html = render_component(&Layout.sidebar_search/1, %{})
      refute html =~ "aria-label"
    end

    test "sidebar_search --input form controls carry aria-label=\"Search\" (oracle casing)" do
      html = render_component(&Layout.sidebar_search/1, %{action: "/search"})
      # Both the submit magnifier and the input use aria-label="Search", matching
      # the oracle snippet + svelte. No empty value attribute on an empty query.
      assert html =~ ~s(aria-label="Search")
      refute html =~ ~s(value=")
    end
  end

  describe "fit_slot/1 + fit_step/1 (rc12/rc14)" do
    test "hide (default) wraps content with data-pc-fit=hide + priority" do
      html = render_component(&Layout.fit_slot/1, %{priority: 15, inner_block: inner("x")})
      assert html =~ ~s(data-pc-fit="hide")
      assert html =~ ~s(data-pc-fit-priority="15")
      assert html =~ "x"
      # default wrapper tag is a span
      assert html =~ ~r{<span[^>]*data-pc-fit="hide"}
    end

    test "strategy=steps carries data-pc-fit=steps + the styled class" do
      html =
        render_component(&Layout.fit_slot/1, %{
          strategy: "steps",
          priority: 30,
          class: "pc-app-header__name",
          inner_block: inner("ladder")
        })

      assert html =~ ~s(data-pc-fit="steps")
      assert html =~ ~s(class="pc-app-header__name")
      assert html =~ "ladder"
    end

    test "sidebar strategy carries the relocation target" do
      html =
        render_component(&Layout.fit_slot/1, %{
          strategy: "sidebar",
          sidebar_target: "#main-nav",
          inner_block: inner("y")
        })

      assert html =~ ~s(data-pc-fit="sidebar")
      assert html =~ ~s(data-pc-fit-sidebar-target="#main-nav")
    end

    test "tag can be overridden to a block element" do
      html = render_component(&Layout.fit_slot/1, %{tag: "div", inner_block: inner("z")})
      assert html =~ ~r{<div[^>]*data-pc-fit="hide"}
    end

    test "fit_step: step 0 emits no class; later steps carry pc-fit-hidden" do
      s0 = render_component(&Layout.fit_step/1, %{index: 0, inner_block: inner("Pure Admin")})
      assert s0 =~ ~r{<span data-pc-fit-step="0">Pure Admin</span>}

      s1 = render_component(&Layout.fit_step/1, %{index: 1, inner_block: inner("PA")})
      assert s1 =~ ~r{data-pc-fit-step="1" class="pc-fit-hidden">PA</span>}
    end
  end

  describe "search_results/1 (rc15)" do
    test "compact is the default preset; renders the canonical item tree" do
      html =
        render_component(&Layout.search_results/1, %{
          results: [%{title: "Getting started", type: "Page", href: "/g", icon: "📄"}]
        })

      assert_class(html, "pa-search-results")
      assert_class(html, "pa-search-results--compact")
      assert html =~ ~r{<a class="pa-search-results__item" href="/g"}
      assert html =~ ~s(class="pa-search-results__icon")
      assert html =~ ~s(<div class="pa-search-results__title">Getting started</div>)
      assert html =~ ~s(<span class="pa-search-results__type">Page</span>)
    end

    test "detailed renders snippet + meta trail" do
      html =
        render_component(&Layout.search_results/1, %{
          variant: "detailed",
          results: [%{title: "T", snippet: "A guide", meta: ["Docs", "2 days ago"]}]
        })

      assert_class(html, "pa-search-results--detailed")
      assert html =~ ~s(<p class="pa-search-results__snippet">A guide</p>)
      assert html =~ ~s(<span class="pa-search-results__meta-item">Docs</span>)
      assert html =~ ~s(<span class="pa-search-results__meta-item">2 days ago</span>)
    end

    test "empty results render a plain paragraph, not an invented class" do
      html = render_component(&Layout.search_results/1, %{results: [], empty_text: "Nothing"})
      assert html =~ ~r{<p>Nothing</p>}
      refute html =~ "pa-search-results__item"
    end

    test "allow_html renders a backend <mark> highlight; escaped by default" do
      escaped =
        render_component(&Layout.search_results/1, %{
          results: [%{title: ~s(a <mark class="pa-search-results__mark">b</mark>)}]
        })

      refute escaped =~ ~s(<mark class="pa-search-results__mark">)
      assert escaped =~ "&lt;mark"

      raw =
        render_component(&Layout.search_results/1, %{
          allow_html: true,
          results: [%{title: ~s(a <mark class="pa-search-results__mark">b</mark>)}]
        })

      assert raw =~ ~s(<mark class="pa-search-results__mark">b</mark>)
    end

    test "grouped buckets items under __group/__group-title by :group" do
      html =
        render_component(&Layout.search_results/1, %{
          variant: "grouped",
          results: [
            %{title: "P1", group: "pages"},
            %{title: "Prod1", group: "products"},
            %{title: "P2", group: "pages"}
          ],
          groups: [%{id: "pages", label: "Pages"}, %{id: "products", label: "Products"}]
        })

      assert_class(html, "pa-search-results--grouped")
      assert html =~ ~s(<div class="pa-search-results__group-title">Pages</div>)
      assert html =~ ~s(<div class="pa-search-results__group-title">Products</div>)
      # Pages group precedes Products per the groups order, and holds both P1 + P2
      assert html =~ ~r{Pages.*P1.*P2.*Products.*Prod1}s
    end

    test "grouped applies a per-group :limit" do
      html =
        render_component(&Layout.search_results/1, %{
          variant: "grouped",
          results: [
            %{title: "One", group: "g"},
            %{title: "Two", group: "g"},
            %{title: "Three", group: "g"}
          ],
          groups: [%{id: "g", label: "G", limit: 2}]
        })

      assert html =~ "One"
      assert html =~ "Two"
      refute html =~ "Three"
    end
  end

  describe "section/1" do
    test "title renders as a BARE <h3>, not .pa-section-title" do
      # .pa-section-title is a SEPARATE standalone heading component; the title
      # INSIDE a .pa-section is a bare child <h3> styled via `.pa-section > h3`.
      html =
        render_component(&Layout.section/1, %{
          title_text: "Section Title",
          inner_block: inner("Body")
        })

      assert_class(html, "pa-section")
      assert html =~ ~r{<h3>\s*Section Title\s*</h3>}
      refute html =~ "pa-section-title"
      refute html =~ "pa-section__title"
    end

    test "no title → no <h3> at all" do
      html = render_component(&Layout.section/1, %{inner_block: inner("Body")})

      assert_class(html, "pa-section")
      refute html =~ "<h3"
      assert html =~ "Body"
    end

    test "class passthrough is appended after pa-section" do
      html =
        render_component(&Layout.section/1, %{class: "mb-4", inner_block: inner("Body")})

      assert_class(html, "pa-section")
      assert_class(html, "mb-4")
    end
  end

  describe "divider/1" do
    test "renders a BARE <hr> with no class (pa-divider was a phantom base class)" do
      # Core defines no class for a standalone rule — `.pa-divider` is absent from
      # main.css, snippets, and every theme, and svelte's <Divider> emits a bare
      # <hr>. Emitting `pa-divider` would be a phantom class; the rule carries none.
      html = render_component(&Layout.divider/1, %{})

      assert html =~ "<hr"
      refute html =~ "pa-divider"
      # No meaningful class — HEEx may emit a harmless empty class="" (which the
      # fidelity normalizer strips), but never a non-empty class token.
      refute html =~ ~r/class="[^"]+"/
    end

    test "class passthrough is the only way to class the rule" do
      html = render_component(&Layout.divider/1, %{class: "my-4"})

      assert_class(html, "my-4")
      refute html =~ "pa-divider"
    end
  end
end
