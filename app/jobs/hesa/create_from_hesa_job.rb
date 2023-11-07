# frozen_string_literal: true

module Hesa
  class CreateFromHesaJob < ApplicationJob
    queue_as :hesa

    def perform(hesa_trainee:, record_source:)
      return unless FeatureService.enabled?("hesa_import.sync_collection")

      Trainees::CreateFromHesa.call(hesa_trainee:, record_source:)
    end
  end
end
