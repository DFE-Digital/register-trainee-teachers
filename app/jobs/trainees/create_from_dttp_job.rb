# frozen_string_literal: true

module Trainees
  class CreateFromDttpJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("import_trainees_from_dttp")

      Dttp::Trainee.joins(:provider).includes(:placement_assignments).unprocessed.each do |dttp_trainee|
        CreateFromDttp.call(dttp_trainee: dttp_trainee)
      end
    end
  end
end
