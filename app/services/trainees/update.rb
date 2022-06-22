# frozen_string_literal: true

module Trainees
  class Update
    include ServicePattern

    def initialize(trainee:, params: {})
      @trainee = trainee
      @params = params
    end

    def call
      trainee.update!(params)
      Dqt::UpdateTraineeJob.perform_later(trainee)
      Trainees::SetAcademicCyclesJob.perform_later(trainee)
      true
    end

  private

    attr_reader :trainee, :params
  end
end
