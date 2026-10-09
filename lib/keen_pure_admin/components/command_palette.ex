defmodule PureAdmin.Components.CommandPalette do
  @moduledoc """
  Command palette **markup** — the presentational (stateless) function
  component. It renders the palette shell + results for a given state; it does
  not own any state.

  Most apps should use the stateful `PureAdmin.CommandPalette` LiveComponent
  instead (mount it once in the layout, back it with a
  `PureAdmin.CommandPalette.Source`). This module is the shared rendering layer
  the LiveComponent builds on, and remains usable directly by a plain-LiveView
  host that wires the `cp:*` events itself.

  Supports three modes:

  - **Commands** (`/prefix`) — multi-step action wizards with step progression
  - **Search contexts** (`:prefix`) — scoped entity search
  - **Global search** (no prefix) — search across everything

  ## Display Styles

  Two display styles for command step progression:

  - `"inline"` (default) — Svelte-style, the input shows the full accumulated text
    like a sentence: `/assign iPad Air to |`. A command badge shows on the right.
    The editable portion is after the last prompt.
  - `"tokens"` — The input is cleared on each step. Previous selections show as
    colored token spans above the input.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import PureAdmin.Helpers
  import PureAdmin.Translations, only: [t: 1, t: 2]
  import PureAdmin.Components.Icon, only: [icon: 1]

  @doc """
  JS command that opens the command palette by id — wire it to any trigger
  (e.g. `navbar_search/1`, `sidebar_search/1`) via `phx-click`.

  It dispatches `pa:command-palette:open` to the palette element; the
  `PureAdminCommandPalette` hook listens and toggles the palette open. This
  avoids each trigger needing its own LiveView event plumbing.

  ## Examples

      <.navbar_search phx-click={show_command_palette()} />
      <.sidebar_search phx-click={show_command_palette("my-palette")} />
  """
  def show_command_palette(js_or_id \\ %JS{}, id \\ "command-palette")

  # Ergonomic single-arg id form: show_command_palette("my-palette").
  def show_command_palette(id, _default) when is_binary(id) do
    JS.dispatch(%JS{}, "pa:command-palette:open", to: "##{id}")
  end

  # Piped/default form: show_command_palette() or JS.push(...) |> show_command_palette("id").
  def show_command_palette(js, id) do
    JS.dispatch(js, "pa:command-palette:open", to: "##{id}")
  end

  attr(:id, :string, default: "command-palette")
  attr(:is_open, :boolean, default: false)
  attr(:query, :string, default: "")

  # phx-target for the internal click handlers (`cp:home_select`, `cp:select`).
  # Set to `@myself` when rendered inside the `PureAdmin.CommandPalette`
  # LiveComponent; leave nil for a plain-LiveView host (events go to the view).
  attr(:target, :any, default: nil)

  # Size preset (rc15): sets container width + results height together. For an
  # arbitrary size, leave this nil and override the runtime CSS variables
  # (`--pa-command-palette-width` / `-offset-top` / `-results-max-height`) at
  # `:root`, inline, or per-instance instead — no recompile needed.
  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg", "xl"],
    doc: "Size preset: sm (48/28.8rem), lg (76.8/51.2rem), xl (89.6/64rem); nil keeps the 60.8/38.4rem default."
  )

  # Display style
  attr(:display, :string,
    default: "inline",
    values: ~w(inline tokens),
    doc: "Step display style: inline (sentence in input) or tokens (spans above input)"
  )

  # Mode
  attr(:mode, :string,
    default: "idle",
    values: ~w(idle command_list command_step context_list context_search global_search)
  )

  # Registrations
  attr(:commands, :list, default: [], doc: "List of command maps")
  attr(:contexts, :list, default: [], doc: "List of search context maps")

  # Results (items displayed in all modes)
  attr(:results, :list, default: [], doc: "Current items to display")
  attr(:active_index, :integer, default: -1)
  attr(:is_loading, :boolean, default: false)

  # Command step state
  attr(:current_command, :map, default: nil, doc: "Active command in step mode")
  attr(:current_step, :map, default: nil, doc: "Active step")
  attr(:current_step_index, :integer, default: 0)
  attr(:total_steps, :integer, default: 0)
  attr(:selections, :list, default: [], doc: "Previous step selections as [%{step_id, label}]")
  attr(:preview, :string, default: nil, doc: "Preview text for command")

  # Inline mode: full input text including command prefix and selections
  attr(:input_text, :string, default: "", doc: "Full input text for inline display mode")

  # Search context state
  attr(:current_context, :map, default: nil, doc: "Active search context")

  # Pagination
  attr(:page, :integer, default: 1)
  attr(:total_pages, :integer, default: 1)
  attr(:total_results, :integer, default: 0)

  # UI
  attr(:placeholder, :string, default: nil)
  attr(:empty_text, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def command_palette(assigns) do
    assigns = prepare(assigns)

    ~H"""
    <div
      id={@id}
      class={build_classes("pa-command-palette", [{"pa-command-palette--active", @is_open}, {"pa-command-palette--#{@size}", @size != nil}], @class)}
      phx-hook="PureAdminCommandPalette"
      data-mode={@mode}
      data-display={@display}
      data-locked-length={@locked_length}
      {@rest}
    >
      <.command_palette_body
        id={@id}
        target={@target}
        display={@display}
        mode={@mode}
        display_value={@display_value}
        commands={@commands}
        contexts={@contexts}
        results={@results}
        active_index={@active_index}
        is_loading={@is_loading}
        current_command={@current_command}
        current_step={@current_step}
        current_step_index={@current_step_index}
        total_steps={@total_steps}
        selections={@selections}
        current_context={@current_context}
        page={@page}
        total_pages={@total_pages}
        total_results={@total_results}
        placeholder={@placeholder}
        empty_text={@empty_text}
      />
    </div>
    """
  end

  @doc """
  The palette's inner markup (backdrop + container). Shared by
  `command_palette/1` and the `PureAdmin.CommandPalette` LiveComponent, whose
  render owns the root `<div>` (a stateful component requires a literal root
  tag, so it can't call `command_palette/1` directly).

  `display_value`/`locked_length` are precomputed by the caller — see
  `prepare/1` and `input_state/1`.
  """
  attr(:id, :string, required: true)
  attr(:target, :any, default: nil)
  attr(:display, :string, default: "inline")
  attr(:mode, :string, default: "idle")
  attr(:display_value, :string, default: "")
  attr(:commands, :list, default: [])
  attr(:contexts, :list, default: [])
  attr(:results, :list, default: [])
  attr(:active_index, :integer, default: -1)
  attr(:is_loading, :boolean, default: false)
  attr(:current_command, :map, default: nil)
  attr(:current_step, :map, default: nil)
  attr(:current_step_index, :integer, default: 0)
  attr(:total_steps, :integer, default: 0)
  attr(:selections, :list, default: [])
  attr(:current_context, :map, default: nil)
  attr(:page, :integer, default: 1)
  attr(:total_pages, :integer, default: 1)
  attr(:total_results, :integer, default: 0)
  attr(:placeholder, :string, default: nil)
  attr(:empty_text, :string, default: nil)

  def command_palette_body(assigns) do
    assigns =
      assigns
      |> assign(:placeholder, assigns[:placeholder] || t("pureAdmin.commandPalette.placeholder"))
      |> assign(:empty_text, assigns[:empty_text] || t("pureAdmin.commandPalette.emptyText"))

    ~H"""
    <div class="pa-command-palette__backdrop"></div>
    <div class="pa-command-palette__container">
      <%!-- Search header --%>
      <div class="pa-command-palette__search">
        <%!-- Token display (tokens mode only) --%>
        <div :if={@display == "tokens"} class="pa-command-palette__tokens">
          <%= if @mode == "command_step" and @current_command do %>
            <span class="pa-badge pa-badge--primary">
              <%= @current_command[:name] || @current_command[:shortcut] %>
            </span>
            <%= for sel <- @selections do %>
              <span class="pa-command-palette__token-prompt">
                <%= sel[:prompt] || "" %>
              </span>
              <span class="pa-badge">
                <%= sel[:label] %>
              </span>
            <% end %>
            <span :if={@current_step && @current_step[:prompt]} class="pa-command-palette__token-prompt">
              <%= @current_step[:prompt] %>
            </span>
          <% end %>
        </div>

        <div class="pa-command-palette__input-wrapper">
          <input
            type="text"
            class="pa-command-palette__input"
            id={"#{@id}-input"}
            value={@display_value}
            placeholder={step_placeholder(assigns)}
            autocomplete="off"
            spellcheck="false"
          />

          <%!-- Command badge (inline mode, shown in step mode) --%>
          <div
            :if={@display == "inline" and @mode == "command_step" and @current_command}
            class="pa-command-palette__context pa-command-palette__context--visible"
          >
            <%= @current_command[:name] %>
          </div>

          <%!-- Context label (in context_search mode) --%>
          <div class={build_classes("pa-command-palette__context", [
            {"pa-command-palette__context--visible", @mode == "context_search" and @current_context != nil}
          ])}>
            <%= if @current_context, do: t("pureAdmin.commandPalette.searchingIn", %{name: @current_context[:name]}) %>
          </div>
        </div>
      </div>

      <%!-- Step progress indicator (tokens mode only) --%>
      <div :if={@display == "tokens" and @mode == "command_step" and @total_steps > 1} class="pa-command-palette__step-indicator">
        <%= t("pureAdmin.commandPalette.stepOf", %{current: @current_step_index + 1, total: @total_steps}) %>
      </div>

      <%!-- Results --%>
      <div class={build_classes("pa-command-palette__results", [
        {"pa-command-palette__results--loading", @is_loading}
      ])}>
        <%= if @is_loading and @results == [] do %>
          <div class="pa-command-palette__loader">
            <div class="pa-spinner pa-spinner--primary"></div>
            <span><%= t("pureAdmin.commandPalette.searching") %></span>
          </div>
        <% else %>
          <%= if @mode == "idle" and @results == [] do %>
            <%!-- Home screen: show commands + contexts --%>
            <div class="pa-command-palette__home">
              <div :if={@commands != []} class="pa-command-palette__home-section">
                <div class="pa-command-palette__home-heading"><%= t("pureAdmin.commandPalette.commands") %></div>
                <%= for {cmd, index} <- Enum.with_index(@commands) do %>
                  <div
                    class={build_classes("pa-command-palette__item", [
                      {"pa-command-palette__item--active", index == @active_index}
                    ])}
                    phx-click="cp:home_select"
                    phx-target={@target}
                    phx-value-type="command"
                    phx-value-shortcut={cmd.shortcut}
                  >
                    <div :if={cmd[:icon]} class="pa-command-palette__item-icon"><.cp_icon icon={cmd[:icon]} /></div>
                    <div class="pa-command-palette__item-content">
                      <div class="pa-command-palette__item-title"><%= cmd[:name] %></div>
                      <div class="pa-command-palette__item-meta"><%= cmd[:description] %></div>
                    </div>
                    <%= if cmd[:hotkey] do %>
                      <div class="pa-command-palette__shortcut">
                        <%= for key <- String.split(cmd[:hotkey], ~r/[+\s]+/, trim: true) do %>
                          <span class="pa-command-palette__key"><%= key %></span>
                        <% end %>
                      </div>
                    <% else %>
                      <span class="pa-command-palette__key"><%= cmd[:shortcut] %></span>
                    <% end %>
                  </div>
                <% end %>
              </div>
              <div :if={@contexts != []} class="pa-command-palette__home-section">
                <div class="pa-command-palette__home-heading"><%= t("pureAdmin.commandPalette.search") %></div>
                <%= for {ctx, index} <- Enum.with_index(@contexts) do %>
                  <div
                    class={build_classes("pa-command-palette__item", [
                      {"pa-command-palette__item--active", length(@commands) + index == @active_index}
                    ])}
                    phx-click="cp:home_select"
                    phx-target={@target}
                    phx-value-type="context"
                    phx-value-shortcut={ctx.shortcut}
                  >
                    <div :if={ctx[:icon]} class="pa-command-palette__item-icon"><.cp_icon icon={ctx[:icon]} /></div>
                    <div class="pa-command-palette__item-content">
                      <div class="pa-command-palette__item-title"><%= ctx[:name] %></div>
                      <div :if={ctx[:description]} class="pa-command-palette__item-meta"><%= ctx[:description] %></div>
                    </div>
                    <span class="pa-command-palette__key"><%= ctx[:shortcut] %></span>
                  </div>
                <% end %>
              </div>
            </div>
          <% else %>
            <%= if @results != [] do %>
              <%= for {item, index} <- Enum.with_index(@results) do %>
                <div
                  class={build_classes("pa-command-palette__item", [
                    {"pa-command-palette__item--active", index == @active_index}
                  ])}
                  phx-click="cp:select"
                  phx-target={@target}
                  phx-value-index={index}
                >
                  <div :if={item[:icon]} class="pa-command-palette__item-icon"><.cp_icon icon={item[:icon]} /></div>
                  <div class="pa-command-palette__item-content">
                    <div class="pa-command-palette__item-title"><%= item[:title] || item[:name] || item[:label] %></div>
                    <div :if={item[:subtitle] || item[:description] || item[:meta]} class="pa-command-palette__item-meta">
                      <%= item[:subtitle] || item[:description] || item[:meta] %>
                    </div>
                  </div>
                  <span :if={item[:badge]} class="pa-badge"><%= item[:badge] %></span>
                  <div :if={item[:shortcut]} class="pa-command-palette__shortcut">
                    <span class="pa-command-palette__key"><%= item[:shortcut] %></span>
                  </div>
                </div>
              <% end %>
              <div :if={@total_pages > 1} class="pa-command-palette__pagination">
                <%= t("pureAdmin.commandPalette.pageOf", %{page: @page, total: @total_pages, count: @total_results}) %>
              </div>
            <% else %>
              <div class="pa-command-palette__empty"><%= @empty_text %></div>
            <% end %>
          <% end %>
        <% end %>
      </div>

      <%!-- Footer with mode-aware hints --%>
      <div class="pa-command-palette__footer">
        <div class="pa-command-palette__hint">
          <span class="pa-command-palette__key">↑↓</span>
          <span><%= t("pureAdmin.commandPalette.navigate") %></span>
        </div>
        <div :if={@mode in ["context_search", "global_search"] and @total_pages > 1} class="pa-command-palette__hint">
          <span class="pa-command-palette__key">←→</span>
          <span><%= t("pureAdmin.commandPalette.pages") %></span>
        </div>
        <div class="pa-command-palette__hint">
          <span class="pa-command-palette__key">↵</span>
          <span><%= t("pureAdmin.commandPalette.select") %></span>
        </div>
        <div :if={@mode in ["command_step", "context_search"]} class="pa-command-palette__hint">
          <span class="pa-command-palette__key">⌫</span>
          <span><%= t("pureAdmin.commandPalette.back") %></span>
        </div>
        <div class="pa-command-palette__hint">
          <span class="pa-command-palette__key">Esc</span>
          <span><%= if @mode in ["command_step", "context_search"], do: t("pureAdmin.commandPalette.back"), else: t("pureAdmin.commandPalette.close") %></span>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Precompute `:display_value` and `:locked_length` onto the assigns (see
  `input_state/1`). Used by `command_palette/1`; `command_palette_body/1` fills
  the `:placeholder` / `:empty_text` translation defaults itself.
  """
  def prepare(assigns) do
    {display_value, locked_length} =
      input_state(%{
        display: assigns.display,
        mode: assigns.mode,
        input_text: assigns.input_text,
        query: assigns.query
      })

    assigns
    |> assign(:display_value, display_value)
    |> assign(:locked_length, locked_length)
  end

  @doc """
  Compute `{display_value, locked_length}` for the input, given a map with
  `:display`, `:mode`, `:input_text`, `:query`.

  In inline command-step mode the input shows the full accumulated text and the
  prefix (everything before the current step's typed portion) is locked.
  """
  def input_state(%{display: display, mode: mode, input_text: input_text, query: query}) do
    display_value =
      if display == "inline" and mode == "command_step", do: input_text, else: query

    locked_length =
      if display == "inline" and mode == "command_step" and input_text != "" do
        max(0, String.length(input_text) - String.length(query || ""))
      else
        0
      end

    {display_value, locked_length}
  end

  defp step_placeholder(assigns) do
    cond do
      assigns.display == "inline" and assigns.mode == "command_step" ->
        # In inline mode, no separate placeholder — the accumulated text IS the context
        ""

      assigns.mode == "command_step" and assigns.current_step ->
        assigns.current_step[:placeholder] || t("pureAdmin.commandPalette.filterPlaceholder")

      true ->
        assigns[:placeholder]
    end
  end

  # Render an item's `:icon`, which may be any of three shapes — mirroring the
  # sidebar's `sidebar_icon_span`, so a source can hand the palette the SAME
  # icons the sidebar uses instead of unicode:
  #   * raw inline SVG markup (Lucide/Heroicon) → rendered raw
  #   * an icon-provider / Font Awesome / affordance NAME → the `<.icon>` dispatcher
  #   * a plain glyph (emoji) → rendered as text
  attr(:icon, :any, default: nil)

  defp cp_icon(assigns) do
    ~H"""
    <%= cond do %>
      <% svg_icon?(@icon) -> %>{Phoenix.HTML.raw(@icon)}
      <% icon_name?(@icon) -> %><.icon name={@icon} />
      <% true -> %>{@icon}
    <% end %>
    """
  end

  defp svg_icon?(icon) when is_binary(icon), do: String.starts_with?(String.trim_leading(icon), "<")
  defp svg_icon?(_), do: false

  # An ASCII-leading string is an icon NAME (fa-*/hero-*/affordance/provider key);
  # a leading non-ASCII byte means it's an emoji glyph, rendered as text.
  defp icon_name?(icon) when is_binary(icon), do: String.match?(icon, ~r/^[A-Za-z]/)
  defp icon_name?(_), do: false
end
