# frozen_string_literal: true

module CookiesHelper
  def hide_cookie_banner?
    cookies[Settings.cookies.consent.name] =~ /yes|no/ || controller_name == "cookie_preferences"
  end

  def google_analytics_allowed?
    cookies[Settings.cookies.consent.name] == "yes"
  end
end
