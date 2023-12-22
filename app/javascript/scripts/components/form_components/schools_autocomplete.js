import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common/index.js'
import tracker from './tracker.js'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-schools-autocomplete"]')
const idElement = document.getElementById('school-id')

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

const findSchools = ({ query, populateResults, onlyLeadSchools }) => {
  idElement.value = ''

  const encodedQuery = encodeURIComponent(query)

  statusMessage = 'Loading...' // Shared state

  window.fetch(`/api/schools?query=${encodedQuery}&lead_school=${onlyLeadSchools ? 'true' : 'false'}`)
    .then(response => response.json())
    .then(guard)
    .then(mapToSchools)
    .then(tryUpdateStatusMessage)
    .then(populateResults)
    .catch(console.log)
}

const inputTemplate = (value) => {
  return value && value.name
}

const suggestionTemplate = (result) => {
  if (result) {
    if (typeof result === 'string') {
      return result
    } else if (typeof result === 'object') {
      const hints = [`URN ${result.urn}`, result.town, result.postcode].filter(Boolean)

      return `${result.name} <span class="autocomplete__option--hint">${hints.join(', ')}</span>`
    }
  } else return ''
}

const renderTemplate = {
  inputValue: inputTemplate,
  suggestion: suggestionTemplate
}

const setSchoolHiddenField = (value) => {
  if (value === undefined) {
    return
  }

  idElement.value = value.id
}

const setupAutoComplete = (form) => {
  const element = form.querySelector('#schools-autocomplete-element')
  const inputs = form.querySelectorAll('[data-field="schools-autocomplete"]')
  const defaultValueOption = element.getAttribute('data-default-value') || ''
  const fieldName = element.getAttribute('data-field-name') || ''

  try {
    inputs.forEach(input => {
      accessibleAutocomplete({
        element,
        id: input.id,
        minLength: 2,
        defaultValue: defaultValueOption,
        name: fieldName,
        source: (query, populateResults) => {
          tracker.trackSearch(query)
          return findSchools({
            query,
            populateResults,
            onlyLeadSchools: element.dataset.onlyLeadSchools
          })
        },
        templates: renderTemplate,
        onConfirm: (value) => {
          if (value?.id && element.dataset.systemAdminRedirectLeadSchool) {
            window.location.assign(`/system-admin/lead-schools/${value.id}`)
          } else {
            tracker.sendTrackingEvent(value, fieldName)
            setSchoolHiddenField(value)
          }
        },
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
