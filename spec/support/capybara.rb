# frozen_string_literal: true

require "capybara/cuprite"

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 800],
    browser_options: { "ignore-certificate-errors" => nil },
    process_timeout: 10,
    inspector: true,
    headless: true,
  )
end

Capybara.server = :puma, { Silent: true }
Capybara.server_host = "0.0.0.0"
Capybara.server_port = "4000"
Capybara.app_host = "http://localhost:4000"
Capybara.asset_host = "https://localhost:5000"

# Enable once Github actions is properly configured
# Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 10
