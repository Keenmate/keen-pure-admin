defmodule DemoWeb.Router do
  use DemoWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {DemoWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(DemoWeb.SessionPlug)
    plug(DemoWeb.Locale)
  end

  live_session :default,
    on_mount: [{DemoWeb.Nav, :default}, {PureAdmin.Dialog, :default}],
    layout: {DemoWeb.Layouts, :app} do
    scope "/", DemoWeb do
      pipe_through(:browser)

      # Locale switch — plain controller (LiveView can't write the Plug session)
      get("/locale/:code", LocaleController, :set)

      live("/", Live.DashboardLive, :index)
      live("/getting-started", Live.GettingStartedLive, :index)
      live("/forms", Live.FormsLive, :index)

      # Scratch structural-audit route — overwritten per-component to render one
      # component every documented way, for DOM-diffing against core snippets.
      live("/audit", Live.AuditLive, :index)

      # Components
      live("/components", Live.ComponentsOverviewLive, :index)
      live("/buttons", Live.ButtonsLive, :index)
      live("/interactive/badges", Live.BadgesLive, :index)
      live("/feedback/alerts", Live.AlertsLive, :index)
      live("/surfaces/cards", Live.CardsLive, :index)
      live("/surfaces/tabs", Live.TabsLive, :index)
      live("/layout/grid", Live.GridLive, :index)
      live("/forms/inputs", Live.InputsLive, :index)
      live("/forms/validations", Live.ValidationsLive, :index)
      live("/forms/checkbox-lists", Live.CheckboxListsLive, :index)
      live("/surfaces/modals", Live.ModalsLive, :index)
      live("/surfaces/modal-dialogs", Live.ModalDialogsLive, :index)
      live("/buttons/popconfirm", Live.PopconfirmLive, :index)
      live("/interactive/command-palette", Live.CommandPaletteLive, :index)
      live("/search", Live.SearchLive, :index)
      live("/feedback/toasts", Live.ToastsLive, :index)
      live("/buttons/pagers", Live.PagersLive, :index)
      live("/feedback/tooltips", Live.TooltipsLive, :index)
      live("/feedback/loaders", Live.LoadersLive, :index)
      live("/data-display/lists", Live.ListsLive, :index)
      live("/feedback/callouts", Live.CalloutsLive, :index)
      live("/data-display/code", Live.CodeLive, :index)
      live("/data-display", Live.DataDisplayLive, :index)
      live("/data-display/data-display-2", Live.DataDisplay2Live, :index)
      live("/data-viz", Live.DataVisualizationLive, :index)
      live("/surfaces/detail-panel", Live.DetailPanelLive, :index)
      live("/data-display/stats", Live.StatsLive, :index)
      live("/feedback/notifications", Live.NotificationsLive, :index)
      live("/layout/sizing", Live.SizingLive, :index)
      live("/surfaces/splitter", Live.SplitterLive, :index)
      live("/forms/range-group", Live.RangeGroupLive, :index)
      live("/layout/container-breakpoint", Live.ContainerBreakpointLive, :index)
      live("/data-display/sheet", Live.SheetLive, :index)
      live("/data-display/document", Live.DocumentLive, :index)

      # Responsivity
      live("/layout/responsivity", Live.ResponsivityLive, :index)
      live("/layout/fit-to-size", Live.FitToSizeLive, :index)
      live("/layout/responsive-form", Live.ResponsiveFormLive, :index)

      # Design
      live("/design/colors", Live.ColorsLive, :index)
      live("/design/icons", Live.IconPrimitivesLive, :index)
      live("/design/helpers", Live.HelpersLive, :index)
      live("/design/layouts", Live.LayoutsLive, :index)
      live("/design/theme-variables", Live.ThemeVariablesLive, :index)
      live("/design/typography", Live.TypographyLive, :index)

      # Tables
      live("/tables/standard", Live.TablesLive, :index)
      live("/tables/sizing", Live.TablesSizingLive, :index)
      live("/tables/responsive", Live.TablesResponsiveLive, :index)
      live("/tables/filters", Live.TableFiltersLive, :index)
      live("/tables/multi-select", Live.TableMultiSelectLive, :index)
      live("/tables/comparison", Live.TablesComparisonLive, :index)

      # Phoenix / LiveView
      live("/phoenix/core-components", Live.CoreComponentsLive, :index)
      live("/phoenix/flash", Live.FlashLive, :index)
      live("/phoenix/form-demo", Live.FormDemoLive, :index)
      live("/phoenix/icons", Live.IconsLive, :index)
      live("/phoenix/command-palette", Live.CommandPaletteGuideLive, :index)

      # Virtual Scroll
      live("/virtual-scroll/demo", Live.VirtualScrollLive, :index)

      # KPI
      live("/kpi/dashboard", Live.KpiDashboardLive, :index)
      live("/kpi/terminal-grid", Live.KpiTerminalGridLive, :index)
      live("/kpi/sparkline-list", Live.KpiSparklineListLive, :index)
      live("/kpi/comparison-gauges", Live.KpiComparisonGaugesLive, :index)
      live("/kpi/hero-supporting", Live.KpiHeroSupportingLive, :index)
      live("/kpi/bento", Live.KpiBentoLive, :index)
      live("/kpi/numeric-strip", Live.KpiNumericStripLive, :index)
      live("/kpi/editorial-minimal", Live.KpiEditorialMinimalLive, :index)

      # Timeline
      live("/timeline/simple", Live.TimelineSimpleLive, :index)
      live("/timeline/block", Live.TimelineBlockLive, :index)
      live("/timeline/advanced", Live.TimelineLive, :index)
      live("/timeline/feed", Live.TimelineFeedLive, :index)
    end
  end
end
