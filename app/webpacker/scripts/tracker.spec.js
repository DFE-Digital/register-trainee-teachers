import tracker from '../../components/form_components/tracker.js'

describe('tracker', () => {
  beforeAll(() => {
    jest.spyOn(Date, 'now').mockImplementation(() => Date.now())
  })

  afterAll(() => { jest.restoreAllMocks() })

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
      jest.spyOn(global, 'window', 'get')
        .mockImplementation(() => ({
          dataLayer: { push: mockedPush }
        }))
    })

    describe('when no match is selected', () => {
      it('sends the autocomplete-search event with the correct params', () => {
        tracker.searches = ['fl', 'flo', 'flow', 'flowe', 'flower']
        tracker.sendTrackingEvent(undefined, 'flower_search')

        expect(mockedPush).toBeCalledWith({
          event: 'autocomplete-search',
          fieldName: 'flower_search',
          failedSearches: ['flower'],
          successfulSearch: undefined,
          match: undefined,
          timeTaken: undefined
        })
      })
    })

    describe('when a match is selected and there were previously failed searches', () => {
      it('excludes the successful search from failedSearches, sends the successfulSearch and the match', () => {
        tracker.searches = ['fl', 'flo', 'flow', 'flowe', 'flower', 'ro']
        tracker.sendTrackingEvent('rose', 'flower_search')

        expect(mockedPush).toBeCalledWith({
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
        expect(mockedPush).not.toBeCalled()
      })
    })

    it('empties searches array', () => {
      tracker.searches = ['fl', 'flo', 'flow', 'flowe', 'flower']
      tracker.sendTrackingEvent('flower', 'flower_search')
      expect(tracker.searches).toEqual([])
    })
  })
})
