# frozen_string_literal: true

module Dttp
  class CreateJob < ApplicationJob
    queue_as :default
    retry_on Dttp::BatchRequest::Error

    def perform(trainee_id)
      Dttp::BatchCreate.call(trainee: Trainee.find(trainee_id))
    end
  end
end
