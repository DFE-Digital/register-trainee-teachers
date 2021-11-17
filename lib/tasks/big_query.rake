# frozen_string_literal: true

require "csv"

ON_REDIS_ERROR_WAIT_TIME_IN_SECONDS = 10
ON_REDIS_ERROR_RETRY_ATTEMPTS = 5

namespace :big_query do
  desc <<~DESC
    Send import events for configured entities
  DESC

  task send_import_events: :environment do
    conf = Rails.configuration.analytics

    class_names = conf.keys.map { |k| k.to_s.singularize.camelize }
    classes = class_names.map { |class_name| class_name.gsub("Dttp", "Dttp::").constantize }

    classes.each do |c|
      puts "Queueing: #{c.count} #{c} entities"

      c.find_each(batch_size: 200) do |entity|
        attempt_count = 0
        begin
          entity.send_import_event
        rescue Redis::CommandError
          attempt_count += 1
          abort if attempt_count > ON_REDIS_ERROR_RETRY_ATTEMPTS

          Rails.logger.info("sleeping for #{ON_REDIS_ERROR_WAIT_TIME_IN_SECONDS} - redis error")

          sleep(ON_REDIS_ERROR_WAIT_TIME_IN_SECONDS)
          retry
        end
      end
    end
  end
end
