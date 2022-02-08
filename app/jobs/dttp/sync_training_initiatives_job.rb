# frozen_string_literal: true

module Dttp
  class SyncTrainingInitiativesJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      return unless FeatureService.enabled?(:sync_trainees_from_dttp)

      @training_initiatives = RetrieveTrainingInitiatives.call(request_uri: request_uri)

      TrainingInitiative.upsert_all(training_initiative_attributes, unique_by: :dttp_id)

      Dttp::SyncTrainingInitiativesJob.perform_later(next_page_url) if next_page?
    end

  private

    attr_reader :training_initiatives

    def training_initiative_attributes
      Parsers::TrainingInitiative.to_attributes(training_initiatives: training_initiatives[:items])
    end

    def next_page_url
      training_initiatives[:meta][:next_page_url]
    end

    def next_page?
      next_page_url.present?
    end
  end
end
