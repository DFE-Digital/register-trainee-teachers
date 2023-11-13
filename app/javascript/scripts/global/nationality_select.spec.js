const templateHTML = `
<form id="personal-details-form-other-1-conditional">
  <div class="govuk-form-group">
    <label for="personal-details-form-other-nationality1-field">Nationality 1</label>
    <input type="text" id="personal-details-form-other-nationality1-field">
  </div>
  <div class="govuk-form-group">
    <label for="personal-details-form-other-nationality2-field">Nationality 2</label>
    <input type="text" id="personal-details-form-other-nationality2-field">
  </div>
  <div class="govuk-form-group">
    <label for="personal-details-form-other-nationality3-field">Nationality 3</label>
    <input type="text" id="personal-details-form-other-nationality3-field">
  </div>
</form>`

describe('Add nationality button', () => {
  beforeAll(() => {
    document.body.innerHTML = templateHTML
    require('./nationality_select')
  })

  it('adds an add nationality button of type button', () => {
    const addNationalityButton = document.body.querySelector('#add-nationality-button')
    expect(addNationalityButton.innerHTML).toEqual('Add another nationality')
    expect(addNationalityButton.type).toEqual('button')
  })
})
