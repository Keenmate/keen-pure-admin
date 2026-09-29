/**
 * PureAdminToast - Toast notification system.
 *
 * Attach to a toast container element. The server triggers toasts via push_event,
 * and the client handles rendering, auto-dismiss, and close button — no server
 * round-trips for display/dismiss.
 *
 * Server usage (in LiveView):
 *
 *   push_toast(socket, "success", "Saved!", "Changes saved.")
 *   push_toast(socket, "danger", "Error", "Failed.", duration: 0)
 *   push_toast(socket, "info", "Note", "FYI", progress: true, filled: true)
 *   push_toast(socket, "warning", "Confirm", "Delete?",
 *     actions: [
 *       %{label: "Undo", event: "undo", params: %{id: 1}, variant: "warning"},
 *       %{label: "Dismiss", dismiss: true}
 *     ])
 *
 * Template:
 *
 *   <.toast_container id="toasts" position="top-end" is_hook />
 *
 * Multiple containers can exist for different positions. Each container only
 * shows toasts matching its position (from data-position attr).
 */
export const PureAdminToast = {
  mounted() {
    this._toastId = 0
    this._position = this.el.dataset.position || 'top-end'

    this.handleEvent("toast", (toast) => {
      const position = toast.position || 'top-end'
      if (position !== this._position) return

      this._showToast(toast)
    })

    // Also support adding toasts from other hooks/JS via custom event
    this.el.addEventListener("pa:toast", (e) => {
      this._showToast(e.detail)
    })
  },

  _showToast(toast) {
    const id = `pa-toast-${this._position}-${this._toastId++}`
    const variant = toast.variant || 'info'
    const title = toast.title || ''
    const message = toast.message || ''
    const duration = toast.duration !== undefined ? toast.duration : 5000
    const filled = toast.filled || false
    const progress = toast.progress || false
    const progressColor = toast.progress_color || null
    const maxWidth = toast.max_width || null
    const actions = toast.actions || []

    const variantClass = filled ? `pa-toast--filled-${variant}` : `pa-toast--${variant}`
    const el = document.createElement('div')
    el.id = id
    el.className = `pa-toast ${variantClass} pa-toast--show`
    if (maxWidth) el.style.maxWidth = maxWidth

    // Build progress bar HTML
    const progressStyle = progressColor
      ? `width: 100%; color: ${progressColor};`
      : 'width: 100%;'
    const progressHtml = progress && duration > 0
      ? `<div class="pa-toast__progress" style="${progressStyle}"></div>`
      : ''

    el.innerHTML = `
      <div class="pa-toast__content">
        ${title ? `<div class="pa-toast__title">${this._escapeHtml(title)}</div>` : ''}
        ${message ? `<div class="pa-toast__message">${this._escapeHtml(message)}</div>` : ''}
      </div>
      <button class="pa-toast__close" aria-label="Close">
        <span class="pa-icon pa-icon--x" aria-hidden="true"></span>
      </button>
      ${progressHtml}
    `

    // Close button
    el.querySelector('.pa-toast__close').addEventListener('click', () => {
      this._dismissToast(el)
    })

    // Action buttons: build each as a DOM element and capture the action
    // object via closure — no JSON round-trip through data-attributes.
    if (actions.length > 0) {
      const actionsWrap = document.createElement('div')
      actionsWrap.className = 'pa-toast__actions'
      for (const action of actions) {
        const btn = document.createElement('button')
        btn.type = 'button'
        btn.className = `pa-btn pa-btn--xs pa-btn--${action.variant || 'secondary'}`
        btn.textContent = action.label || 'Action'
        btn.addEventListener('click', (e) => {
          e.stopPropagation()
          if (action.event) this.pushEvent(action.event, action.params || {})
          if (action.dismiss !== false) this._dismissToast(el)
        })
        actionsWrap.appendChild(btn)
      }
      el.querySelector('.pa-toast__content').appendChild(actionsWrap)
    } else {
      // Toasts without actions are click-to-dismiss
      el.style.cursor = 'pointer'
      el.addEventListener('click', () => this._dismissToast(el))
    }

    this.el.appendChild(el)

    // Ratchet: lock container to its peak width
    requestAnimationFrame(() => {
      const currentWidth = this.el.offsetWidth
      const peakWidth = parseInt(this.el.dataset.peakWidth || '0', 10)
      if (currentWidth > peakWidth) {
        this.el.dataset.peakWidth = currentWidth
        this.el.style.minWidth = currentWidth + 'px'
      }
    })

    // Progress bar animation
    if (progress && duration > 0) {
      const progressEl = el.querySelector('.pa-toast__progress')
      if (progressEl) {
        progressEl.style.transition = `width ${duration}ms linear`
        setTimeout(() => { progressEl.style.width = '0%' }, 50)
      }
    }

    // Auto-dismiss
    if (duration > 0) {
      setTimeout(() => this._dismissToast(el), duration)
    }
  },

  _dismissToast(el) {
    if (!el || !el.parentNode) return
    el.classList.remove('pa-toast--show')
    el.classList.add('pa-toast--hide')
    setTimeout(() => {
      if (el.parentNode) {
        const container = el.parentNode
        container.removeChild(el)

        // Reset peak width when container is empty
        if (!container.querySelector('.pa-toast')) {
          container.style.minWidth = ''
          container.dataset.peakWidth = '0'
        }
      }
    }, 300)
  },

  _escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
