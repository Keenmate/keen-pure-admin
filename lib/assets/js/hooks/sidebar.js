/**
 * PureAdminSidebar — Sidebar toggle + drag-resize + mobile drawer.
 *
 * Handles:
 * - Desktop: toggles sidebar-hidden on body (full hide or icon-collapse)
 * - Mobile (<=768px): toggles sidebar-visible on body (off-canvas drawer)
 *   with an iOS-safe background scroll-lock + tap-scrim-to-dismiss
 * - Burger button active state synced with sidebar visibility
 * - Window resize: resets mobile/desktop state at the breakpoint
 * - localStorage persistence for desktop state
 * - Drag-to-resize: drives the vendored `sidebar_resize_core.js`
 *   (`pureAdmin.components.sidebarResize`) — a LiveView element takes only one
 *   phx-hook and the sidebar already uses this one, so resize is wired here
 *   rather than via a competing hook. No-ops unless `--resizable`.
 *
 * The resize module creates its own `.pc-sidebar-resize` handle (do NOT
 * server-render one — a pre-existing handle makes the module skip binding its
 * drag listeners). `init()` is idempotent and re-run on `updated()` so a handle
 * clobbered by a LiveView diff is recreated.
 *
 * Attach to the sidebar element:
 *   <.sidebar id="sidebar" />
 *
 * The burger button calls: phx-click={toggle_sidebar()}
 * which dispatches "pa:toggle_sidebar" to this hook's element.
 */
import { createLogger } from "../logger"
import "./sidebar_resize_core"

const log = createLogger('SIDEBAR')
const MOBILE_BREAKPOINT = 768

