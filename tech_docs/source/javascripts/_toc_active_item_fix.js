/* eslint-disable */

(function () {
  'use strict'

  function getActiveTocLink () {
    var explicitCurrent = document.querySelector('.app-pane__toc a[aria-current="page"]')
    if (explicitCurrent) return explicitCurrent

    var links = document.querySelectorAll('.app-pane__toc .js-toc-list a[href]')
    var currentPath = window.location.pathname
    for (var i = 0; i < links.length; i++) {
      var href = links[i].getAttribute('href')
      if (!href) continue

      var url = new URL(href, window.location.href)
      if (url.pathname === currentPath) {
        return links[i]
      }
    }

    return null
  }

  function scrollActiveLinkIntoView () {
    var activeLink = getActiveTocLink()
    if (!activeLink || typeof activeLink.scrollIntoView !== 'function') return false

    activeLink.scrollIntoView({ block: 'nearest', inline: 'nearest' })
    return true
  }

  function runWithRetries () {
    var attempts = 0
    var maxAttempts = 6

    function attempt () {
      attempts += 1
      var didScroll = scrollActiveLinkIntoView()

      if (!didScroll || attempts < maxAttempts) {
        window.setTimeout(attempt, 120)
      }
    }

    window.requestAnimationFrame(attempt)
  }

  document.addEventListener('DOMContentLoaded', runWithRetries)
  window.addEventListener('pageshow', runWithRetries)
})()
