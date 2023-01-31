# frozen_string_literal: true

module Sidekiq
  class RemoveDeadDuplicatesJob < ApplicationJob
    queue_as :default

    def perform
      return unless ::Rails.env.production?

      RemoveDeadDuplicates.call
    end
  end
end
