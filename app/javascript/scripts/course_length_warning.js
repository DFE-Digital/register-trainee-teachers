// EYTDA course details: show the Course length warning and checkbox as soon as
// the dates make a full-time course longer than the usual 2 or 3 years.

const plural = (count, word) => `${count} ${word}${count === 1 ? '' : 's'}`

// "3 years", "2 years and 6 months", matching course_length_text on the server.
export function courseLength (start, end) {
  let months = (end.getFullYear() * 12 + end.getMonth()) - (start.getFullYear() * 12 + start.getMonth())
  if (end.getDate() < start.getDate()) months -= 1
  const years = Math.floor(months / 12)
  const remaining = months % 12

  return [
    years > 0 ? plural(years, 'year') : null,
    remaining > 0 || years === 0 ? plural(remaining, 'month') : null
  ].filter(Boolean).join(' and ')
}

// The date in a GOV.UK date field, or null until it's a whole, real date.
// The autofill script moves each field's name to data-nameoriginal, and a field
// with an error gets a different id, so look for either name.
export function dateFrom (form, name) {
  const part = (suffix) => {
    const fieldName = `course_details_form[${name}(${suffix})]`
    const input = form.querySelector(`[data-nameoriginal="${fieldName}"], [name="${fieldName}"]`)
    return (input?.value || '').trim()
  }
  const [day, month, year] = ['3i', '2i', '1i'].map(part)
  if (!/^\d{1,2}$/.test(day) || !/^\d{1,2}$/.test(month) || !/^\d{4}$/.test(year)) return null

  const date = new Date(Number(year), Number(month) - 1, Number(day))
  return date.getDate() === Number(day) && date.getMonth() === Number(month) - 1 ? date : null
}

export default class CourseLengthWarning {
  static init () {
    document.querySelectorAll('[data-module="app-course-length"]').forEach((section) => new CourseLengthWarning(section))
  }

  constructor (section) {
    this.section = section
    this.form = section.closest('form')
    this.shown = section.querySelector('[data-course-length-shown]')
    this.text = section.querySelector('[data-course-length-text]')

    this.form.addEventListener('input', () => this.update())
    this.form.addEventListener('change', () => this.update())
  }

  fullTime () {
    const studyMode = this.form.querySelector('input[name="course_details_form[study_mode]"]:checked')
    return studyMode ? studyMode.value === 'full_time' : this.section.dataset.fullTime === 'true'
  }

  update () {
    const start = dateFrom(this.form, 'itt_start_date')
    const end = dateFrom(this.form, 'itt_end_date')
    let longer = false

    // An end date past the latest year allowed gets an error instead.
    if (this.fullTime() && start && end && end.getFullYear() <= Number(this.section.dataset.latestYear)) {
      const usualEnd = new Date(start)
      usualEnd.setFullYear(start.getFullYear() + Number(this.section.dataset.usualYears))
      longer = end > usualEnd
    }

    if (longer) this.text.textContent = this.section.dataset.warning.replace('{length}', courseLength(start, end))
    this.section.hidden = !longer
    this.shown.value = longer ? '1' : ''
  }
}
