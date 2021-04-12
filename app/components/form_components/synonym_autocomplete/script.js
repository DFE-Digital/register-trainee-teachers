import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-synonym-autocomplete"]')
const defaultValueOption = component => component.getAttribute('data-default-value') || ''

const setupAutoComplete = (component) => {
  const selectEl = component.querySelector('select')
  const selectOptions = Array.apply(null, selectEl.options)

  // Pull out rich data from the attributes on the select options.
  const options = selectOptions.map(option => {
    const boost = parseInt(option.getAttribute('data-boost'), 10) || 1
    let synonyms = option.getAttribute('data-synonyms')
    synonyms = synonyms ? synonyms.split('|') : []

    return {
      name: option.label,
      synonyms: synonyms,
      boost: boost
    }
  })

  // Returns a weighting for an option based on it's 'closeness' to a query.
  // The higher the weight, the better the match. Returns 0 if no match.
  const calculateWeight = ({ name, synonyms }, query) => {
    const queryRegexes = query.split(/\s+/).map(word => new RegExp('\\b' + word, 'i'))

    const matchPositions = (str) => queryRegexes.map(regex => str.search(regex))
    const nameMatchPositions = matchPositions(name).filter(i => i >= 0)
    const synonymMatchPositions = synonyms.map(synonym => matchPositions(synonym)).flat().filter(i => i >= 0)

    // Require all parts of the query to be matches:
    if (nameMatchPositions.length !== queryRegexes.length && synonymMatchPositions.length !== queryRegexes.length) return 0

    // Case insensitive exact matches:
    const nameIsExactMatch = name.toLowerCase() === query.toLowerCase()
    const synonymIsExactMatch = synonyms.some(s => s.toLowerCase() === query.toLowerCase())
    // Case insensitive 'starts with':
    const nameStartsWithQuery = nameMatchPositions.includes(0)
    const synonymStartsWithQuery = synonymMatchPositions.includes(0)
    const wordInNameStartsWithQuery = name.split(' ').map(w => matchPositions(w)).flat().includes(0)

    if (nameIsExactMatch) {
      return 100
    } else if (synonymIsExactMatch) {
      return 75
    } else if (nameStartsWithQuery) {
      return 60
    } else if (synonymStartsWithQuery) {
      return 50
    } else if (wordInNameStartsWithQuery) {
      return 25
    } else {
      return 0
    }
  }

  // Sort options by their weights. If they are equally weighted, sort alphabetically.
  const byWeightThenAlphabetically = (optionA, optionB) => {
    if (optionA.weight > optionB.weight) {
      return -1
    } else if (optionA.weight < optionB.weight) {
      return 1
    } else if (optionA.name < optionB.name) {
      return -1
    } else if (optionA.name > optionB.name) {
      return 1
    } else {
      return 0
    }
  }

  const source = (q, populateResults) => {
    // Tidy up the incoming query by trimming whitespace and removing punctuation.
    const query = q.trim().replace(/[.,/#!$%^&*;:{}=\-_`~()]/g, '')
    // Calculate weights for all our options, boosted by any provided factor.
    const matches = options.map(option => {
      option.weight = calculateWeight(option, query) * option.boost
      return option
    })

    // Remove anything that doesn't match.
    const filteredMatches = matches.filter(option => option.weight !== 0)
    // Sort those that do.
    const sortedFilteredMatches = filteredMatches.sort((a, b) => byWeightThenAlphabetically(a, b))
    // Show just the name.
    const results = sortedFilteredMatches.map(option => option.name)
    return populateResults(results)
  }

  const suggestionTemplate = (value) => {
    const option = selectOptions.find(o => o.label === value)
    const alt = option.getAttribute('data-alt')
    return alt ? `<span>${value}</span> <strong>(${alt})</strong>` : `<span>${value}</span>`
  }

  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: defaultValueOption(component),
    selectElement: selectEl,
    showAllValues: true,
    source: source,
    templates: {
      suggestion: suggestionTemplate
    }
  })

  component.querySelector('input').addEventListener('keyup', () => {
    const noResults = component.querySelector('.autocomplete__option--no-results')
    if (noResults) selectEl.value = ''
  })
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
