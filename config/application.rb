# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require "govuk/components"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RegisterTraineeTeachers
  class Application < Rails::Application
    config.load_defaults(7.1)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.exceptions_app = routes

    config.view_component.preview_paths = [Rails.root.join("spec/components")]
    config.view_component.preview_route = "/view_components"
    config.view_component.show_previews = !Rails.env.production?

    config.middleware.use(Rack::Deflater)
    config.active_job.queue_adapter = :good_job

    # Configure session store to use ActiveRecord.
    # - key: Sets the name of the session cookie.
    # - httponly: Prevents client-side scripts from accessing the cookie.
    # - secure: Ensures the cookie is only sent over HTTPS in non-development and non-test environments.
    config.session_store(:active_record_store,
                         key: "_register_trainee_teachers_session",
                         httponly: true,
                         secure: !Rails.env.development? && !Rails.env.test?)

    config.i18n.load_path += Rails.root.glob("config/locales/**/*.yml")

    config.autoload_paths << Rails.root.join("config/routes")
    config.autoload_once_paths << Rails.root.join("config/initializers/subjects")

    config.analytics = config_for(:analytics)

    config.active_record.encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION__PRIMARY_KEY", nil)
    config.active_record.encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION__DETERMINISTIC_KEY", nil)
    config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION__KEY_DERIVATION_SALT", nil)

    config.active_record.raise_on_assign_to_attr_readonly = false
  end
end
