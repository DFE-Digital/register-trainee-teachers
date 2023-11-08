import 'babel-polyfill'
import jQuery from 'jquery'

import './scripts/global/nationality_select'
import './scripts/global/disable-browser-autofill'

import LiveFilter from './scripts/live_filter'
import FilterToggle from './scripts/filter_toggle'
import CookieBanner from './scripts/cookie_banner'

import { initAll } from 'govuk-frontend'

window.jQuery = jQuery
window.$ = jQuery

initAll()
LiveFilter.init()
FilterToggle.init()
CookieBanner.init()
