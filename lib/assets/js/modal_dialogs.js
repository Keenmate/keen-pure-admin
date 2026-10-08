/**
 * Pure Admin Modal Dialogs
 * Promise-based programmatic modal system (confirm, alert, prompt)
 *
 * Usage:
 *   import { initModalDialogs } from "keen_pure_admin/modal_dialogs"
 *   initModalDialogs()  // sets up window.PureAdmin.confirm/alert/prompt
 *
 *   const result = await PureAdmin.confirm({ title: 'Delete?', message: '...' });
 *   await PureAdmin.alert({ title: 'Success!', message: '...' });
 *   const value = await PureAdmin.prompt({ title: 'Enter name:', message: '...' });
 */

// Modal counter for unique IDs
let modalCounter = 0

/**
 * Escape HTML to prevent XSS
 */
function escapeHtml(text) {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

// Status variants carry the shared severity glyph in the title — the same
// masked --pa-icon-* family the static severity modals and alerts use (core
// 3.2.0). Only status roles have a glyph; `primary` is a brand colour (not a
// status) and has no `.pa-icon--primary`, so it stays icon-less.
const STATUS_TITLE_ICONS = {
  success: 'success',
  warning: 'warning',
  danger: 'danger',
  info: 'info'
}

/**
 * Resolve the optional leading title icon for a dialog.
 * - icon === false         → no icon
 * - typeof icon === string → `.pa-icon--<icon>` (explicit override)
 * - otherwise              → the status glyph for a known variant, else none
 * Returns ready-to-inject markup (with a trailing space) or ''.
 */
function titleIconMarkup(variant, icon) {
  let name = null
  if (icon === false) {
    name = null
  } else if (typeof icon === 'string') {
    name = icon
  } else if (variant && STATUS_TITLE_ICONS[variant]) {
    name = STATUS_TITLE_ICONS[variant]
  }
  return name
    ? `<span class="pa-icon pa-icon--${name}" aria-hidden="true"></span> `
    : ''
}

/**
 * Create modal element with given structure
 */
function createModal(options) {
  const {
    id,
    size = 'sm',
    variant = null,
    position = 'center',
    title,
    message,
    footer
  } = options

  const modal = document.createElement('div')
  let modalClass = 'pa-modal pa-modal--show'
  if (position === 'top') modalClass += ' pa-modal--top'
  if (variant) modalClass += ` pa-modal--${variant}`
  // Banded header + footer bands — pair with a role variant (success/warning/
  // danger/info) for the colour, like the declarative modal.
  if (options.isBanded) modalClass += ' pa-modal--banded'
  modal.className = modalClass
  modal.id = id
  modal.setAttribute('role', 'dialog')
  modal.setAttribute('aria-modal', 'true')
  modal.setAttribute('aria-labelledby', `${id}-title`)

  const containerClass = size === 'md'
    ? 'pa-modal__container'
    : `pa-modal__container pa-modal__container--${size}`

  modal.innerHTML = `
    <div class="pa-modal__backdrop"></div>
    <div class="${containerClass}">
      <div class="pa-modal__header">
        <h3 class="pa-modal__title" id="${id}-title">${titleIconMarkup(variant, options.icon)}${escapeHtml(title)}</h3>
      </div>
      <div class="pa-modal__body">
        <p>${escapeHtml(message)}</p>
        ${options.inputHtml || ''}
      </div>
      <div class="pa-modal__footer">
        ${footer}
      </div>
    </div>
  `

  return modal
}

/**
 * Show modal and return promise that resolves when user responds
 */
function showModal(modal, options = {}) {
  return new Promise((resolve) => {
    document.body.appendChild(modal)

    // Lock background scroll via the shared, refcounted helper. It sets only
    // body{overflow:hidden} and trusts `scrollbar-gutter: stable` on <html> to
    // keep the gutter reserved. The old code added its own paddingRight, which
    // DOUBLE-compensated against the stable gutter and shifted content sideways
    // (core 3.2.0 fix). Refcounting also stops nested overlays clobbering locks.
    if (window.pureAdmin && window.pureAdmin.overlay) {
      modal._scrollLockRelease = window.pureAdmin.overlay.lockBodyScroll()
    } else {
      modal._stashedOverflow = document.body.style.overflow
      document.body.style.overflow = 'hidden'
    }

    setTimeout(() => {
      const firstInput = modal.querySelector('input, textarea')
      const firstButton = modal.querySelector('button')
      if (firstInput) {
        firstInput.focus()
      } else if (firstButton) {
        firstButton.focus()
      }
    }, 100)

    modal._resolve = resolve

    if (options.closeOnBackdrop !== false) {
      const backdrop = modal.querySelector('.pa-modal__backdrop')
      if (backdrop) {
        backdrop.addEventListener('click', () => {
          closeModal(modal, options.cancelValue)
        })
      }
    }

    const escHandler = (e) => {
      if (e.key === 'Escape') {
        closeModal(modal, options.cancelValue)
        document.removeEventListener('keydown', escHandler)
      }
    }
    document.addEventListener('keydown', escHandler)
    modal._escHandler = escHandler
  })
}

/**
 * Close modal and resolve promise
 */
function closeModal(modal, value) {
  if (!modal._resolve) return

  modal.classList.remove('pa-modal--show')

  setTimeout(() => {
    if (modal._escHandler) {
      document.removeEventListener('keydown', modal._escHandler)
    }

    if (modal._scrollLockRelease) {
      modal._scrollLockRelease()
      modal._scrollLockRelease = null
    } else if (typeof modal._stashedOverflow === 'string') {
      document.body.style.overflow = modal._stashedOverflow
      modal._stashedOverflow = null
    }

    modal._resolve(value)
    modal._resolve = null

    if (modal.parentNode) {
      modal.parentNode.removeChild(modal)
    }
  }, 300)
}

/**
 * Confirm dialog - returns Promise<boolean>
 */
function confirm(options = {}) {
  const {
    title = 'Confirm',
    message = 'Are you sure?',
    confirmText = 'OK',
    cancelText = 'Cancel',
    variant = 'primary',
    size = 'sm',
    position = 'center',
    confirmVariant = variant,
    closeOnBackdrop = true
  } = options

  const id = `pa-modal-confirm-${++modalCounter}`

  const footer = `
    <button type="button" class="pa-btn pa-btn--secondary" data-action="cancel">
      ${escapeHtml(cancelText)}
    </button>
    <button type="button" class="pa-btn pa-btn--${confirmVariant}" data-action="confirm">
      ${escapeHtml(confirmText)}
    </button>
  `

  const modal = createModal({ id, size, variant, position, title, message, footer, isBanded: options.isBanded })

  modal.querySelector('[data-action="confirm"]').addEventListener('click', () => closeModal(modal, true))
  modal.querySelector('[data-action="cancel"]').addEventListener('click', () => closeModal(modal, false))

  const enterHandler = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      closeModal(modal, true)
      document.removeEventListener('keydown', enterHandler)
    }
  }
  document.addEventListener('keydown', enterHandler)

  return showModal(modal, { closeOnBackdrop, cancelValue: false })
}

