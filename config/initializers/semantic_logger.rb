# frozen_string_literal: true

Rails.application.configure do
  $stdout.sync = true
  config.rails_semantic_logger.add_file_appender = false # Don't log to file
  config.semantic_logger.environment = Rails.env
  config.semantic_logger.application = "Register Teacher Training"
  config.log_tags = [:request_id]
  config.semantic_logger.add_appender(io: $stdout, formatter: :json, colorize: false)
end
