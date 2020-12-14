# frozen_string_literal: true

class RegisterForTrnJob < ApplicationJob
  queue_as :default
  retry_on Dttp::BatchRequest::Error

  def perform(trainee_id, trainee_creator_dttp_id)
    Dttp::RegisterForTrn.call(trainee: Trainee.find(trainee_id), trainee_creator_dttp_id: trainee_creator_dttp_id)
  end
end
