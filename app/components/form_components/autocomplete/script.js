import './style.scss'
import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-autocomplete"]')
const showAllValuesOption = component => Boolean(component.getAttribute('data-show-all-values'))
const defaultValueOption = component => component.getAttribute('data-default-value') || ''

const setupAutoComplete = (component) => {
  const selectEl = component.querySelector('select')

  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: defaultValueOption(component),
    selectElement: selectEl,
    showAllValues: showAllValuesOption(component)
  })

  // Fixes a bug whereby if the user enters a search term with no results
  // accesible-autocomplete defaults to the last valid input and there is no
  // error to handle.
  component.querySelector('input').addEventListener('keyup', () => {
    const noResults = component.querySelector('.autocomplete__option--no-results')
    if (noResults) selectEl.value = ''
  })
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
