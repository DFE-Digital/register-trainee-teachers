# frozen_string_literal: true

module Dttp
  class SyncTraineesJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      return unless FeatureService.enabled?(:sync_trainees_from_dttp)

      @trainee_list = RetrieveTrainees.call(request_uri: request_uri)

      Trainee.upsert_all(trainee_attributes, unique_by: :dttp_id)

      Dttp::SyncTraineesJob.perform_later(next_page_url) if has_next_page?
    end

  private

  attr_reader :trainee_list

    def trainee_attributes
      Parsers::Contact.to_trainee_attributes(contacts: trainee_list[:items])
    end

    def next_page_url
      trainee_list[:meta][:next_page_url]
    end

    def has_next_page?
      next_page_url.present?
    end
  end
end
