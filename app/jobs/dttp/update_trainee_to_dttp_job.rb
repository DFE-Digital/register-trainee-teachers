# frozen_string_literal: true

module Dttp
  class UpdateTraineeToDttpJob < ApplicationJob
    queue_as :dttp

    def perform(trainee)
      ContactUpdate.call(trainee: trainee)
    end
  end
end
