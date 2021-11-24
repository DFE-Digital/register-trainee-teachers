# frozen_string_literal: true

module Dttp
  class SyncPlacementAssignmentsJob < ApplicationJob
    queue_as :dttp

    def perform(request_uri = nil)
      return unless FeatureService.enabled?(:sync_trainees_from_dttp)

      @placement_assignment_list = RetrievePlacementAssignments.call(request_uri: request_uri)

      PlacementAssignment.upsert_all(placement_assignment_attributes, unique_by: :dttp_id)

      Dttp::SyncPlacementAssignmentsJob.perform_later(next_page_url) if has_next_page?
    end

  private

  attr_reader :placement_assignment_list

    def placement_assignment_attributes
      Parsers::PlacementAssignment.to_attributes(placement_assignments: placement_assignment_list[:items])
    end

    def next_page_url
      placement_assignment_list[:meta][:next_page_url]
    end

    def has_next_page?
      next_page_url.present?
    end
  end
end
