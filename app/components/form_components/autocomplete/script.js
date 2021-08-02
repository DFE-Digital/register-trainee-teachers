import './style.scss'
import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common'
import sort from './sort.js'
import { trackFailedSearch, sendTrackingEvent } from './tracker.js'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-autocomplete"]')
const defaultValueOption = component => component.getAttribute('data-default-value') || ''

const suggestion = (value, options) => {
  const option = options.find(o => o.name === value)
  if (option) {
    return option.append ? `<span>${value}</span> ${option.append}` : `<span>${value}</span>`
  }
}

const enhanceOption = (option) => {
  return {
    name: option.label,
    synonyms: (option.getAttribute('data-synonyms') ? option.getAttribute('data-synonyms').split('|') : []),
    append: option.getAttribute('data-append'),
    boost: (parseFloat(option.getAttribute('data-boost')) || 1)
  }
}

const setupAutoComplete = (component) => {
  const selectEl = component.querySelector('select')
  const selectOptions = Array.from(selectEl.options)
  const options = selectOptions.map(o => enhanceOption(o))
  const inError = component.querySelector('div.govuk-form-group').className.includes('error')
  const inputValue = defaultValueOption(component)

  // We add a name which we base off the name for the select element and add "raw" to it, eg
  // if there is a select input called "course_details[subject]" we add a name to the text input
  // as "course_details[subject_raw]"
  const matches = /(\w+)\[(\w+)\]/.exec(selectEl.name)
  const rawFieldName = `${matches[1]}[${matches[2]}_raw]`

  // For tracking failed search attempts
  const queries = []
  const failedSearches = []

  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: inError ? '' : inputValue,
    selectElement: selectEl,
    minLength: 2,
    source: (query, populateResults) => {
      queries.push(query)
      trackFailedSearch(queries, failedSearches)
      populateResults(sort(query, options))
    },
    autoselect: true,
    templates: { suggestion: (value) => suggestion(value, options) },
    name: rawFieldName,
    onConfirm: (val) => {
      sendTrackingEvent(failedSearches, val)
      // The below is copied directly from autocomplete source code. Providing
      // your own `onConfirm` function seems to override the default functionality... https://github.com/alphagov/accessible-autocomplete/blob/935f0d43aea1c606e6b38985e3fe7049ddbe98be/src/wrapper.js
      const requestedOption = [].filter.call(selectOptions, option => (option.textContent || option.innerText) === val)[0]
      if (requestedOption) requestedOption.selected = true
    }
  })

  if (inError) {
    component.querySelector('input').value = inputValue
  }
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
