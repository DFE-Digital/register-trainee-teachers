// EYTDA course details: show the warning and the declaration as soon as the
// dates make the course longer than the usual 2 years or 33 months.

// The date a number of months after another, on the same day of the month or
// the last day of a shorter month, matching date + n.months on the server.
export function addMonths (date, months) {
  const target = new Date(date.getFullYear(), date.getMonth() + months, 1)
  const lastDay = new Date(target.getFullYear(), target.getMonth() + 1, 0).getDate()
  target.setDate(Math.min(date.getDate(), lastDay))
  return target
}

// The input for one part of a GOV.UK date field ('3i' day, '2i' month, '1i' year).
// The autofill script moves each field's name to data-nameoriginal, and a field
// with an error gets a different id, so look for either name.
export function dateInput (form, name, part) {
  const fieldName = `course_details_form[${name}(${part})]`
  return form.querySelector(`[data-nameoriginal="${fieldName}"], [name="${fieldName}"]`)
}

// The date in a GOV.UK date field, or null until it's a whole, real date.
export function dateFrom (form, name) {
  const [day, month, year] = ['3i', '2i', '1i'].map((part) => (dateInput(form, name, part)?.value || '').trim())
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

    this.form.addEventListener('input', () => this.update())
    this.form.addEventListener('change', () => this.update())
  }

  update () {
    const start = dateFrom(this.form, 'itt_start_date')
    const end = dateFrom(this.form, 'itt_end_date')
    const longer = Boolean(start && end && end > addMonths(start, Number(this.section.dataset.usualMonths)))

    this.section.hidden = !longer
    this.shown.value = longer ? '1' : ''
  }
}
