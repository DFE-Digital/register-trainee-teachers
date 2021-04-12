import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-synonym-autocomplete"]')
const defaultValueOption = component => component.getAttribute('data-default-value') || ''

// Returns an array of integers representing the position of each regex match.
// 0 = the beginning of the string, -1 = no match.
const matchPositions = (string, regexes) => regexes.map(regex => string.search(regex))

const calculateWeight = (name, synonyms, query) => {
  const regexes = query.split(/\s+/).map(word => new RegExp('\\b' + word, 'i'))

  const nameMatchPositions = matchPositions(name, regexes).filter(i => i >= 0)
  const synonymMatchPositions = synonyms.map(synonym => matchPositions(synonym, regexes)).flat().filter(i => i >= 0)

  // Require all parts of the query to be matched:
  if (nameMatchPositions.length !== regexes.length && synonymMatchPositions.length !== regexes.length) return 0

  // Case insensitive exact matches:
  const nameIsExactMatch = name.toLowerCase() === query.toLowerCase()
  const synonymIsExactMatch = synonyms.some(s => s.toLowerCase() === query.toLowerCase())
  // Case insensitive 'starts with':
  const nameStartsWithQuery = nameMatchPositions.includes(0)
  const synonymStartsWithQuery = synonymMatchPositions.includes(0)
  const wordInNameStartsWithQuery = nameMatchPositions.length > 0

  if (nameIsExactMatch) return 100
  if (synonymIsExactMatch) return 75
  if (nameStartsWithQuery) return 60
  if (synonymStartsWithQuery) return 50
  if (wordInNameStartsWithQuery) return 25
  return 0
}

const byWeightThenAlphabetically = (a, b) => {
  if (a.weight > b.weight) return -1
  if (a.weight < b.weight) return 1
  if (a.name < b.name) return -1
  if (a.name > b.name) return 1
  return 0
}

const source = (q, populateResults, selectOptions) => {
  const query = q.trim().replace(/[.,/#!$%^&*;:{}=\-_`~()]/g, '')

  const optionsWithWeights = selectOptions.map(option => {
    const boost = parseInt(option.getAttribute('data-boost'), 10) || 1
    const synonyms = option.getAttribute('data-synonyms') ? option.getAttribute('data-synonyms').split('|') : []
    return {
      name: option.label,
      weight: calculateWeight(option.label, synonyms, query) * boost
    }
  })

  const matches = optionsWithWeights.filter(option => option.weight > 0)
  const results = matches.sort(byWeightThenAlphabetically).map(option => option.name)

  return populateResults(results)
}

const suggestion = (value, selectOptions) => {
  const option = selectOptions.find(o => o.label === value)
  const alt = option.getAttribute('data-alt')
  return alt ? `<span>${value}</span> <strong>(${alt})</strong>` : `<span>${value}</span>`
}

const setupAutoComplete = (component) => {
  const selectEl = component.querySelector('select')
  const selectOptions = Array.apply(null, selectEl.options)

  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: defaultValueOption(component),
    selectElement: selectEl,
    showAllValues: true,
    source: (query, populateResults) => source(query, populateResults, selectOptions),
    templates: {
      suggestion: (value) => suggestion(value, selectOptions)
    }
  })

  component.querySelector('input').addEventListener('keyup', () => {
    const noResults = component.querySelector('.autocomplete__option--no-results')
    if (noResults) selectEl.value = ''
  })
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
