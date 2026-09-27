defmodule DemoWeb.Live.SearchLive do
  @moduledoc """
  Destination page for the rc15 type-and-go search forms (navbar/sidebar
  `--input`). Reads `?q=` from the native GET submit and renders the matches with
  `search_results/1` across all four presets — the page-level counterpart to the
  `.pa-search-autocomplete` dropdown.
  """
  use DemoWeb, :live_view

  # A tiny mixed corpus (pages / products / people) so the grouped preset has
  # something to bucket. Each row is the map `search_results/1` consumes.
  @corpus [
    %{
      id: "d1",
      group: "pages",
      type: "Page",
      icon: "📄",
      href: "/getting-started",
      title: "Getting started with widgets",
      snippet: "A step-by-step guide covering setup, configuration, and troubleshooting for teams of any size.",
      meta: ["Docs / Guides", "Updated 2 days ago"]
    },
    %{
      id: "d2",
      group: "pages",
      type: "Page",
      icon: "📄",
      href: "/components/tables",
      title: "Working with data tables",
      snippet: "Sort, filter, paginate, and make tables responsive on small screens.",
      meta: ["Docs / Components", "Updated 1 week ago"]
    },
    %{
      id: "d3",
      group: "pages",
      type: "Page",
      icon: "📄",
      href: "/design/theme-variables",
      title: "Theming and design tokens",
      snippet: "Customise colours, spacing, and typography with CSS variables.",
      meta: ["Docs / Design"]
    },
    %{
      id: "p1",
      group: "products",
      type: "Product",
      icon: "📦",
      href: "#",
      title: "Widget Pro subscription",
      snippet: "Priority support, unlimited seats, and advanced widget analytics.",
      meta: ["$49 / mo"]
    },
    %{
      id: "p2",
      group: "products",
      type: "Product",
      icon: "📦",
      href: "#",
      title: "Widget Starter kit",
      snippet: "Everything a small team needs to ship its first widgets.",
      meta: ["$0 / mo"]
    },
    %{
      id: "u1",
      group: "people",
      type: "Person",
      icon: "👤",
      href: "#",
      title: "Jane Widget",
      snippet: "Product designer — owns the widget component library.",
      meta: ["jane@example.com", "Design"]
    },
    %{
      id: "u2",
      group: "people",
      type: "Person",
      icon: "👤",
      href: "#",
      title: "John Doe",
      snippet: "Backend engineer working on the search indexing pipeline.",
      meta: ["john@example.com", "Platform"]
    }
  ]

  @groups [
    %{id: "pages", label: "Pages"},
    %{id: "products", label: "Products"},
    %{id: "people", label: "People"}
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Search", groups: @groups)}
  end

  def handle_params(params, _uri, socket) do
    query = params["q"] || ""
    results = filter(query)

    {:noreply,
     socket
     |> assign(:query, query)
     |> assign(:results, results)
     |> assign(:highlighted, Enum.map(results, &highlight(&1, query)))}
  end

  # Case-insensitive substring match over the title + snippet.
  defp filter(""), do: @corpus

  defp filter(query) do
    needle = String.downcase(query)

    Enum.filter(@corpus, fn r ->
      String.contains?(String.downcase(r.title), needle) or
        String.contains?(String.downcase(r.snippet), needle)
    end)
  end

  # Wrap every case-insensitive match in the canonical <mark> so the `detailed`
  # preset can render it via `allow_html` — the shape a backend (Elasticsearch
  # highlight / Postgres ts_headline) returns.
  defp highlight(result, ""), do: result

  defp highlight(result, query) do
    %{result | title: mark(result.title, query), snippet: mark(result.snippet, query)}
  end

  defp mark(text, query) do
    Regex.replace(~r/#{Regex.escape(query)}/i, text, fn m ->
      ~s(<mark class="pa-search-results__mark">#{m}</mark>)
    end)
  end

  def render(assigns) do
    ~H"""
    <.paragraph>
      The destination the rc15 type-and-go search forms submit to (enable
      <strong>Navbar / Sidebar — type-and-go form</strong> in
      Settings → Search Box, then press Enter). This page renders
      <code>&lt;.search_results&gt;</code> — the page-level counterpart to the
      autocomplete dropdown.
    </.paragraph>

    <.card title_text="Query">
      <form action="/search" method="get" role="search" class="pc-navbar-search pc-navbar-search--input">
        <span class="pc-navbar-search__icon" aria-hidden="true"></span>
        <input
          type="search"
          name="q"
          value={@query}
          class="pc-navbar-search__field"
          placeholder="Try “widget”…"
          autocomplete="off"
          aria-label="Search"
        />
      </form>
      <.paragraph :if={@query != ""}>
        <strong>{length(@results)}</strong> result(s) for <strong>“{@query}”</strong>.
      </.paragraph>
    </.card>

    <.card title_text="detailed — with backend <mark> highlight (allow_html)">
      <.search_results results={@highlighted} variant="detailed" allow_html empty_text="No matches — try “widget”." />
    </.card>

    <.card title_text="grouped — bucketed by category">
      <.search_results results={@results} variant="grouped" groups={@groups} empty_text="No matches." />
    </.card>

    <.card title_text="compact — dense one-liners">
      <.search_results results={@results} variant="compact" empty_text="No matches." />
    </.card>

    <.card title_text="cards — responsive grid">
      <.search_results results={@results} variant="cards" empty_text="No matches." />
    </.card>
    """
  end
end
