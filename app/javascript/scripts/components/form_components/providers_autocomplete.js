import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common/index.js'
import tracker from './tracker.js'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-providers-autocomplete"]')
const idElement = document.getElementById('provider-id')

let statusMessage = ' '

const setupAutoComplete = (form) => {
  const element = form.querySelector('#providers-autocomplete-element')
  const inputs = form.querySelectorAll('[data-field="providers-autocomplete"]')
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
          return findProviders({
            query,
            populateResults
          })
        },
        templates: renderTemplate,
        onConfirm: (value) => {
          if (value?.id) {
            window.location.assign(`/system-admin/providers/${value.id}`)
          } else {
            tracker.sendTrackingEvent(value, fieldName)
            setProviderHiddenField(value)
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

const guard = (data) => {
  if (data === undefined) {
    return new Error('An error occured')
  }

  return data
}

const mapToProviders = (data) => data.providers

const tryUpdateStatusMessage = (providers) => {
  if (providers.length === 0) {
    statusMessage = 'No results found'
  }

  return providers
}

const inputTemplate = (value) => {
  return value && value.name
}

const setProviderHiddenField = (value) => {
  if (value === undefined) {
    return
  }

  idElement.value = value.id
}

const suggestionTemplate = (result) => {
  if (result) {
    if (typeof result === 'string') {
      return result
    } else if (typeof result === 'object') {
      const hints = [`Code ${result.code}`, result.name, result.ukprn].filter(Boolean)

      return `${result.name} <span class="autocomplete__option--hint">${hints.join(', ')}</span>`
    }
  } else return ''
}

const renderTemplate = {
  inputValue: inputTemplate,
  suggestion: suggestionTemplate
}

const findProviders = ({ query, populateResults }) => {
  idElement.value = ''

  const encodedQuery = encodeURIComponent(query)

  statusMessage = 'Loading...' // Shared state

  window.fetch(`/api/providers?query=${encodedQuery}`)
    .then(response => response.json())
    .then(guard)
    .then(mapToProviders)
    .then(tryUpdateStatusMessage)
    .then(populateResults)
    .catch(console.log)
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
