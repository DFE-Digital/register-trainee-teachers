import CourseLengthWarning, { courseLength, dateFrom } from './course_length_warning'

// The day field as it is on a page with an error: a different id, and the name
// moved by the autofill script.
const dateFields = (name, [day, month, year]) => `
  <input id="course-details-form-${name}-field-error" name="x1" data-nameoriginal="course_details_form[${name}(3i)]" value="${day}">
  <input id="course_details_form_${name}_2i" name="x2" data-nameoriginal="course_details_form[${name}(2i)]" value="${month}">
  <input id="course_details_form_${name}_1i" name="course_details_form[${name}(1i)]" value="${year}">`

const templateHTML = (start, end) => `
<form>
  <input type="radio" name="course_details_form[study_mode]" value="full_time" checked>
  <input type="radio" name="course_details_form[study_mode]" value="part_time">
  ${dateFields('itt_start_date', start)}
  ${dateFields('itt_end_date', end)}
  <div data-module="app-course-length" data-usual-years="2" data-latest-year="2031" data-full-time="true"
       data-warning="This course is {length}. Courses for trainees with a level 5 qualification are usually 2 years." hidden>
    <input type="hidden" data-course-length-shown value="">
    <span data-course-length-text></span>
  </div>
</form>`

const section = () => document.querySelector('[data-module="app-course-length"]')
const shown = () => document.querySelector('[data-course-length-shown]').value
const setEndYear = (year) => {
  const input = document.getElementById('course_details_form_itt_end_date_1i')
  input.value = year
  input.dispatchEvent(new Event('input', { bubbles: true }))
}

describe('courseLength', () => {
  it('describes whole years', () => {
    expect(courseLength(new Date(2026, 8, 1), new Date(2029, 8, 1))).toEqual('3 years')
  })

  it('describes years and months', () => {
    expect(courseLength(new Date(2026, 8, 1), new Date(2029, 2, 1))).toEqual('2 years and 6 months')
    expect(courseLength(new Date(2026, 8, 1), new Date(2027, 9, 1))).toEqual('1 year and 1 month')
  })

  it('counts a month only once it has passed', () => {
    expect(courseLength(new Date(2026, 8, 1), new Date(2029, 7, 31))).toEqual('2 years and 11 months')
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
  beforeEach(() => {
    document.body.innerHTML = templateHTML(['1', '9', '2026'], ['1', '9', '2028'])
    CourseLengthWarning.init()
  })

  it('shows the warning once the course is longer than usual', () => {
    setEndYear('2029')

    expect(section().hidden).toBe(false)
    expect(section().textContent).toContain('This course is 3 years. Courses for trainees with a level 5 qualification are usually 2 years.')
    expect(shown()).toEqual('1')
  })

  it('hides it again when the course is back to the usual length', () => {
    setEndYear('2029')
    setEndYear('2028')

    expect(section().hidden).toBe(true)
    expect(shown()).toEqual('')
  })

  it('does not show it for an end date past the latest year allowed', () => {
    setEndYear('2035')

    expect(section().hidden).toBe(true)
    expect(shown()).toEqual('')
  })

  it('does not show it for a part-time course', () => {
    const partTime = document.querySelector('[value="part_time"]')
    partTime.checked = true
    partTime.dispatchEvent(new Event('change', { bubbles: true }))
    setEndYear('2030')

    expect(section().hidden).toBe(true)
  })
})
