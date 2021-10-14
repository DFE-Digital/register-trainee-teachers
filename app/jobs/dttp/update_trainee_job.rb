# frozen_string_literal: true

module Dttp
  class UpdateTraineeJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :dttp

    def perform(trainee)
      ContactUpdate.call(trainee: trainee)
    end
  end
end
