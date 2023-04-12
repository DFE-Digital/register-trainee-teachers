import 'babel-polyfill'
import '../scripts/govuk_assets_import'
import '../styles/application.scss'
import '../scripts/components'
import '../scripts/global/nationality_select'
import '../scripts/global/disable-browser-autofill'
import LiveFilter from '../scripts/live_filter'
import FilterToggle from '../scripts/filter_toggle'
import CookieBanner from '../scripts/cookie_banner'

import { initAll } from 'govuk-frontend'

global.$ = require('jquery')

initAll()
LiveFilter.init()
FilterToggle.init()
CookieBanner.init()
