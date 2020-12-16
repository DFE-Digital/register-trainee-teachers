const prepareNationalitySelect = () => {
  const secondInputEl = document.getElementById(
    'personal-detail-form-other-nationality2-field'
  )
  if (!secondInputEl) return

  const thirdInputEl = document.getElementById(
    'personal-detail-form-other-nationality3-field'
  )

  const secondFormLabel = document.querySelector(
    '[for=personal-detail-form-other-nationality2-field]'
  )
  const thirdFormLabel = document.querySelector(
    '[for=personal-detail-form-other-nationality3-field]'
  )

  const secondSelectEl = document.getElementById(
    'personal-detail-form-other-nationality2-field-select'
  )
  const thirdSelectEl = document.getElementById(
    'personal-detail-form-other-nationality2-field-select'
  )

  let addNationalityButton = null

  const addNthNationalityHiddenSpan = (removeLink, nthNationality) => {
    const nthNationalitySpan = document.createElement('span')
    nthNationalitySpan.classList.add('govuk-visually-hidden')
    nthNationalitySpan.innerHTML = `${nthNationality} nationality`
    removeLink.appendChild(nthNationalitySpan)
  }

  const handleRemoveLinkClick = (labelEl, inputEl, selectEl) => {
    addNationalityButton.style.display = ''
    labelEl.parentElement.style.display = 'none'
    inputEl.value = ''
    selectEl.value = ''
  }

  const addRemoveLink = (labelEl, inputEl, selectEl) => {
    const removeLink = document.createElement('a')
    removeLink.innerHTML = 'Remove'
    removeLink.classList.add('govuk-link', 'personal-detail-form-other-nationality__remove-link')
    removeLink.href = '#'
    labelEl.appendChild(removeLink)

    if (labelEl === secondFormLabel) {
      addNthNationalityHiddenSpan(removeLink, 'Second')
    } else {
      addNthNationalityHiddenSpan(removeLink, 'Third')
    }

    removeLink.addEventListener('click', function () {
      handleRemoveLinkClick(labelEl, inputEl, selectEl)
    })
  }

  const handleAddNationalityClick = () => {
    if (
      secondFormLabel.parentElement.style.display === 'none' &&
      thirdFormLabel.parentElement.style.display === 'none'
    ) {
      secondFormLabel.parentElement.style.display = ''
    } else if (secondFormLabel.parentElement.style.display === 'none') {
      secondFormLabel.parentElement.style.display = ''
      addNationalityButton.style.display = 'none'
    } else {
      thirdFormLabel.parentElement.style.display = ''
      addNationalityButton.style.display = 'none'
    }
  }

  const addAddNationalityButton = (parentSelector) => {
    const parent = document.querySelector(parentSelector)
    addNationalityButton = document.createElement('button')
    addNationalityButton.innerHTML = 'Add another nationality'
    addNationalityButton.id = 'add-nationality-button'
    addNationalityButton.classList.add(
      'govuk-button',
      'govuk-button--secondary'
    )
    parent.appendChild(addNationalityButton)

    if (secondInputEl.value && thirdInputEl.value) {
      addNationalityButton.style.display = 'none'
    }

    addNationalityButton.addEventListener('click', function (e) {
      e.preventDefault()
      handleAddNationalityClick()
    })
  }

  const hideSection = (selectEl, labelEl) => {
    if (selectEl.value === '') {
      labelEl.parentElement.style.display = 'none'
    }
  }

  addRemoveLink(secondFormLabel, secondInputEl, secondSelectEl)

  addRemoveLink(thirdFormLabel, thirdInputEl, thirdSelectEl)

  addAddNationalityButton(
    '#personal-detail-form-other-1-conditional'
  )

  hideSection(secondInputEl, secondFormLabel)

  hideSection(thirdInputEl, thirdFormLabel)
}

prepareNationalitySelect()
