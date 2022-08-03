# frozen_string_literal: true

module Trainees
  class Withdraw
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      Dqt::WithdrawTraineeJob.perform_later(trainee) unless hesa_trainee?
      true
    end

  private

    attr_reader :trainee

    def hesa_trainee?
      trainee.hesa_record?
    end
  end
end
