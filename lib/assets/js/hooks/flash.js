/**
 * PureAdminFlash - Independent inline flash message system.
 *
 * Renders flash messages as pa-alert elements inside a container.
 * Multiple containers can exist on the same page, each receiving
 * messages independently via push_flash/5.
 *
 * Supports markdown body (bold, italic, links, lists, paragraphs)
 * and action buttons that push events back to the server.
 *
 * Server usage (in LiveView):
 *
 *   push_flash(socket, "my-form", "success", "Saved!")
 *   push_flash(socket, "my-form", "danger", "Failed.", title: "Error")
 *   push_flash(socket, "my-form", "info", "Gone soon", duration: 5000)
 *
 *   push_flash(socket, "my-form", "info", """
 *   A new version is available. This update includes:
 *
 *   - Performance improvements
 *   - Bug fixes
 *   """, title: "System Update",
 *     actions: [
 *       %{label: "Update Now", event: "do-update", params: %{id: 1}, variant: "primary"},
 *       %{label: "Cancel", dismiss: true, variant: "secondary"}
 *     ])
 *
 * Template:
 *
 *   <.flash_container id="my-form" />
 */
export const PureAdminFlash = {
  mounted() {
    this._flashId = 0
    this._containerId = this.el.dataset.containerId

    this.handleEvent("pa:flash", (flash) => {
      if (flash.container !== this._containerId) return
      if (flash.replace) this._clearAll()
      this._showFlash(flash)
    })

    this.handleEvent("pa:flash-clear", ({container}) => {
      if (container !== this._containerId) return
      this._clearAll()
    })

    // Support adding flashes from other hooks/JS via custom event
    this.el.addEventListener("pa:flash", (e) => {
      if (e.detail && e.detail.replace) this._clearAll()
      this._showFlash(e.detail)
    })
  },

  _clearAll() {
    // Skip the fade — replacement should feel instant.
    while (this.el.firstChild) this.el.removeChild(this.el.firstChild)
  },

  _showFlash(flash) {
    const id = `pa-flash-${this._containerId}-${this._flashId++}`
    const variant = flash.variant || 'info'
    const message = flash.message || ''
    const title = flash.title || ''
    const duration = flash.duration !== undefined ? flash.duration : 0
    const dismissible = flash.dismissible !== undefined ? flash.dismissible : true
    const actions = flash.actions || []

    const el = document.createElement('div')
    el.id = id
    el.className = `pa-alert pa-alert--${variant}${dismissible ? ' pa-alert--dismissible' : ''}`
    el.setAttribute('role', 'alert')

    let contentHtml = ''

    if (title) {
      contentHtml += `<h4 class="pa-alert__heading">${this._escapeHtml(title)}</h4>`
    }

    contentHtml += this._renderMarkdown(message)

    // Severity icon: the SSR flash/1 leads with pa-alert__icon; mirror it here so
    // the hook path (the demo's actual path) isn't an off-contract icon-less alert.
    // Normalise to the masked set (error -> danger; unknown -> info).
    const iconVariant =
      variant === 'error' ? 'danger' : ['success', 'danger', 'warning', 'info'].includes(variant) ? variant : 'info'

    let html =
      `<span class="pa-alert__icon"><span class="pa-icon pa-icon--${iconVariant}" aria-hidden="true"></span></span>` +
      `<div class="pa-alert__content">${contentHtml}</div>`

    if (dismissible) {
      html += `<button class="pa-alert__close" aria-label="Close"><span class="pa-icon pa-icon--x" aria-hidden="true"></span></button>`
    }

    el.innerHTML = html

    // Close button handler
    if (dismissible) {
      el.querySelector('.pa-alert__close').addEventListener('click', () => {
        this._dismissFlash(el)
      })
    }

    // Action buttons: build each as a DOM element and capture the action
    // object via closure — no JSON round-trip through data-attributes, so
    // there's no attribute-escape attack surface.
    if (actions.length > 0) {
      const actionsWrap = document.createElement('div')
      actionsWrap.className = 'pa-alert__actions'
      for (const action of actions) {
        const btn = document.createElement('button')
        btn.type = 'button'
        btn.className = `pa-btn pa-btn--sm pa-btn--${action.variant || 'secondary'}`
        btn.textContent = action.label || 'Action'
        btn.addEventListener('click', () => {
          if (action.dismiss) this._dismissFlash(el)
          if (action.event) this.pushEvent(action.event, action.params || {})
        })
        actionsWrap.appendChild(btn)
      }
      el.querySelector('.pa-alert__content').appendChild(actionsWrap)
    }

    this.el.appendChild(el)

    if (duration > 0) {
      setTimeout(() => this._dismissFlash(el), duration)
    }
  },

  _dismissFlash(el) {
    if (!el || !el.parentNode) return
    el.style.opacity = '0'
    el.style.transition = 'opacity 300ms'
    setTimeout(() => {
      if (el.parentNode) el.parentNode.removeChild(el)
    }, 300)
  },

  /**
   * Minimal markdown renderer.
   * Supports: **bold**, *italic*, [links](url), unordered lists (- item),
   * ordered lists (1. item), and paragraphs (blank-line separated).
   */
  _renderMarkdown(text) {
    if (!text) return ''

    const lines = text.split('\n')
    let html = ''
    let inUl = false
    let inOl = false

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]

      // Unordered list item
      const ulMatch = line.match(/^[-*]\s+(.+)/)
      if (ulMatch) {
        if (!inUl) { html += '<ul class="pa-alert__list">'; inUl = true }
        if (inOl) { html += '</ol>'; inOl = false }
        html += `<li>${this._renderInline(ulMatch[1])}</li>`
        continue
      }

      // Ordered list item
      const olMatch = line.match(/^\d+\.\s+(.+)/)
      if (olMatch) {
        if (!inOl) { html += '<ol class="pa-alert__list">'; inOl = true }
        if (inUl) { html += '</ul>'; inUl = false }
        html += `<li>${this._renderInline(olMatch[1])}</li>`
        continue
      }

      // Close any open list
      if (inUl) { html += '</ul>'; inUl = false }
      if (inOl) { html += '</ol>'; inOl = false }

      // Horizontal rule: ---, ***, ___
      if (/^[-*_]{3,}\s*$/.test(line.trim())) {
        html += '<hr>'
        continue
      }

      // Blank line or empty — skip (paragraph break)
      if (line.trim() === '') continue

      // Regular paragraph
      html += `<p>${this._renderInline(line)}</p>`
    }

    // Close any remaining open list
    if (inUl) html += '</ul>'
    if (inOl) html += '</ol>'

    return html
  },

  /** Renders inline markdown: **bold**, *italic*, [text](url) */
  _renderInline(text) {
    let result = this._escapeHtml(text)
    // Bold: **text**
    result = result.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    // Italic: *text*
    result = result.replace(/\*(.+?)\*/g, '<em>$1</em>')
    // Links: [text](url) — URL scheme validated to block javascript:/data:/vbscript:
    result = result.replace(/\[(.+?)\]\((.+?)\)/g, (_m, label, url) => {
      return `<a href="${this._safeUrl(url)}" class="pa-link">${label}</a>`
    })
    return result
  },

  /**
   * Returns a URL safe to use in an `href` attribute. Rejects `javascript:`,
   * `data:`, and `vbscript:` schemes (case- and whitespace-insensitive); returns
   * "#" for those. Allowed: http/https/mailto/tel and relative paths. The input
   * has already passed through _escapeHtml so quotes and angle brackets are
   * entities — we only need scheme-level filtering here.
   */
  _safeUrl(url) {
    const trimmed = String(url).trim()
    if (/^(?:javascript|data|vbscript)\s*:/i.test(trimmed)) return '#'
    return trimmed
  },

  _escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
