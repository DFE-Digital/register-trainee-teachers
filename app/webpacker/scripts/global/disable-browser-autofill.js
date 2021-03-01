function disableBrowserAutofill () {
  const dataAttributeName = 'data-nameoriginal'
  const inputTypes = ['text', 'tel', 'email', 'number']

  // Missing forEach on NodeList for IE11
  if (window.NodeList && !window.NodeList.prototype.forEach) {
    window.NodeList.prototype.forEach = Array.prototype.forEach
  }

  document.querySelectorAll('form').forEach(form => {
    if (form.getAttribute('autocomplete') === 'off') {
      const inputs = [...form.querySelectorAll('input[autocomplete]')].filter(input => inputTypes.includes(input.type))

      inputs.forEach(input => {
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
