import '../scripts/govuk_assets_import'
import '../styles/application.scss'
import '../scripts/components'
import '../scripts/global/nationality_select'
import '../scripts/global/disable-browser-autofill'
import CookieBanner from '../scripts/cookie_banner'
import { initAll } from 'govuk-frontend'

initAll()
CookieBanner.init()