/**
 * Alert dialog - returns Promise<void>
 */
function alert(options = {}) {
  const {
    title = 'Alert',
    message = '',
    okText = 'OK',
    variant = 'primary',
    size = 'sm',
    position = 'center',
    closeOnBackdrop = true
  } = options

  const id = `pa-modal-alert-${++modalCounter}`

  const footer = `
    <button type="button" class="pa-btn pa-btn--${variant}" data-action="ok">
      ${escapeHtml(okText)}
    </button>
  `

  const modal = createModal({ id, size, variant, position, title, message, footer, isBanded: options.isBanded })

  modal.querySelector('[data-action="ok"]').addEventListener('click', () => closeModal(modal, true))

  const enterHandler = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault()
      closeModal(modal, true)
      document.removeEventListener('keydown', enterHandler)
    }
  }
  document.addEventListener('keydown', enterHandler)

  return showModal(modal, { closeOnBackdrop, cancelValue: true })
}

/**
 * Prompt dialog - returns Promise<string | null>
 */
function prompt(options = {}) {
  const {
    title = 'Input',
    message = 'Enter value:',
    defaultValue = '',
    placeholder = '',
    confirmText = 'OK',
    cancelText = 'Cancel',
    variant = 'primary',
    size = 'sm',
    position = 'center',
    validator = null,
    closeOnBackdrop = true
  } = options

  const id = `pa-modal-prompt-${++modalCounter}`
  const inputId = `${id}-input`
  const errorId = `${id}-error`

  const inputHtml = `
    <div class="pa-form-group" style="margin-top: 1rem;">
      <div class="pa-input-wrapper">
        <input
          type="text"
          id="${inputId}"
          class="pa-input"
          value="${escapeHtml(defaultValue)}"
          placeholder="${escapeHtml(placeholder)}"
          aria-describedby="${errorId}"
        />
      </div>
      <div id="${errorId}" class="pa-form-error" style="display: none;"></div>
    </div>
  `

  const footer = `
    <button type="button" class="pa-btn pa-btn--secondary" data-action="cancel">
      ${escapeHtml(cancelText)}
    </button>
    <button type="button" class="pa-btn pa-btn--${variant}" data-action="confirm">
      ${escapeHtml(confirmText)}
    </button>
  `

  const modal = createModal({ id, size, variant, position, title, message, inputHtml, footer, isBanded: options.isBanded })

  const input = modal.querySelector(`#${inputId}`)
  const errorDiv = modal.querySelector(`#${errorId}`)
  const confirmBtn = modal.querySelector('[data-action="confirm"]')
  const cancelBtn = modal.querySelector('[data-action="cancel"]')

  function validate() {
    if (!validator) return true

    const value = input.value
    const result = validator(value)

    if (result === true) {
      input.classList.remove('pa-input--error')
      errorDiv.style.display = 'none'
      return true
    } else {
      input.classList.add('pa-input--error')
      errorDiv.textContent = typeof result === 'string' ? result : 'Invalid input'
      errorDiv.style.display = 'block'
      return false
    }
  }

  confirmBtn.addEventListener('click', () => {
    if (validate()) closeModal(modal, input.value)
  })

  cancelBtn.addEventListener('click', () => closeModal(modal, null))

  input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      e.preventDefault()
      if (validate()) closeModal(modal, input.value)
    }
  })

  if (validator) {
    input.addEventListener('input', () => {
      if (errorDiv.style.display !== 'none') validate()
    })
  }

  return showModal(modal, { closeOnBackdrop: false, cancelValue: null })
}

