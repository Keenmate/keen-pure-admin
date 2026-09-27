/**
 * PureAdmin - Phoenix LiveView hooks for Pure Admin components.
 *
 * Usage in app.js:
 *
 *   import { PureAdminHooks } from "../deps/keen_pure_admin/assets/js/keen_pure_admin"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { ...PureAdminHooks } })
 */

// Stage C: the `window.pureCss` FOUNDATION runtime (events / viewport / device /
// config / components) — the app-shell engines (fit / navbar-dropdown /
// sidebar-resize / container-breakpoint) moved DOWN into @keenmate/pure-css and
// register on window.pureCss, so it must exist FIRST.
import "./hooks/pure_css_core"
// rc11: the shared `window.pureAdmin` namespace facade (events / viewport /
// config / debug / menus / components). ADOPTS the pureCss buses by reference so
// window.pureAdmin.components.fit resolves the engine registered on window.pureCss.
// Imported after pure_css_core; each *_core module also self-creates the
// namespace defensively, but this installs the once-only parts.
import "./hooks/pure_admin_core"

import { PureAdminTooltip } from "./hooks/tooltip"
import { PureAdminPopover } from "./hooks/popover"
import { PureAdminToast } from "./hooks/toast"
import { PureAdminCommandPalette } from "./hooks/command_palette"
import { PureAdminDetailPanel } from "./hooks/detail_panel"
import { PureAdminSidebarResize } from "./hooks/sidebar_resize"
import { PureAdminSettings } from "./hooks/settings_panel"
import { PureAdminProfilePanel } from "./hooks/profile_panel"
import { PureAdminCharCounter } from "./hooks/char_counter"
import { PureAdminCheckbox } from "./hooks/checkbox"
import { PureAdminSplitButton } from "./hooks/split_button"
import { PureAdminOverflow } from "./hooks/overflow"
import { PureAdminCardActionsOverflow } from "./hooks/card_actions_overflow"
import { PureAdminSplitter } from "./hooks/splitter"
import { PureAdminStatFit } from "./hooks/pa_stat_fit"
import { PureAdminRangeGroup } from "./hooks/range_group"
import { PureAdminSidebarSubmenu } from "./hooks/sidebar_submenu"
import { PureAdminNavFitCollapse } from "./hooks/navbar_fit_collapse"
import { PureAdminNavDropdown } from "./hooks/navbar_dropdown"
import { PureAdminNavFit } from "./hooks/navbar_fit"
import { PureAdminContainerBreakpoint } from "./hooks/container_breakpoint"
import { PureAdminKpiTile } from "./hooks/kpi_tile"
import { PureAdminKpiSparkDot } from "./hooks/kpi_spark_dot"
import { PureAdminKpiTerminalTabs } from "./hooks/kpi_terminal_tabs"
import { PureAdminSheetPrint } from "./hooks/sheet_print"
import { getPageContext, getContextValue, clearContextCache } from "./page-context"
import { enableLogging, disableLogging, setLogLevel, setCategoryLevel, getCategories, createLogger } from "./logger"
import { PureAdminFlash } from "./hooks/flash"
import { PureAdminSidebar } from "./hooks/sidebar"
import { PureAdminInfiniteScroll } from "./hooks/infinite_scroll"
import { initModalDialogs } from "./modal_dialogs"
import { initPureAdminEvents } from "./events"

// Global event listeners for component JS commands
window.addEventListener("kpa:clipboard-copy", (e) => {
  if (!e.detail || !e.detail.text) return
  navigator.clipboard.writeText(e.detail.text)

  // Visual feedback: swap the masked copy glyph to a checkmark briefly.
  const btn = e.target.closest(".pa-comparison-table__copy")
  if (!btn) return
  const icon = btn.querySelector(".pa-icon")
  if (!icon) return
  icon.classList.remove("pa-icon--copy")
  icon.classList.add("pa-icon--check")
  setTimeout(() => {
    icon.classList.remove("pa-icon--check")
    icon.classList.add("pa-icon--copy")
  }, 1000)
})

// rc11 gates layout transitions (mobile drawer slide + backdrop fade, sidebar
// link/chevron transitions) behind `body.loaded` so nothing animates on the
// first paint. Nothing else sets it, so set it once shortly after load.
if (typeof document !== "undefined") {
  const markLoaded = () => document.body && document.body.classList.add("loaded")
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => setTimeout(markLoaded, 50))
  } else {
    setTimeout(markLoaded, 50)
  }
}

export const PureAdminHooks = {
  PureAdminFlash,
  PureAdminSidebar,
  PureAdminTooltip,
  PureAdminPopover,
  PureAdminToast,
  PureAdminCommandPalette,
  PureAdminDetailPanel,
  PureAdminSidebarResize,
  PureAdminSettings,
  PureAdminProfilePanel,
  PureAdminCharCounter,
  PureAdminCheckbox,
  PureAdminSplitButton,
  PureAdminOverflow,
  PureAdminCardActionsOverflow,
  PureAdminSplitter,
  PureAdminStatFit,
  PureAdminRangeGroup,
  PureAdminSidebarSubmenu,
  PureAdminNavFitCollapse,
  PureAdminNavDropdown,
  PureAdminNavFit,
  PureAdminContainerBreakpoint,
  PureAdminInfiniteScroll,
  PureAdminKpiTile,
  PureAdminKpiSparkDot,
  PureAdminKpiTerminalTabs,
  PureAdminSheetPrint,
}

export {
  getPageContext,
  getContextValue,
  clearContextCache,
  enableLogging,
  disableLogging,
  setLogLevel,
  setCategoryLevel,
  getCategories,
  createLogger,
  PureAdminFlash,
  PureAdminSidebar,
  PureAdminTooltip,
  PureAdminPopover,
  PureAdminToast,
  PureAdminCommandPalette,
  PureAdminDetailPanel,
  PureAdminSidebarResize,
  PureAdminSettings,
  PureAdminProfilePanel,
  PureAdminCharCounter,
  PureAdminCheckbox,
  PureAdminSplitButton,
  PureAdminOverflow,
  PureAdminCardActionsOverflow,
  PureAdminSplitter,
  PureAdminStatFit,
  PureAdminRangeGroup,
  PureAdminSidebarSubmenu,
  PureAdminNavFitCollapse,
  PureAdminNavDropdown,
  PureAdminNavFit,
  PureAdminContainerBreakpoint,
  PureAdminInfiniteScroll,
  PureAdminKpiTile,
  PureAdminKpiSparkDot,
  PureAdminKpiTerminalTabs,
  PureAdminSheetPrint,
  initModalDialogs,
  initPureAdminEvents,
}
