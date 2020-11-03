import './style.scss'
import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-autocomplete"]')
const showAllValuesOption = component => Boolean(component.getAttribute('data-show-all-values'))
const defaultValueOption = component => component.getAttribute('data-default-value') || ''

const setupAutoComplete = (component) => {
  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: defaultValueOption(component),
    selectElement: component.querySelector('select'),
    showAllValues: showAllValuesOption(component)
  })
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
