# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "sidekiq/testing"
require "rspec/rails"
require "webmock/rspec"
require "pundit/rspec"
require "audited-rspec"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

WebMock.disable_net_connect!(allow_localhost: true)

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include FactoryBot::Syntax::Methods
  config.infer_base_class_for_anonymous_controllers = false

  # Use t() instead of I18n.t()
  config.include AbstractController::Translation

  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end

  Faker::Config.locale = "en-GB"
end
