# frozen_string_literal: true

module Hesa
  class Client
    def self.get(...)
      new.get(...)
    end

    def get(url:)
      login
      page = agent.get(url)
      page.body
    end

  private

    def login
      page = agent.get(Settings.hesa.auth_url)
      form = page.form_with(id: "loginForm")
      form.EmailAddress = Settings.hesa.username
      form.Password = Settings.hesa.password
      form.submit
    end

    def agent
      @agent ||= Mechanize.new
    end
  end
end
