import accessibleAutocomplete from 'accessible-autocomplete'

const $form = document.querySelector('[data-module="app-schools-autocomplete"]')
const idElement = document.getElementById('lead-school-id')

let statusMessage = null

const findSchools = (query, populateResults) => {
  statusMessage = 'Loading...'

  window.fetch(`/api/schools?query=${query}&lead_school=true`)
    .then(response => response.json())
    .then(data => {
      if (data === undefined) {
        return
      }

      const schools = data.schools

      if (schools.length === 0) {
        statusMessage = 'No results found'
      }

      return schools
    })
    .then(schools => populateResults(schools))
    .catch(err => console.log(err))
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

const setParams = (value) => {
  if (value === undefined) {
    return
  }
  idElement.value = value.id
}

const setupAutoComplete = (form) => {
  if (!form) return

  const element = form.querySelector('#schools-autocomplete-element')

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
