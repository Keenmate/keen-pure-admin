/**
 * PureAdminCommandPalette v2 — Multi-step commands + scoped search.
 *
 * Keyboard shortcuts:
 *   Ctrl+K / Cmd+K  — Toggle palette
 *   ↑↓              — Navigate items
 *   ←→              — Pages (in search modes)
 *   Enter / Tab      — Select item or submit free text
 *   Escape           — Back (in step/context) or close
 *   Backspace at 0   — Back to previous step
 *
 * Event protocol (hook → LiveView):
 *   cp:toggle, cp:close, cp:input, cp:navigate, cp:page, cp:select, cp:step_back
 *
 * Reads data-mode from the component root to determine keyboard behavior.
 */
import { createLogger } from "../logger"

const log = createLogger('CMD_PALETTE')

export const PureAdminCommandPalette = {
  mounted() {
    this.input = this.el.querySelector('.pa-command-palette__input')
    this.backdrop = this.el.querySelector('.pa-command-palette__backdrop')
    this._debounceTimer = null
    this._lastQuery = ''
    // When the palette is rendered inside the `PureAdmin.CommandPalette`
    // LiveComponent, its root carries data-phx-component and events must target
    // the component. In a plain-LiveView host there's no component ancestor, so
    // fall back to pushing to the view. `this.el` IS the palette root either way.
    this._component = this.el.closest('[data-phx-component]')
    log.debug('mounted, input:', !!this.input, 'component:', !!this._component)

    // Global Ctrl+K / Cmd+K and Alt+key hotkeys
    this._globalKeydown = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault()
        log.debug('Ctrl+K pressed')
        this._push('cp:toggle', {})
        return
      }

      // Alt+key hotkeys — open palette with specific command
      if (e.altKey && !e.ctrlKey && !e.metaKey && e.key !== 'Alt') {
        log.debug('Alt+' + e.key + ' pressed')
        this._push('cp:hotkey', { key: e.key.toLowerCase() })
        e.preventDefault()
      }
    }
    document.addEventListener('keydown', this._globalKeydown)

    // Input handler with debounce for search modes
    if (this.input) {
      this._inputHandler = (e) => {
        const query = e.target.value
        const mode = this._getMode()

        // Debounce search modes, instant for command/context list filtering
        if (mode === 'context_search' || mode === 'global_search') {
          clearTimeout(this._debounceTimer)
          this._debounceTimer = setTimeout(() => {
            this._push('cp:input', { query })
          }, 150)
        } else {
          this._push('cp:input', { query })
        }
      }
      this.input.addEventListener('input', this._inputHandler)

      this._keydownHandler = (e) => {
        const mode = this._getMode()

        // Alt+key hotkeys inside the palette
        if (e.altKey && !e.ctrlKey && !e.metaKey && e.key !== 'Alt') {
          e.preventDefault()
          this._push('cp:hotkey', { key: e.key.toLowerCase() })
          return
        }

        switch (e.key) {
          case 'Escape':
            e.preventDefault()
            // In step/context modes, go back instead of closing
            if (mode === 'command_step' || mode === 'context_search') {
              this._push('cp:step_back', {})
            } else {
              this._push('cp:close', {})
            }
            break

          case 'ArrowUp':
            e.preventDefault()
            this._push('cp:navigate', { direction: 'up' })
            break

          case 'ArrowDown':
            e.preventDefault()
            this._push('cp:navigate', { direction: 'down' })
            break

          case 'ArrowLeft':
            if (this.input.selectionStart === 0 && (mode === 'context_search' || mode === 'global_search')) {
              e.preventDefault()
              this._push('cp:page', { direction: 'prev' })
            }
            break

          case 'ArrowRight':
            if (this.input.selectionStart === this.input.value.length && (mode === 'context_search' || mode === 'global_search')) {
              e.preventDefault()
              this._push('cp:page', { direction: 'next' })
            }
            break

          case 'Backspace':
            if (mode === 'command_step' || mode === 'context_search') {
              const display = this.el.dataset.display || 'inline'
              if (display === 'inline') {
                // In inline mode, prevent deleting into the locked prefix
                // The locked prefix length is tracked via data attribute
                const lockedLen = parseInt(this.el.dataset.lockedLength || '0', 10)
                if (this.input.selectionStart <= lockedLen && this.input.selectionEnd <= lockedLen) {
                  e.preventDefault()
                  this._push('cp:step_back', {})
                } else if (this.input.selectionStart <= lockedLen) {
                  e.preventDefault()
                }
              } else {
                // Token mode: backspace at position 0 → go back
                if (this.input.selectionStart === 0 && this.input.selectionEnd === 0) {
                  e.preventDefault()
                  this._push('cp:step_back', {})
                }
              }
            }
            break

          case 'Enter':
          case 'Tab':
            e.preventDefault()
            this._push('cp:select', { index: -1 })
            break
        }
      }
      this.input.addEventListener('keydown', this._keydownHandler)
    }

    // Backdrop click
    if (this.backdrop) {
      this._backdropClick = () => {
        this._push('cp:close', {})
      }
      this.backdrop.addEventListener('click', this._backdropClick)
    }

    // Listen for focus events from LiveView
    this.handleEvent('cp:focus', () => {
      this._focusInput()
    })

    // Listen for input reset (when entering a new step/mode)
    this.handleEvent('cp:reset_input', ({ value }) => {
      if (this.input) {
        this.input.value = value || ''
        this._focusInput()
      }
    })

    // External open trigger: the navbar/sidebar search entry points (rc12)
    // dispatch this to `this.el` via `show_command_palette/2`, so a click opens
    // the palette without each trigger needing its own LiveView wiring.
    this._openListener = () => this._push('cp:toggle', {})
    this.el.addEventListener('pa:command-palette:open', this._openListener)

    // rc12: on phones the palette is a fullscreen sheet (pureAdmin.device),
    // scroll-locked with its bottom pinned above the soft keyboard
    // (pureAdmin.overlay); a floating dialog everywhere else. Re-sync when the
    // device class flips (rotation / pointer change).
    this._syncSurface()
    if (window.pureAdmin && window.pureAdmin.events) {
      this._offDevice = window.pureAdmin.events.on('device:change', () => this._syncSurface())
    }

    this._focusIfOpen()
  },

  updated() {
    this._focusIfOpen()
    this._scrollActiveIntoView()
    this._syncSurface()
  },

  // Route a server event to the component (when mounted inside one) or the view.
  _push(event, payload) {
    if (this._component) {
      this.pushEventTo(this._component, event, payload)
    } else {
      this.pushEvent(event, payload)
    }
  },

  _getMode() {
    return this.el.dataset.mode || 'idle'
  },

  _focusInput() {
    if (this.input) {
      setTimeout(() => {
        this.input.focus()
        // Place cursor at end
        this.input.selectionStart = this.input.value.length
        this.input.selectionEnd = this.input.value.length
      }, 50)
    }
  },

  _focusIfOpen() {
    if (this.el.classList.contains('pa-command-palette--active')) {
      this._focusInput()
    }
  },

  _scrollActiveIntoView() {
    const active = this.el.querySelector('.pa-command-palette__item--active')
    if (active) {
      active.scrollIntoView({ block: 'nearest' })
    }
  },

  _isMobile() {
    const d = window.pureAdmin && window.pureAdmin.device
    return !!(d && d.class === 'mobile')
  },

  // Toggle the fullscreen-sheet class by device, and (only while open on a phone)
  // hold a body scroll-lock + soft-keyboard inset via pureAdmin.overlay. Both
  // helpers are ref-counted / idempotent-release, so re-entry is safe.
  _syncSurface() {
    this.el.classList.toggle('pa-command-palette--fullscreen', this._isMobile())

    const active = this.el.classList.contains('pa-command-palette--active')
    const overlay = window.pureAdmin && window.pureAdmin.overlay
    if (active && this._isMobile() && overlay) {
      if (!this._releaseScroll) this._releaseScroll = overlay.lockBodyScroll()
      if (!this._releaseInset) {
        const container = this.el.querySelector('.pa-command-palette__container')
        this._releaseInset = overlay.observeKeyboardInset(container)
      }
    } else {
      this._releaseSurface()
    }
  },

  _releaseSurface() {
    if (this._releaseScroll) { this._releaseScroll(); this._releaseScroll = null }
    if (this._releaseInset) { this._releaseInset(); this._releaseInset = null }
  },

  destroyed() {
    document.removeEventListener('keydown', this._globalKeydown)
    if (this._openListener) this.el.removeEventListener('pa:command-palette:open', this._openListener)
    if (this._offDevice) this._offDevice()
    this._releaseSurface()
    clearTimeout(this._debounceTimer)
  }
}
