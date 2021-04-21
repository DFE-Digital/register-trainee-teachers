import accessibleAutocomplete from 'accessible-autocomplete'

const $form = document.querySelector('[data-module="app-schools-autocomplete"]')

// This will be calling our `/api/schools` endpoint for matching schools.
const schools = [
  'School1',
  'School2',
  'School3'
]

const hideFallback = (form) => {
  const fallbackInput = form.querySelector('#schools-autocomplete-no-js')
  if (fallbackInput) fallbackInput.setAttribute("type", "hidden")
}

const createHiddenInput = (form) => {
  const input = document.createElement('input')
  input.setAttribute('type', 'hidden')
  input.setAttribute('name', 'update')
  input.setAttribute('value', 'true')
  form.appendChild(input)
}

const setupAutoComplete = (form) => {
  const element = form.querySelector('#schools-autocomplete')

  hideFallback(form)

  createHiddenInput(form)

  accessibleAutocomplete({
    element: element,
    id: 'schools-autocomplete',
    source: schools,
    showAllValues: false,
    autoselect: true,
  })
}

setupAutoComplete($form)
