// Disable browser autofill

// This code is used to force the disabling of browser autofill. It’s needed
// for browsers that ignore the `autocomplete="off"` attribute.

// To use, add `data-js-disable-browser-autofill='on'` either on a form
// element or on individual inputs where autofill should be disabled.

// ## Accessibility
// The solution relies on setting the `autocomplete` attribute to a
// non-standard attribute. This may be considered a fail for WCAG 1.3.5 -
// Identify Input Purpose. However, we accept this is a necessary and
// worthwhile tradeoff for the benefits of preventing browser autofill on
// inputs where it shouldn’t appear.

function disableBrowserAutofill () {
  const dataAttributeName = 'data-nameoriginal'
  const inputTypes = ['text', 'tel', 'email', 'number']

  // Missing forEach on NodeList for IE11
  if (window.NodeList && !window.NodeList.prototype.forEach) {
    window.NodeList.prototype.forEach = Array.prototype.forEach
  }

  document.querySelectorAll('form').forEach(form => {
    let inputs = [...form.querySelectorAll('input')]
      .filter(input => inputTypes.includes(input.type))

    if (form.dataset.jsDisableBrowserAutofill === 'on') {
      inputs = inputs.filter(input => input.dataset.jsDisableBrowserAutofill !== 'off')
    } else {
      inputs = inputs.filter(input => input.dataset.jsDisableBrowserAutofill === 'on')
    }

    if (inputs.length) {
      inputs.forEach(input => {
        // The autocomplete attribute needs to be set to a non-standard attribute
        // for the solution to work
        input.setAttribute('autocomplete', 'disabled')
        input.setAttribute(dataAttributeName, input.name)
        input.name = Math.random().toString(36).substring(7) // NOSONAR
      })

      form.addEventListener('submit', () => {
        inputs.forEach(input => {
          input.name = input.getAttribute(dataAttributeName)
        })
      })
    }
  })
}

disableBrowserAutofill()
