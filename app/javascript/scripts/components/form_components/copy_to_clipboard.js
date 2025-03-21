document.addEventListener('DOMContentLoaded', () => {
  const button = document.getElementById('copy-to-clipboard-button')

  if (button) {
    const token = document.getElementById('token-text').innerHTML

    copyTokenToClipboard = () => {
      navigator.clipboard.writeText(token)
    }

    button.classList.remove('govuk-visually-hidden');
    button.addEventListener('click', copyTokenToClipboard)
  }
})
