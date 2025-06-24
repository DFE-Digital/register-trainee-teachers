import tracker from './components/form_components/tracker.js'
jest.useFakeTimers('modern')

describe('tracker', () => {
  beforeAll(() => {
    jest.useFakeTimers('modern')
  })

  afterAll(() => {
    jest.restoreAllMocks()
    jest.useRealTimers()
  })

  describe('trackSearch', () => {
    it('pushes a search into the searches array', () => {
      tracker.trackSearch('flower')
      expect(tracker.searches).toEqual(['flower'])
    })
  })

  describe('sendTrackingEvent', () => {
    let mockedPush

    beforeEach(() => {
      mockedPush = jest.fn()
      global.window = Object.create(window)
      window.dataLayer = { push: mockedPush }
    })

    describe('when no match is selected', () => {
      it('sends the autocomplete-search event with the correct params', () => {
        tracker.searches = ['fl', 'flo', 'flow', 'flowe', 'flower']
        tracker.sendTrackingEvent(undefined, 'flower_search')

        expect(mockedPush).toHaveBeenCalledWith({
          event: 'autocomplete-search',
          fieldName: 'flower_search',
          failedSearches: ['flower'],
          successfulSearch: undefined,
          match: undefined,
          timeTaken: 0
        })
      })
    })

    describe('when a match is selected and there were previously failed searches', () => {
      it('excludes the successful search from failedSearches, sends the successfulSearch and the match', () => {
        tracker.searches = ['fl', 'flo', 'flow', 'flowe', 'flower', 'ro']
        tracker.sendTrackingEvent('rose', 'flower_search')

        expect(mockedPush).toHaveBeenCalledWith({
          event: 'autocomplete-search',
          fieldName: 'flower_search',
          failedSearches: ['flower'],
          successfulSearch: 'ro',
          match: 'rose'
        })
      })
    })

    describe('when a match is selected and no search was failed', () => {
      it('does not send an event', () => {
        tracker.searches = ['fl', 'flo', 'flow', 'flowe', 'flower']
        tracker.sendTrackingEvent('flower', 'flower_search')
        expect(mockedPush).not.toHaveBeenCalled()
      })
    })

    it('empties searches array', () => {
      tracker.searches = ['fl', 'flo', 'flow', 'flowe', 'flower']
      tracker.sendTrackingEvent('flower', 'flower_search')
      expect(tracker.searches).toEqual([])
    })
  })
})
