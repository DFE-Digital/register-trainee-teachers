# frozen_string_literal: true

class CustomLogFormatter < SemanticLogger::Formatters::Raw
  def call(log, logger)
    super
    format_job_data
    format_exception
    format_stacktrace
    format_json_message_context
    remove_post_params
    filter_authorization_header
    hash.to_json
  end

private

  # Place a more readable version of the exception into the message field.
  def format_exception
    exception_message = hash.dig(:exception, :message)
    hash[:message] = "Exception occurred: #{exception_message}" if exception_message.present?
  end

  def format_stacktrace
    # If the payload usually has a stack trace, that can make
    # the whole object too big in which case Logstash
    # will fail and the log will not be passed
    # We need to trim the stack trace.
    stack_trace = hash.dig(:exception, :stack_trace)

    if stack_trace.present?
      hash[:stacktrace] = stack_trace.first(3)
      hash[:exception].delete(:stack_trace)
    end
  end

  def format_job_data
    hash[:job_id] = RequestStore.store[:job_id] if RequestStore.store[:job_id].present?
    hash[:job_queue] = RequestStore.store[:job_queue] if RequestStore.store[:job_queue].present?
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

  def remove_post_params
    if method_is_post_or_put? && hash.dig(:payload, :params).present?
      hash[:payload][:params].clear
    end
  end

  def filter_authorization_header
    if hash.dig(:payload, :headers)&.key?("Authorization")
      hash[:payload][:headers].delete("Authorization")
    end
  end

  def method_is_post_or_put?
    hash.dig(:payload, :method).in?(%w[PUT POST])
  end
end

unless Rails.env.local?
  SemanticLogger.add_appender(io: $stdout, level: :info, formatter: CustomLogFormatter.new)
end
