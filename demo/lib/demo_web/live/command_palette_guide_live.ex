defmodule DemoWeb.Live.CommandPaletteGuideLive do
  use DemoWeb, :live_view

  @mount_layout ~S'''
  # In your app layout (e.g. lib/my_app_web/components/layouts/app.html.heex),
  # mount the palette ONCE so Ctrl+K and every search trigger work app-wide:
  <.live_component
    module={PureAdmin.CommandPalette}
    id="command-palette"
    source={MyApp.Palette}
  />
  '''

  @source_module ~S'''
  defmodule MyApp.Palette do
    use PureAdmin.CommandPalette.Source

    # Commands appear under "/" and on the idle home screen.
    def commands do
      [
        %{
          id: "go",
          shortcut: "/go",
          aliases: ["/g"],
          hotkey: "Alt+G",
          name: "Go to Page",
          description: "Jump to any page",
          icon: "🧭",
          steps: [
            %{id: "page", prompt: " ", placeholder: "Type a page…", free_text: true}
          ]
        }
      ]
    end

    # Contexts appear under ":" for scoped search.
    def contexts do
      [%{id: "users", shortcut: ":users", aliases: [":u"], name: "Users", icon: "👤"}]
    end

    # Options for a command step, already filtered by `query`.
    def step_options("go", "page", query, _selections), do: search_pages(query)
    def step_options(_command, _step, _query, _selections), do: []

    # Search results for a scope, already filtered by `query`.
    def search(:global, query), do: search_everything(query)
    def search({:context, "users"}, query), do: search_users(query)
    def search(_scope, _query), do: []

    # What a selection / a finished command DOES — a declarative directive.
    def on_select(item), do: {:navigate, item.href}
    def on_complete("go", selections), do: {:navigate, List.last(selections).value}
    def on_complete(_command, _selections), do: :close
  end
  '''

  @triggers ~S'''
  # Any trigger opens it — no per-trigger LiveView wiring. `show_command_palette/0`
  # dispatches `pa:command-palette:open` to the palette element by id.
  <.navbar_search phx-click={show_command_palette()} />
  <.sidebar_search phx-click={show_command_palette()} />

  # ...or from your own button:
  <.button phx-click={show_command_palette()}>Search…</.button>
  '''

  @send_update ~S'''
  # Drive the global palette from any LiveView via send_update/2:
  def handle_event("search", _params, socket) do
    send_update(PureAdmin.CommandPalette, id: "command-palette", open_with: "/")
    {:noreply, socket}
  end

  # Switch the step display style ("inline" | "tokens"):
  send_update(PureAdmin.CommandPalette, id: "command-palette", display: "tokens")
  '''

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Command Palette",
       mount_layout: @mount_layout,
       source_module: @source_module,
       triggers: @triggers,
       send_update: @send_update
     )}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>
      The command palette (Spotlight / Ctrl+K style) ships as a <strong>stateful
      LiveComponent</strong> plus a <strong>behaviour</strong> you implement. The reusable
      interaction — modes, the multi-step wizard, pagination, keyboard navigation and the
      global <kbd>Ctrl+K</kbd> / <kbd>⌘K</kbd> shortcut — lives in the component; everything
      that differs per project — your commands, contexts, search and actions — is injected
      through a <code>PureAdmin.CommandPalette.Source</code> module.
    </.paragraph>

    <div class="mb-4">
      <.button variant="primary" phx-click={show_command_palette()}>
        <:icon><i class="fa-solid fa-magnifying-glass"></i></:icon>
        Open the palette (Ctrl+K)
      </.button>
      <.button variant="secondary" href={~p"/components/command-palette"}>
        See the interactive demo
      </.button>
    </div>

    <.callout variant="info" class="mb-4">
      Mount the component <strong>once, in your layout</strong>. Because it lives in the layout,
      <kbd>Ctrl+K</kbd> and the navbar/sidebar search triggers work on <em>every</em> page —
      there is no per-page setup and no per-trigger event plumbing.
    </.callout>

    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text="1 · Mount it in your layout" class="mb-4">
          <.paragraph class="mb-3">
            One instance, referenced by <code>id</code>. The <code>source</code> is a module
            (below) that supplies your app's data and actions.
          </.paragraph>
          <.code_block language="heex">{@mount_layout}</.code_block>
        </.card>

        <.card title_text="2 · Wire triggers" class="mb-4">
          <.paragraph class="mb-3">
            <code>show_command_palette/0</code> is a <code>JS</code> command — attach it to
            anything. It dispatches to the palette by id, so no LiveView event is needed.
          </.paragraph>
          <.code_block language="heex">{@triggers}</.code_block>
        </.card>

        <.card title_text="Drive it from a LiveView" class="mb-4">
          <.paragraph class="mb-3">
            Open it pre-filled, or change the display style, with <code>send_update/2</code>.
          </.paragraph>
          <.code_block language="elixir">{@send_update}</.code_block>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text="3 · Implement a Source" class="mb-4">
          <.paragraph class="mb-3">
            <code>use PureAdmin.CommandPalette.Source</code> gives overridable no-op defaults —
            define only the callbacks you need.
          </.paragraph>
          <.code_block language="elixir">{@source_module}</.code_block>
        </.card>
      </.column>
    </.grid>

    <.card title_text="Source callbacks" class="mb-4">
      <.paragraph class="mb-3">
        The contract in <code>PureAdmin.CommandPalette.Source</code>. Filtering is the source's
        job — <code>search/2</code> and <code>step_options/4</code> receive the query and return
        the already-filtered list; the component paginates and, in global search, prepends the
        commands/contexts that match.
      </.paragraph>
      <.table rows={[
        %{cb: "commands/0", ret: "[command]", desc: "Commands shown under / and on the home screen"},
        %{cb: "contexts/0", ret: "[context]", desc: "Search contexts shown under :"},
        %{cb: "step_options/4", ret: "[option]", desc: "Options for (command_id, step_id, query, selections)"},
        %{cb: "search/2", ret: "[item]", desc: "Results for a scope (:global | {:context, id}) + query"},
        %{cb: "on_select/1", ret: "directive", desc: "What selecting a search result does"},
        %{cb: "on_complete/2", ret: "directive", desc: "What finishing a command does (command_id, selections)"}
      ]} size="sm">
        <:col :let={r} label="Callback"><code>{r.cb}</code></:col>
        <:col :let={r} label="Returns"><code>{r.ret}</code></:col>
        <:col :let={r} label="Purpose">{r.desc}</:col>
      </.table>
    </.card>

    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text="Directives" class="mb-4">
          <.paragraph class="mb-3">
            <code>on_select/1</code> and <code>on_complete/2</code> return a directive the
            component executes — so the palette can live globally without any LiveView carrying
            selection handlers.
          </.paragraph>
          <.table rows={[
            %{d: "{:navigate, path}", w: "push_navigate (closes the palette first)"},
            %{d: "{:patch, path}", w: "push_patch"},
            %{d: "{:toast, variant, title, msg}", w: "flash a toast (opts as a 5th element)"},
            %{d: ":close", w: "just close the palette"},
            %{d: ":noop / nil", w: "do nothing"}
          ]} size="sm">
            <:col :let={r} label="Directive"><code>{r.d}</code></:col>
            <:col :let={r} label="Effect">{r.w}</:col>
          </.table>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text="Data shapes" class="mb-4">
          <.table rows={[
            %{t: "command", s: "%{id, shortcut, aliases, hotkey, name, description, icon, steps}"},
            %{t: "step", s: "%{id, prompt, placeholder, free_text}"},
            %{t: "context", s: "%{id, shortcut, aliases, name, description, icon}"},
            %{t: "option", s: "%{label, value, description, icon, code}"},
            %{t: "item", s: "%{title, subtitle, icon, badge, …your keys}"}
          ]} size="sm">
            <:col :let={r} label="Type"><code>{r.t}</code></:col>
            <:col :let={r} label="Shape"><code>{r.s}</code></:col>
          </.table>
          <.paragraph class="mt-3">
            <code>free_text</code> on a step lets the user submit typed text when nothing matches.
            A search <code>item</code> can carry any extra keys your <code>on_select/1</code>
            needs (e.g. <code>:href</code>).
          </.paragraph>
        </.card>
      </.column>
    </.grid>

    <.card title_text="Modes & keyboard" class="mb-4">
      <.grid>
        <.column size="100" lg="1-2">
          <.heading level={4} class="mb-2">Modes</.heading>
          <.table rows={[
            %{prefix: "/", mode: "Commands", description: "Multi-step action wizards"},
            %{prefix: ":", mode: "Search", description: "Scoped entity search"},
            %{prefix: "(none)", mode: "Global", description: "Search everything"}
          ]} size="sm">
            <:col :let={row} label="Prefix"><code>{row.prefix}</code></:col>
            <:col :let={row} label="Mode">{row.mode}</:col>
            <:col :let={row} label="Description">{row.description}</:col>
          </.table>
        </.column>
        <.column size="100" lg="1-2">
          <.heading level={4} class="mb-2">Keyboard</.heading>
          <.table rows={[
            %{key: "Ctrl+K / ⌘K", action: "Toggle palette"},
            %{key: "↑ ↓", action: "Navigate results"},
            %{key: "← →", action: "Previous / next page (search modes)"},
            %{key: "Enter / Tab", action: "Select or confirm free text"},
            %{key: "Backspace (at start)", action: "Back to previous step"},
            %{key: "Esc", action: "Back (in step/context) or close"}
          ]} size="sm">
            <:col :let={row} label="Key"><kbd>{row.key}</kbd></:col>
            <:col :let={row} label="Action">{row.action}</:col>
          </.table>
        </.column>
      </.grid>
    </.card>
    """
  end
end
