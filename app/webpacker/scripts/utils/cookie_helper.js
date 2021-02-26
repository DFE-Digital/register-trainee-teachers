/** @description Sets a cookie to store whether the user has seen the cookie banner
 * @param {Boolean} value - true/false
 * @returns {Boolean} true, if it successfully set the viewed_cookie_message cookie
 */
const setViewedCookieMessage = (value) => {
  if (typeof value === 'boolean') {
    setCookie('viewed_cookie_message', value, { days: 182 })
    return true
  } else {
    throw new Error('setViewedCookieMessage: Only accepts boolean parameters')
  }
}

/** @summary Checks if the viewed_cookie_message cookie exists
 * @returns {Boolean} true if it finds the viewed_cookie_message & false if it does not find it
*/
const viewedCookieMessageExists = () => {
  return getCookie('viewed_cookie_message') !== null
}

/**
 *  @private
 *  @summary Fetches and returns a cookie by cookie name
 *  @param {string} name - Cookie name which the method should lookup
 *  @returns {string} Cookie string in key=value format
 *  @returns {null} if Cookie is not found
 */
function getCookie (name) {
  const nameEQ = name + '='
  const cookies = document.cookie.split(';')
  for (let i = 0, len = cookies.length; i < len; i++) {
    let cookie = cookies[i]
    while (cookie.charAt(0) === ' ') {
      cookie = cookie.substring(1, cookie.length)
    }
    if (cookie.indexOf(nameEQ) === 0) {
      return decodeURIComponent(cookie.substring(nameEQ.length))
    }
  }
  return null
}

/**
 *  @private
 *  @summary Sets a cookie
 *  @param {string} name - Cookie name
 *  @param {string} value - Value the cookie will be set to
 *  @param {object} options - used to set cookie options like secure/ expiry date etc
 *  @example chocolateChip cookie value is tasty and expires in 2 days time
 *  setCookie('chocolateChip', 'Tasty', {days: 2 })
 *  @example Delete/Expire existing chocolateChip cookie
 *  setCookie('chocolateChip', '', {days: -1 })
 */
function setCookie (name, value, options) {
  if (typeof options === 'undefined') {
    options = {}
  }
  let cookieString = name + '=' + value + '; path=/'
  if (options.days) {
    const date = new Date()
    date.setTime(date.getTime() + (options.days * 24 * 60 * 60 * 1000))
    cookieString = cookieString + '; expires=' + date.toGMTString()
  }
  if (document.location.protocol === 'https:') {
    cookieString = cookieString + '; Secure'
  }
  document.cookie = cookieString
}

export {
  setViewedCookieMessage,
  viewedCookieMessageExists
}
