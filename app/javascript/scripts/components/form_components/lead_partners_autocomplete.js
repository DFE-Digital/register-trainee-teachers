import accessibleAutocomplete from 'accessible-autocomplete'
import tracker from './tracker.js'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-lead-partners-autocomplete"]')
const idElement = document.getElementById('lead-partners-id')

let statusMessage = ' '

const guard = (data) => {
  if (data === undefined) {
    return new Error('An error occured')
  }

  return data
}

const mapToLeadPartners = (data) => data.lead_partners

const tryUpdateStatusMessage = (leadPartners) => {
  if (leadPartners.length === 0) {
    statusMessage = 'No results found'
  }

  return leadPartners
}

const findLeadPartners = ({ query, populateResults }) => {
  idElement.value = ''

  const encodedQuery = encodeURIComponent(query)

  statusMessage = 'Loading...' // Shared state

  window.fetch(`/autocomplete/lead_partners?query=${encodedQuery}`)
    .then(response => response.json())
    .then(guard)
    .then(mapToLeadPartners)
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

const setLeadPartnerHiddenField = (value) => {
  if (value === undefined) {
    return
  }

  idElement.value = value.id
}

const setupAutoComplete = (form) => {
  const element = form.querySelector('#lead-partners-autocomplete-element')
  const inputs = form.querySelectorAll('[data-field="lead-partners-autocomplete"]')
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
          return findLeadPartners({
            query,
            populateResults,
          })
        },
        templates: renderTemplate,
        onConfirm: (value) => {
          if (value?.id && element.dataset.systemAdminRedirectLeadPartner) {
            window.location.assign(`/system-admin/lead-partners/${value.id}`)
          } else {
            tracker.sendTrackingEvent(value, fieldName)
            setLeadPartnerHiddenField(value)
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
