function Tracker () {
  this.searches = []
  this.startTime = false

  this.trackSearch = (query) => {
    if (!this.startTime) { this.startTime = Date.now() }
    this.searches.push(query)
  }

  // Push an 'autocomplete-search' event to the dataLayer with the searches and
  // the final choice (if present).
  this.sendTrackingEvent = (val, fieldName) => {
    let successfulSearch
    let timeTaken
    const filteredSearches = this.searches.filter(s => !this._containsStringStartingWith(s))

    // Record the time taken from first search to selection (or giving up).
    if (this.startTime) { timeTaken = Date.now() - this.startTime }

    // If the user selected something i.e. val !== nil, then the last tracked
    // search counts as successful. Remove this.
    if (val) { successfulSearch = filteredSearches.pop() }

    if (filteredSearches.length > 0) {
      window.dataLayer.push({
        event: 'autocomplete-search',
        fieldName: fieldName,
        failedSearches: filteredSearches,
        successfulSearch: successfulSearch,
        match: val,
        timeTaken: timeTaken
      })
    }
    // Empty out the searches array.
    this.searches.splice(0, this.searches.length)
    this.startTime = false
  }

  // Returns true/false if any string in the array starts with the item (excluding)
  // the item itself.
  this._containsStringStartingWith = (item) => {
    const newArray = [...this.searches]
    newArray.splice(this.searches.indexOf(item), 1)
    return newArray.some(a => a.search(item) === 0)
  }
}

export default new Tracker()
