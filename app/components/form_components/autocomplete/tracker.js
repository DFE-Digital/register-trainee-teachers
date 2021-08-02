const trackFailedSearch = (queries, failedSearches) => {
  const query = queries[queries.length - 1]
  const lastQuery = queries[queries.length - 2]
  const lastFailedSeach = failedSearches[failedSearches.length - 1]

  const pressedDelete = lastQuery && query.length < lastQuery.length
  const isSubstring = lastFailedSeach && lastFailedSeach.indexOf(query) !== -1
  // If a user is deleting, we assume that their search failed, so add the
  // last query to the failedSearched array.
  //
  // However, we don't want to store all substrings of previous failed searches
  // as the user deletes words character-by-character.
  if (pressedDelete && !isSubstring) failedSearches.push(lastQuery)
}

const sendTrackingEvent = (val, failedSearches) => {
  if (val && failedSearches.length > 0) {
    window.dataLayer.push({
      event: 'autocomplete-search',
      failedSearches: failedSearches,
      match: val
    })
  }
}

export { trackFailedSearch, sendTrackingEvent }