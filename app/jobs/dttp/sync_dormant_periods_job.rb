# frozen_string_literal: true

module Dttp
  class SyncDormantPeriodsJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      return unless FeatureService.enabled?(:sync_trainees_from_dttp)

      @dormant_periods = RetrieveDormantPeriods.call(request_uri:)

      DormantPeriod.upsert_all(dormant_period_attributes, unique_by: :dttp_id)

      Dttp::SyncDormantPeriodsJob.perform_later(next_page_url) if next_page?
    end

  private

    attr_reader :dormant_periods

    def dormant_period_attributes
      Parsers::DormantPeriod.to_attributes(dormant_periods: dormant_periods[:items])
    end

    def next_page_url
      dormant_periods[:meta][:next_page_url]
    end

    def next_page?
      next_page_url.present?
    end
  end
end
