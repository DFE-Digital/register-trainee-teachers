# frozen_string_literal: true

module Dttp
  class SyncSchoolsJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      return unless FeatureService.enabled?(:sync_from_dttp)

      @school_list = RetrieveSchools.call(request_uri: request_uri)

      School.upsert_all(school_attributes, unique_by: :dttp_id)

      Dttp::SyncSchoolsJob.perform_later(next_page_url) if has_next_page?
    end

  private

    attr_reader :school_list

    def school_attributes
      Parsers::Account.to_school_attributes(schools: school_list[:items])
    end

    def next_page_url
      school_list[:meta][:next_page_url]
    end

    def has_next_page?
      next_page_url.present?
    end
  end
end
