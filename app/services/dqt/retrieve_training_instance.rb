# frozen_string_literal: true

module Dqt
  class RetrieveTrainingInstance
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return training_instances.first if training_instances.one?

      training_instances.find do |training_instance|
        training_instance["programmeStartDate"].to_date == trainee.itt_start_date
      end
    end

    attr_reader :trainee

  private

    def training_instances
      @training_instances ||= RetrieveTeacher.call(trainee:)["initialTeacherTraining"]
    end
  end
end
