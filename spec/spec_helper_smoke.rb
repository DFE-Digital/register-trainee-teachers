# frozen_string_literal: true

require "dotenv/load"

ENV["RAILS_ENV"] ||= "staging"

require "rspec/core"
require "rspec/retry"
require "config"
require "httparty"
require "capybara/rspec"
require "selenium-webdriver"
require "byebug"

Config.load_and_set_settings(Config.setting_files("config", ENV.fetch("RAILS_ENV", nil)))

Capybara.register_driver :selenium_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--disable-gpu")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = :selenium_headless
Capybara.javascript_driver = :selenium_headless
Capybara.default_max_wait_time = 20

RSpec.configure do |config|
  config.include Capybara::DSL
  config.verbose_retry = true
  config.display_try_failure_messages = true

  config.around :each, :js do |ex|
    ex.run_with_retry retry: 3
  end
end
