import accessibleAutocomplete from 'accessible-autocomplete'

const $form = document.querySelector('[data-module="app-schools-autocomplete"]')

// This will be calling our `/api/schools` endpoint for matching schools.
const schools = [
  'School1',
  'School2',
  'School3'
]

const hideNoJs = (form) => {
  const fallbackInput = form.querySelector('#schools-autocomplete-no-js')

  if (fallbackInput) {
    fallbackInput.setAttribute("type", "hidden")
  }

  form.action = 'somehow_recreate_the_rails_path_here'
  form.method = 'patch'
}

const setupAutoComplete = (form) => {
  const element = form.querySelector('#schools-autocomplete')
  hideNoJs(form)

  accessibleAutocomplete({
    element: element,
    id: 'schools-autocomplete',
    source: schools,
    showAllValues: false,
    autoselect: true,
  })
}

setupAutoComplete($form)
