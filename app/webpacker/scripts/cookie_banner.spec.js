import CookieBanner from './cookie_banner'
import {
  setViewedCookieMessage,
  viewedCookieMessageExists
} from './utils/cookie_helper'

jest.mock('./utils/cookie_helper')

const templateHTML = `
<div class="govuk-cookie-banner govuk-cookie-banner--hidden" role="region" aria-label="Cookie banner" data-module="govuk-cookie-banner">
  <div class="govuk-cookie-banner__message govuk-width-container">
    <div class="govuk-grid-row">
      <div class="govuk-grid-column-two-thirds">
          <h2 class="govuk-cookie-banner__heading govuk-heading-m">
            Cookies on Register trainee teachers
          </h2>

        <div class="govuk-cookie-banner__content">
          <p class="govuk-body">We use some essential cookies to make this service work.</p>
        </div>
      </div>
    </div>

    <div class="govuk-button-group">
      <a class="govuk-link" href="/cookies">View cookies</a>

      <button type="button" class="govuk-button" data-qa="govuk-cookie-banner__hide">
        Hide this message
      </button>
    </div>
  </div>
</div>`

describe('CookieBanner', () => {
  beforeEach(() => {
    document.body.innerHTML = templateHTML
  })

  describe('constructor', () => {
    beforeEach(() => {
      document.body.innerHTML = templateHTML
    })

    afterEach(() => {
      jest.clearAllMocks()
    })

    it("doesn't run if theres no cookie banner markup", () => {
      document.body.innerHTML = ''
      const banner = new CookieBanner()
      expect(banner.$module).toBeNull()
    })

    it('binds event to the hide button', () => {
      viewedCookieMessageExists.mockImplementationOnce(() => false)
      jest.spyOn(CookieBanner.prototype, 'bindEvents')
      CookieBanner.init()
      expect(CookieBanner.prototype.bindEvents).toHaveBeenCalledTimes(1)
    })

    it('displays the Cookie Banner if user has not hidden the banner', () => {
      viewedCookieMessageExists.mockImplementationOnce(() => false)

      const banner = new CookieBanner()
      expect(banner.$module.className).not.toContain(
        'govuk-cookie-banner--hidden'
      )
      expect(banner.$module.className).toContain('govuk-cookie-banner')
    })

    it('hides the Cookie Banner if user has hidden the banner', () => {
      viewedCookieMessageExists.mockImplementationOnce(() => true)

      const banner = new CookieBanner()
      expect(banner.$module.className).toContain('govuk-cookie-banner--hidden')
      expect(banner.$module.className).toContain('govuk-cookie-banner')
    })
  })

  describe('viewedCookieBanner', () => {
    it('hides the cookie banner once a user has accepted cookies', () => {
      const banner = new CookieBanner()
      banner.viewedCookieBanner()
      expect(banner.$module.className).toContain('govuk-cookie-banner--hidden')
    })

    it('sets consented-to-cookies to true', () => {
      const banner = new CookieBanner()
      banner.viewedCookieBanner()
      expect(setViewedCookieMessage).toBeCalled()
    })
  })
})
