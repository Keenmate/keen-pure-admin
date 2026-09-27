/**
 * PureAdminSheetPrint hook — LiveView-idiomatic trigger for the vendored
 * single-element print helper (`sheet_print_core.js`, ported verbatim from
 * `@keenmate/pure-admin-core`).
 *
 * Core's print API is a pair of GLOBAL helpers (`pureAdmin.printElement` /
 * `pureAdmin.printSheet`), normally called from an inline `onclick`. LiveView
 * discourages inline handlers, so attach this hook to a print button instead:
 *
 *   <button phx-hook="PureAdminSheetPrint" data-print-title="Invoice 2026-0142">
 *     Print
 *   </button>
 *
 * On click it climbs to the enclosing `.pa-sheet` and prints it in isolation.
 * `data-print-title` sets the print-document title (the "Save as PDF" filename);
 * `data-print-target` (a CSS selector) overrides which element is printed.
 * The globals stay available for direct `pureAdmin.printSheet(this)` use too.
 */
import "./sheet_print_core"

export const PureAdminSheetPrint = {
  mounted() {
    this._onClick = (e) => {
      e.preventDefault()
      const pa = window.pureAdmin
      if (!pa || typeof pa.printSheet !== "function") return
      const title = this.el.getAttribute("data-print-title")
      const targetSel = this.el.getAttribute("data-print-target")
      const opts = title ? { title } : {}
      if (targetSel) {
        pa.printElement(targetSel, opts)
      } else {
        pa.printSheet(this.el, opts)
      }
    }
    this.el.addEventListener("click", this._onClick)
  },

  destroyed() {
    if (this._onClick) this.el.removeEventListener("click", this._onClick)
  }
}
