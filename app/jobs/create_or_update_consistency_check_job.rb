# frozen_string_literal: true

class CreateOrUpdateConsistencyCheckJob < ApplicationJob
  queue_as :default

  def perform(trainee)
    contact = Dttp::Contacts::Fetch.call(contact_entity_id: trainee.dttp_id)
    placement_assignment = Dttp::PlacementAssignments::Fetch.call(placement_assignment_dttp_id: trainee.placement_assignment_dttp_id)

    consistency_check = ConsistencyCheck.find_or_create_by!(trainee_id: trainee.id)
    consistency_check.contact_last_updated_at = contact.updated_at
    consistency_check.placement_assignment_last_updated_at = placement_assignment.updated_at
    consistency_check.save!
  end
end
