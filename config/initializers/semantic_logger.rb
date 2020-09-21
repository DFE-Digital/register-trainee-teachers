class CustomLogFormatter < SemanticLogger::Formatters::Raw
  def call(log, logger)
    super(log, logger)
    format_add_type
    format_job_data
    format_duration
    format_exception
    format_json_message_context
    format_backtrace
    hash.to_json
  end

private

  def format_add_type
    hash[:type] = "rails"
  end

  def format_job_data
    hash[:job_id] = RequestStore.store[:job_id] if RequestStore.store[:job_id].present?
    hash[:job_queue] = RequestStore.store[:job_queue] if RequestStore.store[:job_queue].present?
  end

  def format_duration
    hash[:duration] = hash[:duration_ms]
    hash[:duration_ms] = nil
  end

  def format_exception
    exception_message = hash.dig(:exception, :message)
    if exception_message.present?
      hash[:message] = "Exception occured: #{exception_message}"
    end
  end

  def format_json_message_context
    if hash[:message].present?
      context = JSON.parse(hash[:message])["context"]
      hash[:sidekiq_job_context] = hash[:message]
      hash[:message] = context
    end
  rescue JSON::ParserError
    nil
  end

  def format_backtrace
    if hash[:message]&.start_with?("/")
      message_lines = hash[:message].split("\n")
      if message_lines.all? { |line| line.start_with?("/") }
        hash[:backtrace] = hash[:message]
        hash[:message] = "Exception occured: #{message_lines.first}"
      end
    end
  end
end

unless Rails.env.development?
  SemanticLogger.add_appender(io: STDOUT, level: :info, formatter: CustomLogFormatter.new)
end
