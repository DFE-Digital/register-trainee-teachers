# frozen_string_literal: true

require "capybara/cuprite"

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 800],
    browser_options: {
      "ignore-certificate-errors": nil,
      "no-sandbox": nil,
      "disable-gpu": nil,
      "disable-popup-blocking": nil,
    },
    process_timeout: 10,
    inspector: true,
    headless: true,
    browser_args: [
      "--disable-popup-blocking",
      "--disable-extensions",
      "--disable-infobars",
      "--disable-dev-shm-usage",
      "--disable-translate",
      "--disable-notifications",
    ],
    context_attributes: {
      prefs: {
        "download.default_directory" => DownloadHelper::PATH.to_s,
        "download.prompt_for_download" => false,
      },
    },
  )
end

Capybara.server = :puma, { Silent: true }
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 10
