# frozen_string_literal: true

class DeleteEmptyTraineesJob < ApplicationJob
  queue_as :default

  def perform
    FindEmptyTrainees.call.map(&:destroy)
  end
end
