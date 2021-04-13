import accessibleAutocomplete from 'accessible-autocomplete'
import { nodeListForEach } from 'govuk-frontend/govuk/common'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-synonym-autocomplete"]')
const defaultValueOption = component => component.getAttribute('data-default-value') || ''

const setupAutoComplete = (component) => {
  const selectEl = component.querySelector('select')
  const selectOptions = Array.apply(null, selectEl.options)

  const options = selectOptions.map(option => {
    let synonyms = option.getAttribute('data-synonyms')
    synonyms = synonyms ? synonyms.split('|') : []
    return {
      name: option.label,
      synonyms: synonyms
    }
  })

  const regexes = (query) => {
    return query.trim().split(/\s+/).map(word => {
      const pattern = '\\b' + word.replace(/[-[\]/{}()*+?.\\^$|]/g, '\\$&')
      return new RegExp(pattern, 'i')
    })
  }

  const source = (query, populateResults) => {
    const optionsWithPositions = options.map(option => {
      const allTerms = [option.name].concat(option.synonyms)

      option.resultPosition = null

      allTerms.forEach(term => {
        const matches = regexes(query).reduce((acc, regex) => {
          const matchPosition = term.search(regex)

          if (matchPosition > -1) {
            acc.count += 1

            // Is this match earlier on in the result?
            if (acc.earliestPosition === -1 || matchPosition < acc.earliestPosition) {
              acc.earliestPosition = matchPosition
            }
          }
          return acc
        }, { count: 0, earliestPosition: -1 })

        // Save the earliest matched postiion, but require all search terms present.
        if (matches.count === regexes(query).length && (option.resultPosition == null || matches.earliestPosition < option.resultPosition)) {
          option.resultPosition = matches.earliestPosition
        }
      })

      return option
    })

    const filteredMatches = optionsWithPositions.filter(option => option.resultPosition != null)

    const sortedFilteredMatches = filteredMatches.sort((optionA, optionB) => {
      // Favour 'earlier' matches
      if (optionA.resultPosition < optionB.resultPosition) return -1
      if (optionA.resultPosition > optionB.resultPosition) return 1
      return 0
    })

    const results = sortedFilteredMatches.map(option => option.name)

    return populateResults(results)
  }

  const suggestion = (value) => {
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
      suggestion
    }
  })

  component.querySelector('input').addEventListener('keyup', () => {
    const noResults = component.querySelector('.autocomplete__option--no-results')
    if (noResults) selectEl.value = ''
  })
}

nodeListForEach($allAutocompleteElements, setupAutoComplete)
