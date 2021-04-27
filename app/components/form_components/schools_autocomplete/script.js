import accessibleAutocomplete from 'accessible-autocomplete'

const $form = document.querySelector('[data-module="app-schools-autocomplete"]')
const id_element = document.getElementById("lead-school-id")

let statusMessage = null

const findSchools = (query, populateResults) =>  {
  statusMessage = 'Loading...';

  fetch(`/api/schools?query=${query}&lead_school=true`)
    .then(response => {
      return response.json()
    })
    .then(data => {
      if (data === undefined) {
        return
      }

      let schools = query ? data.schools : []

      if(schools.length === 0){
        statusMessage = 'No results found';
      }

      populateResults(schools)
    })
    .catch(err => console.log(err))
}


const suggestionTemplate = (value) => {
  return value && value.name
}

const inputTemplate = (value) => {
  return value && value.name
}

const renderTemplate = {
  inputValue: inputTemplate,
  suggestion: suggestionTemplate
}

const setParams = (value) => {
  if (value === undefined) {
    return
  }
  id_element.value = value.id
}

const setupAutoComplete = (form) => {
  const element = form.querySelector('#schools-autocomplete-element')

  accessibleAutocomplete({
    element: element,
    id: 'schools-autocomplete',
    minLength: 3,
    source: findSchools,
    templates: renderTemplate,
    onConfirm: setParams,
    showAllValues: false,
    tNoResults: () => statusMessage
  })
}

setupAutoComplete($form)
