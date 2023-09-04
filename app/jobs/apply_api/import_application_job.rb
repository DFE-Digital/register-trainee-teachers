# frozen_string_literal: true

module ApplyApi
  class ImportApplicationJob < ApplicationJob
    queue_as :apply

    def perform(application_data)
      ImportApplication.call(application_data:)
    rescue ApplyApi::ImportApplication::ApplyApiMissingDataError => e
      Sentry.capture_exception(e)
    end
  end
end
