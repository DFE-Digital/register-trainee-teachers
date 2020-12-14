# frozen_string_literal: true

class RecommendForQtsJob < ApplicationJob
  queue_as :default
  retry_on Dttp::RecommendForQTS::Error

  def perform(trainee_id)
    Dttp::RecommendForQTS.call(trainee: Trainee.find(trainee_id))
  end
end
