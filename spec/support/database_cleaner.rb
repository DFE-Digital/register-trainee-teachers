# frozen_string_literal: true

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, except: %w[ar_internal_metadata])
  end

  config.before do |example|
    DatabaseCleaner.strategy =
      if example.metadata[:type] == :feature &&
          Capybara.current_driver != :rack_test
        :truncation
      else
        :transaction
      end

    DatabaseCleaner.start
  end

  config.append_after do
    DatabaseCleaner.clean
  end

  config.around do |example|
    example.run

    # Clear session data
    Capybara.reset_sessions!
  end
end
