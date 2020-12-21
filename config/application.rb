# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"
require "view_component/engine"
require "govuk/components"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RegisterTraineeTeachers
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.exceptions_app = routes

    config.view_component.preview_paths = [Rails.root.join("spec/components")]
    config.view_component.preview_route = "/view_components"
    config.view_component.show_previews = !Settings.features.use_dfe_sign_in

    config.middleware.use Rack::Deflater
    config.active_job.queue_adapter = :sidekiq

    config.session_store :cookie_store, key: "_register_trainee_teachers_session", expire_after: 6.hours
  end
end
