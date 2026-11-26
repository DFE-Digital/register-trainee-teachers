import CourseLengthWarning, { addMonths, dateFrom } from './course_length_warning'

// The day field as it is on a page with an error: a different id, and the name
// moved by the autofill script.
const dateFields = (name, [day, month, year]) => `
  <input id="course-details-form-${name}-field-error" name="x1" data-nameoriginal="course_details_form[${name}(3i)]" value="${day}">
  <input id="course_details_form_${name}_2i" name="x2" data-nameoriginal="course_details_form[${name}(2i)]" value="${month}">
  <input id="course_details_form_${name}_1i" name="course_details_form[${name}(1i)]" value="${year}">`

const templateHTML = (usualMonths, start, end) => `
<form>
  ${dateFields('itt_start_date', start)}
  ${dateFields('itt_end_date', end)}
  <div data-module="app-course-length" data-usual-months="${usualMonths}" hidden>
    <input type="hidden" data-course-length-shown value="">
  </div>
</form>`

const section = () => document.querySelector('[data-module="app-course-length"]')
const shown = () => document.querySelector('[data-course-length-shown]').value
const setEnd = (month, year) => {
  document.getElementById('course_details_form_itt_end_date_2i').value = month
  const input = document.getElementById('course_details_form_itt_end_date_1i')
  input.value = year
  input.dispatchEvent(new Event('input', { bubbles: true }))
}

describe('addMonths', () => {
  it('adds whole months', () => {
    expect(addMonths(new Date(2026, 8, 1), 33)).toEqual(new Date(2029, 5, 1))
    expect(addMonths(new Date(2026, 8, 1), 24)).toEqual(new Date(2028, 8, 1))
  })

  it('uses the last day of a shorter month', () => {
    expect(addMonths(new Date(2026, 7, 31), 33)).toEqual(new Date(2029, 4, 31))
    expect(addMonths(new Date(2026, 4, 31), 33)).toEqual(new Date(2029, 1, 28))
  })
})

describe('dateFrom', () => {
  it('needs a whole, real date', () => {
    document.body.innerHTML = `<form>${dateFields('itt_end_date', ['31', '2', '2029'])}</form>`
    expect(dateFrom(document.querySelector('form'), 'itt_end_date')).toBeNull()

    document.body.innerHTML = `<form>${dateFields('itt_end_date', ['1', '9', '202'])}</form>`
    expect(dateFrom(document.querySelector('form'), 'itt_end_date')).toBeNull()
  })
})

describe('CourseLengthWarning', () => {
  describe('the standard length, 33 months', () => {
    beforeEach(() => {
      document.body.innerHTML = templateHTML(33, ['1', '9', '2026'], ['1', '6', '2029'])
      CourseLengthWarning.init()
    })

    it('shows the warning once the end date is later than 33 months', () => {
      setEnd('9', '2029')

      expect(section().hidden).toBe(false)
      expect(shown()).toEqual('1')
    })

    it('hides it again when the end date is back to 33 months', () => {
      setEnd('9', '2029')
      setEnd('6', '2029')

      expect(section().hidden).toBe(true)
      expect(shown()).toEqual('')
    })

    it('shows it for an end date many years ahead', () => {
      setEnd('9', '2036')

      expect(section().hidden).toBe(false)
    })

    it('does not show it for a year that is not 4 digits', () => {
      setEnd('9', '20299')

      expect(section().hidden).toBe(true)
    })
  })

  describe('Year 2 entry, 2 years', () => {
    beforeEach(() => {
      document.body.innerHTML = templateHTML(24, ['1', '9', '2026'], ['1', '9', '2028'])
      CourseLengthWarning.init()
    })

    it('shows the warning once the end date is later than 2 years', () => {
      setEnd('10', '2028')

      expect(section().hidden).toBe(false)
    })
  })
})
