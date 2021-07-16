// Returns an array of integers representing the position of each regex match.
const matchPositions = (string, regexes) => regexes.map(regex => string.search(regex)).filter(i => i >= 0)

// Returns a lowercase string with some common punctation removed / replaced
// by whitespace.
const clean = s => s.trim().replace(/['’]/g, '').replace(/[.,"/#!$%^&*;:{}=\-_`~()]/g, ' ').toLowerCase()

// Determines how closely a query matches either an option's name/synonyms.
// Returns an integer ranging from 0 (no match) to 100 (exact name match).
const calculateWeight = (rawName, query, rawSynonyms = []) => {
  const regexes = clean(query).split(/\s+/).map(word => new RegExp('\\b' + word, 'i'))
  const name = clean(rawName)
  const synonyms = rawSynonyms.map(s => clean(s))

  const nameMatchPositions = matchPositions(name, regexes)
  const synonymMatchPositions = synonyms.map(synonym => matchPositions(synonym, regexes)).flat()

  // Require either all parts of a name to be matched, or all parts of a synonym
  const allNameMatches = nameMatchPositions.length === regexes.length
  const allSynonymMatches = synonymMatchPositions.length >= regexes.length
  if (!allNameMatches && !allSynonymMatches) return 0

  // Case insensitive exact matches:
  const nameIsExactMatch = query === name.toLowerCase()
  const synonymIsExactMatch = synonyms.some(s => query === s.toLowerCase())

  // Case insensitive 'starts with':
  const nameStartsWithQuery = nameMatchPositions.includes(0)
  const synonymStartsWithQuery = synonymMatchPositions.includes(0)
  const wordInNameStartsWithQuery = nameMatchPositions.length > 0

  if (nameIsExactMatch) return 100
  if (synonymIsExactMatch) return 75
  if (nameStartsWithQuery) return 60
  if (synonymStartsWithQuery) return 50
  if (wordInNameStartsWithQuery) return 25

  return 0
}

const byWeightThenAlphabetically = (a, b) => {
  if (a.weight > b.weight) return -1
  if (a.weight < b.weight) return 1
  if (a.name < b.name) return -1
  if (a.name > b.name) return 1

  return 0
}

export default (query, options) => {
  // Calculate a weight for each option and multiply by any boost supplied.
  //
  // The boost amount is a float and can be as large as the user wants. It is
  // meant to be 'tweakable' per option and should be fine-tuned based on user
  // research.
  //
  // For example a boost of 1.5 maked low matches (synonymStartsWithQuery and
  // wordInNameStartsWithQuery) bump up the list a lot, but would not position
  // them above an exact name match.
  options.forEach(o => { o.weight = calculateWeight(o.name, query, o.synonyms) * (o.boost || 1) })

  return options.filter(o => o.weight > 0)
    .sort(byWeightThenAlphabetically)
    .map(o => o.name)
}
