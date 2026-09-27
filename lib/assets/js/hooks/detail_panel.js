/**
 * PureAdminDetailPanel hook — Resizable detail-panel divider.
 *
 * Mirrors the JS contract documented in `pure-admin/snippets/detail-panel.html`:
 *
 * - Drag the `.pa-detail-panel-resize` handle (a child of the panel) to
 *   resize the panel.
 * - The width is written to the `--pa-local-detail-panel-width` CSS
 *   custom property on `<html>`, so any panel reading
 *   `width: var(--pa-local-detail-panel-width)` follows the change.
 * - During the drag, `pa-detail-panel-resizing` is added to `<body>` to
 *   suppress text selection, and `pa-detail-panel-resize--active` to the
 *   handle for cursor styling.
 * - Direction is inverted in RTL so dragging toward the inline-start
 *   widens the panel on the inline-end (the natural feel).
 * - Width is clamped to a 200 px minimum.
 *
 * Attach via `phx-hook="PureAdminDetailPanel"` on the `.pa-detail-view__panel`
 * (or `.pa-detail-panel__content`) wrapper that owns the handle. The hook
 * locates the handle inside `this.el`.
 */
const MIN_WIDTH = 200

export const PureAdminDetailPanel = {
  mounted() {
    const handle = this.el.querySelector(".pa-detail-panel-resize")
    if (!handle) return

    this._handle = handle
    this._onMouseDown = (event) => startDrag(event, this.el, handle)
    handle.addEventListener("mousedown", this._onMouseDown)
  },

  destroyed() {
    if (this._handle && this._onMouseDown) {
      this._handle.removeEventListener("mousedown", this._onMouseDown)
    }
  },
}

function startDrag(event, panel, handle) {
  const startX = event.clientX
  const startWidth = panel.getBoundingClientRect().width
  document.body.classList.add("pa-detail-panel-resizing")
  handle.classList.add("pa-detail-panel-resize--active")

  const onMove = (moveEvent) => {
    // Drag toward inline-start widens panel on inline-end; invert in RTL.
    const dir = document.documentElement.dir === "rtl" ? +1 : -1
    const next = Math.max(MIN_WIDTH, startWidth + dir * (moveEvent.clientX - startX))
    document.documentElement.style.setProperty("--pa-local-detail-panel-width", `${next}px`)
  }

  const onUp = () => {
    document.body.classList.remove("pa-detail-panel-resizing")
    handle.classList.remove("pa-detail-panel-resize--active")
    document.removeEventListener("mousemove", onMove)
    document.removeEventListener("mouseup", onUp)
  }

  document.addEventListener("mousemove", onMove)
  document.addEventListener("mouseup", onUp)
}