export const PureAdminSidebar = {
  mounted() {
    this._body = document.body
    this._burger = document.querySelector('.burger-menu')

    // Listen for toggle events from the burger button (via JS.dispatch)
    this.el.addEventListener("pa:toggle_sidebar", () => {
      this._toggle()
    })

    // Window resize: reset state at breakpoint
    this._lastMobile = this._isMobile()
    this._resizeHandler = () => this._onResize()
    window.addEventListener('resize', this._resizeHandler)

    // Tap outside the open mobile drawer (on the scrim) closes it. The backdrop
    // is a body::before pseudo-element, so a scrim tap reports .pc-layout (not
    // body) as target — use the "outside the panel" model, not target===body.
    this._outsideClick = (e) => this._onDocumentClick(e)
    document.addEventListener('click', this._outsideClick)

    // Drag-to-resize (no-op unless the sidebar carries --resizable).
    this._initResize()

    // Set initial state
    this._syncInitialState()

    log.debug('mounted, mobile:', this._isMobile())
  },

  updated() {
    // A LiveView diff can clobber the JS-created resize handle; init() re-adds
    // it (idempotent when the handle is still attached).
    this._initResize()
  },

  destroyed() {
    window.removeEventListener('resize', this._resizeHandler)
    document.removeEventListener('click', this._outsideClick)
    this._unlockBodyScroll()
  },

  _initResize() {
    const r = window.pureAdmin && window.pureAdmin.components && window.pureAdmin.components.sidebarResize
    if (r && typeof r.init === "function") r.init()
  },

  _isMobile() {
    return window.innerWidth <= MOBILE_BREAKPOINT
  },

  _toggle() {
    const isMobile = this._isMobile()
    const behavior = localStorage.getItem('sidebar-behavior') || 'hide'

    if (isMobile) {
      // Mobile: toggle the off-canvas drawer + lock/unlock background scroll
      const visible = this._body.classList.toggle('sidebar-visible')
      if (this._burger) this._burger.classList.toggle('active')
      if (visible) this._lockBodyScroll()
      else this._unlockBodyScroll()
      log.debug('mobile toggle, visible:', visible)
    } else {
      // Desktop: toggle sidebar-hidden
      const isHidden = this._body.classList.contains('sidebar-hidden')

      if (isHidden) {
        this._body.classList.remove('sidebar-hidden')
        if (this._burger) this._burger.classList.add('active')
      } else {
        this._body.classList.add('sidebar-hidden')
        if (this._burger) this._burger.classList.remove('active')
      }

      localStorage.setItem('sidebar-hidden', this._body.classList.contains('sidebar-hidden').toString())
      log.debug('desktop toggle, hidden:', this._body.classList.contains('sidebar-hidden'), 'behavior:', behavior)
    }
  },

  _closeMobileDrawer() {
    this._body.classList.remove('sidebar-visible')
    if (this._burger) this._burger.classList.remove('active')
    this._unlockBodyScroll()
  },

  _onDocumentClick(e) {
    if (!this._isMobile()) return
    if (!this._body.classList.contains('sidebar-visible')) return
    const t = e.target
    if (this.el.contains(t)) return // tap inside the drawer
    if (this._burger && this._burger.contains(t)) return // burger owns its own toggle
    this._closeMobileDrawer()
  },

  // iOS-safe background scroll-lock: pin <body> and restore scroll on release.
  // `body { overflow: hidden }` (core CSS) covers desktop/Android but iOS Safari
  // ignores it for touch, so we also fix the body position while the drawer is open.
  _lockBodyScroll() {
    if (this._scrollLocked) return
    this._scrollY = window.scrollY || window.pageYOffset || 0
    const sbw = window.innerWidth - document.documentElement.clientWidth
    if (sbw > 0) this._body.style.paddingInlineEnd = `${sbw}px` // avoid sideways reflow
    this._body.style.position = 'fixed'
    this._body.style.top = `-${this._scrollY}px`
    this._body.style.width = '100%'
    this._scrollLocked = true
  },

  _unlockBodyScroll() {
    if (!this._scrollLocked) return
    this._body.style.position = ''
    this._body.style.top = ''
    this._body.style.width = ''
    this._body.style.paddingInlineEnd = ''
    window.scrollTo(0, this._scrollY || 0)
    this._scrollLocked = false
  },

  _onResize() {
    const isMobile = this._isMobile()

    // Only act on breakpoint crossings
    if (isMobile === this._lastMobile) return
    this._lastMobile = isMobile

    if (isMobile) {
      // Entering mobile: remove desktop state, reset burger
      this._body.classList.remove('sidebar-hidden')
      this._body.classList.remove('sidebar-visible')
      if (this._burger) this._burger.classList.remove('active')
      this._unlockBodyScroll() // drawer is closed on cross-over
    } else {
      // Entering desktop: remove mobile state, restore from localStorage
      this._body.classList.remove('sidebar-visible')
      this._unlockBodyScroll()
      const sidebarHidden = localStorage.getItem('sidebar-hidden') === 'true'

      if (sidebarHidden) {
        this._body.classList.add('sidebar-hidden')
        if (this._burger) this._burger.classList.remove('active')
      } else {
        this._body.classList.remove('sidebar-hidden')
        if (this._burger) this._burger.classList.add('active')
      }
    }
  },

  _syncInitialState() {
    const isMobile = this._isMobile()

    if (isMobile) {
      // Mobile: sidebar hidden by default, burger shows hamburger
      this._body.classList.remove('sidebar-hidden')
      this._body.classList.remove('sidebar-visible')
      if (this._burger) this._burger.classList.remove('active')
    } else {
      // Desktop: body.sidebar-hidden is set from localStorage by the FOUC
      // prevention script. Sync the burger to it so it shows the X when the
      // sidebar is OPEN and the hamburger when it's hidden. Without this, a
      // fresh burger after a page navigation (the hook re-mounts) is always the
      // hamburger even when the restored sidebar is open.
      const isHidden = this._body.classList.contains('sidebar-hidden')
      if (this._burger) this._burger.classList.toggle('active', !isHidden)
    }
  }
}
