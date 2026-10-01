defmodule Mix.Tasks.Pa.Fidelity.Dump do
  @shortdoc "Render a component's fidelity scenarios to a dump file"

  @moduledoc """
  Markup-fidelity dumper — keen-pure-admin side (component-generic).

  Reads the core NEUTRAL fixture + this repo's `<component>.map.json`, maps each
  scenario's neutral props to the component's assigns via the map, renders via
  `Phoenix.LiveViewTest.render_component/2` (server markup, pre-JS-hook — the
  layer the core snippet describes), and writes a dump the core comparator diffs
  against the goldens.

      mix pa.fidelity.dump button
      mix pa.fidelity.dump card
        # → fidelity/keen-<component>.dump.json

  Base assigns (every declared attr's default + every slot ⇒ []) are seeded from
  the component's own `__components__/0` metadata, so a component with many slots
  needs no per-component wiring — only a `render/2` + `meta/1` clause below.

  Override paths with `--fixture` / `--map` / `--out`.
  """
  use Mix.Task

  # render_component/2 is a macro — import it so it expands around our runtime assigns.
  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias PureAdmin.Components.Alert
  alias PureAdmin.Components.Badge
  alias PureAdmin.Components.Button
  alias PureAdmin.Components.Callout
  alias PureAdmin.Components.Card
  alias PureAdmin.Components.CheckboxList
  alias PureAdmin.Components.DataDisplay
  alias PureAdmin.Components.DataViz
  alias PureAdmin.Components.FilterCard
  alias PureAdmin.Components.Loader
  alias PureAdmin.Components.Modal
  alias PureAdmin.Components.Pager
  alias PureAdmin.Components.Popconfirm
  alias PureAdmin.Components.Splitter
  alias PureAdmin.Components.Stat
  alias PureAdmin.Components.Timeline
  alias PureAdmin.Components.Toast
  alias PureAdmin.Components.Tooltip
  alias PureAdmin.Components.SettingsPanel
  alias PureAdmin.Components.Table
  alias PureAdmin.Components.Layout
  alias PureAdmin.Components.RangeGroup
  alias PureAdmin.Components.CommandPalette
  alias PureAdmin.Components.Profile
  alias PureAdmin.Components.Form
  alias PureAdmin.Components.KpiBento
  alias PureAdmin.Components.KpiStrip
  alias PureAdmin.Components.KpiEditorial
  alias PureAdmin.Components.KpiSparklineList
  # NOTE: PureAdmin.Components.Code / .List are NOT aliased — they'd shadow the
  # built-in Elixir `Code` / `List` modules (the task uses `List.first/1`).
  # Their render/meta clauses use the fully-qualified module name instead.

  @impl Mix.Task
  def run(args) do
    {opts, positional, _} =
      OptionParser.parse(args, strict: [fixture: :string, map: :string, out: :string])

    component = List.first(positional) || "button"

    fixture_path = opts[:fixture] || "../pure-admin/packages/core/fidelity/fixtures/#{component}.json"
    map_path = opts[:map] || "fidelity/#{component}.map.json"
    out_path = opts[:out] || "fidelity/keen-#{component}.dump.json"

    fixture = fixture_path |> File.read!() |> Jason.decode!()
    features = (map_path |> File.read!() |> Jason.decode!())["features"]
    meta = meta(component)

    dump =
      for scenario <- fixture["scenarios"] do
        html =
          scenario["props"]
          |> build_assigns(features, meta)
          |> render(component)

        %{name: scenario["name"], html: html}
      end

    out_path |> Path.dirname() |> File.mkdir_p!()
    File.write!(out_path, Jason.encode!(dump, pretty: true))
    Mix.shell().info("wrote #{length(dump)} scenarios -> #{out_path}")
  end

  # render_component/2 needs a literal &Mod.fun/1 (for its attr/slot default
  # handling), so dispatch per component with the literal capture.
  defp render(assigns, "button"), do: render_component(&Button.button/1, assigns)
  defp render(assigns, "card"), do: render_component(&Card.card/1, assigns)
  defp render(assigns, "badge"), do: render_component(&Badge.badge/1, assigns)
  defp render(assigns, "alert"), do: render_component(&Alert.alert/1, assigns)
  defp render(assigns, "callout"), do: render_component(&Callout.callout/1, assigns)
  defp render(assigns, "stat"), do: render_component(&Stat.stat/1, assigns)
  defp render(assigns, "tooltip"), do: render_component(&Tooltip.tooltip/1, assigns)
  defp render(assigns, "code"), do: render_component(&PureAdmin.Components.Code.code/1, assigns)
  defp render(assigns, "progress"), do: render_component(&DataViz.progress/1, assigns)
  defp render(assigns, "loader"), do: render_component(&Loader.loader/1, assigns)
  defp render(assigns, "timeline"), do: render_component(&Timeline.timeline/1, assigns)
  defp render(assigns, "list"), do: render_component(&PureAdmin.Components.List.list/1, assigns)
  defp render(assigns, "modal"), do: render_component(&Modal.modal/1, assigns)
  defp render(assigns, "popconfirm"), do: render_component(&Popconfirm.popconfirm/1, assigns)
  defp render(assigns, "pager"), do: render_component(&Pager.pager/1, assigns)
  defp render(assigns, "toast"), do: render_component(&Toast.toast/1, assigns)
  defp render(assigns, "data-bar"), do: render_component(&DataViz.data_bar/1, assigns)
  defp render(assigns, "stacked-bar"), do: render_component(&DataViz.stacked_bar/1, assigns)
  defp render(assigns, "heatmap"), do: render_component(&DataViz.heatmap/1, assigns)
  defp render(assigns, "splitter"), do: render_component(&Splitter.splitter/1, assigns)
  defp render(assigns, "checkbox-list"), do: render_component(&CheckboxList.checkbox_list/1, assigns)
  defp render(assigns, "filter-card"), do: render_component(&FilterCard.filter_card/1, assigns)
  defp render(assigns, "banded"), do: render_component(&DataDisplay.banded/1, assigns)
  defp render(assigns, "desc-table"), do: render_component(&DataDisplay.desc_table/1, assigns)
  defp render(assigns, "dot-leaders"), do: render_component(&DataDisplay.dot_leaders/1, assigns)
  defp render(assigns, "fields"), do: render_component(&DataDisplay.fields/1, assigns)
  defp render(assigns, "prop-card"), do: render_component(&DataDisplay.prop_card/1, assigns)
  defp render(assigns, "accent-grid"), do: render_component(&DataDisplay.accent_grid/1, assigns)
  defp render(assigns, "label"), do: render_component(&Badge.label/1, assigns)
  defp render(assigns, "composite-badge"), do: render_component(&Badge.composite_badge/1, assigns)
  defp render(assigns, "definition-list"), do: render_component(&PureAdmin.Components.List.definition_list/1, assigns)
  defp render(assigns, "gauge"), do: render_component(&DataViz.gauge/1, assigns)
  defp render(assigns, "settings-panel"), do: render_component(&SettingsPanel.settings_panel/1, assigns)
  defp render(assigns, "sparkline"), do: render_component(&DataViz.sparkline/1, assigns)
  defp render(assigns, "table"), do: render_component(&Table.table/1, assigns)
  defp render(assigns, "section"), do: render_component(&Layout.section/1, assigns)
  defp render(assigns, "range-group"), do: render_component(&RangeGroup.range_group/1, assigns)
  defp render(assigns, "table-card"), do: render_component(&Table.table_card/1, assigns)
  defp render(assigns, "command-palette"), do: render_component(&CommandPalette.command_palette/1, assigns)
  defp render(assigns, "profile"), do: render_component(&Profile.profile_panel/1, assigns)
  defp render(assigns, "input"), do: render_component(&Form.input/1, assigns)
  defp render(assigns, "kpi-bento"), do: render_component(&KpiBento.kpi_bento/1, assigns)
  defp render(assigns, "kpi-strip"), do: render_component(&KpiStrip.kpi_strip/1, assigns)
  defp render(assigns, "kpi-editorial"), do: render_component(&KpiEditorial.kpi_editorial/1, assigns)
  defp render(assigns, "kpi-sparkline-list"), do: render_component(&KpiSparklineList.kpi_sparkline_list/1, assigns)
  # Fragment fixtures — sub-components tested in isolation. (keen has no
  # card_tab_content counterpart — that fragment is svelte-only.)
  defp render(assigns, "card-tab"), do: render_component(&Card.card_tab/1, assigns)
  defp render(assigns, "list-item"), do: render_component(&PureAdmin.Components.List.list_item/1, assigns)
  defp render(assigns, "timeline-item"), do: render_component(&Timeline.timeline_item/1, assigns)

  defp meta("button"), do: PureAdmin.Components.Button.__components__()[:button]
  defp meta("card"), do: PureAdmin.Components.Card.__components__()[:card]
  defp meta("badge"), do: PureAdmin.Components.Badge.__components__()[:badge]
  defp meta("alert"), do: PureAdmin.Components.Alert.__components__()[:alert]
  defp meta("callout"), do: PureAdmin.Components.Callout.__components__()[:callout]
  defp meta("stat"), do: PureAdmin.Components.Stat.__components__()[:stat]
  defp meta("tooltip"), do: PureAdmin.Components.Tooltip.__components__()[:tooltip]
  defp meta("code"), do: PureAdmin.Components.Code.__components__()[:code]
  defp meta("progress"), do: PureAdmin.Components.DataViz.__components__()[:progress]
  defp meta("loader"), do: PureAdmin.Components.Loader.__components__()[:loader]
  defp meta("timeline"), do: PureAdmin.Components.Timeline.__components__()[:timeline]
  defp meta("list"), do: PureAdmin.Components.List.__components__()[:list]
  defp meta("modal"), do: PureAdmin.Components.Modal.__components__()[:modal]
  defp meta("popconfirm"), do: PureAdmin.Components.Popconfirm.__components__()[:popconfirm]
  defp meta("pager"), do: PureAdmin.Components.Pager.__components__()[:pager]
  defp meta("toast"), do: PureAdmin.Components.Toast.__components__()[:toast]
  defp meta("data-bar"), do: PureAdmin.Components.DataViz.__components__()[:data_bar]
  defp meta("stacked-bar"), do: PureAdmin.Components.DataViz.__components__()[:stacked_bar]
  defp meta("heatmap"), do: PureAdmin.Components.DataViz.__components__()[:heatmap]
  defp meta("splitter"), do: PureAdmin.Components.Splitter.__components__()[:splitter]
  defp meta("checkbox-list"), do: PureAdmin.Components.CheckboxList.__components__()[:checkbox_list]
  defp meta("filter-card"), do: PureAdmin.Components.FilterCard.__components__()[:filter_card]
  defp meta("banded"), do: PureAdmin.Components.DataDisplay.__components__()[:banded]
  defp meta("desc-table"), do: PureAdmin.Components.DataDisplay.__components__()[:desc_table]
  defp meta("dot-leaders"), do: PureAdmin.Components.DataDisplay.__components__()[:dot_leaders]
  defp meta("fields"), do: PureAdmin.Components.DataDisplay.__components__()[:fields]
  defp meta("prop-card"), do: PureAdmin.Components.DataDisplay.__components__()[:prop_card]
  defp meta("accent-grid"), do: PureAdmin.Components.DataDisplay.__components__()[:accent_grid]
  defp meta("label"), do: PureAdmin.Components.Badge.__components__()[:label]
  defp meta("composite-badge"), do: PureAdmin.Components.Badge.__components__()[:composite_badge]
  defp meta("definition-list"), do: PureAdmin.Components.List.__components__()[:definition_list]
  defp meta("gauge"), do: PureAdmin.Components.DataViz.__components__()[:gauge]
  defp meta("settings-panel"), do: PureAdmin.Components.SettingsPanel.__components__()[:settings_panel]
  defp meta("sparkline"), do: PureAdmin.Components.DataViz.__components__()[:sparkline]
  defp meta("table"), do: PureAdmin.Components.Table.__components__()[:table]
  defp meta("section"), do: PureAdmin.Components.Layout.__components__()[:section]
  defp meta("range-group"), do: PureAdmin.Components.RangeGroup.__components__()[:range_group]
  defp meta("table-card"), do: PureAdmin.Components.Table.__components__()[:table_card]
  defp meta("command-palette"), do: PureAdmin.Components.CommandPalette.__components__()[:command_palette]
  defp meta("profile"), do: PureAdmin.Components.Profile.__components__()[:profile_panel]
  defp meta("input"), do: PureAdmin.Components.Form.__components__()[:input]
  defp meta("kpi-bento"), do: PureAdmin.Components.KpiBento.__components__()[:kpi_bento]
  defp meta("kpi-strip"), do: PureAdmin.Components.KpiStrip.__components__()[:kpi_strip]
  defp meta("kpi-editorial"), do: PureAdmin.Components.KpiEditorial.__components__()[:kpi_editorial]
  defp meta("kpi-sparkline-list"), do: PureAdmin.Components.KpiSparklineList.__components__()[:kpi_sparkline_list]
  defp meta("card-tab"), do: PureAdmin.Components.Card.__components__()[:card_tab]
  defp meta("list-item"), do: PureAdmin.Components.List.__components__()[:list_item]
  defp meta("timeline-item"), do: PureAdmin.Components.Timeline.__components__()[:timeline_item]

  # Base assigns from the component's own metadata: every attr that declares a
  # default gets it, every slot defaults to []. Fully generic — no per-component
  # seed list to drift.
  defp base_assigns(meta) do
    attrs =
      for a <- meta.attrs, a.name != :rest, Keyword.has_key?(a.opts, :default), into: %{} do
        {a.name, a.opts[:default]}
      end

    slots = for s <- meta.slots, into: %{}, do: {s.name, []}
    Map.merge(attrs, slots)
  end

  # Neutral scenario props → keen assigns, driven by <component>.map.json.
  # kinds: slot (→ slot list), const (fixed value from a flag, e.g. keen's stat
  # ⇒ variant="stat"), bool (with optional `negate` + `channel:"rest"`), string
  # (optional `channel:"rest"` for globals), enum. `channel:"rest"` values ride
  # in the :global :rest map with STRING keys.
  defp build_assigns(props, features, meta) do
    base = base_assigns(meta)

    {assigns, rest} =
      Enum.reduce(props, {base, %{}}, fn {key, value}, {acc, rest} ->
        case features[key] do
          nil ->
            IO.warn(~s(scenario prop "#{key}" has no entry in the map — skipped))
            {acc, rest}

          %{"kind" => "slot", "prop" => prop} ->
            atom = String.to_atom(prop)
            {Map.put(acc, atom, text_slot(atom, value || "")), rest}

          %{"kind" => "const", "prop" => prop} = e ->
            if value, do: {Map.put(acc, String.to_atom(prop), e["value"]), rest}, else: {acc, rest}

          %{"kind" => "bool"} = e ->
            val = if e["negate"], do: !value, else: !!value

            if e["channel"] == "rest",
              do: {acc, maybe_put(rest, e["prop"], val)},
              else: {Map.put(acc, String.to_atom(e["prop"]), val), rest}

          %{"channel" => "rest", "prop" => prop} ->
            {acc, maybe_put(rest, prop, value)}

          %{"prop" => prop} ->
            {Map.put(acc, String.to_atom(prop), value), rest}
        end
      end)

    Map.put(assigns, :rest, rest)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, false), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp text_slot(name, text) do
    [%{__slot__: name, inner_block: fn _, _ -> text end}]
  end
end
