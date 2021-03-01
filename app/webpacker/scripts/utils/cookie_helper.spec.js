import {
  setViewedCookieMessage,
  viewedCookieMessageExists
} from './cookie_helper'

const setCookie = (cookieName, value) => {
  document.cookie = `${cookieName}=${value};`
}

const clearCookie = (cookieName) => {
  document.cookie = `${cookieName}=; expires=Thu, 01 Jan 1970 00:00:00 GMT`
}

describe('cookie helper methods', () => {
  afterEach(() => {
    clearCookie('viewed_cookie_message')
  })

  describe('setViewedCookieMessage', () => {
    it('uses a boolean value to set a cookie', () => {
      const response = setViewedCookieMessage(true)
      expect(document.cookie).toEqual('viewed_cookie_message=true')
      expect(response).toEqual(true)
    })

    it('uses a boolean value to set a cookie - user has not seen cookie message', () => {
      const response = setViewedCookieMessage(false)
      expect(document.cookie).toEqual('viewed_cookie_message=false')
      expect(response).toEqual(true)
    })

    it('raises an error if the arg is not a boolean', () => {
      expect(setViewedCookieMessage).toThrowError(
        new Error('setViewedCookieMessage: Only accepts boolean parameters')
      )
    })
  })

  describe('viewedCookieMessageExists', () => {
    it('returns true if cookie exists - User rejected', () => {
      setCookie('viewed_cookie_message', false)
      const response = viewedCookieMessageExists()
      expect(response).toEqual(true)
    })

    it('returns true if cookie exists - User consented', () => {
      setCookie('viewed_cookie_message', true)
      const response = viewedCookieMessageExists()
      expect(response).toEqual(true)
    })

    it('returns false if cookie does not exist', () => {
      setCookie('some-other-cookie', 'not-consented')
      const response = viewedCookieMessageExists()
      expect(response).toEqual(false)
      clearCookie('some-other-cookie')
    })
  })
})
