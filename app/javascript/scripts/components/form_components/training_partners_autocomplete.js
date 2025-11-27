import accessibleAutocomplete from 'accessible-autocomplete'
import tracker from './tracker.js'
import { guard, renderTemplate, setHiddenField } from './autocomplete/helpers.js'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-training-partners-autocomplete"]')
const idElement = document.getElementById('lead-partners-id')

let statusMessage = ' '

const fetchLeadPartners = ({ query, populateResults }) => {
  const encodedQuery = encodeURIComponent(query)

  window.fetch(`/autocomplete/training-partners?query=${encodedQuery}`)
    .then(response => response.json())
    .then(guard)
    .then(data => data.lead_partners)
    .then((leadPartners) => {
      if (leadPartners.length === 0) {
        statusMessage = 'No results found'
      }

      return leadPartners
    })
    .then(populateResults)
    .catch(console.log)
}

const findLeadPartners = ({ query, populateResults }) => {
  idElement.value = ''

  statusMessage = 'Loading...' // Shared state

  fetchLeadPartners({ query, populateResults })
}

const setupAutoComplete = (form) => {
  const element = form.querySelector('#training-partners-autocomplete-element')
  const inputs = form.querySelectorAll('[data-field="training-partners-autocomplete"]')
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
            populateResults
          })
        },
        templates: renderTemplate,
        onConfirm: (value) => {
          if (value?.id && element.dataset.systemAdminRedirectTrainingPartner) {
            window.location.assign(`/system-admin/training-partners/${value.id}`)
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
