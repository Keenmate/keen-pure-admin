/**
 * PureAdminCommandPalette v2 — Multi-step commands + scoped search.
 *
 * Keyboard shortcuts:
 *   Ctrl+K / Cmd+K  — Toggle palette
 *   g <letter>       — Leading-key command sequence (e.g. "g g" → Go to Page),
 *                      modifier-free, only when NOT typing and the palette is closed
 *   ↑↓              — Navigate items (incl. the idle home screen)
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

// Width presets (rc15). The settings panel toggles one of these on the palette
// root client-side. Because this palette is a LiveComponent, its root `class`
// is server-owned and gets rewritten on every re-render (open/input/select) —
// which would strip a client-set preset. beforeUpdate/updated below keep it
// sticky across re-renders.
const SIZE_CLASSES = ['pa-command-palette--sm', 'pa-command-palette--lg', 'pa-command-palette--xl']

export const PureAdminCommandPalette = {
  mounted() {
    this.input = this.el.querySelector('.pa-command-palette__input')
    this.backdrop = this.el.querySelector('.pa-command-palette__backdrop')
    this._debounceTimer = null
    this._lastQuery = ''
    // Active-item index is owned CLIENT-SIDE. Navigation (↑↓ PgUp/PgDn Home/End)
    // only moves a highlight through the already-rendered list, so it's pure DOM
    // work — no server round-trip. The server still owns the *reset*: whenever the
    // list changes it renders active=0, and we re-adopt that from the DOM in
    // updated(). Enter pushes the real local index, so the server never has to
    // track navigation. (See the long comment on _navLocal.)
    this._activeIndex = -1
    // When the palette is rendered inside the `PureAdmin.CommandPalette`
    // LiveComponent, its root carries data-phx-component and events must target
    // the component. In a plain-LiveView host there's no component ancestor, so
    // fall back to pushing to the view. `this.el` IS the palette root either way.
    this._component = this.el.closest('[data-phx-component]')
    log.debug('mounted, input:', !!this.input, 'component:', !!this._component)

    // Global Ctrl+K / Cmd+K + leading-key "g <letter>" command sequences.
    // Sequences are modifier-free and inert while typing in a field or when the
    // palette is already open. Chosen over Alt+letter, which on macOS is a
    // text-composition modifier (Option+G types "©") — it inserts glyphs and is
    // non-idiomatic there. Ctrl/⌘+K still opens the full palette.
    this._seqActive = false
    this._seqTimer = null
    this._globalKeydown = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault()
        log.debug('Ctrl+K pressed')
        this._push('cp:toggle', {})
        return
      }

      const open = this.el.classList.contains('pa-command-palette--active')
      if (e.ctrlKey || e.metaKey || e.altKey || open || this._isTyping(e.target)) {
        this._endSeq()
        return
      }

      if (!this._seqActive) {
        // Arm on the leader key ("g"); wait a short window for the second key.
        if (e.key.toLowerCase() === 'g') {
          this._seqActive = true
          clearTimeout(this._seqTimer)
          this._seqTimer = setTimeout(() => this._endSeq(), 1200)
        }
        return
      }

      // Second key — the server resolves it against each command's hotkey.
      this._endSeq()
      log.debug('g-sequence: g ' + e.key)
      this._push('cp:hotkey', { key: e.key.toLowerCase() })
    }
    document.addEventListener('keydown', this._globalKeydown)

    // Input handler with debounce for search modes
    if (this.input) {
      this._inputHandler = (e) => {
        const query = e.target.value
        // data-cp-input (set by the server) decides where this keystroke goes:
        //   client → filter the already-rendered list in-browser, no round-trip
        //   search → debounced round-trip (live server search)
        //   server → immediate round-trip (idle first char, mode transitions)
        const inputMode = this.el.dataset.cpInput || 'server'

        if (inputMode === 'client' && this._clientFilter(query)) return

        clearTimeout(this._debounceTimer)
        if (inputMode === 'search') {
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
            this._navLocal('up')
            break

          case 'ArrowDown':
            e.preventDefault()
            this._navLocal('down')
            break

          case 'PageUp':
            e.preventDefault()
            this._navLocal('page_up')
            break

          case 'PageDown':
            e.preventDefault()
            this._navLocal('page_down')
            break

          case 'Home':
            e.preventDefault()
            this._navLocal('home')
            break

          case 'End':
            e.preventDefault()
            this._navLocal('end')
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
            // Select the active item by its SERVER index (data-cp-index), not its
            // positional index — client-side filtering hides items, so position no
            // longer maps to the server's list. -1 (no active item, e.g. empty
            // filter) preserves the server's free-text-submit path.
            {
              const sel = this.el.querySelector('.pa-command-palette__item--active:not([hidden])')
              const idx = sel && sel.dataset.cpIndex !== undefined
                ? parseInt(sel.dataset.cpIndex, 10)
                : -1
              const payload = { index: idx }
              // No active item → carry the editable text so a free-text step can
              // submit it (the server didn't see the keystrokes we filtered locally).
              if (idx === -1) {
                const offset = parseInt(this.el.dataset.cpFilterOffset || '0', 10)
                payload.query = this.input ? this.input.value.slice(offset) : ''
              }
              this._push('cp:select', payload)
            }
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

  // The server re-render is about to rewrite the root class to its server-owned
  // value, dropping any width preset the settings panel toggled on client-side.
  // Remember it so updated() can restore it. (Must be synchronous.)
  beforeUpdate() {
    this._sizeClass = SIZE_CLASSES.find((c) => this.el.classList.contains(c)) || null
  },

  updated() {
    // Re-assert the client-owned width preset the server render just clobbered.
    if (this._sizeClass) this.el.classList.add(this._sizeClass)
    this._focusIfOpen()
    // The server render is authoritative and unfiltered — drop any client-filter
    // hiding / injected empty state left over from the previous mode.
    this.el.querySelectorAll('.pa-command-palette__item[hidden]').forEach((i) => { i.hidden = false })
    const staleEmpty = this.el.querySelector('[data-cp-client-empty]')
    if (staleEmpty) staleEmpty.remove()
    // The server re-rendered the list (open / input / step / page / select) and,
    // with it, the active=0 reset. Adopt that position as the client's new base
    // so subsequent arrow presses move locally from there.
    this._syncActiveFromDom()
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

  _isTyping(t) {
    return !!t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.isContentEditable)
  },

  _endSeq() {
    this._seqActive = false
    clearTimeout(this._seqTimer)
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

  // The navigable items — VISIBLE ones only, in DOM order (client-side filtering
  // hides non-matching items via [hidden]). Navigation + the positional active
  // index walk this filtered view; selection resolves back to the server index
  // via each item's data-cp-index.
  _navItems() {
    return Array.from(this.el.querySelectorAll('.pa-command-palette__item')).filter((el) => !el.hidden)
  },

  // Adopt whatever the server rendered as active (its reset point). -1 when the
  // list is empty / has no active item.
  _syncActiveFromDom() {
    const items = this._navItems()
    this._activeIndex = items.findIndex((i) =>
      i.classList.contains('pa-command-palette__item--active')
    )
  },

  // Paint the active highlight at _activeIndex (among visible items) and keep it
  // in view. Clears --active from ALL items first so a hidden item never keeps it.
  _applyActive() {
    const all = Array.from(this.el.querySelectorAll('.pa-command-palette__item'))
    all.forEach((i) => i.classList.remove('pa-command-palette__item--active'))
    const el = this._navItems()[this._activeIndex]
    if (el) {
      el.classList.add('pa-command-palette__item--active')
      el.scrollIntoView({ block: 'nearest' })
    }
  },

  // Client-side filtering — substring-match the already-rendered list in-browser,
  // ZERO round-trips. Returns false (→ caller falls back to a server push) when
  // the input broke out of the filterable prefix (e.g. the leading `/` was
  // deleted, or a space in a list mode may complete a command/context).
  _clientFilter(value) {
    const offset = parseInt(this.el.dataset.cpFilterOffset || '0', 10)
    if (value.length < offset) return false // prefix gone → let the server re-derive the mode
    const q = value.slice(offset)
    const mode = this._getMode()
    if ((mode === 'command_list' || mode === 'context_list') && q.includes(' ')) {
      return false // a space may complete a command/context shortcut — server decides
    }

    const needle = q.trim().toLowerCase()
    let anyVisible = false
    this.el.querySelectorAll('.pa-command-palette__item').forEach((item) => {
      const hay = (item.dataset.cpMatch || item.textContent || '').toLowerCase()
      const show = needle === '' || hay.includes(needle)
      item.hidden = !show
      if (show) anyVisible = true
    })

    this._toggleClientEmpty(!anyVisible)
    this._activeIndex = anyVisible ? 0 : -1
    this._applyActive()
    return true
  },

  // Show/hide a client-rendered "no results" row (the server thinks its list is
  // non-empty, so it won't render one). Self-cleans on the next server render.
  _toggleClientEmpty(show) {
    const results = this.el.querySelector('.pa-command-palette__results')
    if (!results) return
    let el = results.querySelector('[data-cp-client-empty]')
    if (show && !el) {
      el = document.createElement('div')
      el.className = 'pa-command-palette__empty'
      el.setAttribute('data-cp-client-empty', '')
      el.textContent = 'No results found'
      results.appendChild(el)
    } else if (!show && el) {
      el.remove()
    }
  },

  // Client-side navigation — move the highlight through the already-rendered list
  // with ZERO server round-trips (the whole point: on a LiveView host every
  // keypress was a websocket round-trip just to move a highlight). Single-step
  // arrows wrap; page/home/end clamp — mirrors the old server-side logic exactly.
  // The server only learns the index on select, so cp_active_index staying stale
  // between renders is harmless.
  _navLocal(direction) {
    const count = this._navItems().length
    if (count === 0) {
      this._activeIndex = -1
      return
    }
    const active = this._activeIndex
    const from = active < 0 ? 0 : active
    const page = 8

    switch (direction) {
      case 'up': this._activeIndex = active <= 0 ? count - 1 : active - 1; break
      case 'down': this._activeIndex = active >= count - 1 ? 0 : active + 1; break
      case 'page_up': this._activeIndex = Math.max(0, from - page); break
      case 'page_down': this._activeIndex = Math.min(count - 1, from + page); break
      case 'home': this._activeIndex = 0; break
      case 'end': this._activeIndex = count - 1; break
      default: return
    }
    this._applyActive()
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
    clearTimeout(this._seqTimer)
  }
}
