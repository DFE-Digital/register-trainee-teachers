import {
  getCookie,
  setCookie
} from './utils/cookie_helper'

export default class CookieBanner {
  static init () {
    return new CookieBanner()
  }

  constructor () {
    this.$module = document.querySelector(
      '[data-module="govuk-cookie-banner"]'
    )

    if (!this.$module) return

    this.hideButton = this.$module.querySelector(
      '[data-qa="govuk-cookie-banner__hide"]'
    )

    this.cookieKey = this.$module.attributes['data-cookie-banner-key'].value
    this.cookieLength = this.$module.attributes[
      'data-cookie-banner-period'
    ].value

    if (!this.cookieExists()) {
      this._showCookieMessage()
      this._bindEvents()
    } else {
      this._hideCookieMessage()
    }
  }

  viewedCookieBanner () {
    this._hideCookieMessage()
    this.setViewedCookie(true)
  }

  cookieExists () {
    return getCookie(this.cookieKey) !== null
  }

  setViewedCookie (value) {
    if (typeof value === 'boolean') {
      setCookie(this.cookieKey, value, { days: this.cookieLength })
      return true
    } else {
      throw new Error('setViewedCookie: Only accepts boolean parameters')
    }
  }

  _bindEvents () {
    this.hideButton.addEventListener('click', () => this.viewedCookieBanner())
  }

  _showCookieMessage () {
    this.$module.hidden = false
    this.hideButton.classList.remove('govuk-cookie-banner__hide')
  }

  _hideCookieMessage () {
    this.$module.hidden = true
  }
}
