# frozen_string_literal: true

module Trainees
  class Withdraw
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      Dqt::WithdrawTraineeJob.perform_later(trainee)
    end

  private

    attr_reader :trainee
  end
end
