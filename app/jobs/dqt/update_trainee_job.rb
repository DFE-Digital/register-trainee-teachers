# frozen_string_literal: true

module Dqt
  class UpdateTraineeJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :dqt

    def perform(trainee)
      TraineeUpdate.call(trainee: trainee)
    end
  end
end
