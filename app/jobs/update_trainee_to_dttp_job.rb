# frozen_string_literal: true

class UpdateTraineeToDttpJob < ApplicationJob
  queue_as :dttp

  discard_on Dttp::ContactUpdate::Error

  def perform(trainee)
    Dttp::ContactUpdate.call(trainee: trainee)
  end
end
