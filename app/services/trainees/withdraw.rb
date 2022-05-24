# frozen_string_literal: true

module Trainees
  class Withdraw
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      trainee.save!
      Dqt::WithdrawTraineeJob.perform_later(trainee)
      true
    end

  private

    attr_reader :trainee
  end
end
