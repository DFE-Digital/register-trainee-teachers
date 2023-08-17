# frozen_string_literal: true

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner[:active_record, db: "register_trainee_teacher_data_test#{ENV.fetch('TEST_ENV_NUMBER', nil)}".to_sym].clean_with(:truncation, except: %w[ar_internal_metadata])
  end

  config.before do |example|
    DatabaseCleaner[:active_record, db: "register_trainee_teacher_data_test#{ENV.fetch('TEST_ENV_NUMBER', nil)}".to_sym].strategy =
      if example.metadata[:type] == :feature &&
          Capybara.current_driver != :rack_test
        :truncation
      else
        :transaction
      end

    DatabaseCleaner[:active_record, db: "register_trainee_teacher_data_test#{ENV.fetch('TEST_ENV_NUMBER', nil)}".to_sym].start
  end

  config.append_after do
    DatabaseCleaner[:active_record, db: "register_trainee_teacher_data_test#{ENV.fetch('TEST_ENV_NUMBER', nil)}".to_sym].clean
  end

  config.around do |example|
    example.run

    # Clear session data
    Capybara.reset_sessions!
  end
end
