# frozen_string_literal: true

require "capybara/cuprite"

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 800],
    browser_options: { "ignore-certificate-errors" => nil, "no-sandbox" => nil },
    process_timeout: 10,
    inspector: true,
    headless: true,
  )
end

Capybara.server = :puma, { Silent: true }
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 10
