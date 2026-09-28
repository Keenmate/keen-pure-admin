defmodule DemoWeb.CommandPaletteSource do
  @moduledoc """
  Demo `PureAdmin.CommandPalette.Source` — supplies the commands, contexts,
  step options, search data and selection actions for the demo's global command
  palette (mounted once in the app layout).

  This is the per-project half of the palette: a real app swaps this module for
  one backed by its own router, contexts and data. The reusable state machine
  lives in `PureAdmin.CommandPalette`.
  """
  use PureAdmin.CommandPalette.Source

  # Translations resolve per-request: commands/0 and contexts/0 are functions
  # (NOT module attributes) so gettext/1 runs at call time under the active
  # locale — a module attribute would freeze the strings at compile time.
  use Gettext, backend: DemoWeb.Gettext

  @page_size 8

  # -- Demo data --

  @products [
    %{id: "p1", title: "MacBook Pro 16\"", subtitle: "Electronics · $2,499", icon: "💻", badge: "In Stock"},
    %{id: "p2", title: "iPhone 15 Pro", subtitle: "Electronics · $999", icon: "📱", badge: "In Stock"},
    %{id: "p3", title: "AirPods Pro", subtitle: "Electronics · $249", icon: "🎧", badge: "Low Stock"},
    %{id: "p4", title: "iPad Air", subtitle: "Electronics · $599", icon: "📱", badge: "In Stock"},
    %{id: "p5", title: "Apple Watch Ultra", subtitle: "Electronics · $799", icon: "⌚", badge: "In Stock"},
    %{id: "p6", title: "Magic Keyboard", subtitle: "Accessories · $299", icon: "⌨️", badge: "In Stock"},
    %{id: "p7", title: "Studio Display", subtitle: "Electronics · $1,599", icon: "🖥️", badge: "Pre-order"},
    %{id: "p8", title: "HomePod mini", subtitle: "Electronics · $99", icon: "🔊", badge: "In Stock"},
    %{id: "p9", title: "AirTag 4 Pack", subtitle: "Accessories · $99", icon: "📍", badge: "In Stock"},
    %{id: "p10", title: "MagSafe Charger", subtitle: "Accessories · $39", icon: "🔌", badge: "In Stock"}
  ]

  @orders [
    %{id: "o1", title: "Order #10421", subtitle: "John Doe · 3 items · $3,747", icon: "📦", badge: "Shipped"},
    %{id: "o2", title: "Order #10422", subtitle: "Jane Smith · 1 item · $999", icon: "📦", badge: "Processing"},
    %{id: "o3", title: "Order #10423", subtitle: "Bob Wilson · 2 items · $348", icon: "📦", badge: "Delivered"},
    %{id: "o4", title: "Order #10424", subtitle: "Alice Brown · 1 item · $2,499", icon: "📦", badge: "Pending"},
    %{id: "o5", title: "Order #10425", subtitle: "Charlie Davis · 5 items · $1,235", icon: "📦", badge: "Shipped"},
    %{id: "o6", title: "Order #10426", subtitle: "Diana Evans · 2 items · $698", icon: "📦", badge: "Delivered"},
    %{id: "o7", title: "Order #10427", subtitle: "Frank Garcia · 1 item · $599", icon: "📦", badge: "Processing"},
    %{id: "o8", title: "Order #10428", subtitle: "Grace Hall · 3 items · $447", icon: "📦", badge: "Shipped"},
    %{id: "o9", title: "Order #10429", subtitle: "Henry Irving · 1 item · $799", icon: "📦", badge: "Pending"},
    %{id: "o10", title: "Order #10430", subtitle: "Ivy Johnson · 4 items · $1,836", icon: "📦", badge: "Delivered"}
  ]

  @users [
    %{id: "u1", title: "John Doe", subtitle: "john@example.com · Admin", icon: "👤", badge: "Active"},
    %{id: "u2", title: "Jane Smith", subtitle: "jane@example.com · Editor", icon: "👤", badge: "Active"},
    %{id: "u3", title: "Bob Wilson", subtitle: "bob@example.com · Viewer", icon: "👤", badge: "Inactive"},
    %{id: "u4", title: "Alice Brown", subtitle: "alice@example.com · Admin", icon: "👤", badge: "Active"},
    %{id: "u5", title: "Charlie Davis", subtitle: "charlie@example.com · Editor", icon: "👤", badge: "Active"},
    %{id: "u6", title: "Diana Evans", subtitle: "diana@example.com · Viewer", icon: "👤", badge: "Active"},
    %{id: "u7", title: "Frank Garcia", subtitle: "frank@example.com · Editor", icon: "👤", badge: "Inactive"},
    %{id: "u8", title: "Grace Hall", subtitle: "grace@example.com · Admin", icon: "👤", badge: "Active"},
    %{id: "u9", title: "Henry Irving", subtitle: "henry@example.com · Viewer", icon: "👤", badge: "Active"},
    %{id: "u10", title: "Ivy Johnson", subtitle: "ivy@example.com · Editor", icon: "👤", badge: "Active"}
  ]

  @invoices [
    %{id: "i1", title: "INV-2024-001", subtitle: "John Doe · $3,747.00", icon: "🧾", badge: "Paid"},
    %{id: "i2", title: "INV-2024-002", subtitle: "Jane Smith · $999.00", icon: "🧾", badge: "Pending"},
    %{id: "i3", title: "INV-2024-003", subtitle: "Bob Wilson · $348.00", icon: "🧾", badge: "Paid"},
    %{id: "i4", title: "INV-2024-004", subtitle: "Alice Brown · $2,499.00", icon: "🧾", badge: "Overdue"},
    %{id: "i5", title: "INV-2024-005", subtitle: "Charlie Davis · $1,235.00", icon: "🧾", badge: "Paid"},
    %{id: "i6", title: "INV-2024-006", subtitle: "Diana Evans · $698.00", icon: "🧾", badge: "Pending"},
    %{id: "i7", title: "INV-2024-007", subtitle: "Frank Garcia · $599.00", icon: "🧾", badge: "Paid"},
    %{id: "i8", title: "INV-2024-008", subtitle: "Grace Hall · $447.00", icon: "🧾", badge: "Paid"},
    %{id: "i9", title: "INV-2024-009", subtitle: "Henry Irving · $799.00", icon: "🧾", badge: "Overdue"},
    %{id: "i10", title: "INV-2024-010", subtitle: "Ivy Johnson · $1,836.00", icon: "🧾", badge: "Pending"}
  ]

  # -- Source behaviour --

  @impl true
  def commands do
    [
      %{
        id: "deploy",
        shortcut: "/deploy",
        aliases: ["/d"],
        hotkey: "Alt+D",
        name: gettext("Deploy to Environment"),
        description: gettext("Deploy a branch to an environment"),
        icon: "🚀",
        steps: [
          %{id: "environment", prompt: gettext(" in "), placeholder: gettext("Select environment...")},
          %{id: "branch", prompt: gettext(" branch "), placeholder: gettext("Select or type branch..."), free_text: true}
        ]
      },
      %{
        id: "assign",
        shortcut: "/assign",
        aliases: ["/a"],
        hotkey: "Alt+A",
        name: gettext("Assign to User"),
        description: gettext("Assign an item to a team member"),
        icon: "👤",
        steps: [
          %{id: "item", prompt: " ", placeholder: gettext("Select item...")},
          %{id: "user", prompt: gettext(" to "), placeholder: gettext("Select user...")}
        ]
      },
      %{
        id: "go",
        shortcut: "/go",
        aliases: ["/g", "/nav"],
        hotkey: "Alt+G",
        name: gettext("Go to Page"),
        description: gettext("Navigate to a page"),
        icon: "🧭",
        steps: [
          %{id: "page", prompt: " ", placeholder: gettext("Type page name..."), free_text: true}
        ]
      },
      %{
        id: "theme",
        shortcut: "/theme",
        aliases: ["/t"],
        hotkey: "Alt+T",
        name: gettext("Switch Theme"),
        description: gettext("Change the visual theme"),
        icon: "🎨",
        steps: [
          %{id: "theme", prompt: " ", placeholder: gettext("Select theme...")}
        ]
      }
    ]
  end

  @impl true
  def contexts do
    [
      %{id: "products", shortcut: ":products", aliases: [":p"], name: gettext("Products"), description: gettext("Search products"), icon: "📦"},
      %{id: "orders", shortcut: ":orders", aliases: [":o"], name: gettext("Orders"), description: gettext("Search orders"), icon: "📋"},
      %{id: "users", shortcut: ":users", aliases: [":u"], name: gettext("Users"), description: gettext("Search users"), icon: "👥"},
      %{id: "invoices", shortcut: ":invoices", aliases: [":i"], name: gettext("Invoices"), description: gettext("Search invoices"), icon: "🧾"}
    ]
  end

  @impl true
  def search(:global, query) do
    filter_items(@products ++ @orders ++ @users ++ @invoices, query)
  end

  def search({:context, id}, query) do
    id |> context_data() |> filter_items(query)
  end

  @impl true
  def step_options("deploy", "environment", query, _selections) do
    [
      %{id: "prod", label: gettext("Production"), description: gettext("Live servers"), icon: "🔴", value: "production"},
      %{id: "staging", label: gettext("Staging"), description: gettext("Pre-production"), icon: "🟡", value: "staging"},
      %{id: "dev", label: gettext("Development"), description: gettext("Dev servers"), icon: "🟢", value: "development"}
    ]
    |> filter_options(query)
  end

  def step_options("deploy", "branch", query, _selections) do
    [
      %{id: "main", label: "main", description: gettext("Default branch"), icon: "🌿", value: "main"},
      %{id: "develop", label: "develop", description: gettext("Development branch"), icon: "🌱", value: "develop"},
      %{id: "feature", label: "feature/new-ui", description: gettext("Feature branch"), icon: "🔧", value: "feature/new-ui"}
    ]
    |> filter_options(query)
  end

  def step_options("assign", "item", query, _selections) do
    @products
    |> Enum.map(fn p -> %{id: p.id, label: p.title, description: p.subtitle, icon: p.icon, value: p.id} end)
    |> filter_options(query)
  end

  def step_options("assign", "user", query, _selections) do
    @users
    |> Enum.map(fn u -> %{id: u.id, label: u.title, description: u.subtitle, icon: u.icon, value: u.id} end)
    |> filter_options(query)
  end

  def step_options("go", "page", query, _selections) do
    [
      %{id: "dashboard", label: gettext("Dashboard"), code: "01", icon: "📊", value: "/"},
      %{id: "forms", label: gettext("Forms"), code: "10", icon: "📝", value: "/forms"},
      %{id: "buttons", label: gettext("Buttons"), code: "20", icon: "🔘", value: "/components/buttons"},
      %{id: "inputs", label: gettext("Inputs"), code: "21", icon: "✏️", value: "/components/inputs"},
      %{id: "cards", label: gettext("Cards"), code: "22", icon: "🃏", value: "/components/cards"},
      %{id: "tables", label: gettext("Tables"), code: "23", icon: "📊", value: "/tables/standard"},
      %{id: "alerts", label: gettext("Alerts"), code: "24", icon: "⚠️", value: "/components/alerts"},
      %{id: "toasts", label: gettext("Toasts"), code: "25", icon: "🔔", value: "/components/toasts"},
      %{id: "modals", label: gettext("Modals"), code: "26", icon: "🔳", value: "/components/modals"},
      %{id: "tabs", label: gettext("Tabs"), code: "27", icon: "📑", value: "/components/tabs"},
      %{id: "badges", label: gettext("Badges"), code: "28", icon: "🏷️", value: "/components/badges"},
      %{id: "tooltips", label: gettext("Tooltips"), code: "29", icon: "💬", value: "/components/tooltips"},
      %{id: "command-palette", label: gettext("Command Palette"), code: "30", icon: "🔍", value: "/components/command-palette"}
    ]
    |> filter_options(query)
  end

  def step_options("theme", "theme", query, _selections) do
    [
      %{id: "audi", label: "Audi", description: gettext("Premium dark theme"), icon: "🔴", value: "audi"},
      %{id: "dark", label: "Dark", description: gettext("Clean dark theme"), icon: "🌑", value: "dark"},
      %{id: "express", label: "Express", description: gettext("Blue professional theme"), icon: "🔵", value: "express"},
      %{id: "corporate", label: "Corporate", description: gettext("Business theme"), icon: "🏢", value: "corporate"},
      %{id: "minimal", label: "Minimal", description: gettext("Clean minimal theme"), icon: "⚪", value: "minimal"}
    ]
    |> filter_options(query)
  end

  def step_options(_command_id, _step_id, _query, _selections), do: []

  # Selecting a data result just acknowledges it (a real app would navigate/act).
  @impl true
  def on_select(item), do: {:toast, :info, gettext("Selected"), "#{item[:title]}"}

  # Finishing "Go to Page" navigates; other commands acknowledge with a toast.
  @impl true
  def on_complete("go", selections) do
    case List.last(selections) do
      %{value: path} when is_binary(path) -> {:navigate, path}
      _ -> {:toast, :success, gettext("Command Executed"), "go"}
    end
  end

  def on_complete(command_id, selections) do
    sel_str = selections |> Enum.map(fn s -> "#{s.step_id}=#{s.label}" end) |> Enum.join(", ")
    {:toast, :success, gettext("Command Executed"), "#{command_id}: #{sel_str}"}
  end

  # -- Helpers --

  defp context_data("products"), do: @products
  defp context_data("orders"), do: @orders
  defp context_data("users"), do: @users
  defp context_data("invoices"), do: @invoices
  defp context_data(_), do: []

  defp filter_items(data, query) do
    term = query |> to_string() |> String.trim()

    if term == "" do
      data
    else
      t = String.downcase(term)

      Enum.filter(data, fn item ->
        String.contains?(String.downcase(item[:title] || ""), t) or
          String.contains?(String.downcase(item[:subtitle] || item[:meta] || ""), t) or
          String.contains?(String.downcase(item[:badge] || ""), t)
      end)
    end
  end

  defp filter_options(options, query) do
    q = query |> to_string() |> String.trim() |> String.downcase()

    if q == "" do
      options
    else
      Enum.filter(options, fn opt ->
        String.contains?(String.downcase(opt[:label] || ""), q) or
          String.contains?(String.downcase(opt[:description] || ""), q) or
          (opt[:code] || "") == q
      end)
    end
  end

  @doc "Page size used by the demo palette (matches the component default)."
  def page_size, do: @page_size
end
