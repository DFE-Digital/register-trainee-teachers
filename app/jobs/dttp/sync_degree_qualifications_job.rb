# frozen_string_literal: true

module Dttp
  class SyncDegreeQualificationsJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      return unless FeatureService.enabled?(:sync_trainees_from_dttp)

      @degree_list = RetrieveDegreeQualifications.call(request_uri: request_uri)

      DegreeQualification.upsert_all(degree_attributes, unique_by: :dttp_id)

      Dttp::SyncDegreeQualificationsJob.perform_later(next_page_url) if next_page?
    end

  private

    attr_reader :degree_list

    def degree_attributes
      Parsers::DegreeQualification.to_attributes(degree_qualifications: degree_list[:items])
    end

    def next_page_url
      degree_list[:meta][:next_page_url]
    end

    def next_page?
      next_page_url.present?
    end
  end
end
