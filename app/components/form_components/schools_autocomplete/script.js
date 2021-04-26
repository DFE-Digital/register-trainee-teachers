import accessibleAutocomplete from 'accessible-autocomplete'

const $form = document.querySelector('[data-module="app-schools-autocomplete"]')
const id_element = document.getElementById("lead-school-id")

const findSchools = (query, populateResults) =>  {
  fetch(`/api/schools?query=${query}&lead_school=true`)
    .then(response => {
      return response.json()
    })
    .then(data => {
      if (data === undefined) {
        return 
      }
      let schools = query ? data.schools : []
      populateResults(schools)
    })
    .catch(err => console.log(err))
}


const hideFallback = (form) => {
  const fallbackInput = form.querySelector('#schools-autocomplete-no-js')
  if (fallbackInput) fallbackInput.setAttribute("type", "hidden")
}

const suggestionTemplate = (value) => {
  return value && value.name
}

const inputTemplate = (value) => {
  return value && value.name
}

const renderTemplate = {
  inputValue: inputTemplate,
  suggestion: suggestionTemplate
}

const createHiddenInput = (form) => {
  const input = document.createElement('input')
  input.setAttribute('type', 'hidden')
  input.setAttribute('name', 'update')
  input.setAttribute('value', 'true')
  form.appendChild(input)
}

const setParams = (value) => {
  if (value === undefined) {
    return 
  }
  id_element.value = value.id
}

const setupAutoComplete = (form) => {
  const element = form.querySelector('#schools-autocomplete')

  hideFallback(form)

  createHiddenInput(form)

  accessibleAutocomplete({
    element: element,
    id: 'schools-autocomplete',
    minLength: 3,
    source: findSchools,
    templates: renderTemplate,
    onConfirm: setParams, 
    showAllValues: false,
    autoselect: true,
  })
}

setupAutoComplete($form)
