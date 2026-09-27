defmodule DemoWeb.Live.CommandPaletteLive do
  use DemoWeb, :live_view

  alias DemoWeb.CommandPaletteSource

  # `show_command_palette/0` is imported via `use PureAdmin.Components`
  # (PureAdmin.Components.CommandPalette).
  #
  # The palette itself is mounted globally in the app layout
  # (`<.live_component module={PureAdmin.CommandPalette} id="command-palette" …>`),
  # so this page only documents it and drives it via `show_command_palette/0`
  # (JS dispatch) and `send_update/2`. The commands/contexts/search/actions live
  # in `DemoWeb.CommandPaletteSource`.

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Command Palette",
       cp_display: "inline",
       cp_commands: CommandPaletteSource.commands(),
       cp_contexts: CommandPaletteSource.contexts()
     )}
  end

  def render(assigns) do
    ~H"""
    <.paragraph>
      macOS Spotlight-style command palette with multi-step commands and scoped search.
      Press <kbd>Ctrl+K</kbd> or <kbd>⌘K</kbd> to open — it's mounted once in the layout,
      so the shortcut and the navbar/sidebar search triggers work on every page.
    </.paragraph>

    <.grid>
      <.column size="100" lg="1-2">
        <.card title_text="Quick Start" class="mb-4">
          <.paragraph class="mb-3">
            Open the command palette and try the different modes:
          </.paragraph>
          <div class="mb-4">
            <.button variant="primary" size="lg" is_block phx-click={show_command_palette()}>
              <:icon><i class="fa-solid fa-magnifying-glass"></i></:icon>
              Open Command Palette (Ctrl+K)
            </.button>
          </div>

          <div class="mb-3" style="display: flex; gap: 8px; align-items: center;">
            <span>Display style:</span>
            <.button size="sm" variant={if @cp_display == "inline", do: "primary", else: "secondary"} phx-click="set_display" phx-value-display="inline">Inline</.button>
            <.button size="sm" variant={if @cp_display == "tokens", do: "primary", else: "secondary"} phx-click="set_display" phx-value-display="tokens">Tokens</.button>
          </div>

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
        </.card>

        <.card title_text="Commands (/)" class="mb-4">
          <.paragraph class="mb-3">Type <code>/</code> to see available commands:</.paragraph>
          <.table rows={@cp_commands} size="sm">
            <:col :let={cmd} label="Shortcut"><code>{cmd.shortcut}</code></:col>
            <:col :let={cmd} label="Name">{cmd.name}</:col>
            <:col :let={cmd} label="Steps">{length(cmd.steps)} steps</:col>
          </.table>

          <.heading level={4} class="mt-3 mb-2">Try it</.heading>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query="/">/  (list all)</.button>
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query="/deploy">/deploy</.button>
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query="/go">/go</.button>
          </div>
        </.card>
      </.column>

      <.column size="100" lg="1-2">
        <.card title_text="Search Contexts (:)" class="mb-4">
          <.paragraph class="mb-3">Type <code>:</code> to see search contexts:</.paragraph>
          <.table rows={@cp_contexts} size="sm">
            <:col :let={ctx} label="Shortcut"><code>{ctx.shortcut}</code></:col>
            <:col :let={ctx} label="Context">{ctx.name}</:col>
          </.table>

          <.heading level={4} class="mt-3 mb-2">Try it</.heading>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query=":">:  (list all)</.button>
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query=":p macbook">:p macbook</.button>
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query=":o shipped">:o shipped</.button>
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query=":u admin">:u admin</.button>
          </div>
        </.card>

        <.card title_text="Global Search" class="mb-4">
          <.paragraph class="mb-3">Just type without a prefix to search everything:</.paragraph>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query="john">john</.button>
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query="shipped">shipped</.button>
            <.button variant="secondary" size="sm" phx-click="open_with_query" phx-value-query="macbook">macbook</.button>
          </div>
        </.card>

        <.card title_text="Extending it" class="mb-4">
          <.paragraph class="mb-3">
            The palette ships as a reusable LiveComponent. Mount it once in your layout and
            point it at a <code>PureAdmin.CommandPalette.Source</code> module that supplies
            your app's commands, contexts, search and actions:
          </.paragraph>
          <.code_block language="elixir">{code_example()}</.code_block>
        </.card>

        <.card title_text="Keyboard Shortcuts" class="mb-4">
          <.table rows={[
            %{key: "Ctrl+K / ⌘K", action: "Toggle command palette"},
            %{key: "↑ ↓", action: "Navigate results"},
            %{key: "← →", action: "Previous / next page (search modes)"},
            %{key: "Enter / Tab", action: "Select item or confirm free text"},
            %{key: "Backspace (at start)", action: "Go back to previous step"},
            %{key: "Esc", action: "Back (in step/context) or close"}
          ]} size="sm">
            <:col :let={row} label="Key"><kbd>{row.key}</kbd></:col>
            <:col :let={row} label="Action">{row.action}</:col>
          </.table>
        </.card>
      </.column>
    </.grid>
    """
  end

  # -- Event handlers (drive the global palette component) --

  def handle_event("set_display", %{"display" => display}, socket) do
    send_update(PureAdmin.CommandPalette, id: "command-palette", display: display)
    {:noreply, assign(socket, cp_display: display)}
  end

  def handle_event("open_with_query", %{"query" => query}, socket) do
    send_update(PureAdmin.CommandPalette, id: "command-palette", open_with: query)
    {:noreply, socket}
  end

  defp code_example do
    ~S|<.live_component
  module={PureAdmin.CommandPalette}
  id="command-palette"
  source={MyApp.Palette} />

defmodule MyApp.Palette do
  use PureAdmin.CommandPalette.Source

  def commands, do: [%{id: "go", shortcut: "/go", ...}]
  def contexts, do: [%{id: "products", shortcut: ":p", ...}]
  def step_options("go", "page", q, _sel), do: search_pages(q)
  def search(:global, q), do: search_all(q)
  def on_select(item), do: {:navigate, item.href}
  def on_complete("go", sels), do: {:navigate, List.last(sels).value}
end|
  end
end
