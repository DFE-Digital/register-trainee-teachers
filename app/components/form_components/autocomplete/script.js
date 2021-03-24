import './style.scss'
import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-autocomplete"]')
const showAllValuesOption = component => Boolean(component.getAttribute('data-show-all-values'))
const disableAutoselectOption = component => Boolean(component.getAttribute('data-disable-autoselect'))
const disableConfirmOnBlurOption = component => Boolean(component.getAttribute('data-disable-confirm-on-blur'))
const defaultValueOption = component => component.getAttribute('data-default-value') || ''

const suggestionTemplate = (value) => {
  const matches = /(.+)\(([^)]+)\)/.exec(value)
  if (matches) {
    return `<span>${matches[1]}</span> <strong>(${matches[2]})</strong>`
  } else {
    return `<span>${value}</span>`
  }
}

const setupAutoComplete = (component) => {
  const selectEl = component.querySelector('select')

  // We add a name which we base off the name for the select element and add "raw" to it, eg
  // if there is a select input called "course_details[subject]" we add a name to the text input
  // as "course_details[subject_raw]"
  const matches = /(\w+)\[(\w+)\]/.exec(selectEl.name)
  const group = matches[1]
  const field = matches[2]
  const rawFieldName = `${matches[1]}[${matches[2]}_raw]`

  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: defaultValueOption(component),
    selectElement: selectEl,
    showAllValues: showAllValuesOption(component),
    autoselect: !disableAutoselectOption(component),
    confirmOnBlur: !disableConfirmOnBlurOption(component),
    templates: { suggestion: suggestionTemplate },
    name: rawFieldName
  })
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
