# frozen_string_literal: true

class CustomLogFormatter < SemanticLogger::Formatters::Raw
  def call(log, logger)
    super(log, logger)
    format_job_data
    format_exception
    format_json_message_context
    format_backtrace
    remove_post_params
    hash.to_json
  end

private

  def format_job_data
    hash[:job_id] = RequestStore.store[:job_id] if RequestStore.store[:job_id].present?
    hash[:job_queue] = RequestStore.store[:job_queue] if RequestStore.store[:job_queue].present?
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

  def remove_post_params
    if method_is_post_or_put? && hash.dig(:payload, :params).present?
      hash[:payload][:params].clear
    end
  end

  def method_is_post_or_put?
    hash.dig(:payload, :method).in?(%w[PUT POST])
  end
end

unless Rails.env.development? || Rails.env.test?
  SemanticLogger.add_appender(io: $stdout, level: :info, formatter: CustomLogFormatter.new)
end
