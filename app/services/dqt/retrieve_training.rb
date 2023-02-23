# frozen_string_literal: true

module Dqt
  class NoTrainingInstanceError < StandardError; end

  class RetrieveTraining
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      raise(NoTrainingInstanceError) if trainings.blank? || training.nil?

      training
    end

    attr_reader :trainee

  private

    def training
      @training ||= trainings.find do |training|
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
