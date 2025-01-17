# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Bullet gem configuration for detecting N+1 queries and more
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
    Bullet.unused_eager_loading_enable = false
  end

  # Code reloading and eager loading settings
  config.cache_classes = false
  config.eager_load = false

  # Error reporting and debugging
  config.consider_all_requests_local = true
  config.server_timing = true

  # Caching configuration
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :redis_cache_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}",
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Active Storage configuration
  config.active_storage.service = :local

  # Mailer configuration
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Deprecation and migration settings
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load

  # Database query logs
  config.active_record.verbose_query_logs = true

  # Internationalization
  config.i18n.raise_on_missing_translations = true

  # File watcher
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Security and SSL
  config.force_ssl = Settings.features.use_ssl

  # Hosts authorization
  config.hosts.clear

  # Active Job
  config.active_job.queue_adapter = :sidekiq

  # Public file server
  config.public_file_server.enabled = true

  # Logging configuration
  config.colorize_logging = true
  config.rails_semantic_logger.semantic   = false
  config.rails_semantic_logger.started    = true
  config.rails_semantic_logger.processing = true
  config.rails_semantic_logger.rendered   = true

  # Uncomment to suppress logger output for asset requests
  # config.assets.quiet = true

  # Uncomment to annotate rendered view with file names
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment to allow Action Cable access from any origin
  # config.action_cable.disable_request_forgery_protection = true
end
