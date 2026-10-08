defmodule DemoWeb.Live.IconsLive do
  use DemoWeb, :live_view

  # Heroicons shipped in PureAdmin.Components.Heroicon (the 25 curated outline icons).
  # Listed here so the showcase grid stays in sync with what the module actually supports.
  @heroicons ~w(
    rocket-launch chart-bar briefcase user-group cog-6-tooth
    user arrow-right-on-rectangle plus user-plus arrow-down-tray
    pencil trash shopping-cart bookmark paint-brush
    chart-bar-square home list-bullet view-columns pencil-square
    lock-closed bell swatch squares-2x2 book-open
  )

  # Lucide SVGs shipped in demo/priv/static/assets/icons/lucide/. Names must
  # match the filenames (without .svg) — the callback in DemoWeb.Icons maps
  # `lucide-X` to `/assets/icons/lucide/X.svg`.
  @lucide ~w(rocket bell settings user house search plus trash)

  def mount(_params, _session, socket) do
    # Source snippets shown in <.code_block> sections. They're passed as
    # strings so the code block displays the literal HEEx instead of
    # evaluating it (which would dump rendered SVGs into the code box).
    code_examples = %{
      dispatch_affordance: ~s|<.icon name="success" />|,
      dispatch_hero: ~s|<.icon name="hero-rocket-launch" />|,
      dispatch_fa: ~s|<.icon name="fa-solid fa-rocket" />|,
      dispatch_nil: ~s|<.icon name={@maybe_nil} />|,
      faicon_solid: ~s|<.faicon name="rocket" />|,
      faicon_regular: ~s|<.faicon name="bell" variant="regular" />|,
      faicon_brands: ~s|<.faicon name="github" variant="brands" />|,
      pass_title: ~s|<.heroicon name="bell" title="Notifications" aria_label="Notifications" />|,
      pass_stroke: ~s|<.heroicon name="bookmark" stroke="red" />|,
      pass_fill: ~s|<.heroicon name="bookmark" fill="currentColor" />|,
      dispatcher_pattern: ~s"""
      <.sidebar_item label="Dashboard" icon="hero-chart-bar-square" href="/" />
      <.sidebar_item label="Profile" icon="fa-solid fa-user" href="/profile" />\
      """,
      callback_config: ~s"""
      # config/config.exs
      config :keen_pure_admin,
        icon_providers: [{MyAppWeb.Icons, :render}]\
      """,
      callback_module: ~S"""
      defmodule MyAppWeb.Icons do
        use Phoenix.Component

        # Lucide SVGs saved at priv/static/assets/icons/lucide/*.svg.
        # Sizing goes through `style` (not width/height attrs) because
        # HTML <img> attrs require integer pixels — "1.75rem" would
        # parse as "1" and render at 1px wide.
        def render(%{name: "lucide-" <> file} = assigns) do
          assigns = assign(assigns, :file, file)

          ~H\"""
          <img
            src={"/assets/icons/lucide/\#{@file}.svg"}
            style={"width: \#{@size_value}; height: \#{@size_value};"}
            class={@class}
            alt={@aria_label || @file}
            title={@title}
          />
          \"""
        end

        # Return nil for anything else — the next provider (or the
        # library's built-in hero-/FA fallback) then handles it.
        def render(_assigns), do: nil
      end\
      """,
      callback_usage: ~s|<.icon name="lucide-rocket" />|
    }

    # `maybe_nil` is used in the "Empty / nil" example so Phoenix.Component
    # can't static-check it as a literal nil (which would warn against the
    # `required: true` attr declaration even though the runtime handles it).
    {:ok,
     assign(socket,
       page_title: "Icons",
       heroicons: @heroicons,
       lucide: @lucide,
       maybe_nil: nil,
       code_examples: code_examples
     )}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>
      Three components for icons: <.code>&lt;.icon&gt;</.code> (smart dispatcher),
      <.code>&lt;.faicon&gt;</.code> (Font Awesome wrapper), and
      <.code>&lt;.heroicon&gt;</.code> (inline-SVG Heroicons). All share the same
      attribute surface: <.code>name</.code>, <.code>class</.code>,
      <.code>color</.code>, <.code>size</.code>, <.code>variant</.code>,
      <.code>fill</.code>, <.code>stroke</.code>, <.code>title</.code>,
      <.code>aria_label</.code>.
    </.paragraph>

    <%!-- ── How the icon system works ──────────────────────────────────── --%>
    <.card title_text="How the icon system works">
      <.paragraph class="mb-4">
        Pure Admin has <strong>two</strong> icon layers — know which one you're touching:
      </.paragraph>
      <.grid>
        <.column size="100" md="50">
          <.heading level={4}>1. Masked <.code>.pa-icon</.code> primitive</.heading>
          <.paragraph>
            The framework's closed set of structural affordances (close, chevrons,
            <.code>success</.code>, <.code>danger</.code>, …) — a raw
            <.code>{"<span class=\"pa-icon pa-icon--NAME\">"}</.code> painted in
            <.code>currentColor</.code> via CSS mask. No component, no provider; it's how
            the library's own chrome (alerts, flash, filter cards) draws glyphs.
            Catalogued on <.pa_link href="/design/icons">Design › Icons</.pa_link>.
          </.paragraph>
        </.column>
        <.column size="100" md="50">
          <.heading level={4}>2. The <.code>&lt;.icon&gt;</.code> component</.heading>
          <.paragraph>
            A thin dispatcher over that primitive plus a swappable <strong>provider</strong>
            system, so you render decorative / brand icons (Font Awesome, Heroicons,
            Lucide, …) from a single <.code>&lt;.icon name="…"&gt;</.code> call-site —
            without hand-authoring elements each time. That's this page.
          </.paragraph>
        </.column>
      </.grid>

      <.heading level={4} class="mt-4">Resolution order</.heading>
      <.paragraph class="mb-2">A name flows through three stages — the first hit wins:</.paragraph>
      <.basic_list>
        <li>
          <strong>Framework affordance (reserved, built-in).</strong>
          <.code>affordance?/1</.code> → <.code>{"<span class=\"pa-icon pa-icon--NAME\">"}</.code>,
          then stop. No provider can shadow it; zero-config, always resolves.
        </li>
        <li>
          <strong>Provider list</strong> — each entry in <.code>:icon_providers</.code>
          (see <.code>PureAdmin.Config</.code>), in order; the first to return markup
          (non-<.code>nil</.code>) wins.
        </li>
        <li>
          <strong>Built-in fallback</strong> — <.code>"hero-X"</.code> →
          <.code>&lt;.heroicon&gt;</.code>; anything else → FA-style
          <.code>&lt;i class=&#123;name&#125;&gt;</.code>.
        </li>
      </.basic_list>

      <.heading level={4} class="mt-4">What a provider is</.heading>
      <.paragraph>
        A 1-arity Phoenix function component receiving the full assigns — the
        <.code>name</.code> plus render context (<.code>class</.code>, <.code>color</.code>,
        <.code>size</.code>, <.code>size_value</.code>, <.code>variant</.code>,
        <.code>fill</.code>, <.code>stroke</.code>, <.code>title</.code>,
        <.code>aria_label</.code>, <.code>is_interactive</.code>) — and returning rendered
        HEEx, or <.code>nil</.code> to pass the name to the next provider. The
        <.code>name</.code> is opaque: a provider parses whatever convention you adopt
        (<.code>"lucide-rocket"</.code>, <.code>"fa-solid fa-x"</.code>). List several to
        support several sets at once; the full context flows to each so a set can embed its
        own sizing / hover marker.
      </.paragraph>

      <.callout variant="info" class="mt-3">
        <strong>Reserved names:</strong> qualify external names (prefix them) so they don't
        collide with the bare affordance names — a bare <.code>"success"</.code> always
        resolves to the framework glyph, never a provider.
      </.callout>
    </.card>

    <%!-- ── <.icon> dispatcher ─────────────────────────────────────────── --%>
    <.card title_text="<.icon> — smart dispatcher">
      <.paragraph class="mb-4">
        Resolves in order: a framework affordance (<.code>"success"</.code>,
        <.code>"chevron-down"</.code>, …) → masked <.code>pa-icon--*</.code> span,
        built-in and reserved; then the configured <.code>:icon_providers</.code>
        list; then the built-in fallback — <.code>"hero-X"</.code> → inline SVG via
        <.code>&lt;.heroicon&gt;</.code>, anything else → <.code>&lt;i class&gt;</.code>
        (Font Awesome, Bootstrap Icons, Lucide-font, etc.).
      </.paragraph>

      <.grid>
        <.column size="100" md="1-3">
          <.heading level={4}>Affordance branch</.heading>
          <.code_block language="heex">{@code_examples.dispatch_affordance}</.code_block>
          <div class="mt-2 flex-row gap-3 align-items-center">
            <.icon name="success" />
            <.icon name="danger" />
            <.icon name="search" />
          </div>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>Heroicons branch</.heading>
          <.code_block language="heex">{@code_examples.dispatch_hero}</.code_block>
          <div class="mt-2 flex-row gap-3 align-items-center">
            <.icon name="hero-rocket-launch" />
            <.icon name="hero-bell" />
            <.icon name="hero-cog-6-tooth" />
          </div>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>FA / class-based branch</.heading>
          <.code_block language="heex">{@code_examples.dispatch_fa}</.code_block>
          <div class="mt-2 flex-row gap-3 align-items-center">
            <.icon name="fa-solid fa-rocket" />
            <.icon name="fa-solid fa-bell" />
            <.icon name="fa-solid fa-cog" />
          </div>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>Empty / nil</.heading>
          <.code_block language="heex">{@code_examples.dispatch_nil}</.code_block>
          <div class="mt-2">
            <.icon name={@maybe_nil} />
            <.paragraph class="text-color-2 mt-2">
              Renders nothing — useful when the icon is data-driven and may be absent.
            </.paragraph>
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- ── <.heroicon> direct use ─────────────────────────────────────── --%>
    <.card title_text="<.heroicon> — all 25 curated icons">
      <.paragraph class="mb-4">
        Outline variants from <.pa_link href="https://heroicons.com" target="_blank">heroicons.com</.pa_link>,
        embedded as inline SVG with <.code>stroke="currentColor"</.code> so they
        inherit the parent text color.
      </.paragraph>

      <.grid>
        <.column :for={name <- @heroicons} size="1-3" md="1-4" lg="1-6" class="text-center mb-3">
          <.heroicon name={name} size="1.75rem" />
          <div><.code>{name}</.code></div>
        </.column>
      </.grid>
    </.card>

    <%!-- ── <.faicon> direct use ──────────────────────────────────────── --%>
    <.card title_text="<.faicon> — Font Awesome wrapper">
      <.paragraph class="mb-4">
        Decomposes name + variant so callers don't have to remember the
        <.code>fa-solid</.code> / <.code>fa-regular</.code> / <.code>fa-light</.code> /
        <.code>fa-brands</.code> class prefixes. Requires Font Awesome CSS to be
        loaded.
      </.paragraph>

      <.grid>
        <.column size="100" md="1-3">
          <.heading level={4}>Solid (default)</.heading>
          <.code_block language="heex">{@code_examples.faicon_solid}</.code_block>
          <div class="mt-2 flex-row gap-3 align-items-center">
            <.faicon name="rocket" />
            <.faicon name="user" />
            <.faicon name="bell" />
          </div>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>Regular</.heading>
          <.code_block language="heex">{@code_examples.faicon_regular}</.code_block>
          <div class="mt-2 flex-row gap-3 align-items-center">
            <.faicon name="bell" variant="regular" />
            <.faicon name="heart" variant="regular" />
            <.faicon name="star" variant="regular" />
          </div>
        </.column>
        <.column size="100" md="1-3">
          <.heading level={4}>Brands</.heading>
          <.code_block language="heex">{@code_examples.faicon_brands}</.code_block>
          <div class="mt-2 flex-row gap-3 align-items-center">
            <.faicon name="github" variant="brands" />
            <.faicon name="elixir" variant="brands" />
            <.faicon name="phoenix-framework" variant="brands" />
          </div>
        </.column>
      </.grid>
    </.card>

    <%!-- ── Pass-through attrs ────────────────────────────────────────── --%>
    <.card title_text="Pass-through attrs (color, size, fill, stroke, title, aria_label)">
      <.paragraph class="mb-4">
        Every named attr declared on the component flows through to the
        rendered element. Phoenix.Component validates each at compile time —
        a typo at the call site becomes a warning instead of a silently
        dropped attribute.
      </.paragraph>

      <.heading level={4}>Title (tooltip) and aria_label</.heading>
      <.code_block language="heex">{@code_examples.pass_title}</.code_block>
      <div class="mt-2">
        <.heroicon name="bell" title="Notifications" aria_label="Notifications" />
      </div>

      <.heading level={4} class="mt-4">Stroke override</.heading>
      <.code_block language="heex">{@code_examples.pass_stroke}</.code_block>
      <div class="mt-2 flex-row gap-3 align-items-center">
        <.heroicon name="bookmark" />
        <.heroicon name="bookmark" stroke="red" />
        <.heroicon name="bookmark" stroke="green" />
      </div>

      <.heading level={4} class="mt-4">Fill override</.heading>
      <.code_block language="heex">{@code_examples.pass_fill}</.code_block>
      <div class="mt-2 flex-row gap-3 align-items-center">
        <.heroicon name="bookmark" fill="currentColor" />
        <.heroicon name="bookmark" fill="lightblue" stroke="blue" />
      </div>
    </.card>

    <%!-- ── String-attr dispatcher pattern ────────────────────────────── --%>
    <.card title_text="Why <.icon> exists — the string-attr pattern">
      <.paragraph class="mb-4">
        Library chrome components like <.code>&lt;.sidebar_item&gt;</.code>,
        <.code>&lt;.button&gt;</.code>, <.code>&lt;.flash&gt;</.code>, and
        <.code>&lt;.profile_nav_item&gt;</.code> take a single <.code>icon</.code>
        string and don't know whether it's an FA class or a heroicon name. They
        delegate the decision to <.code>&lt;.icon&gt;</.code>.
      </.paragraph>

      <.code_block language="heex">{@code_examples.dispatcher_pattern}</.code_block>

      <.paragraph class="mt-4">
        Both calls work because <.code>&lt;.sidebar_item&gt;</.code> renders
        <.code>&lt;.icon name=&#123;@icon&#125; /&gt;</.code> internally — heroicons go
        through the SVG branch, FA strings through the <.code>&lt;i class&gt;</.code> branch.
      </.paragraph>
    </.card>

    <%!-- ── Custom icon set via providers (Lucide demo) ────────────────── --%>
    <.card title_text="Custom icon set via :icon_providers (Lucide demo)">
      <.paragraph class="mb-4">
        Most projects standardize on one or more icon sets — a custom SVG sprite
        folder, a special font, a base64 sprite map, etc. Wire an ordered
        <.code>:icon_providers</.code> list in <.code>config.exs</.code>;
        <.code>&lt;.icon&gt;</.code> resolves framework affordances
        (<.code>pa-icon--*</.code>) first, built-in, then hands every other name to
        each provider in turn — the first to return markup wins.
      </.paragraph>

      <.heading level={4}>1. Configure the provider list</.heading>
      <.code_block language="elixir">{@code_examples.callback_config}</.code_block>

      <.heading level={4} class="mt-4">2. Define the function component</.heading>
      <.paragraph class="mb-2">
        Each provider receives the full assigns map: <.code>name</.code>,
        <.code>class</.code>, <.code>color</.code>, <.code>size</.code>,
        <.code>size_value</.code> (resolved from <.code>size</.code> or the
        configured default), <.code>variant</.code>, <.code>fill</.code>,
        <.code>stroke</.code>, <.code>title</.code>, <.code>aria_label</.code>,
        <.code>is_interactive</.code>. Pattern-match on <.code>name</.code> to
        handle your set, and return <.code>nil</.code> for anything else so the
        next provider (or the built-in <.code>hero-</.code>/FA fallback) gets a turn.
      </.paragraph>
      <.code_block language="elixir">{@code_examples.callback_module}</.code_block>

      <.heading level={4} class="mt-4">3. Use it</.heading>
      <.code_block language="heex">{@code_examples.callback_usage}</.code_block>

      <.paragraph class="mt-4 mb-2">
        This demo ships 8 Lucide SVGs under
        <.code>demo/priv/static/assets/icons/lucide/</.code>. Each tile below
        is a real <.code>&lt;.icon name="lucide-X" /&gt;</.code> routed through
        the configured provider:
      </.paragraph>

      <.grid>
        <.column :for={name <- @lucide} size="1-3" md="1-4" lg="1-6" class="text-center mb-3">
          <.icon name={"lucide-" <> name} size="1.75rem" />
          <div><.code>{"lucide-" <> name}</.code></div>
        </.column>
      </.grid>

      <.paragraph class="mt-4 text-color-2">
        Note: rendering Lucide via <.code>&lt;img&gt;</.code> loses
        <.code>stroke="currentColor"</.code> recoloring — for full CSS color
        inheritance you'd inline the SVG (read at compile time, or read +
        cached at request time).
      </.paragraph>
    </.card>

    <%!-- ── When to use which ─────────────────────────────────────────── --%>
    <.card title_text="When to use which component">
      <.table is_compact rows={[
        %{component: "<.icon>", when: "You have a string and don't know its type (e.g. attr-driven, config-driven). Used internally by library chrome."},
        %{component: "<.faicon>", when: "Direct FA use with explicit variant control. Cleanest when you know it's FA."},
        %{component: "<.heroicon>", when: "Direct Heroicon use, no name-prefix ceremony. Cleanest when you know it's a heroicon."}
      ]}>
        <:col :let={row} label="Component"><.code>{row.component}</.code></:col>
        <:col :let={row} label="When">{row.when}</:col>
      </.table>
    </.card>
    """
  end
end
