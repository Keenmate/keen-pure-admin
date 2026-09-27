defmodule PureAdmin.Components do
  @moduledoc """
  Bulk import macro for all PureAdmin components.

  Use this module as a full replacement for Phoenix's generated `CoreComponents`:

      # In your app's html_helpers or where you had:
      # import MyAppWeb.CoreComponents
      use PureAdmin.Components

  This imports all function components from every component module, giving you
  access to `button/1`, `badge/1`, `alert/1`, `card/1`, `modal/1`, `table/1`,
  `tabs/1`, `input/1`, `grid/1`, `layout/1`, and many more.
  """

  defmacro __using__(_opts) do
    quote do
      import PureAdmin.Components.Alert
      import PureAdmin.Components.Badge
      import PureAdmin.Components.Button
      import PureAdmin.Components.Callout
      import PureAdmin.Components.Card
      import PureAdmin.Components.Comparison
      import PureAdmin.Components.CommandPalette
      import PureAdmin.Components.CheckboxList
      import PureAdmin.Components.Code
      import PureAdmin.Components.DataDisplay
      import PureAdmin.Components.Document
      import PureAdmin.Components.FilterCard
      import PureAdmin.Components.Flash
      import PureAdmin.Components.DataViz
      import PureAdmin.Components.Faicon
      import PureAdmin.Components.Form
      import PureAdmin.Components.Grid
      import PureAdmin.Components.Heroicon
      import PureAdmin.Components.Icon
      import PureAdmin.Components.Kpi
      import PureAdmin.Components.KpiBento
      import PureAdmin.Components.KpiEditorial
      import PureAdmin.Components.KpiGaugeList
      import PureAdmin.Components.KpiHero
      import PureAdmin.Components.KpiSparklineList
      import PureAdmin.Components.KpiStrip
      import PureAdmin.Components.KpiTerminal
      import PureAdmin.Components.Layout
      import PureAdmin.Components.List
      import PureAdmin.Components.Loader
      import PureAdmin.Components.Modal
      import PureAdmin.Components.Navigation
      import PureAdmin.Components.Pager
      import PureAdmin.Components.Popconfirm
      import PureAdmin.Components.Profile
      import PureAdmin.Components.RangeGroup
      import PureAdmin.Components.Responsive
      import PureAdmin.Components.Sheet
      import PureAdmin.Components.Splitter
      import PureAdmin.Components.Stat
      import PureAdmin.Components.Table
      import PureAdmin.Components.Timeline
      import PureAdmin.Components.SettingsPanel
      import PureAdmin.Components.Toast
      import PureAdmin.Components.Tooltip
      import PureAdmin.Components.Typography
    end
  end
end
