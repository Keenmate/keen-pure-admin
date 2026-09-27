defmodule PureAdmin.CommandPalette do
  @moduledoc """
  Stateful command palette — a `Phoenix.LiveComponent` that owns the reusable
  interaction state machine and delegates every app-specific decision to a
  `PureAdmin.CommandPalette.Source` module.

  Mount it **once**, in your app layout, so it (and its global `Ctrl+K` / `⌘K`
  listener) is available on every page:

      <.live_component
        module={PureAdmin.CommandPalette}
        id="command-palette"
        source={MyApp.Palette} />

  Any trigger opens it without extra plumbing —
  `PureAdmin.Components.CommandPalette.show_command_palette/2` dispatches
  `pa:command-palette:open` to the element by id:

      <.navbar_search phx-click={show_command_palette()} />
      <.sidebar_search phx-click={show_command_palette()} />

  A parent LiveView can drive it via `send_update/2`:

      send_update(PureAdmin.CommandPalette, id: "command-palette", open_with: "/deploy")
      send_update(PureAdmin.CommandPalette, id: "command-palette", display: "tokens")

  ## Assigns

    * `id` (required) — DOM id; the same value triggers dispatch to.
    * `source` (required) — a module implementing `PureAdmin.CommandPalette.Source`.
    * `display` — `"inline"` (default) or `"tokens"`.
    * `page_size` — search results per page (default `8`).

  See `PureAdmin.CommandPalette.Source` for the injected contract, data shapes
  and the directive vocabulary (`{:navigate, path}`, `{:toast, …}`, `:close`).
  """
  use Phoenix.LiveComponent

  import PureAdmin.Helpers, only: [build_classes: 3]
  import PureAdmin.Components.CommandPalette, only: [command_palette_body: 1, input_state: 1]

  alias PureAdmin.Components.Toast

  @default_page_size 8

  @impl true
  def update(assigns, socket) do
    # send_update/2 only carries the keys it was given (no :source), so fall back
    # to the source already stored from the initial parent render.
    source = assigns[:source] || Map.get(socket.assigns, :source) || raise_missing_source()

    socket =
      socket
      |> assign(:id, assigns.id)
      |> assign(:source, source)
      |> assign(:cp_display, assigns[:display] || Map.get(socket.assigns, :cp_display, "inline"))
      |> assign(:page_size, assigns[:page_size] || Map.get(socket.assigns, :page_size, @default_page_size))
      |> assign_new(:cp_open, fn -> false end)
      |> assign_new(:cp_mode, fn -> "idle" end)
      |> assign_new(:cp_query, fn -> "" end)
      |> assign_new(:cp_results, fn -> [] end)
      |> assign_new(:cp_active_index, fn -> -1 end)
      |> assign_new(:cp_loading, fn -> false end)
      |> assign_new(:cp_current_command, fn -> nil end)
      |> assign_new(:cp_current_step, fn -> nil end)
      |> assign_new(:cp_step_index, fn -> 0 end)
      |> assign_new(:cp_total_steps, fn -> 0 end)
      |> assign_new(:cp_selections, fn -> [] end)
      |> assign_new(:cp_preview, fn -> nil end)
      |> assign_new(:cp_current_context, fn -> nil end)
      |> assign_new(:cp_scope, fn -> :global end)
      |> assign_new(:cp_page, fn -> 1 end)
      |> assign_new(:cp_total_pages, fn -> 1 end)
      |> assign_new(:cp_total_results, fn -> 0 end)
      |> assign_new(:cp_input_text, fn -> "" end)
      |> assign_new(:cp_commands, fn -> source.commands() end)
      |> assign_new(:cp_contexts, fn -> source.contexts() end)

    socket =
      cond do
        Map.has_key?(assigns, :open_with) ->
          socket |> open_palette() |> process_input(assigns.open_with)

        true ->
          socket
      end

    {:ok, socket}
  end

  defp raise_missing_source do
    raise ArgumentError,
          "PureAdmin.CommandPalette requires a `source` assign (a module implementing " <>
            "PureAdmin.CommandPalette.Source) on its initial render"
  end

  @impl true
  def render(assigns) do
    {display_value, locked_length} =
      input_state(%{
        display: assigns.cp_display,
        mode: assigns.cp_mode,
        input_text: assigns.cp_input_text,
        query: assigns.cp_query
      })

    assigns = assign(assigns, display_value: display_value, locked_length: locked_length)

    ~H"""
    <div
      id={@id}
      class={build_classes("pa-command-palette", [{"pa-command-palette--active", @cp_open}], nil)}
      phx-hook="PureAdminCommandPalette"
      data-mode={@cp_mode}
      data-display={@cp_display}
      data-locked-length={@locked_length}
    >
      <.command_palette_body
        id={@id}
        target={@myself}
        display={@cp_display}
        mode={@cp_mode}
        display_value={@display_value}
        commands={@cp_commands}
        contexts={@cp_contexts}
        results={@cp_results}
        active_index={@cp_active_index}
        is_loading={@cp_loading}
        current_command={@cp_current_command}
        current_step={@cp_current_step}
        current_step_index={@cp_step_index}
        total_steps={@cp_total_steps}
        selections={@cp_selections}
        current_context={@cp_current_context}
        page={@cp_page}
        total_pages={@cp_total_pages}
        total_results={@cp_total_results}
      />
    </div>
    """
  end

  # -- Event handlers --

  @impl true
  def handle_event("cp:toggle", _params, socket) do
    if socket.assigns.cp_open do
      {:noreply, close_palette(socket)}
    else
      {:noreply, open_palette(socket)}
    end
  end

  def handle_event("cp:close", _params, socket) do
    {:noreply, close_palette(socket)}
  end

  def handle_event("cp:input", %{"query" => query}, socket) do
    {:noreply, process_input(socket, query)}
  end

  def handle_event("cp:navigate", %{"direction" => direction}, socket) do
    count = length(socket.assigns.cp_results)
    active = socket.assigns.cp_active_index

    new_index =
      case direction do
        "up" -> if active <= 0, do: count - 1, else: active - 1
        "down" -> if active >= count - 1, do: 0, else: active + 1
        _ -> active
      end

    {:noreply, assign(socket, cp_active_index: new_index)}
  end

  def handle_event("cp:page", %{"direction" => direction}, socket) do
    page = socket.assigns.cp_page
    total = socket.assigns.cp_total_pages

    new_page =
      case direction do
        "prev" -> max(1, page - 1)
        "next" -> min(total, page + 1)
        _ -> page
      end

    if new_page != page do
      {:noreply, run_search(socket, socket.assigns.cp_scope, socket.assigns.cp_query, new_page)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("cp:select", %{"index" => index_str}, socket) do
    index =
      case index_str do
        i when is_integer(i) -> i
        s when is_binary(s) -> String.to_integer(s)
      end

    index = if index == -1, do: socket.assigns.cp_active_index, else: index
    handle_select(socket, index)
  end

  def handle_event("cp:step_back", _params, socket) do
    {:noreply, step_back(socket)}
  end

  def handle_event("cp:home_select", %{"type" => "command", "shortcut" => shortcut}, socket) do
    command = find_command(socket.assigns.cp_commands, shortcut)

    if command do
      socket = if !socket.assigns.cp_open, do: open_palette(socket), else: socket
      {:noreply, enter_command(socket, command)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("cp:home_select", %{"type" => "context", "shortcut" => shortcut}, socket) do
    context = find_context(socket.assigns.cp_contexts, shortcut)

    if context do
      socket = if !socket.assigns.cp_open, do: open_palette(socket), else: socket
      {:noreply, enter_context_search(socket, context, "")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("cp:hotkey", %{"key" => key}, socket) do
    command =
      Enum.find(socket.assigns.cp_commands, fn cmd ->
        case cmd[:hotkey] do
          nil ->
            false

          hotkey ->
            parts = String.split(String.downcase(hotkey), ~r/[+\s]+/)
            List.last(parts) == key
        end
      end)

    if command do
      socket = if !socket.assigns.cp_open, do: open_palette(socket), else: socket
      {:noreply, enter_command(socket, command)}
    else
      {:noreply, socket}
    end
  end

  # -- State machine --

  defp open_palette(socket) do
    socket
    |> assign(cp_open: true, cp_mode: "idle", cp_query: "", cp_results: [], cp_active_index: -1)
    |> push_event("cp:focus", %{})
  end

  defp close_palette(socket) do
    assign(socket,
      cp_open: false,
      cp_mode: "idle",
      cp_query: "",
      cp_results: [],
      cp_active_index: -1,
      cp_loading: false,
      cp_current_command: nil,
      cp_current_step: nil,
      cp_step_index: 0,
      cp_total_steps: 0,
      cp_selections: [],
      cp_preview: nil,
      cp_current_context: nil,
      cp_scope: :global,
      cp_page: 1,
      cp_total_pages: 1,
      cp_total_results: 0
    )
  end

  defp process_input(socket, query) do
    cond do
      socket.assigns.cp_mode == "command_step" ->
        filter_step_options(socket, query)

      socket.assigns.cp_mode == "context_search" ->
        run_search(socket, socket.assigns.cp_scope, query)

      String.starts_with?(query, "/") ->
        handle_command_input(socket, query)

      String.starts_with?(query, ":") ->
        handle_context_input(socket, query)

      query == "" ->
        assign(socket, cp_mode: "idle", cp_query: "", cp_results: [], cp_active_index: -1)

      true ->
        run_search(socket, :global, query)
    end
  end

  # -- Command handling --

  defp handle_command_input(socket, query) do
    commands = socket.assigns.cp_commands

    parts = String.split(query, " ", parts: 2)
    cmd_part = hd(parts)

    matched_command = if length(parts) > 1, do: find_command(commands, cmd_part)

    if matched_command do
      enter_command(socket, matched_command)
    else
      filtered =
        if query == "/" do
          commands
        else
          filter_items(commands, String.trim_leading(query, "/"), fn cmd ->
            [cmd.shortcut, cmd[:name] | cmd[:aliases] || []]
          end)
        end

      results = Enum.map(filtered, fn cmd -> Map.put(cmd, :shortcut, cmd.shortcut) end)

      assign(socket,
        cp_mode: "command_list",
        cp_query: query,
        cp_results: results,
        cp_active_index: if(results != [], do: 0, else: -1)
      )
    end
  end

  defp find_command(commands, input) do
    Enum.find(commands, fn cmd ->
      input == cmd.shortcut or input in (cmd[:aliases] || [])
    end)
  end

  defp enter_command(socket, command) do
    steps = command[:steps] || []

    if steps == [] do
      complete_command(socket, command.id, [])
    else
      step = hd(steps)
      options = socket.assigns.source.step_options(command.id, step.id, "", [])
      inline_text = command.shortcut <> (step[:prompt] || " ")

      socket
      |> assign(
        cp_mode: "command_step",
        cp_query: "",
        cp_current_command: command,
        cp_current_step: step,
        cp_step_index: 0,
        cp_total_steps: length(steps),
        cp_selections: [],
        cp_results: options,
        cp_active_index: if(options != [], do: 0, else: -1),
        cp_preview: nil,
        cp_input_text: inline_text
      )
      |> push_reset_input(inline_text)
    end
  end

  defp filter_step_options(socket, query) do
    command = socket.assigns.cp_current_command
    step = socket.assigns.cp_current_step
    selections = socket.assigns.cp_selections
    display = socket.assigns.cp_display

    search_query =
      if display == "inline" do
        prefix = build_inline_text(command, selections, step)

        if String.starts_with?(query, prefix) do
          String.slice(query, String.length(prefix)..-1//1)
        else
          query
        end
      else
        query
      end

    options = socket.assigns.source.step_options(command.id, step.id, search_query, selections)

    assign(socket,
      cp_query: search_query,
      cp_input_text: query,
      cp_results: options,
      cp_active_index: if(options != [], do: 0, else: -1)
    )
  end

  defp advance_step(socket, selected_option) do
    command = socket.assigns.cp_current_command
    step = socket.assigns.cp_current_step
    step_index = socket.assigns.cp_step_index
    selections = socket.assigns.cp_selections
    steps = command[:steps] || []

    label = selected_option[:label] || selected_option[:title] || to_string(selected_option[:value])

    new_selection = %{
      step_id: step.id,
      label: label,
      value: selected_option[:value] || label,
      prompt: step[:prompt]
    }

    new_selections = selections ++ [new_selection]
    next_index = step_index + 1

    if next_index >= length(steps) do
      complete_command(socket, command.id, new_selections)
    else
      next_step = Enum.at(steps, next_index)
      options = socket.assigns.source.step_options(command.id, next_step.id, "", new_selections)
      inline_text = build_inline_text(command, new_selections, next_step)

      socket
      |> assign(
        cp_step_index: next_index,
        cp_current_step: next_step,
        cp_selections: new_selections,
        cp_query: "",
        cp_results: options,
        cp_active_index: if(options != [], do: 0, else: -1),
        cp_preview: build_preview(command, new_selections),
        cp_input_text: inline_text
      )
      |> push_reset_input(inline_text)
    end
  end

  defp step_back(socket) do
    case socket.assigns.cp_mode do
      "command_step" ->
        step_index = socket.assigns.cp_step_index

        if step_index == 0 do
          socket
          |> assign(
            cp_mode: "command_list",
            cp_query: "/",
            cp_results: Enum.map(socket.assigns.cp_commands, &Map.put(&1, :shortcut, &1.shortcut)),
            cp_active_index: 0,
            cp_current_command: nil,
            cp_current_step: nil,
            cp_step_index: 0,
            cp_selections: [],
            cp_preview: nil,
            cp_input_text: "/"
          )
          |> push_reset_input("/")
        else
          command = socket.assigns.cp_current_command
          steps = command[:steps] || []
          prev_index = step_index - 1
          prev_step = Enum.at(steps, prev_index)
          prev_selections = Enum.take(socket.assigns.cp_selections, prev_index)
          options = socket.assigns.source.step_options(command.id, prev_step.id, "", prev_selections)
          inline_text = build_inline_text(command, prev_selections, prev_step)

          socket
          |> assign(
            cp_step_index: prev_index,
            cp_current_step: prev_step,
            cp_selections: prev_selections,
            cp_query: "",
            cp_results: options,
            cp_active_index: if(options != [], do: 0, else: -1),
            cp_preview: build_preview(command, prev_selections),
            cp_input_text: inline_text
          )
          |> push_reset_input(inline_text)
        end

      "context_search" ->
        socket
        |> assign(
          cp_mode: "context_list",
          cp_query: ":",
          cp_results: Enum.map(socket.assigns.cp_contexts, &Map.put(&1, :shortcut, &1.shortcut)),
          cp_active_index: 0,
          cp_current_context: nil,
          cp_scope: :global,
          cp_page: 1,
          cp_total_pages: 1,
          cp_total_results: 0
        )
        |> push_event("cp:reset_input", %{value: ":"})

      _ ->
        close_palette(socket)
    end
  end

  # -- Context handling --

  defp handle_context_input(socket, query) do
    contexts = socket.assigns.cp_contexts

    parts = String.split(query, " ", parts: 2)
    ctx_part = hd(parts)

    matched_context = if length(parts) > 1, do: find_context(contexts, ctx_part)

    if matched_context do
      search_query = Enum.at(parts, 1) || ""
      enter_context_search(socket, matched_context, search_query)
    else
      filtered =
        if query == ":" do
          contexts
        else
          filter_items(contexts, String.trim_leading(query, ":"), fn ctx ->
            [ctx.shortcut, ctx[:name] | ctx[:aliases] || []]
          end)
        end

      results = Enum.map(filtered, fn ctx -> Map.put(ctx, :shortcut, ctx.shortcut) end)

      assign(socket,
        cp_mode: "context_list",
        cp_query: query,
        cp_results: results,
        cp_active_index: if(results != [], do: 0, else: -1)
      )
    end
  end

  defp find_context(contexts, input) do
    Enum.find(contexts, fn ctx ->
      input == ctx.shortcut or input in (ctx[:aliases] || [])
    end)
  end

  defp enter_context_search(socket, context, query) do
    socket
    |> assign(cp_mode: "context_search", cp_current_context: context)
    |> run_search({:context, context.id}, query)
    |> push_event("cp:reset_input", %{value: query})
  end

  # -- Search --

  defp run_search(socket, scope, query, page \\ 1) do
    data = socket.assigns.source.search(scope, query)

    results =
      case scope do
        :global -> global_matches(socket, query) ++ data
        _ -> data
      end

    mode = if scope == :global, do: "global_search", else: socket.assigns.cp_mode

    socket
    |> assign(cp_mode: mode, cp_scope: scope, cp_query: query)
    |> paginate(results, page)
  end

  # Global search prepends commands/contexts whose name/shortcut/alias match.
  defp global_matches(socket, query) do
    q = String.downcase(String.trim(query))

    cmd_results =
      socket.assigns.cp_commands
      |> Enum.filter(&matches?(&1, q))
      |> Enum.map(fn cmd ->
        %{
          id: "cmd-#{cmd.id}",
          title: cmd[:name],
          subtitle: cmd[:description],
          icon: cmd[:icon],
          badge: cmd.shortcut,
          _type: "command",
          _shortcut: cmd.shortcut
        }
      end)

    ctx_results =
      socket.assigns.cp_contexts
      |> Enum.filter(&matches?(&1, q))
      |> Enum.map(fn ctx ->
        %{
          id: "ctx-#{ctx.id}",
          title: ctx[:name],
          subtitle: ctx[:description],
          icon: ctx[:icon],
          badge: ctx.shortcut,
          _type: "context",
          _shortcut: ctx.shortcut
        }
      end)

    cmd_results ++ ctx_results
  end

  defp matches?(_entry, ""), do: false

  defp matches?(entry, q) do
    String.contains?(String.downcase(entry[:name] || ""), q) or
      String.contains?(String.downcase(entry.shortcut), q) or
      Enum.any?(entry[:aliases] || [], &String.contains?(String.downcase(&1), q))
  end

  defp paginate(socket, results, page) do
    size = socket.assigns.page_size
    total = length(results)
    total_pages = max(1, ceil(total / size))
    page = min(max(page, 1), total_pages)

    page_results =
      results
      |> Enum.drop((page - 1) * size)
      |> Enum.take(size)

    assign(socket,
      cp_results: page_results,
      cp_page: page,
      cp_total_pages: total_pages,
      cp_total_results: total,
      cp_active_index: if(page_results != [], do: 0, else: -1)
    )
  end

  # -- Selection handling --

  defp handle_select(socket, index) do
    results = socket.assigns.cp_results
    mode = socket.assigns.cp_mode

    if index >= 0 and index < length(results) do
      item = Enum.at(results, index)

      case mode do
        "command_list" ->
          command = find_command(socket.assigns.cp_commands, item[:shortcut])
          if command, do: {:noreply, enter_command(socket, command)}, else: {:noreply, socket}

        "command_step" ->
          {:noreply, advance_step(socket, item)}

        "context_list" ->
          context = find_context(socket.assigns.cp_contexts, item[:shortcut])
          if context, do: {:noreply, enter_context_search(socket, context, "")}, else: {:noreply, socket}

        "context_search" ->
          {:noreply, apply_directive(socket, socket.assigns.source.on_select(item))}

        "global_search" ->
          cond do
            item[:_type] == "command" ->
              command = find_command(socket.assigns.cp_commands, item[:_shortcut])
              if command, do: {:noreply, enter_command(socket, command)}, else: {:noreply, socket}

            item[:_type] == "context" ->
              context = find_context(socket.assigns.cp_contexts, item[:_shortcut])
              if context, do: {:noreply, enter_context_search(socket, context, "")}, else: {:noreply, socket}

            true ->
              {:noreply, apply_directive(socket, socket.assigns.source.on_select(item))}
          end

        _ ->
          {:noreply, socket}
      end
    else
      # No item under the cursor — allow free-text submit in a free_text step.
      if mode == "command_step" do
        step = socket.assigns.cp_current_step

        if step[:free_text] do
          query = socket.assigns.cp_query
          {:noreply, advance_step(socket, %{label: query, value: query})}
        else
          {:noreply, socket}
        end
      else
        {:noreply, socket}
      end
    end
  end

  defp complete_command(socket, command_id, selections) do
    apply_directive(socket, socket.assigns.source.on_complete(command_id, selections))
  end

  # Execute a source-returned directive. The palette closes first for anything
  # that leaves it (navigate/patch/toast/close) so it never lingers over a new page.
  defp apply_directive(socket, directive) do
    case directive do
      {:navigate, path} ->
        socket |> close_palette() |> Phoenix.LiveView.push_navigate(to: path)

      {:patch, path} ->
        socket |> close_palette() |> Phoenix.LiveView.push_patch(to: path)

      {:toast, variant, title, message} ->
        socket |> close_palette() |> Toast.push_toast(to_string(variant), title, message)

      {:toast, variant, title, message, opts} ->
        socket |> close_palette() |> Toast.push_toast(to_string(variant), title, message, opts)

      :close ->
        close_palette(socket)

      _ ->
        socket
    end
  end

  # -- Helpers --

  defp filter_items(items, query, get_searchable_fn) do
    if query == "" do
      items
    else
      q = String.downcase(query)

      Enum.filter(items, fn item ->
        get_searchable_fn.(item)
        |> Enum.any?(fn field -> String.contains?(String.downcase(field || ""), q) end)
      end)
    end
  end

  defp build_preview(command, []), do: build_preview_name(command)
  defp build_preview(command, nil), do: build_preview_name(command)

  defp build_preview(command, selections) do
    parts = selections |> Enum.map(& &1.label) |> Enum.join(" → ")
    "#{command[:name]}: #{parts}"
  end

  defp build_preview_name(_command), do: nil

  # Build the full inline text for the input: "/assign iPad Air to "
  defp build_inline_text(command, selections, current_step) do
    base = command.shortcut

    text =
      Enum.reduce(selections, base, fn sel, acc ->
        acc <> (sel[:prompt] || " ") <> sel[:label]
      end)

    text <> (current_step[:prompt] || " ")
  end

  defp push_reset_input(socket, inline_value) do
    if socket.assigns.cp_display == "inline" do
      push_event(socket, "cp:reset_input", %{value: inline_value})
    else
      push_event(socket, "cp:reset_input", %{value: ""})
    end
  end
end
