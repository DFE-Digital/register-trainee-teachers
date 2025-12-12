import accessibleAutocomplete from 'accessible-autocomplete'

const $allAutocompleteElements = document.querySelectorAll('[data-module="app-users-autocomplete"]')

let statusMessage = ' '
let userSelected = false

const guard = (data) => {
  if (data === undefined) {
    return new Error('An error occurred')
  }

  return data
}

// Sort two things alphabetically, not case-sensitive
const sortAlphabetical = (x, y) => {
  if (x.toLowerCase() !== y.toLowerCase()) {
    x = x.toLowerCase()
    y = y.toLowerCase()
  }
  return x > y ? 1 : (x < y ? -1 : 0)
}

const tryUpdateStatusMessage = (users) => {
  if (users.length === 0) {
    statusMessage = 'No results found'
  }

  return users
}

// The autocomplete plugin prevents the user from submitting the form on enter
const overrideEnterKey = (form, autocompleteElement) => {
  form.addEventListener('keydown', function (event) {
    if (event.keyCode === 13 && !userSelected) {
      const input = autocompleteElement.querySelector('input')
      const searchField = document.createElement('input')
      searchField.setAttribute('type', 'hidden')
      searchField.setAttribute('name', 'search')
      searchField.setAttribute('value', input.value)
      form.appendChild(searchField)
      input.removeAttribute('name')
      form.submit()
    }
  })
}

const findUsers = ({ query, populateResults }) => {
  const encodedQuery = encodeURIComponent(query)

  statusMessage = 'Loading...'

  window.fetch(`/autocomplete/users?query=${encodedQuery}`)
    .then(response => response.json())
    .then(guard)
    .then(data => data.users)
    .then(tryUpdateStatusMessage)
    .then(populateResults)
    .catch(console.log)
}

const inputTemplate = (user) => {
  return user && `${user.first_name} ${user.last_name}`
}

const suggestionTemplate = (user) => {
  if (typeof user === 'object' && 'first_name' in user) {
    const providerNames = user.providers.map(provider => provider.name).sort(sortAlphabetical)
    const trainingPartners = user.training_partners.map(partner => partner.name).sort(sortAlphabetical)
    const name = `${user.first_name} ${user.last_name}`
    const allOrgs = providerNames.concat(trainingPartners)

    return `${name} <span class="autocomplete__option--hint">${user.email}<br>${allOrgs.join(', ')}</span>`
  } else {
    return 'No results found'
  }
}

const renderTemplate = {
  inputValue: inputTemplate,
  suggestion: suggestionTemplate
}

const setupAutoComplete = (form) => {
  const inputs = form.querySelectorAll('[data-field="users-autocomplete"]')
  const autocompleteElement = form.querySelector('#users-autocomplete-element')
  const fieldName = autocompleteElement.getAttribute('data-field-name') || ''
  const defaultValue = autocompleteElement.getAttribute('data-default-value') || ''
  const inputFormGroup = autocompleteElement.previousElementSibling

  try {
    inputs.forEach(input => {
      accessibleAutocomplete({
        element: autocompleteElement,
        id: input.id,
        minLength: 2,
        name: fieldName,
        defaultValue,
        source: (query, populateResults) => {
          return findUsers({
            query,
            populateResults
          })
        },
        templates: renderTemplate,
        onConfirm: (user) => {
          if (user) {
            userSelected = true
            window.location.assign(`/system-admin/users/${user.id}`)
          }
        },
        tNoResults: () => statusMessage
      })

      // Move autocomplete to the form group containing the input to be replaced
      if (inputFormGroup.contains(input)) {
        inputFormGroup.appendChild(autocompleteElement)
      }

      input.remove()

      overrideEnterKey(form, autocompleteElement)
    })
  } catch (err) {
    console.error('Could not enhance:', err)
  }
}

$allAutocompleteElements.forEach(setupAutoComplete)
