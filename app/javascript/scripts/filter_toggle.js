import $ from 'jquery'
import { FilterToggleButton } from '@ministryofjustice/frontend/moj/all.mjs'

export default class FilterToggle {
  static init () {
    const filterContainer = $('.moj-filter-layout__filter')
    const buttonContainer = $('.moj-action-bar__filter')

    if (filterContainer.length && buttonContainer.length) {
      return new FilterToggleButton(
        buttonContainer[0],
        {
          bigModeMediaQuery: '(min-width: 48.063em)',
          startHidden: false,
          toggleButton: {
            container: buttonContainer,
            showText: 'Show filters',
            hideText: 'Hide filters',
            classes: 'govuk-button--secondary'
          },
          closeButton: {
            container: $('.moj-filter__header-action'),
            text: 'Close'
          },
          filter: {
            container: filterContainer
          }
        }
      )
    }
  }
}
