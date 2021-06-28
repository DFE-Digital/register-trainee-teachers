# frozen_string_literal: true

module Dttp
  class CreateOrUpdateConsistencyCheckJob < ApplicationJob
    queue_as :default

    def perform(trainee)
      return if trainee.draft?

      contact = Contacts::Fetch.call(dttp_id: trainee.dttp_id)
      placement_assignment = PlacementAssignments::Fetch.call(dttp_id: trainee.placement_assignment_dttp_id)

      consistency_check = ConsistencyCheck.find_or_create_by!(trainee_id: trainee.id)
      consistency_check.contact_last_updated_at = contact.updated_at
      consistency_check.placement_assignment_last_updated_at = placement_assignment.updated_at
      consistency_check.save!
    end
  end
end
