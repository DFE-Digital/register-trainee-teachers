# frozen_string_literal: true

module Trainees
  class Update
    include ServicePattern

    def initialize(trainee:, params: {}, withdrawal: false)
      @trainee = trainee
      @params = params
      @withdrawal = withdrawal
    end

    def call
      trainee.update!(params)
      Dqt::UpdateTraineeJob.perform_later(trainee)
      Dqt::WithdrawTraineeJob.perform_later(trainee) if @withdrawal
      Trainees::SetCohortJob.perform_later(trainee)
      true
    end

  private

    attr_reader :trainee, :params
  end
end