/**
 * Custom dialog - returns Promise<any>.
 *
 * ⚠ SECURITY: your `render(container, close)` function receives the body
 * container directly. Any HTML you write into it is NOT escaped by this
 * library — it goes straight to the DOM. If you're inserting values that
 * could ever be user-controlled, use `container.textContent = ...`,
 * `document.createElement(...)`, or a trusted templating system. Using
 * `container.innerHTML = userInput` here is an XSS.
 */
function custom(options = {}) {
  const {
    title = 'Dialog',
    size = 'md',
    variant = null,
    position = 'center',
    closeOnBackdrop = true,
    render
  } = options

  if (typeof render !== 'function') {
    throw new Error('PureAdmin.custom() requires a render function')
  }

  const id = `pa-modal-custom-${++modalCounter}`

  const modal = document.createElement('div')
  let modalClass = 'pa-modal pa-modal--show'
  if (position === 'top') modalClass += ' pa-modal--top'
  if (variant) modalClass += ` pa-modal--${variant}`
  // Banded header + footer bands — pair with a role variant (success/warning/
  // danger/info) for the colour, like the declarative modal.
  if (options.isBanded) modalClass += ' pa-modal--banded'
  modal.className = modalClass
  modal.id = id
  modal.setAttribute('role', 'dialog')
  modal.setAttribute('aria-modal', 'true')

  const containerClass = size === 'md'
    ? 'pa-modal__container'
    : `pa-modal__container pa-modal__container--${size}`

  const backdrop = document.createElement('div')
  backdrop.className = 'pa-modal__backdrop'
  modal.appendChild(backdrop)

  const container = document.createElement('div')
  container.className = containerClass

  const headerDiv = document.createElement('div')
  headerDiv.className = 'pa-modal__header'
  headerDiv.innerHTML = `<h3 class="pa-modal__title">${titleIconMarkup(variant, options.icon)}${escapeHtml(title)}</h3>`
  container.appendChild(headerDiv)

  modal.appendChild(container)

  const closeCallback = (value) => closeModal(modal, value)
  render(container, closeCallback)

  return showModal(modal, { closeOnBackdrop, cancelValue: null })
}

/**
 * Initialize PureAdmin dialog API on window.
 * Call this once in your app.js.
 */
export function initModalDialogs() {
  const PureAdmin = window.PureAdmin || {}
  PureAdmin.confirm = confirm
  PureAdmin.alert = alert
  PureAdmin.prompt = prompt
  PureAdmin.custom = custom
  window.PureAdmin = PureAdmin
}

// Also export individual functions for direct ES module usage
export { confirm, alert, prompt, custom }
