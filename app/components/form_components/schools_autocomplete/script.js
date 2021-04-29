import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-schools-autocomplete"]')
const idElement = document.getElementById('lead-school-id')

let statusMessage = ' '

const guard = (data) => {
  if (data === undefined) {
    return new Error('An error occured')
  }

  return data
}

const mapToSchools = (data) => data.schools

const tryUpdateStatusMessage = (schools) => {
  if (schools.length === 0) {
    statusMessage = 'No results found'
  }

  return schools
}

const findSchools = (query, populateResults) => {
  statusMessage = 'Loading...' // Shared state

  window.fetch(`/api/schools?query=${query}&lead_school=true`)
    .then(response => response.json())
    .then(guard)
    .then(mapToSchools)
    .then(tryUpdateStatusMessage)
    .then(populateResults)
    .catch(console.log)
}

const suggestionTemplate = (value) => {
  return value && value.name
}

const renderTemplate = {
  inputValue: suggestionTemplate,
  suggestion: suggestionTemplate
}

const setLeadSchoolHiddenField = (value) => {
  if (value === undefined) {
    return
  }

  idElement.value = value.id
}

const setupAutoComplete = (form) => {
  const element = form.querySelector('#schools-autocomplete-element')

  accessibleAutocomplete({
    element: element,
    id: 'schools-autocomplete',
    minLength: 3,
    source: findSchools,
    templates: renderTemplate,
    onConfirm: setLeadSchoolHiddenField,
    showAllValues: false,
    defaultValue: element.dataset.value,
    tNoResults: () => statusMessage
  })
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
