import { Turbo } from '@hotwired/turbo-rails'

import jQuery from 'jquery'

import './scripts/global/nationality_select'
import './scripts/global/disable-browser-autofill'

// Import individual components
import './scripts/components/form_components/autocomplete/script'
import './scripts/components/form_components/autocomplete/helpers'
import './scripts/components/form_components/copy_to_clipboard'
import './scripts/components/form_components/country_autocomplete'
import './scripts/components/form_components/schools_autocomplete'
import './scripts/components/form_components/training_partners_autocomplete'
import './scripts/components/form_components/providers_autocomplete'
import './scripts/components/form_components/users_autocomplete'
import './scripts/components/form_components/tracker'

import LiveFilter from './scripts/live_filter'
import FilterToggle from './scripts/filter_toggle'
import CookieBanner from './scripts/cookie_banner'

import { initAll } from 'govuk-frontend'

Turbo.session.drive = false

window.jQuery = jQuery
window.$ = jQuery

document.addEventListener('turbo:load', function () {
  // Initialize GOV.UK Frontend components
  initAll()

  // Initialize custom components
  LiveFilter.init()
  FilterToggle.init()
  CookieBanner.init()
})
