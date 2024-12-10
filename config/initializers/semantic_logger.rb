# frozen_string_literal: true

Rails.application.configure do
  config.semantic_logger.application = ""
  config.log_tags = [:request_id]
end

SemanticLogger.add_appender(io: $stdout, level: Rails.application.config.log_level, formatter: Rails.application.config.log_format)
Rails.application.config.logger.info('Application logging to $stdout')
