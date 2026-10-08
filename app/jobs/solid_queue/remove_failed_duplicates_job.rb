# frozen_string_literal: true

module SolidQueue
  class RemoveFailedDuplicatesJob < ApplicationJob
    queue_as :default

    def perform
      return unless ::Rails.env.production?

      RemoveFailedDuplicates.call
    end
  end
end
