# frozen_string_literal: true

module Dttp
  class RegisterForTrn
    include ServicePattern

    attr_reader :trainee, :trainee_creator_dttp_id, :batch_request

    def initialize(trainee:, trainee_creator_dttp_id: nil)
      @trainee = trainee
      @trainee_creator_dttp_id = trainee_creator_dttp_id
      @batch_request = BatchRequest.new
    end

    def call
      contact_change_set_id = build_contact_change_set

      placement_assignment_change_set_id = build_placement_assignment_change_set(contact_change_set_id)
      degree_change_set_ids = build_degree_qualification_change_sets(contact_change_set_id,
                                                                     placement_assignment_change_set_id)

      batch_response = batch_request.submit

      entity_ids = OdataParser.entity_ids(batch_response: batch_response)
      contact_dttp_id = entity_ids["contacts"].first[:entity_id]

      trainee.trn_requested!(contact_dttp_id, entity_ids["dfe_placementassignments"].first[:entity_id])

      degree_change_set_ids.each do |degree, content_id|
        result = entity_ids["dfe_degreequalifications"].find { |item| item[:content_id] == content_id }
        degree.update!(dttp_id: result[:entity_id])
      end

      # Has to be done after the contact entity is created - can't be done in the batch request
      ChangeTraineeStatusJob.perform_later(status: DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
                                           entity_id: contact_dttp_id,
                                           entity_type: :contact)

      entity_ids
    end

  private

    def build_contact_change_set
      contact_payload = Params::Contact.new(trainee, trainee_creator_dttp_id).to_json
      batch_request.add_change_set(entity: "contacts", payload: contact_payload)
    end

    def build_placement_assignment_change_set(contact_change_set_id)
      placement_assignment_payload = Params::PlacementAssignment.new(trainee, contact_change_set_id).to_json
      batch_request.add_change_set(entity: "dfe_placementassignments", payload: placement_assignment_payload)
    end

    def build_degree_qualification_change_sets(contact_change_set_id, placement_assignment_change_set_id)
      degree_change_set_ids = {}

      trainee.degrees.each do |degree|
        degree_qualification_payload = Params::DegreeQualification.new(degree,
                                                                       contact_change_set_id,
                                                                       placement_assignment_change_set_id).to_json

        change_set_id = batch_request.add_change_set(entity: "dfe_degreequalifications",
                                                     payload: degree_qualification_payload)

        degree_change_set_ids[degree] = change_set_id
      end

      degree_change_set_ids
    end
  end
end
