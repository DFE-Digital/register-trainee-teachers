import $ from 'jquery'
import LiveFilter from './live_filter'

describe('LiveFilter', () => {
  beforeEach(() => {
    const $form = $(`<form method="get" id="js-live-filter">
    <input type="submit" name="commit" value="Apply filters" id="js-submit">
    <input type="checkbox" name="level[]" id="level-early_years" value="early_years">
    <input type="checkbox" name="level[]" id="level-primary" value="primary">
    <select name="subject" id="subject" class="govuk-select"><option value="All subjects">All subjects</option>
      <option value="ancient hebrew">Ancient hebrew</option>
      <option value="applied biology">Applied biology</option>
      <option value="applied chemistry">Applied chemistry</option>
    </select>
    </form>`)

    const $results = $('<div id="js-results"></div>')
    const $selectedFilters = $('<div id="js-selected-filters"></div>')

    $('body').append($selectedFilters).append($form).append($results)
  })

  describe('constructor', () => {
    afterEach(() => {
      jest.clearAllMocks()
    })

    it('binds event form inputs', () => {
      jest.spyOn(LiveFilter.prototype, 'bindEvents')
      LiveFilter.init()
      expect(LiveFilter.prototype.bindEvents).toHaveBeenCalledTimes(1)
    })
  })

  describe('saveState', () => {
    let filter

    beforeEach(() => {
      filter = new LiveFilter()
    })

    it('updates with the new state', () => {
      filter.form.querySelector('#level-early_years').checked = true
      filter.saveState()
      expect(filter.state).toEqual([{ name: 'level[]', value: 'early_years' }, { name: 'subject', value: 'All subjects' }])
    })

    it('updates with a passed in state', () => {
      filter.saveState([{ name: 'new', value: 'state' }])
      expect(filter.state).toEqual([{ name: 'new', value: 'state' }])
    })
  })

  describe('popState', () => {
    let dummyHistoryState, filter

    beforeEach(() => {
      filter = new LiveFilter()
      dummyHistoryState = { state: true }
    })

    it('should call restoreBooleans, restoreTextInputs, saveState and updateResults if there is an event in the history', () => {
      jest.spyOn(filter, 'restoreCheckboxes')
      jest.spyOn(filter, 'restoreSelects')
      jest.spyOn(filter, 'saveState')
      jest.spyOn(filter, 'fetchResults')

      filter.popState(dummyHistoryState)

      expect(filter.restoreCheckboxes).toHaveBeenCalled()
      expect(filter.restoreSelects).toHaveBeenCalled()
      expect(filter.saveState).toHaveBeenCalled()
      expect(filter.fetchResults).toHaveBeenCalled()
    })
  })
})
