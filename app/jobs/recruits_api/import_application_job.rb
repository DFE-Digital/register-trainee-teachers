# frozen_string_literal: true

module RecruitsApi
  class ImportApplicationJob < ApplicationJob
    queue_as :apply

    def perform(application_data)
      ImportApplication.call(application_data:)
    rescue RecruitsApi::ImportApplication::RecruitsApiMissingDataError => e
      Sentry.capture_exception(e)
    end
  end
end
