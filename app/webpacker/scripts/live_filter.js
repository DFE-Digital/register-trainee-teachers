import $ from 'jquery'

export default class LiveFilter {
  static init () {
    return new LiveFilter()
  }

  constructor () {
    this.form = document.querySelector('#js-live-filter')
    this.resultsDiv = document.querySelector('#js-results')
    this.endpoint = this.form.attributes['data-search-endpoint'].value
    this.selectedFiltersDiv = document.querySelector('#js-selected-filters')
    this.traineeCount = document.querySelector('#js-trainee-count')
    this.actionBar = document.querySelector('#js-action-bar')

    this.state = null

    if (!(this.form && this.resultsDiv && this.selectedFiltersDiv)) return

    this.saveState()
    this.setInitialStateToHistory()
    this.hideButton()
    this.bindEvents()
  }

  updateUrl () {
    const newPath = window.location.pathname + '?' + $.param(this.state)
    window.history.pushState(this.state, '', newPath)
  }

  updatePage (response) {
    this.resultsDiv.innerHTML = response.results
    this.selectedFiltersDiv.innerHTML = response.selected_filters
    this.traineeCount.innerHTML = response.trainee_count
    this.actionBar.innerHTML = response.action_bar
    document.title = response.page_title
  }

  fetchResults (shouldUpdateUrl = true) {
    return $.ajax({
      url: this.endpoint,
      dataType: 'json',
      data: this.state
    }).done((response) => {
      // If we've arrived here from a popState action, don't update the URL -
      // popState does this already.
      if (shouldUpdateUrl) {
        this.updateUrl(response)
      }
      this.updatePage(response)
    })
  }

  restoreCheckboxes () {
    const checkboxes = this.form.querySelectorAll('input[type=checkbox]')
    checkboxes.forEach(box => {
      const selected = this.isSelected(box.getAttribute('name'), box.value)
      box.checked = selected
      box.blur()
    })
  }

  isSelected (name, value) {
    let i, _i
    for (i = 0, _i = this.state.length; i < _i; i++) {
      if (this.state[i].name === name && this.state[i].value === value) { return true }
    }
    return false
  }

  restoreSelects () {
    const selects = this.form.querySelectorAll('select')
    selects.forEach(input => {
      input.value = this.textInputValue(input.getAttribute('name'))
    })
  }

  textInputValue (name) {
    let i, _i
    for (i = 0, _i = this.state.length; i < _i; i++) {
      if (this.state[i].name === name) { return this.state[i].value }
    }
    return ''
  }

  saveState (state) {
    if (typeof state === 'undefined') {
      // Save the serialised form data to state.
      const serialized = $(this.form).serializeArray()
      state = serialized.filter(field => field.value !== '')
    }
    this.state = state
  }

  popState (e) {
    if (e.state) {
      // Grab the state from the last event and overwrite our current state.
      this.saveState(e.state)
      this.fetchResults(false)
      // Make the form visually match the state.
      this.restoreCheckboxes()
      this.restoreSelects()
    }
  }

  setInitialStateToHistory () {
    window.history.replaceState(this.state, '')
  }

  formChange () {
    this.saveState()
    this.fetchResults()
  }

  bindEvents () {
    // Add event listeners to all form fields
    this.form.addEventListener('change', this.formChange.bind(this))
    // Add event listener for when the user navigates using browser back button
    window.addEventListener('popstate', this.popState.bind(this))
  }

  hideButton () {
    const submitButton = this.form.querySelector('#js-submit')
    $(submitButton).hide()
  }
}
