// EYTDA course details: the expected end date is filled in from the usual
// course length (2 years or 33 months). It moves with the start date until the
// provider changes the end date themselves.
import { addMonths, dateFrom, dateInput } from './course_length_warning'

const PARTS = {
  '3i': (date) => date.getDate(),
  '2i': (date) => date.getMonth() + 1,
  '1i': (date) => date.getFullYear()
}

export default class CourseEndDate {
  static init () {
    document.querySelectorAll('[data-module="app-course-end-date"]').forEach((element) => new CourseEndDate(element))
  }

  constructor (element) {
    this.form = element.closest('form')
    this.months = Number(element.dataset.fillMonths)
    this.filled = this.endDateFilledIn()

    element.addEventListener('input', (event) => this.changed(event))
  }

  endInput (part) {
    return dateInput(this.form, 'itt_end_date', part)
  }

  // The end date is blank, or the one filled in from the start date.
  endDateFilledIn () {
    if (Object.keys(PARTS).every((part) => (this.endInput(part)?.value || '').trim() === '')) return true

    const start = dateFrom(this.form, 'itt_start_date')
    const end = dateFrom(this.form, 'itt_end_date')
    return Boolean(start && end && end.getTime() === addMonths(start, this.months).getTime())
  }

  changed (event) {
    if (Object.keys(PARTS).some((part) => this.endInput(part) === event.target)) {
      this.filled = this.endDateFilledIn()
      return
    }

    const start = dateFrom(this.form, 'itt_start_date')
    if (!this.filled || !start) return

    const end = addMonths(start, this.months)
    Object.entries(PARTS).forEach(([part, value]) => { this.endInput(part).value = value(end) })
    // Tell the course length warning the end date changed.
    this.endInput('1i').dispatchEvent(new Event('input', { bubbles: true }))
  }
}
