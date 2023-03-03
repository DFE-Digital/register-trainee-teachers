# frozen_string_literal: true

module Dqt
  class NoTrainingInstanceError < StandardError; end
  class DuplicateTrainingInstanceError < StandardError; end

  class RetrieveTraining
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      raise(NoTrainingInstanceError) if trainings.blank? || trainings_with_matching_criteria.empty?
      raise(DuplicateTrainingInstanceError) if trainings_with_matching_criteria.size > 1

      trainings_with_matching_criteria.first
    end

    attr_reader :trainee

  private

    def trainings_with_matching_criteria
      @trainings_with_matching_criteria ||= trainings.select do |training|
        training.dig("provider", "ukprn") == trainee.provider.ukprn &&
          training["programmeType"] == programme_type(trainee)
      end
    end

    def programme_type(trainee)
      Dqt::Params::TrnRequest::PROGRAMME_TYPE[trainee.training_route]
    end

    def trainings
      @trainings ||= RetrieveTeacher.call(trainee:)["initialTeacherTraining"]
    end
  end
end
