# frozen_string_literal: true

module Trainees
  class Update
    include ServicePattern

    def initialize(trainee:, params: {}, update_dtq: true, set_academic_cycles_now: false)
      @trainee = trainee
      @params = params
      @update_dtq = update_dtq
      @set_academic_cycles_now = set_academic_cycles_now
    end

    def call
      trainee.update!(params)
      Dqt::UpdateTraineeJob.perform_later(trainee) if update_dtq
      Trainees::SetAcademicCyclesJob.send(set_academic_cycles_now ? :perform_now : :perform_later, trainee)
      true
    end

  private

    attr_reader :trainee, :params, :update_dtq, :set_academic_cycles_now
  end
end
