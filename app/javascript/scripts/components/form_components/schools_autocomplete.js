import accessibleAutocomplete from 'accessible-autocomplete'
import tracker from './tracker.js'
import { guard, renderTemplate, setHiddenField } from './autocomplete/helpers.js'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-schools-autocomplete"]')
const idElement = document.getElementById('school-id')

let statusMessage = ' '

const mapToSchools = (data) => data.schools

const tryUpdateStatusMessage = (collection) => {
  if (collection.length === 0) {
    statusMessage = 'No results found'
  }

  return collection
}

const findSchools = ({ query, populateResults, onlyLeadSchools }) => {
  idElement.value = ''

  const encodedQuery = encodeURIComponent(query)

  statusMessage = 'Loading...' // Shared state

  window.fetch(`/autocomplete/schools?query=${encodedQuery}&lead_school=${onlyLeadSchools ? 'true' : 'false'}`)
    .then(response => response.json())
    .then(guard)
    .then(mapToSchools)
    .then(tryUpdateStatusMessage)
    .then(populateResults)
    .catch(console.log)
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
            setHiddenField(idElement, value)
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

$allAutocompleteElements.forEach(setupAutoComplete)
