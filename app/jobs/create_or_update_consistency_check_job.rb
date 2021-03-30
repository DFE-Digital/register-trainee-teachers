# frozen_string_literal: true

class CreateOrUpdateConsistencyCheckJob < ApplicationJob
  queue_as :default

  def perform(trainee)
    contact = Dttp::Contacts::Fetch.call(trainee: trainee)
    placement_assignment = Dttp::PlacementAssignments::Fetch.call(dttp_id: trainee.dttp_id)

    consistency_check = ConsistencyCheck.find_or_create_by!(trainee_id: trainee.id)
    consistency_check.contact_last_updated_at = contact.updated_on
    consistency_check.placement_assignment_last_updated_at = placement_assignment.updated_at
    consistency_check.save!
  end
end
