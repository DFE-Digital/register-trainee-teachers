import CookieBanner from './cookie_banner'

// Test Helpers
const setCookie = (cookieName, value) => {
  document.cookie = `${cookieName}=${value};`
}

const clearCookie = (cookieName) => {
  document.cookie = `${cookieName}=; expires=Thu, 01 Jan 1970 00:00:00 GMT`
}

const templateHTML = `
<div class="govuk-cookie-banner" role="region" aria-label="Cookie banner" data-module="govuk-cookie-banner" data-cookie-banner-key="viewed_cookie_message" data-cookie-banner-period="182">
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
    let banner

    afterEach(() => {
      jest.clearAllMocks()
    })

    it("doesn't run if theres no cookie banner markup", () => {
      document.body.innerHTML = ''
      banner = new CookieBanner()
      expect(banner.$module).toBeNull()
    })

    it('binds event to the hide button', () => {
      jest.spyOn(CookieBanner.prototype, '_bindEvents')
      jest
        .spyOn(CookieBanner.prototype, 'cookieExists')
        .mockImplementation(() => false)
      CookieBanner.init()
      expect(CookieBanner.prototype._bindEvents).toHaveBeenCalledTimes(1)
    })

    it('displays the Cookie Banner if user has not hidden the banner', () => {
      jest
        .spyOn(CookieBanner.prototype, 'cookieExists')
        .mockImplementation(() => false)

      banner = new CookieBanner()
      expect(banner.$module.hidden).toBeFalsy()
    })

    it('hides the Cookie Banner if user has hidden the banner', () => {
      jest
        .spyOn(CookieBanner.prototype, 'cookieExists')
        .mockImplementation(() => true)

      banner = new CookieBanner()
      expect(banner.$module.hidden).toBeTruthy()
    })
  })

  describe('viewedCookieBanner', () => {
    let banner

    beforeEach(() => {
      banner = new CookieBanner()
    })

    it('hides the cookie banner once a user has accepted cookies', () => {
      banner.viewedCookieBanner()
      expect(banner.$module.hidden).toBeTruthy()
    })

    it('sets viewed_cookie_message to true', () => {
      jest.spyOn(banner, 'setViewedCookie')
      banner.viewedCookieBanner()
      expect(banner.setViewedCookie).toHaveBeenCalledWith(true)
    })
  })

  describe('cookie helper methods', () => {
    let banner

    beforeEach(() => {
      banner = new CookieBanner()
    })

    afterEach(() => {
      clearCookie(banner.cookieKey)
    })

    describe('setViewedCookie', () => {
      it('uses a boolean value to set a cookie', () => {
        const response = banner.setViewedCookie(true)
        expect(document.cookie).toEqual(`${banner.cookieKey}=true`)
        expect(response).toEqual(true)
      })

      it('uses a boolean value to set a cookie - user has not seen cookie message', () => {
        const response = banner.setViewedCookie(false)
        expect(document.cookie).toEqual(`${banner.cookieKey}=false`)
        expect(response).toEqual(true)
      })

      it('raises an error if the arg is not a boolean', () => {
        expect(banner.setViewedCookie).toThrowError(
          new Error('setViewedCookie: Only accepts boolean parameters')
        )
      })
    })

    describe('cookieExists', () => {
      beforeEach(() => {
        jest.restoreAllMocks()
      })

      it('returns true if cookie exists', () => {
        setCookie('viewed_cookie_message', true)
        expect(banner.cookieExists()).toEqual(true)
      })

      it('returns false if cookie does not exist', () => {
        setCookie('some-other-cookie', 'not-consented')
        expect(banner.cookieExists()).toEqual(false)
        clearCookie('some-other-cookie')
      })
    })
  })
})
