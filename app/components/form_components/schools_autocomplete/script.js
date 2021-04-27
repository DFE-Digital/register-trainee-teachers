import accessibleAutocomplete from 'accessible-autocomplete'

const $form = document.querySelector('[data-module="app-schools-autocomplete"]')
const id_element = document.getElementById("lead-school-id")

let statusMessage = null

const findSchools = (query, populateResults) =>  {
  statusMessage = 'Loading...';

  fetch(`/api/schools?query=${query}&lead_school=true`)
    .then(response => {
      return response.json()
    })
    .then(data => {
      if (data === undefined) {
        return
      }

      let schools = query ? data.schools : []

      if(schools.length === 0){
        statusMessage = 'No results found';
      }

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
  const element = form.querySelector('#schools-autocomplete-element')

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
    tNoResults: () => statusMessage
  })
}

setupAutoComplete($form)
