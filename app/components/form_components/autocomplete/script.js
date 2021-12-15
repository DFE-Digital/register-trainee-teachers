import './style.scss'
import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common'
import sort from './sort'
import tracker from '../tracker.js'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-autocomplete"]')
const defaultValueOption = component => component.getAttribute('data-default-value') || ''

const suggestion = (value, options) => {
  const option = options.find(o => o.name === value)
  if (option) {
    const html = option.append ? `<span>${value}</span> ${option.append}` : `<span>${value}</span>`
    return option.hint ? `${html}<br>${option.hint}` : html
  }
}

const enhanceOption = (option) => {
  return {
    name: option.label,
    synonyms: (option.getAttribute('data-synonyms') ? option.getAttribute('data-synonyms').split('|') : []),
    append: option.getAttribute('data-append'),
    hint: option.getAttribute('data-hint'),
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
  const matches = /^(\w+)\[(\w+)\]$/.exec(selectEl.name)
  const rawFieldName = `${matches[1]}[${matches[2]}_raw]`

  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: inError ? '' : inputValue,
    selectElement: selectEl,
    minLength: 2,
    source: (query, populateResults) => {
      tracker.trackSearch(query)
      populateResults(sort(query, options))
    },
    autoselect: true,
    templates: { suggestion: (value) => suggestion(value, options) },
    name: rawFieldName,
    onConfirm: (val) => {
      tracker.sendTrackingEvent(val, selectEl.name)
      const selectedOption = [].filter.call(selectOptions, option => (option.textContent || option.innerText) === val)[0]
      if (selectedOption) selectedOption.selected = true
    }
  })

  if (inError) {
    component.querySelector('input').value = inputValue
  }
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
