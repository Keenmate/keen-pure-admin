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
  alias PureAdmin.Components.Navigation
  alias PureAdmin.Components.KpiGaugeList
  alias PureAdmin.Components.KpiHero
  alias PureAdmin.Components.Typography
  alias PureAdmin.Components.Grid
  alias PureAdmin.Components.Responsive
  alias PureAdmin.Components.Kpi
  alias PureAdmin.Components.KpiTerminal
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
  defp render(assigns, "navbar"), do: render_component(&Layout.navbar/1, assigns)
  defp render(assigns, "sidebar"), do: render_component(&Layout.sidebar/1, assigns)
  defp render(assigns, "footer"), do: render_component(&Layout.footer/1, assigns)
  defp render(assigns, "tabs"), do: render_component(&Navigation.tabs/1, assigns)
  defp render(assigns, "kpi-gauge-list"), do: render_component(&KpiGaugeList.kpi_gauge_list/1, assigns)
  defp render(assigns, "kpi-hero"), do: render_component(&KpiHero.kpi_hero_list/1, assigns)
  # Batch 12 (finish) — form family
  defp render(assigns, "textarea"), do: render_component(&Form.textarea/1, assigns)
  defp render(assigns, "select"), do: render_component(&Form.select/1, assigns)
  defp render(assigns, "checkbox"), do: render_component(&Form.checkbox/1, assigns)
  defp render(assigns, "radio"), do: render_component(&Form.radio/1, assigns)
  defp render(assigns, "form-group"), do: render_component(&Form.form_group/1, assigns)
  defp render(assigns, "form-label"), do: render_component(&Form.form_label/1, assigns)
  defp render(assigns, "form-help"), do: render_component(&Form.form_help/1, assigns)
  defp render(assigns, "input-group"), do: render_component(&Form.input_group/1, assigns)
  defp render(assigns, "checkbox-group"), do: render_component(&Form.checkbox_group/1, assigns)
  defp render(assigns, "radio-group"), do: render_component(&Form.radio_group/1, assigns)
  # Batch 12 — layout/shell family
  defp render(assigns, "app-header"), do: render_component(&Layout.app_header/1, assigns)
  defp render(assigns, "page-header"), do: render_component(&Layout.page_header/1, assigns)
  defp render(assigns, "main"), do: render_component(&Layout.main/1, assigns)
  defp render(assigns, "divider"), do: render_component(&Layout.divider/1, assigns)
  defp render(assigns, "layout"), do: render_component(&Layout.layout/1, assigns)
  defp render(assigns, "nav-menu"), do: render_component(&Layout.nav_menu/1, assigns)
  defp render(assigns, "nav-dropdown"), do: render_component(&Layout.nav_dropdown/1, assigns)
  defp render(assigns, "notifications"), do: render_component(&Layout.notifications/1, assigns)
  defp render(assigns, "profile-button"), do: render_component(&Layout.profile_button/1, assigns)
  defp render(assigns, "sidebar-search"), do: render_component(&Layout.sidebar_search/1, assigns)
  # Batch 12 — grid / typography / list / loader / data-viz / misc
  defp render(assigns, "grid"), do: render_component(&Grid.grid/1, assigns)
  defp render(assigns, "column"), do: render_component(&Grid.column/1, assigns)
  defp render(assigns, "heading"), do: render_component(&Typography.heading/1, assigns)
  defp render(assigns, "paragraph"), do: render_component(&Typography.paragraph/1, assigns)
  defp render(assigns, "text"), do: render_component(&Typography.text/1, assigns)
  defp render(assigns, "link"), do: render_component(&Typography.pa_link/1, assigns)
  defp render(assigns, "basic-list"), do: render_component(&PureAdmin.Components.List.basic_list/1, assigns)
  defp render(assigns, "ordered-list"), do: render_component(&PureAdmin.Components.List.ordered_list/1, assigns)
  defp render(assigns, "spinner"), do: render_component(&Loader.spinner/1, assigns)
  defp render(assigns, "loader-center"), do: render_component(&Loader.loader_center/1, assigns)
  defp render(assigns, "loader-overlay"), do: render_component(&Loader.loader_overlay/1, assigns)
  defp render(assigns, "progress-group"), do: render_component(&DataViz.progress_group/1, assigns)
  defp render(assigns, "progress-ring"), do: render_component(&DataViz.progress_ring/1, assigns)
  defp render(assigns, "button-group"), do: render_component(&Button.button_group/1, assigns)
  defp render(assigns, "split-button"), do: render_component(&Button.split_button/1, assigns)
  defp render(assigns, "badge-group"), do: render_component(&Badge.badge_group/1, assigns)
  defp render(assigns, "code-block"), do: render_component(&PureAdmin.Components.Code.code_block/1, assigns)
  defp render(assigns, "load-more"), do: render_component(&Pager.load_more/1, assigns)
  defp render(assigns, "table-container"), do: render_component(&Table.table_container/1, assigns)
  defp render(assigns, "popover"), do: render_component(&Tooltip.popover/1, assigns)
  defp render(assigns, "breakpoint-container"), do: render_component(&Responsive.breakpoint_container/1, assigns)
  # Fragment fixtures — sub-components tested in isolation. (keen has no
  # card_tab_content counterpart — that fragment is svelte-only.)
  defp render(assigns, "card-tab"), do: render_component(&Card.card_tab/1, assigns)
  defp render(assigns, "list-item"), do: render_component(&PureAdmin.Components.List.list_item/1, assigns)
  defp render(assigns, "timeline-item"), do: render_component(&Timeline.timeline_item/1, assigns)

  # KPI fragment fixtures — the per-tile / per-row sub-components the KPI
  # showcase containers defer, plus the terminal container itself.
  defp render(assigns, "kpi-tile"), do: render_component(&Kpi.kpi_tile/1, assigns)
  defp render(assigns, "kpi-detail"), do: render_component(&Kpi.kpi_detail/1, assigns)
  defp render(assigns, "kpi-sparkline"), do: render_component(&Kpi.kpi_sparkline/1, assigns)
  defp render(assigns, "kpi-bento-tile"), do: render_component(&KpiBento.kpi_bento_tile/1, assigns)
  defp render(assigns, "kpi-editorial-tile"), do: render_component(&KpiEditorial.kpi_editorial_tile/1, assigns)
  defp render(assigns, "kpi-strip-row"), do: render_component(&KpiStrip.kpi_strip_row/1, assigns)
  defp render(assigns, "kpi-sparkline-row"), do: render_component(&KpiSparklineList.kpi_sparkline_row/1, assigns)
  defp render(assigns, "kpi-hero-main"), do: render_component(&KpiHero.kpi_hero_main/1, assigns)
  defp render(assigns, "kpi-hero-side"), do: render_component(&KpiHero.kpi_hero_side/1, assigns)
  defp render(assigns, "kpi-gauge"), do: render_component(&KpiGaugeList.kpi_gauge/1, assigns)

  # kpi-terminal's :pane slot carries required attrs (id / label_text /
  # is_active) the generic text-slot path can't express. A `tabs` neutral
  # feature maps (keen side) to the throwaway bool assign `pane_demo`; when set,
  # we swap in two attributed demo panes so the tabs/tab/pane markup renders.
  defp render(assigns, "kpi-terminal") do
    assigns =
      if Map.get(assigns, :pane_demo) do
        assigns |> Map.delete(:pane_demo) |> Map.put(:pane, demo_panes())
      else
        Map.delete(assigns, :pane_demo)
      end

    render_component(&KpiTerminal.kpi_terminal/1, assigns)
  end

  defp demo_panes do
    [
      %{__slot__: :pane, id: "overview", label_text: "OVERVIEW", is_active: true, inner_block: fn _, _ -> "TILES" end},
      %{__slot__: :pane, id: "finance", label_text: "FINANCE", is_active: false, inner_block: fn _, _ -> "TILES" end}
    ]
  end

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
  defp meta("navbar"), do: PureAdmin.Components.Layout.__components__()[:navbar]
  defp meta("sidebar"), do: PureAdmin.Components.Layout.__components__()[:sidebar]
  defp meta("footer"), do: PureAdmin.Components.Layout.__components__()[:footer]
  defp meta("tabs"), do: PureAdmin.Components.Navigation.__components__()[:tabs]
  defp meta("kpi-gauge-list"), do: PureAdmin.Components.KpiGaugeList.__components__()[:kpi_gauge_list]
  defp meta("kpi-hero"), do: PureAdmin.Components.KpiHero.__components__()[:kpi_hero_list]
  defp meta("textarea"), do: PureAdmin.Components.Form.__components__()[:textarea]
  defp meta("select"), do: PureAdmin.Components.Form.__components__()[:select]
  defp meta("checkbox"), do: PureAdmin.Components.Form.__components__()[:checkbox]
  defp meta("radio"), do: PureAdmin.Components.Form.__components__()[:radio]
  defp meta("form-group"), do: PureAdmin.Components.Form.__components__()[:form_group]
  defp meta("form-label"), do: PureAdmin.Components.Form.__components__()[:form_label]
  defp meta("form-help"), do: PureAdmin.Components.Form.__components__()[:form_help]
  defp meta("input-group"), do: PureAdmin.Components.Form.__components__()[:input_group]
  defp meta("checkbox-group"), do: PureAdmin.Components.Form.__components__()[:checkbox_group]
  defp meta("radio-group"), do: PureAdmin.Components.Form.__components__()[:radio_group]
  defp meta("app-header"), do: PureAdmin.Components.Layout.__components__()[:app_header]
  defp meta("page-header"), do: PureAdmin.Components.Layout.__components__()[:page_header]
  defp meta("main"), do: PureAdmin.Components.Layout.__components__()[:main]
  defp meta("divider"), do: PureAdmin.Components.Layout.__components__()[:divider]
  defp meta("layout"), do: PureAdmin.Components.Layout.__components__()[:layout]
  defp meta("nav-menu"), do: PureAdmin.Components.Layout.__components__()[:nav_menu]
  defp meta("nav-dropdown"), do: PureAdmin.Components.Layout.__components__()[:nav_dropdown]
  defp meta("notifications"), do: PureAdmin.Components.Layout.__components__()[:notifications]
  defp meta("profile-button"), do: PureAdmin.Components.Layout.__components__()[:profile_button]
  defp meta("sidebar-search"), do: PureAdmin.Components.Layout.__components__()[:sidebar_search]
  defp meta("grid"), do: PureAdmin.Components.Grid.__components__()[:grid]
  defp meta("column"), do: PureAdmin.Components.Grid.__components__()[:column]
  defp meta("heading"), do: PureAdmin.Components.Typography.__components__()[:heading]
  defp meta("paragraph"), do: PureAdmin.Components.Typography.__components__()[:paragraph]
  defp meta("text"), do: PureAdmin.Components.Typography.__components__()[:text]
  defp meta("link"), do: PureAdmin.Components.Typography.__components__()[:pa_link]
  defp meta("basic-list"), do: PureAdmin.Components.List.__components__()[:basic_list]
  defp meta("ordered-list"), do: PureAdmin.Components.List.__components__()[:ordered_list]
  defp meta("spinner"), do: PureAdmin.Components.Loader.__components__()[:spinner]
  defp meta("loader-center"), do: PureAdmin.Components.Loader.__components__()[:loader_center]
  defp meta("loader-overlay"), do: PureAdmin.Components.Loader.__components__()[:loader_overlay]
  defp meta("progress-group"), do: PureAdmin.Components.DataViz.__components__()[:progress_group]
  defp meta("progress-ring"), do: PureAdmin.Components.DataViz.__components__()[:progress_ring]
  defp meta("button-group"), do: PureAdmin.Components.Button.__components__()[:button_group]
  defp meta("split-button"), do: PureAdmin.Components.Button.__components__()[:split_button]
  defp meta("badge-group"), do: PureAdmin.Components.Badge.__components__()[:badge_group]
  defp meta("code-block"), do: PureAdmin.Components.Code.__components__()[:code_block]
  defp meta("load-more"), do: PureAdmin.Components.Pager.__components__()[:load_more]
  defp meta("table-container"), do: PureAdmin.Components.Table.__components__()[:table_container]
  defp meta("popover"), do: PureAdmin.Components.Tooltip.__components__()[:popover]
  defp meta("breakpoint-container"), do: PureAdmin.Components.Responsive.__components__()[:breakpoint_container]
  defp meta("card-tab"), do: PureAdmin.Components.Card.__components__()[:card_tab]
  defp meta("list-item"), do: PureAdmin.Components.List.__components__()[:list_item]
  defp meta("timeline-item"), do: PureAdmin.Components.Timeline.__components__()[:timeline_item]
  defp meta("kpi-terminal"), do: PureAdmin.Components.KpiTerminal.__components__()[:kpi_terminal]
  defp meta("kpi-tile"), do: PureAdmin.Components.Kpi.__components__()[:kpi_tile]
  defp meta("kpi-detail"), do: PureAdmin.Components.Kpi.__components__()[:kpi_detail]
  defp meta("kpi-sparkline"), do: PureAdmin.Components.Kpi.__components__()[:kpi_sparkline]
  defp meta("kpi-bento-tile"), do: PureAdmin.Components.KpiBento.__components__()[:kpi_bento_tile]
  defp meta("kpi-editorial-tile"), do: PureAdmin.Components.KpiEditorial.__components__()[:kpi_editorial_tile]
  defp meta("kpi-strip-row"), do: PureAdmin.Components.KpiStrip.__components__()[:kpi_strip_row]
  defp meta("kpi-sparkline-row"), do: PureAdmin.Components.KpiSparklineList.__components__()[:kpi_sparkline_row]
  defp meta("kpi-hero-main"), do: PureAdmin.Components.KpiHero.__components__()[:kpi_hero_main]
  defp meta("kpi-hero-side"), do: PureAdmin.Components.KpiHero.__components__()[:kpi_hero_side]
  defp meta("kpi-gauge"), do: PureAdmin.Components.KpiGaugeList.__components__()[:kpi_gauge]

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
