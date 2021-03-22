# frozen_string_literal: true

module CookiesHelper
  def cookie_message_seen?
    cookies[:viewed_cookie_message].present?
  end
end
