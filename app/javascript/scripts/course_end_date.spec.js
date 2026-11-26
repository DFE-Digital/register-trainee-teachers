import CourseEndDate from './course_end_date'

const dateFields = (name, [day, month, year]) => `
  <input id="course_details_form_${name}_3i" name="course_details_form[${name}(3i)]" value="${day}">
  <input id="course_details_form_${name}_2i" name="course_details_form[${name}(2i)]" value="${month}">
  <input id="course_details_form_${name}_1i" name="course_details_form[${name}(1i)]" value="${year}">`

const templateHTML = (start, end) => `
<form>
  <div data-module="app-course-end-date" data-fill-months="33">
    ${dateFields('itt_start_date', start)}
    ${dateFields('itt_end_date', end)}
  </div>
</form>`

const value = (name, part) => document.getElementById(`course_details_form_${name}_${part}`).value
const endDate = () => ['3i', '2i', '1i'].map((part) => value('itt_end_date', part))
const type = (name, part, text) => {
  const input = document.getElementById(`course_details_form_${name}_${part}`)
  input.value = text
  input.dispatchEvent(new Event('input', { bubbles: true }))
}

describe('CourseEndDate', () => {
  it('fills in a blank end date 33 months after the start date', () => {
    document.body.innerHTML = templateHTML(['', '', ''], ['', '', ''])
    CourseEndDate.init()

    type('itt_start_date', '3i', '1')
    type('itt_start_date', '2i', '9')
    type('itt_start_date', '1i', '2026')

    expect(endDate()).toEqual(['1', '6', '2029'])
  })

  it('moves a filled-in end date with the start date', () => {
    document.body.innerHTML = templateHTML(['1', '9', '2026'], ['1', '6', '2029'])
    CourseEndDate.init()

    type('itt_start_date', '1i', '2027')

    expect(endDate()).toEqual(['1', '6', '2030'])
  })

  it('keeps an end date the provider entered', () => {
    document.body.innerHTML = templateHTML(['1', '9', '2026'], ['1', '9', '2030'])
    CourseEndDate.init()

    type('itt_start_date', '1i', '2027')

    expect(endDate()).toEqual(['1', '9', '2030'])
  })

  it('stops moving the end date once the provider changes it', () => {
    document.body.innerHTML = templateHTML(['1', '9', '2026'], ['1', '6', '2029'])
    CourseEndDate.init()

    type('itt_end_date', '1i', '2031')
    type('itt_start_date', '1i', '2027')

    expect(endDate()).toEqual(['1', '6', '2031'])
  })
})
