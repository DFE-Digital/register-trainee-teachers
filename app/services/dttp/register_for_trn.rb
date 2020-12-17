# frozen_string_literal: true

module Dttp
  class RegisterForTrn
    include ServicePattern

    attr_reader :trainee, :trainee_creator_dttp_id, :batch_request

    def initialize(trainee:, trainee_creator_dttp_id:)
      @trainee = Dttp::TraineePresenter.new(trainee: trainee)
      @trainee_creator_dttp_id = trainee_creator_dttp_id
      @batch_request = BatchRequest.new
    end

    def call
      contact_payload = trainee.contact_params(trainee_creator_dttp_id).to_json
      contact_change_set_id = batch_request.add_change_set(entity: "contacts", payload: contact_payload)

      placement_assignment_payload = trainee.placement_assignment_params(contact_change_set_id).to_json
      batch_request.add_change_set(entity: "dfe_placementassignments", payload: placement_assignment_payload)

      batch_response = batch_request.submit

      entity_ids = OdataParser.entity_ids(batch_response: batch_response)
      # TODO: make this a state transition method
      trainee.update!(dttp_id: entity_ids["contacts"],
                      placement_assignment_dttp_id: entity_ids["dfe_placementassignments"],
                      submitted_for_trn_at: Time.zone.now)
      entity_ids
    end
  end
end
