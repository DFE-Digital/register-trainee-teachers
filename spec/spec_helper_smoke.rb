# frozen_string_literal: true

require "dotenv/load"

ENV["RAILS_ENV"] ||= "test"

require "rspec/core"
require "config"
require "httparty"
require "capybara/rspec"
require "selenium-webdriver"

Config.load_and_set_settings(Config.setting_files("config", ENV.fetch("RAILS_ENV", nil)))

Capybara.register_driver :selenium_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--disable-gpu")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = :selenium_headless
Capybara.javascript_driver = :selenium_headless
Capybara.default_max_wait_time = 5

RSpec.configure do |config|
  config.include Capybara::DSL
end
