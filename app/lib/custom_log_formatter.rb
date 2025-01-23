# frozen_string_literal: true

class CustomLogFormatter < SemanticLogger::Formatters::Json
  def call(log, logger)
    super

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
    return if exception_message.nil?

    hash[:message] = "Exception occurred: #{exception_message}"
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
    return unless hash[:message]&.start_with?("/")

    message_lines = hash[:message].split("\n")
    return unless message_lines.all? { |line| line.start_with?("/") }

    hash[:backtrace] = hash[:message]
    hash[:message] = "Exception occured: #{message_lines.first}"
  end

  def remove_post_params
    return unless method_is_post_or_put_or_patch? && hash.dig(:payload, :params).present?

    hash[:payload][:params].clear
  end

  def method_is_post_or_put_or_patch?
    hash.dig(:payload, :method).in?(%w[PUT POST PATCH])
  end
end
