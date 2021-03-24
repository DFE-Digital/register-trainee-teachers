# frozen_string_literal: true

module CookiesHelper
  def cookie_message_seen?
    cookies[Settings.cookies.cookie_banner_key].present?
  end
end
