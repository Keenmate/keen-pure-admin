defmodule PureAdmin.CommandPalette.Source do
  @moduledoc """
  Behaviour that supplies the **per-project half** of the command palette.

  The `PureAdmin.CommandPalette` LiveComponent owns the reusable half — the
  modes (`/command`, `:context`, global), the multi-step wizard, pagination,
  keyboard navigation, inline/token display and open/close lifecycle. What
  *differs per project* — which commands and contexts exist, how to resolve a
  step's options, how to search, and what a selection does — is injected through
  a module implementing this behaviour and passed as the `source` assign:

      <.live_component
        module={PureAdmin.CommandPalette}
        id="command-palette"
        source={MyApp.Palette} />

  Implement it with `use PureAdmin.CommandPalette.Source`, which provides
  overridable no-op defaults so you only define the callbacks you need:

      defmodule MyApp.Palette do
        use PureAdmin.CommandPalette.Source

        def commands, do: [
          %{id: "go", shortcut: "/go", name: "Go to Page", icon: "🧭",
            steps: [%{id: "page", prompt: " ", placeholder: "Type a page…", free_text: true}]}
        ]

        def contexts, do: [
          %{id: "products", shortcut: ":products", aliases: [":p"], name: "Products", icon: "📦"}
        ]

        def step_options("go", "page", query, _selections), do: search_pages(query)

        def search(:global, query), do: search_everything(query)
        def search({:context, "products"}, query), do: search_products(query)

        def on_select(item), do: {:navigate, item.href}
        def on_complete("go", selections), do: {:navigate, List.last(selections).value}
      end

  ## Data shapes

  A **command** is a map with `:id` and `:shortcut` (`"/deploy"`) and optionally
  `:aliases`, `:hotkey`, `:name`, `:description`, `:icon`, and `:steps`. Each
  **step** is `%{id, prompt, placeholder, free_text}` (`:free_text` lets the
  user submit typed text when nothing matches).

  A **context** is a map with `:id` and `:shortcut` (`":products"`) and
  optionally `:aliases`, `:name`, `:description`, `:icon`.

  A step **option** (returned by `c:step_options/4`) is `%{label, value}` plus
  optional `:description`, `:icon`, `:code`. A search **item** (returned by
  `c:search/2`) is `%{title, subtitle, icon, badge}` — and whatever else your
  `c:on_select/1` needs (e.g. `:href`).

  ## Directives

  `c:on_select/1` and `c:on_complete/2` return a **directive** the component
  executes, so the palette can live once in the layout without every LiveView
  needing matching handlers:

    * `{:navigate, path}` — `push_navigate` (closes the palette first)
    * `{:patch, path}` — `push_patch`
    * `{:toast, variant, title, message}` / `{:toast, variant, title, message, opts}`
    * `:close` — just close the palette
    * `:noop` / `nil` — do nothing

  ## Filtering

  Filtering is the source's job — `c:search/2` and `c:step_options/4` receive the
  current query and return the already-filtered list. The component paginates
  search results (`page_size`, default 8) and, in **global** search, prepends the
  commands and contexts whose name/shortcut/alias match the query.
  """

  @type command :: %{
          required(:id) => String.t(),
          required(:shortcut) => String.t(),
          optional(:aliases) => [String.t()],
          optional(:hotkey) => String.t(),
          optional(:name) => String.t(),
          optional(:description) => String.t(),
          optional(:icon) => any(),
          optional(:steps) => [step()]
        }

  @type step :: %{
          required(:id) => String.t(),
          optional(:prompt) => String.t(),
          optional(:placeholder) => String.t(),
          optional(:free_text) => boolean()
        }

  @type context :: %{
          required(:id) => String.t(),
          required(:shortcut) => String.t(),
          optional(:aliases) => [String.t()],
          optional(:name) => String.t(),
          optional(:description) => String.t(),
          optional(:icon) => any()
        }

  @type option :: %{
          required(:label) => String.t(),
          optional(:value) => any(),
          optional(:description) => String.t(),
          optional(:icon) => any(),
          optional(:code) => String.t()
        }

  @type item :: map()

  @type scope :: :global | {:context, String.t()}

  @type directive ::
          {:navigate, String.t()}
          | {:patch, String.t()}
          | {:toast, atom() | String.t(), String.t(), String.t()}
          | {:toast, atom() | String.t(), String.t(), String.t(), keyword()}
          | :close
          | :noop
          | nil

  @doc "The commands shown under `/` (and on the idle home screen)."
  @callback commands() :: [command()]

  @doc "The search contexts shown under `:` (and on the idle home screen)."
  @callback contexts() :: [context()]

  @doc """
  Options for a command step, already filtered by `query`.

  `selections` holds the prior steps' picks as `%{step_id, label, value, prompt}`.
  """
  @callback step_options(
              command_id :: String.t(),
              step_id :: String.t(),
              query :: String.t(),
              selections :: [map()]
            ) :: [option()]

  @doc """
  Search results for a `scope`, already filtered by `query`.

  Return the full filtered list; the component paginates it. For `:global`, the
  component additionally prepends matching commands/contexts.
  """
  @callback search(scope(), query :: String.t()) :: [item()]

  @doc "What selecting a search-result `item` does. Returns a `t:directive/0`."
  @callback on_select(item()) :: directive()

  @doc "What finishing a command does. Returns a `t:directive/0`."
  @callback on_complete(command_id :: String.t(), selections :: [map()]) :: directive()

  defmacro __using__(_opts) do
    quote do
      @behaviour PureAdmin.CommandPalette.Source

      @impl true
      def commands, do: []

      @impl true
      def contexts, do: []

      @impl true
      def step_options(_command_id, _step_id, _query, _selections), do: []

      @impl true
      def search(_scope, _query), do: []

      @impl true
      def on_select(item),
        do: {:toast, :info, "Selected", to_string(item[:title] || item[:label] || item[:name] || "")}

      @impl true
      def on_complete(command_id, _selections),
        do: {:toast, :success, "Command executed", command_id}

      defoverridable commands: 0,
                     contexts: 0,
                     step_options: 4,
                     search: 2,
                     on_select: 1,
                     on_complete: 2
    end
  end
end
