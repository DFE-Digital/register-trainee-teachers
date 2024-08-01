export const guard = (data) => {
  if (data === undefined) {
    return new Error('An error occured')
  }

  return data
}

const prefixed_result = (prefix, value) => {
  if (value) {
    return `${prefix} ${value}`
  } else {
    return null;
  }
}

const suggestionTemplate = (result) => {
  if (result) {
    if (typeof result === 'string') {
      return result
    } else if (typeof result === 'object') {
      const hints = [
        prefixed_result('URN', result.urn),
        prefixed_result('UKPRN', result.ukprn),
        result.town,
        result.postcode
      ].filter(Boolean)

      return `${result.name} <span class="autocomplete__option--hint">${hints.join(', ')}</span>`
    }
  } else return ''
}

const inputTemplate = (value) => {
  return value && value.name
}

export const renderTemplate = {
  inputValue: inputTemplate,
  suggestion: suggestionTemplate
}

export const setHiddenField = (idElement, value) => {
  if (value === undefined) {
    return
  }

  idElement.value = value.id
}
