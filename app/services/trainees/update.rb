# frozen_string_literal: true

module Trainees
  class Update
    include ServicePattern

    def initialize(trainee:, params: {}, update_dtq: true)
      @trainee = trainee
      @params = params
      @update_dtq = update_dtq
    end

    def call
      trainee.update!(params)
      Dqt::UpdateTraineeJob.perform_later(trainee) if update_dtq
      Trainees::SetAcademicCyclesJob.perform_later(trainee)
      true
    end

  private

    attr_reader :trainee, :params, :update_dtq
  end
end
