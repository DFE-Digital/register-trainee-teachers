# frozen_string_literal: true

module Hesa
  class Client
    def self.get(...)
      new.get(...)
    end

    def self.upload_trn_file(...)
      new.upload_trn_file(...)
    end

    def get(url:)
      login
      page = agent.get(url)
      page.body
    end

    def upload_trn_file(url:, file:)
      login
      agent.post(url, file:)
    end

  private

    def login
      form = agent.get(Settings.hesa.auth_url).form
      form.Username = Settings.hesa.username
      form.Password = Settings.hesa.password
      agent.submit(form, form.button_with(type: "submit"))
    end

    def agent
      @agent ||= Mechanize.new
    end
  end
end
