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
      contact_payload = Params::Contact.new(trainee, trainee_creator_dttp_id).to_json
      contact_change_set_id = batch_request.add_change_set(entity: "contacts", payload: contact_payload)

      placement_assignment_payload = Params::PlacementAssignment.new(trainee, contact_change_set_id).to_json
      placement_assignment_change_set_id = batch_request.add_change_set(entity: "dfe_placementassignments",
                                                                        payload: placement_assignment_payload)

      trainee.degrees.each do |degree|
        degree_qualification_payload = Params::DegreeQualification.new(degree,
                                                                       contact_change_set_id,
                                                                       placement_assignment_change_set_id).to_json
        batch_request.add_change_set(entity: "dfe_degreequalifications", payload: degree_qualification_payload)
      end

      batch_response = batch_request.submit

      entity_ids = OdataParser.entity_ids(batch_response: batch_response)

      trainee.trn_requested!(entity_ids["contacts"].first, entity_ids["dfe_placementassignments"].first)

      entity_ids
    end
  end
end
