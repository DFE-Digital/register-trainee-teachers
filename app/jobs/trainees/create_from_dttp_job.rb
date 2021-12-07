# frozen_string_literal: true

module Trainees
  class CreateFromDttpJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("import_trainees_from_dttp")

      Dttp::Trainee.joins(:provider).unprocessed.each do |dttp_trainee|
        CreateFromDttp.call(dttp_trainee: dttp_trainee)
      rescue Trainees::CreateFromDttp::UnrecognisedStatusError => e
        Sentry.capture_exception(e)
      end
    end
  end
end
