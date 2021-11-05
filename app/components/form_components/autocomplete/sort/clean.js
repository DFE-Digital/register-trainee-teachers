const clean = (word) => word.trim()
  .replace(/['’]/g, '')
  .replace(/[.,"/#!$%^&*;:{}=\-_`~()]/g, ' ')
  .toLowerCase()

export default clean
