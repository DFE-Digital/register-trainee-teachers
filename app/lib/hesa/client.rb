# frozen_string_literal: true

module Hesa
  class Client
    AUTH_URL = "https://identity.hesa.ac.uk/Account/RemoteLogOn?ReturnDomain=https://datacollection.hesa.ac.uk&ReturnUrl=%2f"

    class LoginError < StandardError; end

    class UnauthorizedError < StandardError; end

    def login
      page = agent.get(AUTH_URL)
      form = page.form_with(id: "loginForm")
      form.EmailAddress = Settings.hesa.username
      form.Password = Settings.hesa.password
      page = form.submit

      unless logged_in?(page)
        raise(LoginError, "Unable to login to HESA with form")
      end

      page
    end

    def logged_in?(page)
      !!(page.css("a").text.match("Log off") && page.css("a").text.match(Settings.hesa.username))
    end

    def agent
      @agent ||= Mechanize.new
    end

    def get(url:)
      login
      page = agent.get(url)
      page.body
    rescue Mechanize::UnauthorizedError => e
      raise(UnauthorizedError, e.message)
    end

    def self.get(...)
      new.get(...)
    end
  end
end
