const prepareNationalitySelect = () => {
  const secondInputEl = document.querySelector(
    '[id^=personal-details-form-other-nationality2-field][type=text]'
  )
  if (!secondInputEl) return

  const thirdInputEl = document.querySelector(
    '[id^=personal-details-form-other-nationality3-field][type=text]'
  )

  const secondFormLabel = document.querySelector(
    '[for^=personal-details-form-other-nationality2-field]'
  )
  const thirdFormLabel = document.querySelector(
    '[for^=personal-details-form-other-nationality3-field]'
  )

  const secondSelectEl = document.querySelector(
    '[id^=personal-details-form-other-nationality2-field][type=select]'
  )
  const thirdSelectEl = document.querySelector(
    '[for^=personal-details-form-other-nationality3-field][type=select]'
  )

  const firstInputEl = document.querySelector(
    '[id^=personal-details-form-other-nationality1-field][type=text]'
  )

  let addNationalityButton = null

  const addNthNationalityHiddenSpan = (removeLink, nthNationality) => {
    const nthNationalitySpan = document.createElement('span')
    nthNationalitySpan.classList.add('govuk-visually-hidden')
    nthNationalitySpan.innerHTML = `${nthNationality} nationality`
    removeLink.appendChild(nthNationalitySpan)
  }

  const handleRemoveLinkClick = (labelEl, inputEl, selectEl, prevInputEl) => {
    addNationalityButton.style.display = ''
    labelEl.parentElement.style.display = 'none'
    inputEl.value = ''
    selectEl.value = ''
    prevInputEl.focus()
  }

  const addRemoveLink = (labelEl, inputEl, selectEl, prevInputEl) => {
    const removeLink = document.createElement('a')
    const parentEl = labelEl.parentElement
    removeLink.innerHTML = 'Remove'
    removeLink.classList.add('govuk-link', 'app-autocomplete__remove-link')
    removeLink.href = '#'

    parentEl.insertBefore(removeLink, labelEl)

    if (labelEl === secondFormLabel) {
      addNthNationalityHiddenSpan(removeLink, 'second')
    } else {
      addNthNationalityHiddenSpan(removeLink, 'third')
    }

    removeLink.addEventListener('click', function (e) {
      e.preventDefault()
      handleRemoveLinkClick(labelEl, inputEl, selectEl, prevInputEl)
    })
  }

  const handleAddNationalityClick = () => {
    if (
      secondFormLabel.parentElement.style.display === 'none' &&
      thirdFormLabel.parentElement.style.display === 'none'
    ) {
      secondFormLabel.parentElement.style.display = ''
      secondInputEl.focus()
    } else if (secondFormLabel.parentElement.style.display === 'none') {
      secondFormLabel.parentElement.style.display = ''
      addNationalityButton.style.display = 'none'
    } else {
      thirdFormLabel.parentElement.style.display = ''
      addNationalityButton.style.display = 'none'
      thirdInputEl.focus()
    }
  }

  const addAddNationalityButton = (parentSelector) => {
    const parent = document.querySelector(parentSelector)
    addNationalityButton = document.createElement('button')
    addNationalityButton.innerHTML = 'Add another nationality'
    addNationalityButton.id = 'add-nationality-button'
    addNationalityButton.type = 'button'
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

  addRemoveLink(secondFormLabel, secondInputEl, secondSelectEl, firstInputEl)

  addRemoveLink(thirdFormLabel, thirdInputEl, thirdSelectEl, secondInputEl)

  addAddNationalityButton(
    '#personal-details-form-other-1-conditional'
  )

  hideSection(secondInputEl, secondFormLabel)

  hideSection(thirdInputEl, thirdFormLabel)
}

prepareNationalitySelect()
