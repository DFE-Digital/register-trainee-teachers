import { nodeListForEach } from 'govuk-frontend/govuk/common'
import openregisterLocationPicker from 'govuk-country-and-territory-autocomplete'

const $allCountryAutoCompleteElements = document.querySelectorAll('[data-module="app-country-autocomplete"]')
const defaultValueOption = component => component.getAttribute('data-default-value') || ''

nodeListForEach($allCountryAutoCompleteElements, (component) => {
  const selectEl = component.querySelector('select')
  const inputValue = defaultValueOption(component)

  // We add a name which we base off the name for the select element and add "raw" to it, eg
  // if there is a select input called "course_details[subject]" we add a name to the text input
  // as "course_details[subject_raw]"
  const matches = /(\w+)\[(\w+)\]/.exec(selectEl.name)
  const rawFieldName = `${matches[1]}[${matches[2]}_raw]`

  openregisterLocationPicker({
    defaultValue: inputValue,
    selectElement: component.querySelector('select'),
    name: rawFieldName,
    url: '/location-autocomplete-graph.json'
  })
})
