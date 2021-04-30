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
  const encodedQuery = encodeURIComponent(query)

  statusMessage = 'Loading...' // Shared state

  window.fetch(`/api/schools?query=${encodedQuery}&lead_school=true`)
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
  const inputs = form.querySelectorAll('[data-field="schools-autocomplete"]')

  try {
    inputs.forEach(input => {
      accessibleAutocomplete({
        element: element,
        id: input.id,
        minLength: 3,
        source: findSchools,
        templates: renderTemplate,
        onConfirm: setLeadSchoolHiddenField,
        showAllValues: false,
        tNoResults: () => statusMessage
      })

      // Move autocomplete to the form group containing the input to be replaced
      const inputFormGroup = element.previousElementSibling
      if (inputFormGroup.contains(input)) {
        inputFormGroup.appendChild(element)
      }

      input.remove()
    })
  } catch (err) {
    console.error('Could not enhance:', err)
  }
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
