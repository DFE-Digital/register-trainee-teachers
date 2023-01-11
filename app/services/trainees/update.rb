# frozen_string_literal: true

module Trainees
  class Update
    include ServicePattern

    def initialize(trainee:, params: {}, update_dqt: true)
      @trainee = trainee
      @params = params
      @update_dqt = update_dqt
    end

    def call
      trainee.update!(params)
      Dqt::UpdateTraineeJob.perform_later(trainee) if update_dqt
      true
    end

  private

    attr_reader :trainee, :params, :update_dqt
  end
end
