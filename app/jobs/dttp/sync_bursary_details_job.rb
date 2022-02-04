# frozen_string_literal: true

module Dttp
  class SyncBursaryDetailsJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      return unless FeatureService.enabled?(:sync_trainees_from_dttp)

      @bursary_details = RetrieveBursaryDetails.call(request_uri: request_uri)

      BursaryDetail.upsert_all(bursary_detail_attributes, unique_by: :dttp_id)

      Dttp::SyncBursaryDetailsJob.perform_later(next_page_url) if next_page?
    end

  private

    attr_reader :bursary_details

    def bursary_detail_attributes
      Parsers::BursaryDetail.to_attributes(bursary_details: bursary_details[:items])
    end

    def next_page_url
      bursary_details[:meta][:next_page_url]
    end

    def next_page?
      next_page_url.present?
    end
  end
end
