# frozen_string_literal: true

class UpdateTraineeToDttpJob < ApplicationJob
  queue_as :dttp

  def perform(trainee)
    Dttp::ContactUpdate.call(trainee: trainee)
  end
end
