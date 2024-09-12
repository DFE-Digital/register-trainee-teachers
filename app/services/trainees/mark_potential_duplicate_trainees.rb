# frozen_string_literal: true

module Trainees
  class MarkPotentialDuplicateTrainees
    include ServicePattern

    def initialize(trainees:)
      @trainees = trainees
    end

    def call
      group_id = SecureRandom.uuid
      @trainees.each do |trainee|
        PotentialDuplicateTrainee.create!(trainee:, group_id:)
      end
    end
  end
end
