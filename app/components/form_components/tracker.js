function Tracker () {
  this.searches = []
  this.startTime = false

  this.trackSearch = (query) => {
    if (!this.startTime) { this.startTime = Date.now() }
    this.searches.push(query)
  }

  // Push an 'autocomplete-search' event to the dataLayer with the searches and
  // the final choice (if present).
  this.sendTrackingEvent = (match, fieldName) => {
    if (window.dataLayer) {
      let successfulSearch
      const filteredSearches = this.searches.filter(s => !this._containsStringStartingWith(s))

      // If the user selected something i.e. match !== nil, then the last tracked
      // search counts as successful. Remove this.
      if (match) { successfulSearch = filteredSearches.pop() }

      if (filteredSearches.length > 0) {
        window.dataLayer.push({
          event: 'autocomplete-search',
          fieldName: fieldName,
          failedSearches: filteredSearches,
          successfulSearch: successfulSearch,
          match: this._match(fieldName, match),
          timeTaken: this._timeTaken()
        })
      }
      // Empty out the searches array.
      this.searches.splice(0, this.searches.length)
      this.startTime = false
    }
  }

  // Returns true/false if any string in the array starts with the item (excluding)
  // the item itself.
  this._containsStringStartingWith = (item) => {
    const newArray = [...this.searches]
    newArray.splice(this.searches.indexOf(item), 1)
    return newArray.some(a => a.search(item) === 0)
  }

  this._isObject = (o) => {
    return !!o && o.constructor === Object
  }

  // Our school matches are objects - turn them into a more analysable string.
  this._match = (fieldName, match) => {
    if (fieldName.indexOf('school') !== -1 && this._isObject(match)) {
      return `${match.name} ${match.urn}`
    }
    return match
  }

  // Record the time taken from first search to selection (or giving up).
  this._timeTaken = () => {
    if (this.startTime) {
      return Date.now() - this.startTime
    }
  }
}

export default new Tracker()
