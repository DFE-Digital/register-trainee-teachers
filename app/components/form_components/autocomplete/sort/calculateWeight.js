const exactMatch = (word, query) => (word === query)

const startsWithReqExp = (query) => new RegExp('\\b' + query, 'i')
const startsWith = (word, query) => (word.search(startsWithReqExp(query)) === 0)

const wordsStartsWithQuery = (word, regExps) => regExps.every(
  (regExp) => (word.search(regExp) >= 0)
)

const anyMatch = (words, query, evaluatorFunc) =>
  words.some((word) => evaluatorFunc(word, query))
const synonymsExactMatch = (synonyms, query) =>
  anyMatch(synonyms, query, exactMatch)
const synonymsStartsWith = (synonyms, query) =>
  anyMatch(synonyms, query, startsWith)
const wordInSynonymStartsWithQuery = (synonyms, startsWithQueryWordsRegexes) =>
  anyMatch(synonyms, startsWithQueryWordsRegexes, wordsStartsWithQuery)

// NOTE: Determines how the query matches either an option's name/synonyms.
// Returns an integer ranging from 0 (no match) to 100 (exact match).
const calculateWeight = ({ name, synonyms }, query) => {
  if (exactMatch(name, query)) return 100
  if (synonymsExactMatch(synonyms, query)) return 75
  if (startsWith(name, query)) return 60
  if (synonymsStartsWith(synonyms, query)) return 50

  const startsWithReqExps = query.split(/\s+/).map(startsWithReqExp)

  if (wordsStartsWithQuery(name, startsWithReqExps)) return 25
  if (wordInSynonymStartsWithQuery(synonyms, startsWithReqExps)) return 10

  return 0
}

export {
  exactMatch,
  startsWithReqExp,
  startsWith,
  wordsStartsWithQuery,
  synonymsExactMatch,
  synonymsStartsWith,
  wordInSynonymStartsWithQuery
}

export default calculateWeight
