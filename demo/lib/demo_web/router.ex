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

  live_session :default, on_mount: [{DemoWeb.Nav, :default}], layout: {DemoWeb.Layouts, :app} do
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
      live("/components/buttons", Live.ButtonsLive, :index)
      live("/components/badges", Live.BadgesLive, :index)
      live("/components/alerts", Live.AlertsLive, :index)
      live("/components/cards", Live.CardsLive, :index)
      live("/components/tabs", Live.TabsLive, :index)
      live("/components/grid", Live.GridLive, :index)
      live("/components/inputs", Live.InputsLive, :index)
      live("/components/validations", Live.ValidationsLive, :index)
      live("/components/checkbox-lists", Live.CheckboxListsLive, :index)
      live("/components/modals", Live.ModalsLive, :index)
      live("/components/modal-dialogs", Live.ModalDialogsLive, :index)
      live("/components/popconfirm", Live.PopconfirmLive, :index)
      live("/components/command-palette", Live.CommandPaletteLive, :index)
      live("/search", Live.SearchLive, :index)
      live("/components/toasts", Live.ToastsLive, :index)
      live("/components/pagers", Live.PagersLive, :index)
      live("/components/tooltips", Live.TooltipsLive, :index)
      live("/components/loaders", Live.LoadersLive, :index)
      live("/components/lists", Live.ListsLive, :index)
      live("/components/callouts", Live.CalloutsLive, :index)
      live("/components/code", Live.CodeLive, :index)
      live("/components/data-display", Live.DataDisplayLive, :index)
      live("/components/data-display-2", Live.DataDisplay2Live, :index)
      live("/components/data-visualization", Live.DataVisualizationLive, :index)
      live("/components/detail-panel", Live.DetailPanelLive, :index)
      live("/components/stats", Live.StatsLive, :index)
      live("/components/typography", Live.TypographyLive, :index)
      live("/components/notifications", Live.NotificationsLive, :index)
      live("/components/sizing", Live.SizingLive, :index)
      live("/components/splitter", Live.SplitterLive, :index)
      live("/components/range-group", Live.RangeGroupLive, :index)
      live("/components/container-breakpoint", Live.ContainerBreakpointLive, :index)
      live("/components/sheet", Live.SheetLive, :index)
      live("/components/document", Live.DocumentLive, :index)

      # Responsivity
      live("/responsivity", Live.ResponsivityLive, :index)
      live("/components/fit-to-size", Live.FitToSizeLive, :index)
      live("/components/responsive-form", Live.ResponsiveFormLive, :index)

      # Design
      live("/design/colors", Live.ColorsLive, :index)
      live("/design/helpers", Live.HelpersLive, :index)
      live("/design/layouts", Live.LayoutsLive, :index)
      live("/design/theme-variables", Live.ThemeVariablesLive, :index)

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
