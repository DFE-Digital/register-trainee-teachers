# frozen_string_literal: true

module Trainees
  class CreateFromDttpJob < ApplicationJob
    queue_as :default

    def perform(dttp_trainee)
      return unless FeatureService.enabled?("import_trainees_from_dttp")

      CreateFromDttp.call(dttp_trainee: dttp_trainee)
    end
  end
end
